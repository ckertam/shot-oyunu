import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'room_models.dart';
import 'room_repository.dart';

/// The single shared-state hub every screen listens to via `provider`. Wraps
/// [RoomRepository] with the current room stream + the "which room was I in"
/// reconnect persistence (shared_preferences — Firebase Anonymous Auth
/// already persists the uid itself across reloads on web).
class RoomController extends ChangeNotifier {
  RoomController([RoomRepository? repository]) : _repo = repository ?? RoomRepository();

  static const _prefsKey = 'shot_oyunu_room_code';

  final RoomRepository _repo;
  StreamSubscription<Room?>? _sub;

  bool loading = true;
  String? code;
  String? myUid;
  Room? room;

  Player? get myPlayer => (room != null && myUid != null) ? room!.players[myUid] : null;
  bool get isHost => myPlayer?.isHost ?? false;

  /// Called once at app startup: signs in anonymously and, if the browser
  /// remembers a room code and this uid is still a member, reattaches.
  Future<void> restoreSession() async {
    myUid = await _repo.ensureSignedIn();
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_prefsKey);
    if (savedCode != null) {
      final stillIn = await _repo.isPlayerInRoom(savedCode, myUid!);
      if (stillIn) {
        _attach(savedCode);
        _repo.armPresence(savedCode, myUid!);
      } else {
        await prefs.remove(_prefsKey);
      }
    }
    loading = false;
    notifyListeners();
  }

  Future<void> hostNewRoom(String hostName) async {
    final newCode = await _repo.createRoomWithFreshCode(hostName);
    await _persistCode(newCode);
    _attach(newCode);
  }

  /// Returns an error message on failure, or null on success.
  Future<String?> joinExistingRoom(String roomCode, String name) async {
    final exists = await _repo.roomExists(roomCode);
    if (!exists) return 'Bu kodla bir oda bulunamadı.';
    await _repo.joinRoom(code: roomCode, name: name);
    await _persistCode(roomCode);
    _attach(roomCode);
    return null;
  }

  void _attach(String roomCode) {
    code = roomCode;
    _sub?.cancel();
    _sub = _repo.watchRoom(roomCode).listen((r) {
      room = r;
      notifyListeners();
    });
  }

  Future<void> _persistCode(String roomCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, roomCode);
  }

  Future<void> leaveRoom() async {
    await _sub?.cancel();
    _sub = null;
    code = null;
    room = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    notifyListeners();
  }

  Future<void> setMode(GameMode mode) => _repo.setMode(code!, mode);
  Future<void> clearMode() => _repo.clearMode(code!);
  Future<void> setDifficulty(Difficulty d) => _repo.setDifficulty(code!, d);
  Future<void> startGame() => _repo.startGame(code!);
  Future<void> endNight() => _repo.endNight(code!);
  Future<void> playAgain() => _repo.playAgain(code!, room!.players.keys);
  Future<void> incrementShots(String uid) => _repo.incrementShots(code!, uid);
  Future<void> drawNextKing({required int deckSize}) =>
      _repo.drawNextKing(code!, deckSize: deckSize);
  Future<void> advanceNever({required int deckSize}) =>
      _repo.advanceNever(code!, deckSize: deckSize);
  Future<void> advanceMost({required int deckSize}) =>
      _repo.advanceMost(code!, deckSize: deckSize);
  Future<void> castVote(String votedForUid) => _repo.castVote(code!, myUid!, votedForUid);
  Future<void> spinWheel({required int segmentCount}) =>
      _repo.spinWheel(code!, segmentCount: segmentCount);
  Future<void> removePlayer(String uid) => _repo.removePlayer(code!, uid);
  Future<void> renameMe(String name) => _repo.setName(code!, myUid!, name);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
