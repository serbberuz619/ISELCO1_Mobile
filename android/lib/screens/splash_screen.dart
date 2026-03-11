import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'login_screen.dart';
import '../widgets/global_background.dart'; // Import natin ang ginawang global background

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Subscription para ma-monitor ang internet connection
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    // Tatawagin natin ang checkInitialConnection kapag nag-load ang screen
    _checkInitialConnection();
  }

  // Function para i-check kung may internet bago mag-proceed
  Future<void> _checkInitialConnection() async {
    // I-delay nang onti para makita yung splash screen (e.g. 3 seconds)
    await Future.delayed(const Duration(seconds: 3));

    // Gamit ang connectivity_plus natin, ichecheck natin kung anong connection niya
    var connectivityResult = await (Connectivity().checkConnectivity());

    // Kung walang connection
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _showNoInternetDialog();
      // Simulan ang pakikinig kapag bumalik na ang internet para mag-proceed
      _listenToConnectionChanges();
    } else {
      // Kung may internet, proceed sa Login Screen
      _navigateToLogin();
    }
  }

  // Function listener kapag biglang nagbago internet
  void _listenToConnectionChanges() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (!results.contains(ConnectivityResult.none) && !_isConnected) {
        _isConnected = true;
        // Tanggalin yung nakaharang na dialog kapag bumalik wifi
        if (!mounted) return;
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        _navigateToLogin();
      }
    });
  }

  // Popup na nagsasabing walang internet
  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Hindi pwedeng isara kapag pinindot sa labas ng box
      builder: (context) => AlertDialog(
        title: const Text(
          'No Internet Connection',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Please connect first to the internet to proceed.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Isara yung popup
              _checkInitialConnection(); // I-retry ang proseso
            },
            child: const Text(
              'Retry',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    // Importante ito para maiwasan ang "Memory Leak" kapag lumipat na ng screen.
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Kukunin natin ang screen size para maging responsive
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GlobalBackground(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo Image
            Image.asset(
              'assets/images/Logo.png',
              width:
                  size.width *
                  0.3, // Responsive size ng logo (50% ng screen width)
            ),
            const SizedBox(height: 40), // Space sa pagitan ng Logo at Spinner
            // Loading Spinner widget sa ilalim ng logo
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white,
              ), // Puti para mag-contrast sa background
            ),
          ],
        ),
      ),
    );
  }
}
