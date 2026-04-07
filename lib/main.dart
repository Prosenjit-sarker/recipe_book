import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_book/core/app_color.dart';
import 'package:recipe_book/presentation/provider/recipe_provider.dart';
import 'package:recipe_book/presentation/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RecipeProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Recipe Book',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          scaffoldBackgroundColor: AppColors.surface,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
