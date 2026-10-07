import 'package:flutter/material.dart';

class Palette {
  Palette._();
  static const bg = Color(0xFF0A0A0C);
  static const surface = Color(0xFF16171B);
  static const surface2 = Color(0xFF222329);
  static const line = Color(0xFF2C2D34);
  static const text = Color(0xFFF4F5F7);
  static const textSoft = Color(0xFF9EA2AC);
  static const blue = Color(0xFF2F6BFF);
  static const red = Color(0xFFFF3B30);
  static const white = Color(0xFFFFFFFF);
}

const cardRadius = BorderRadius.all(Radius.circular(16));
const hairline = BorderSide(color: Palette.line, width: 1);

BoxDecoration cardDecoration({bool selected = false}) => BoxDecoration(
  borderRadius: cardRadius,
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1F26), Color(0xFF131418)],
  ),
  border: Border.all(color: selected ? Palette.blue : const Color(0x14FFFFFF), width: selected ? 2 : 1),
  boxShadow: [
    const BoxShadow(color: Color(0x80000000), blurRadius: 24, offset: Offset(0, 10)),
    if (selected) BoxShadow(color: Palette.blue.withAlpha(70), blurRadius: 22),
  ],
);

BoxDecoration fieldDecoration() => BoxDecoration(
  borderRadius: BorderRadius.circular(18),
  gradient: const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF101115), Color(0xFF1A1B21)],
  ),
  border: Border.all(color: const Color(0x1AFFFFFF)),
  boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 8))],
);

WidgetStateProperty<T> _pick<T>(T selected, T other) =>
    WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? selected : other);

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: Palette.blue, brightness: Brightness.dark).copyWith(
    primary: Palette.blue,
    onPrimary: Palette.white,
    secondary: Palette.red,
    onSecondary: Palette.white,
    error: Palette.red,
    surface: Palette.surface,
    onSurface: Palette.text,
    surfaceContainerHighest: Palette.surface2,
    outline: Palette.line,
    outlineVariant: Palette.line,
  );
  final base = ThemeData(useMaterial3: true, brightness: Brightness.dark, colorScheme: scheme);
  final applied = base.textTheme.apply(bodyColor: Palette.text, displayColor: Palette.text);
  final text = applied.copyWith(
    headlineMedium: applied.headlineMedium?.copyWith(letterSpacing: -0.8),
    titleMedium: applied.titleMedium?.copyWith(letterSpacing: -0.2),
  );

  return base.copyWith(
    scaffoldBackgroundColor: Palette.bg,
    textTheme: text,
    dividerColor: Palette.line,
    iconTheme: const IconThemeData(color: Palette.text),
    appBarTheme: const AppBarTheme(
      backgroundColor: Palette.bg,
      foregroundColor: Palette.text,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Palette.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Palette.surface,
      showDragHandle: true,
      dragHandleColor: Palette.line,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Palette.surface2,
      contentTextStyle: text.bodyMedium?.copyWith(color: Palette.text, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Palette.surface2,
      selectedColor: Palette.blue,
      side: BorderSide.none,
      showCheckmark: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      labelStyle: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: Palette.text),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: const TextStyle(color: Palette.textSoft),
      labelStyle: const TextStyle(color: Palette.textSoft),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: hairline),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Palette.blue, width: 1.5),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: _pick(Palette.blue, Palette.surface2),
        foregroundColor: _pick(Palette.white, Palette.text),
        side: const WidgetStatePropertyAll(BorderSide.none),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: _pick(Palette.white, Palette.textSoft),
      trackColor: _pick(Palette.blue, Palette.surface2),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: _pick(Palette.blue, Colors.transparent),
      checkColor: const WidgetStatePropertyAll(Palette.white),
      side: const BorderSide(color: Palette.textSoft, width: 1.5),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Palette.surface2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: Palette.blue),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Palette.blue,
      thumbColor: Palette.blue,
      inactiveTrackColor: Palette.surface2,
    ),
    listTileTheme: const ListTileThemeData(iconColor: Palette.textSoft, textColor: Palette.text),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Palette.surface,
      indicatorColor: Palette.blue,
      height: 68,
      elevation: 12,
      shadowColor: Colors.black,
      iconTheme: _pick(const IconThemeData(color: Palette.white), const IconThemeData(color: Palette.textSoft)),
      labelTextStyle: _pick(
        const TextStyle(color: Palette.white, fontWeight: FontWeight.w700),
        const TextStyle(color: Palette.textSoft, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Palette.blue,
        textStyle: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
  );
}
