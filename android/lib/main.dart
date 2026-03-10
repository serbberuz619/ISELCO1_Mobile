import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // Na-import natin ang ginawa nating splash screen

void main() {
  runApp(const IselcoMobileApp());
}

class IselcoMobileApp extends StatelessWidget {
  const IselcoMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ISELCO1_Mobile',
      debugShowCheckedModeBanner:
          false, // Tatanggalin nito yung "DEBUG" banner sa gilid
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // Dito natin ise-set globally ang Poppins.
        // Ibig sabihin bawat screen ay automatic Poppins na ang gagamiting font!
        fontFamily: 'Poppins',
      ),
      // ITO ANG MAGIC CODE PARA HINDI MA-A-APEKTOHAN NG PHONE SETTINGS ANG APP DESIGN MO
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            // Ito pipigil mag-adjust ng font size kahit mag-zoom sila sa phone settings nila
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
      home: const SplashScreen(), // Naka-point na ang app sa Splash Screen mo
    );
  }
}
