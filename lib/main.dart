import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chess_clock/home_page.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() {
  //for locking orientation
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      maxMobileWidth: 320,
      builder: (context, orientation, screenType) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: HomePage(),
        );
      },
    );
  }
}
