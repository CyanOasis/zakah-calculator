/**
 * Zakah & Tazkiyah Calculator
 * 
 * Developed in collaboration with OpenAI Codex & GPT-5.6
 * for the OpenAI Build Week Hackathon.
 * 
 * Code generated, refactored, and optimized by OpenAI Codex.
 */

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:zakat/l10n/app_localizations.dart';
import 'providers/zakat_provider.dart';
import 'ui/splash_screen.dart';

/// Custom scroll behavior that enables drag scrolling with mouse/trackpad.
/// WSA translates touch events as mouse pointer events, so Flutter's default
/// behavior (scroll-wheel only for mouse) breaks scrolling on WSA.
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Preload Kalpurush font to avoid any async loading and text layout/size jumps
  try {
    final fontLoader = FontLoader('Kalpurush');
    fontLoader.addFont(rootBundle.load('assets/fonts/kalpurush.ttf'));
    await fontLoader.load();
  } catch (e) {
    debugPrint('Error preloading Kalpurush font: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ZakatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ZakatProvider>();
    final baseTextTheme = Theme.of(context).textTheme.apply(fontFamily: 'Kalpurush');

    return MaterialApp(
      title: 'Zakat Calculator',
      debugShowCheckedModeBanner: false,
      scrollBehavior: AppScrollBehavior(),
      themeAnimationDuration: Duration.zero,
      locale: Locale(provider.selectedLanguageCode),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('bn'),
        Locale('tr'),
      ],
      theme: ThemeData(
        useMaterial3: true,
        typography: Typography.material2021(
          englishLike: Typography.englishLike2021,
          dense: Typography.englishLike2021,
          tall: Typography.englishLike2021,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A462C), // Deep Green
          primary: const Color(0xFF0A462C),
          secondary: const Color(0xFFC5A059), // Metallic Gold
          surface: const Color(0xFFFBFDFF),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0A462C),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: baseTextTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textTheme: baseTextTheme.copyWith(
          headlineLarge: baseTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF0A462C)),
          headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF0A462C)),
          titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
          color: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
