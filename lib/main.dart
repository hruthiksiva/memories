import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/swipe_screen.dart';
import 'screens/memory_board_screen.dart';
import 'providers/photo_provider.dart';
import 'providers/memory_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PhotoProvider()),
        ChangeNotifierProvider(create: (_) => MemoryProvider()),
      ],
      child: MaterialApp(
        title: 'Best Memories Mood Board',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0D47A1), // Dark blue
            foregroundColor: Colors.white,
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Color(0xFF0D47A1)),
          ),
        ),
        initialRoute: '/memory_board', // Start at memory board
        routes: {
          '/swipe': (context) => const SwipeScreen(),
          '/memory_board': (context) => const MemoryBoardScreen(),
        },
      ),
    );
  }
}