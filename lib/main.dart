import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/local_settings.dart';
import 'data/room_controller.dart';
import 'firebase_options.dart';
import 'screens/root_screen.dart';
import 'theme/nocturne_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Multiplayer is web-only — native builds never touch Firebase.
  if (kIsWeb) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  }
  runApp(const ShotOyunuApp());
}

class ShotOyunuApp extends StatelessWidget {
  const ShotOyunuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoomController()..restoreSession()),
        ChangeNotifierProvider(create: (_) => LocalSettings()..load()),
      ],
      child: MaterialApp(
        title: 'Shot Oyunu',
        debugShowCheckedModeBanner: false,
        theme: buildNocturneTheme(),
        home: const RootScreen(),
      ),
    );
  }
}
