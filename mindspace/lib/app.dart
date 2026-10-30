import 'package:flutter/material.dart';
import 'all.dart';

class MindSpaceApp extends StatelessWidget {
  const MindSpaceApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'MindSpace',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: kPrimary,
          scaffoldBackgroundColor: kBg,
          navigationBarTheme: NavigationBarThemeData(
            height: 68, indicatorColor: kPrimary.withValues(alpha: .14),
            labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, backgroundColor: kText,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
          appBarTheme: const AppBarTheme(backgroundColor: kBg, elevation: 0, scrolledUnderElevation: 0),
        ),
        home: const SplashScreen(),
      );
}
