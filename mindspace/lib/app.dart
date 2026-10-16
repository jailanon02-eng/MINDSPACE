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
          appBarTheme: const AppBarTheme(backgroundColor: kBg, elevation: 0, scrolledUnderElevation: 0),
        ),
        home: const SplashScreen(),
      );
}
