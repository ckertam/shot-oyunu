import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'room_models.dart';

/// Thin wrapper around Firebase Auth (anonymous) + Realtime Database for the
/// shared `/rooms/{code}` tree. See database.rules.json for the write rules
/// this code relies on (host-only fields, self-only identity, any-member
/// shots/game writes).
class RoomRepository {
  RoomRepository({FirebaseDatabase? database, FirebaseAuth? auth})
    : _db = database ?? FirebaseDatabase.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseDatabase _db;
  final FirebaseAuth _auth;

  Future<String> ensureSignedIn() async {
    final current = _auth.currentUser;
    if (current != null) return current.uid;
    final cred = await _auth.signInAnonymously();
    return cred.user!.uid;
  }

  String? get currentUid => _auth.currentUser?.uid;

  String generateRoomCode() {
    final rnd = Random();
    const letters = 'ABCDEFGHJKLMNPQRSTUVWXYZ'; // no I/O — avoid 1/0 confusion
    const digits = '0123456789';
    final l = List.generate(3, (_) => letters[rnd.nextInt(letters.length)]).join();
    final d = List.generate(3, (_) => digits[rnd.nextInt(digits.length)]).join();
    return '$l-$d';
  }

  Future<bool> roomExists(String code) async {
    await ensureSignedIn();
    final snap = await _db.ref('rooms/$code/hostId').get();
    return snap.exists;
  }

  /// Generates a fresh code (retrying on the rare collision), creates the
  /// room with the caller as host, and arms presence tracking.
  Future<String> createRoomWithFreshCode(String hostName) async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = generateRoomCode();
      if (!await roomExists(code)) {
        await createRoom(code: code, hostName: hostName);
        return code;
      }
    }
    throw StateError('Oda kodu üretilemedi, tekrar dene.');
  }

  Future<void> createRoom({required String code, required String hostName}) async {
    final uid = await ensureSignedIn();
    await _db.ref().update({
      'rooms/$code/hostId': uid,
      'rooms/$code/createdAt': ServerValue.timestamp,
      'rooms/$code/status': RoomStatus.lobby.name,
      'rooms/$code/difficulty': Difficulty.light.name,
      'rooms/$code/players/$uid': {
        'name': hostName,
        'joinedAt': ServerValue.timestamp,
        'connected': true,
        'shots': 0,
        'isHost': true,
      },
    });
    armPresence(code, uid);
  }

  Future<void> joinRoom({required String code, required String name}) async {
    final uid = await ensureSignedIn();
    await _db.ref('rooms/$code/players/$uid').set({
      'name': name,
      'joinedAt': ServerValue.timestamp,
      'connected': true,
      'shots': 0,
      'isHost': false,
    });
    armPresence(code, uid);
  }

  Future<bool> isPlayerInRoom(String code, String uid) async {
    final snap = await _db.ref('rooms/$code/players/$uid').get();
    return snap.exists;
  }

  /// Re-registers the `onDisconnect` cleanup every time the socket
  /// reconnects — Firebase only fires a registered onDisconnect once per
  /// underlying connection, so a mid-game reconnect must re-arm it.
  void armPresence(String code, String uid) {
    final playerConnectedRef = _db.ref('rooms/$code/players/$uid/connected');
    _db.ref('.info/connected').onValue.listen((event) async {
      if (event.snapshot.value == true) {
        await playerConnectedRef.onDisconnect().set(false);
        await playerConnectedRef.set(true);
      }
    });
  }

  Stream<Room?> watchRoom(String code) {
    return _db.ref('rooms/$code').onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) return null;
      return Room.fromMap(code, value as Map);
    });
  }

  Future<void> setName(String code, String uid, String name) {
    return _db.ref('rooms/$code/players/$uid/name').set(name);
  }

  Future<void> removePlayer(String code, String uid) {
    return _db.ref('rooms/$code/players/$uid').remove();
  }

  Future<void> setMode(String code, GameMode mode) {
    return _db.ref('rooms/$code/mode').set(gameModeKey(mode));
  }

  Future<void> clearMode(String code) {
    return _db.ref('rooms/$code/mode').set(null);
  }

  Future<void> setDifficulty(String code, Difficulty difficulty) {
    return _db.ref('rooms/$code/difficulty').set(difficulty.name);
  }

  Future<void> startGame(String code) {
    return _db.ref().update({
      'rooms/$code/status': RoomStatus.playing.name,
      'rooms/$code/startedAt': ServerValue.timestamp,
    });
  }

  Future<void> endNight(String code) {
    return _db.ref().update({
      'rooms/$code/status': RoomStatus.ended.name,
      'rooms/$code/endedAt': ServerValue.timestamp,
    });
  }

  Future<void> playAgain(String code, Iterable<String> playerUids) {
    final updates = <String, Object?>{
      'rooms/$code/status': RoomStatus.playing.name,
      'rooms/$code/startedAt': ServerValue.timestamp,
      'rooms/$code/endedAt': null,
      'rooms/$code/mode': null,
      'rooms/$code/game': null,
    };
    for (final uid in playerUids) {
      updates['rooms/$code/players/$uid/shots'] = 0;
    }
    return _db.ref().update(updates);
  }

  Future<void> incrementShots(String code, String uid) {
    final ref = _db.ref('rooms/$code/players/$uid/shots');
    return ref.runTransaction((data) {
      final current = (data as num?)?.toInt() ?? 0;
      return Transaction.success(current + 1);
    });
  }

  Future<void> drawNextKing(String code, {required int deckSize}) async {
    final ref = _db.ref('rooms/$code/game/kings');
    await ref.runTransaction((data) {
      final map = Map<String, dynamic>.from((data as Map?) ?? {});
      var order = (map['order'] as List?)?.map((e) => (e as num).toInt()).toList() ?? <int>[];
      var drawn = (map['drawnCount'] as num?)?.toInt() ?? 0;
      if (order.isEmpty || drawn >= order.length) {
        order = List.generate(deckSize, (i) => i)..shuffle();
        drawn = 0;
      }
      drawn += 1;
      return Transaction.success({'order': order, 'drawnCount': drawn});
    });
  }

  Future<void> advanceNever(String code, {required int deckSize}) async {
    final ref = _db.ref('rooms/$code/game/never');
    await ref.runTransaction((data) {
      final map = Map<String, dynamic>.from((data as Map?) ?? {});
      var order = (map['order'] as List?)?.map((e) => (e as num).toInt()).toList() ?? <int>[];
      var index = (map['index'] as num?)?.toInt() ?? -1;
      index += 1;
      if (order.isEmpty || index >= order.length) {
        order = List.generate(deckSize, (i) => i)..shuffle();
        index = 0;
      }
      return Transaction.success({'order': order, 'index': index});
    });
  }

  Future<void> advanceMost(String code, {required int deckSize}) async {
    final ref = _db.ref('rooms/$code/game/most');
    await ref.runTransaction((data) {
      final map = Map<String, dynamic>.from((data as Map?) ?? {});
      var order = (map['order'] as List?)?.map((e) => (e as num).toInt()).toList() ?? <int>[];
      var index = (map['index'] as num?)?.toInt() ?? -1;
      index += 1;
      if (order.isEmpty || index >= order.length) {
        order = List.generate(deckSize, (i) => i)..shuffle();
        index = 0;
      }
      return Transaction.success({'order': order, 'index': index, 'votes': null});
    });
  }

  Future<void> castVote(String code, String voterUid, String votedForUid) {
    return _db.ref('rooms/$code/game/most/votes/$voterUid').set(votedForUid);
  }

  Future<void> spinWheel(String code, {required int segmentCount}) {
    final resultIndex = Random().nextInt(segmentCount);
    return _db.ref('rooms/$code/game/wheel').set({
      'spinId': ServerValue.timestamp,
      'resultIndex': resultIndex,
    });
  }
}
