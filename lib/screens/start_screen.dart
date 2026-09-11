import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/room_controller.dart';
import '../theme/nocturne_theme.dart';
import '../theme/nocturne_widgets.dart';

/// Oda kur / odaya katıl — the entry point before a device is attached to
/// any room. Reads `?room=CODE` from the URL (the link the brief's "Oda
/// linkini paylaş" button copies) to prefill the join field.
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final _nameController = TextEditingController();
  late final TextEditingController _codeController;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: _roomCodeFromUrl() ?? '');
  }

  String? _roomCodeFromUrl() {
    try {
      final room = Uri.base.queryParameters['room'];
      return (room == null || room.isEmpty) ? null : room.toUpperCase();
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Önce adını yaz.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<RoomController>().hostNewRoom(name);
    } catch (e) {
      setState(() => _error = 'Oda kurulamadı, tekrar dene.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _joinRoom() async {
    final name = _nameController.text.trim();
    final code = _codeController.text.trim().toUpperCase();
    if (name.isEmpty) {
      setState(() => _error = 'Önce adını yaz.');
      return;
    }
    if (code.isEmpty) {
      setState(() => _error = 'Oda kodunu gir.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await context.read<RoomController>().joinExistingRoom(code, name);
    if (mounted) {
      setState(() {
        _busy = false;
        _error = err;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: NocturneSpace.side,
                vertical: 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🍻', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  const Text(
                    'Shot Oyunu',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.6,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bir oda kur ya da arkadaşının kodunu gir — herkes kendi telefonundan oynar.',
                    style: TextStyle(fontSize: 15, color: NocturneColors.neutral500, height: 1.4),
                  ),
                  const SizedBox(height: 32),
                  const NocturneKicker('Adın'),
                  const SizedBox(height: 8),
                  _NocturneField(controller: _nameController, hint: 'Örn. Deniz'),
                  const SizedBox(height: 20),
                  const NocturneKicker('Oda kodu (katılmak için)'),
                  const SizedBox(height: 8),
                  _NocturneField(
                    controller: _codeController,
                    hint: 'ABC-214',
                    textCapitalization: TextCapitalization.characters,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: NocturneColors.accent400)),
                  ],
                  const SizedBox(height: 28),
                  NocturnePrimaryButton(
                    label: _busy ? 'Kuruluyor…' : 'Oda kur',
                    onPressed: _busy ? null : _createRoom,
                  ),
                  const SizedBox(height: 12),
                  NocturneSecondaryButton(
                    label: _busy ? 'Katılıyor…' : 'Odaya katıl',
                    onPressed: _busy ? null : _joinRoom,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Sorumlu iç, kimseyi zorlama. 18+',
                    style: TextStyle(fontSize: 13, color: NocturneColors.neutral600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NocturneField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextCapitalization textCapitalization;

  const _NocturneField({
    required this.controller,
    required this.hint,
    this.textCapitalization = TextCapitalization.words,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: textCapitalization,
      style: const TextStyle(fontSize: 16, color: NocturneColors.text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: NocturneColors.neutral600),
        filled: true,
        fillColor: NocturneColors.surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NocturneRadius.md),
          borderSide: const BorderSide(color: NocturneColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NocturneRadius.md),
          borderSide: const BorderSide(color: NocturneColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NocturneRadius.md),
          borderSide: const BorderSide(color: NocturneColors.accent),
        ),
      ),
    );
  }
}
