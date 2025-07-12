import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF1565C0);
  static const accent = Color(0xFF00C853);
  static const background = Color(0xFFF5F5F5);
  static const cardGlass = Colors.white24;
  static const darkBackground = Color(0xFF181A20);
  static const darkCardGlass = Colors.white10;
}

ThemeData appLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  cardColor: AppColors.cardGlass,
  textTheme: GoogleFonts.poppinsTextTheme(),
  fontFamily: GoogleFonts.poppins().fontFamily,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    background: AppColors.background,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    filled: true,
    fillColor: Colors.white.withOpacity(0.8),
    labelStyle: GoogleFonts.poppins(),
  ),
);

ThemeData appDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.darkBackground,
  cardColor: AppColors.darkCardGlass,
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
  fontFamily: GoogleFonts.poppins().fontFamily,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    background: AppColors.darkBackground,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    filled: true,
    fillColor: Colors.white.withOpacity(0.1),
    labelStyle: GoogleFonts.poppins(),
  ),
);

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double elevation;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  const GlassmorphicCard({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.elevation = 4,
    this.margin,
    this.padding,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: elevation * 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
} 