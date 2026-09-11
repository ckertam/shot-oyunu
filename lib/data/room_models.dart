// Shared-room data model. Mirrors the Realtime Database shape under
// /rooms/{code} — see database.rules.json for the matching security rules.

enum RoomStatus { lobby, playing, ended }

enum GameMode { kings, never, most, wheel }

enum Difficulty { light, hard }

GameMode? gameModeFromKey(Object? key) {
  switch (key) {
    case 'kings':
      return GameMode.kings;
    case 'never':
      return GameMode.never;
    case 'most':
      return GameMode.most;
    case 'wheel':
      return GameMode.wheel;
    default:
      return null;
  }
}

String gameModeKey(GameMode mode) => mode.name;

class Player {
  final String uid;
  final String name;
  final int joinedAt;
  final bool connected;
  final int shots;
  final bool isHost;

  const Player({
    required this.uid,
    required this.name,
    required this.joinedAt,
    required this.connected,
    required this.shots,
    required this.isHost,
  });

  factory Player.fromMap(String uid, Map<dynamic, dynamic> map) {
    return Player(
      uid: uid,
      name: (map['name'] as String?) ?? '?',
      joinedAt: (map['joinedAt'] as num?)?.toInt() ?? 0,
      connected: map['connected'] == true,
      shots: (map['shots'] as num?)?.toInt() ?? 0,
      isHost: map['isHost'] == true,
    );
  }
}

class KingsState {
  final List<int> order;
  final int drawnCount;

  const KingsState({required this.order, required this.drawnCount});

  factory KingsState.fromMap(Map<dynamic, dynamic> map) {
    return KingsState(
      order: (map['order'] as List?)?.cast<Object?>().map((e) => (e as num).toInt()).toList() ?? const [],
      drawnCount: (map['drawnCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class SequenceState {
  final List<int> order;
  final int index;

  const SequenceState({required this.order, required this.index});

  factory SequenceState.fromMap(Map<dynamic, dynamic> map) {
    return SequenceState(
      order: (map['order'] as List?)?.cast<Object?>().map((e) => (e as num).toInt()).toList() ?? const [],
      index: (map['index'] as num?)?.toInt() ?? 0,
    );
  }
}

class MostState {
  final List<int> order;
  final int index;
  final Map<String, String> votes;

  const MostState({required this.order, required this.index, required this.votes});

  factory MostState.fromMap(Map<dynamic, dynamic> map) {
    final rawVotes = (map['votes'] as Map?) ?? const {};
    return MostState(
      order: (map['order'] as List?)?.cast<Object?>().map((e) => (e as num).toInt()).toList() ?? const [],
      index: (map['index'] as num?)?.toInt() ?? 0,
      votes: rawVotes.map((k, v) => MapEntry(k as String, v as String)),
    );
  }
}

class WheelState {
  final int? spinId;
  final int? resultIndex;

  const WheelState({this.spinId, this.resultIndex});

  factory WheelState.fromMap(Map<dynamic, dynamic> map) {
    return WheelState(
      spinId: (map['spinId'] as num?)?.toInt(),
      resultIndex: (map['resultIndex'] as num?)?.toInt(),
    );
  }
}

class Room {
  final String code;
  final String hostId;
  final RoomStatus status;
  final GameMode? mode;
  final Difficulty difficulty;
  final Map<String, Player> players;
  final int? createdAt;
  final int? startedAt;
  final int? endedAt;
  final KingsState? kings;
  final SequenceState? never;
  final MostState? most;
  final WheelState? wheel;

  const Room({
    required this.code,
    required this.hostId,
    required this.status,
    required this.mode,
    required this.difficulty,
    required this.players,
    required this.createdAt,
    required this.startedAt,
    required this.endedAt,
    required this.kings,
    required this.never,
    required this.most,
    required this.wheel,
  });

  factory Room.fromMap(String code, Map<dynamic, dynamic> map) {
    final rawPlayers = (map['players'] as Map?) ?? const {};
    final game = (map['game'] as Map?) ?? const {};
    return Room(
      code: code,
      hostId: (map['hostId'] as String?) ?? '',
      status: RoomStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => RoomStatus.lobby,
      ),
      mode: gameModeFromKey(map['mode']),
      difficulty: (map['difficulty'] == 'hard') ? Difficulty.hard : Difficulty.light,
      players: rawPlayers.map(
        (k, v) => MapEntry(k as String, Player.fromMap(k, v as Map)),
      ),
      createdAt: (map['createdAt'] as num?)?.toInt(),
      startedAt: (map['startedAt'] as num?)?.toInt(),
      endedAt: (map['endedAt'] as num?)?.toInt(),
      kings: game['kings'] != null ? KingsState.fromMap(game['kings'] as Map) : null,
      never: game['never'] != null ? SequenceState.fromMap(game['never'] as Map) : null,
      most: game['most'] != null ? MostState.fromMap(game['most'] as Map) : null,
      wheel: game['wheel'] != null ? WheelState.fromMap(game['wheel'] as Map) : null,
    );
  }

  List<Player> get sortedByShotsDesc =>
      players.values.toList()..sort((a, b) => b.shots.compareTo(a.shots));
}
