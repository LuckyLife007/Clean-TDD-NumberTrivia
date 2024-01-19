import 'package:clean_app/features/number_trivia/presentation/pages/number_trivia_page.dart';
import 'package:clean_app/injection_container.dart' as di;
import 'package:flutter/material.dart';

void main() {
  di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Number Trivia',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            colorScheme: ColorScheme.light(
                primary: Colors.green.shade800, onPrimary: Colors.white),
            appBarTheme: AppBarTheme(color: Colors.green.shade800)),
        home: const NumberTriviaPage());
  }
}
