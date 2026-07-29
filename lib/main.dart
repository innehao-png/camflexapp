import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/favorite_service.dart';
import 'providers/auth_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/profile_provider.dart';

void main() {
  runApp(
    // Move Providers here to make them global across all routes/screens
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sastra Film',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF007A),
          secondary: Color(0xFFFF007A),
        ),
      ),
      home: FutureBuilder<String?>(
        future: AuthService.getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFFF007A)),
              ),
            );
          }

          final token = snapshot.data;
          if (token != null && token.isNotEmpty) {
            // IMPORTANT: Initialize the service inside the provider now that we have the token
            context.read<FavoriteProvider>().setService(FavoriteService(token));
            return const MainScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}