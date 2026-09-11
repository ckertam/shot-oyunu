import 'package:flutter/material.dart';

import 'nocturne_theme.dart';

/// Small uppercase, letter-spaced label — used for section kickers
/// ("ADIM 1 / 2", "GECE BİTTİ · 2s 06dk") throughout the brief.
class NocturneKicker extends StatelessWidget {
  final String text;
  final Color color;
  const NocturneKicker(this.text, {super.key, this.color = NocturneColors.neutral500});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
        color: color,
      ),
    );
  }
}

/// Outlined "primary action" button: ~12% accent tint fill, 1px accent
/// border, accent-300 text. Brief's primary actions are never solid fills.
class NocturnePrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  const NocturnePrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 62,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: NocturneColors.accentTint(disabled ? 0.06 : 0.12),
        borderRadius: BorderRadius.circular(NocturneRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(NocturneRadius.md),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(NocturneRadius.md),
              border: Border.all(
                color: disabled
                    ? NocturneColors.accent.withValues(alpha: 0.35)
                    : NocturneColors.accent,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: disabled
                    ? NocturneColors.accent300.withValues(alpha: 0.5)
                    : NocturneColors.accent300,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined neutral secondary button ("Pas", "Paylaş").
class NocturneSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  const NocturneSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 62,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(NocturneRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(NocturneRadius.md),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(NocturneRadius.md),
              border: Border.all(color: NocturneColors.border),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: NocturneColors.neutral400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small filled neutral pill — "Kopyala", "Kapat".
class NocturneChipButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const NocturneChipButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: NocturneColors.border,
      borderRadius: BorderRadius.circular(NocturneRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(NocturneRadius.lg),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: NocturneColors.text),
          ),
        ),
      ),
    );
  }
}

/// Generic surfaced container — the "card" shape used for mode cards,
/// player rows, info panels, etc.
class NocturneCard extends StatelessWidget {
  final Widget child;
  final Color background;
  final Color? borderColor;
  final double radius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const NocturneCard({
    super.key,
    required this.child,
    this.background = NocturneColors.surface2,
    this.borderColor = NocturneColors.border,
    this.radius = NocturneRadius.lg,
    this.padding = const EdgeInsets.all(22),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(borderRadius: BorderRadius.circular(radius), onTap: onTap, child: content),
    );
  }
}

/// "HOST" style tag — tinted accent background, accent border, accent-300 text.
class NocturneTag extends StatelessWidget {
  final String label;
  const NocturneTag(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: NocturneColors.accent900,
        borderRadius: BorderRadius.circular(NocturneRadius.sm),
        border: Border.all(color: NocturneColors.accent700),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: NocturneColors.accent300,
        ),
      ),
    );
  }
}

/// Two-option segmented control (Ayarlar's Light/Hard difficulty switch).
class NocturneSegmentedControl<T> extends StatelessWidget {
  final List<(T value, String label)> options;
  final T selected;
  final ValueChanged<T> onChanged;

  const NocturneSegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: NocturneColors.surface2,
        border: Border.all(color: NocturneColors.border),
        borderRadius: BorderRadius.circular(NocturneRadius.md),
      ),
      child: Row(
        children: [
          for (final (value, label) in options)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: options.first.$1 == value ? 0 : 4),
                child: _SegmentOption(
                  label: label,
                  selected: value == selected,
                  onTap: () => onChanged(value),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SegmentOption({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? NocturneColors.accentTint(0.12) : Colors.transparent,
      borderRadius: BorderRadius.circular(NocturneRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(NocturneRadius.md),
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(NocturneRadius.md),
            border: Border.all(color: selected ? NocturneColors.accent : Colors.transparent),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: selected ? NocturneColors.accent300 : NocturneColors.neutral500,
            ),
          ),
        ),
      ),
    );
  }
}

/// One row of a grouped settings list ("Titreşim", "Shot sayacı", …).
class NocturneToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const NocturneToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: NocturneColors.surface2,
        border: showDivider
            ? const Border(bottom: BorderSide(color: NocturneColors.border))
            : null,
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Round avatar with the player's initial — used in player lists everywhere.
class NocturneAvatar extends StatelessWidget {
  final String name;
  final bool accented;
  const NocturneAvatar({super.key, required this.name, this.accented = false});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accented ? NocturneColors.accentTint(0.12) : NocturneColors.border,
        border: accented ? Border.all(color: NocturneColors.accent) : null,
      ),
      child: Text(
        initial,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: accented ? NocturneColors.accent300 : NocturneColors.text,
        ),
      ),
    );
  }
}
