import 'package:ecostep/providers/gemini_notifier.dart';
import 'package:ecostep/providers/selected_date_notifier.dart';
import 'package:ecostep/views/home_screen.dart';
import 'package:ecostep/views/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (_, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<GeminiNotifier>(
                create: (_) => GeminiNotifier()),
            ChangeNotifierProvider<SelectedDateNotifier>(
                create: (_) => SelectedDateNotifier()),
          ],
          child: MaterialApp(
            title: 'EcoStep',
            theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.primaryColor,
                ),
                useMaterial3: true,
                fontFamily: 'Poppins'),
            home: child,
            debugShowCheckedModeBanner: false,
          ),
        );
      },
      child: const HomeScreen(),
    );
  }
}
