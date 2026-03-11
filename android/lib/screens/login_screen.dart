import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import '../widgets/global_background.dart';
import '../services/api_services.dart';
import '../utils/top_snackbar.dart';
import 'registration_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Pam-pigil ng inputs habang nag-a-API
  bool _isLoading = false;

  // Para itago or ipakita ang password
  bool _obscurePassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle Login using API Services
  Future<void> _handleLogin() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showTopSnackBar(
        context,
        'Please enter both email and password.',
        color: Colors.redAccent,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var response = await ApiServices().loginUser(email, password);

      if (response['success'] == true) {
        String token = response['token'];
        var user = response['user'];

        // 1. I-save yung Laravel Bearer Token locally sa phone
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setInt('user_id', user['user_id']);
        await prefs.setString('user_name', user['fullname']);
        await prefs.setString(
          'saved_email',
          email,
        ); // I-save natin ito para magamit ng Biometric Login next time

        if (!mounted) return;

        // // [REMOVED] Prompt for biometric setup upon login. It is now moved to More/Settings tab.
        // if (!kIsWeb && !isBiometricEnabled) {
        //   await _promptBiometricSetup(token);
        // }

        // Kahit in-enable, cinancel, or allowed without hardware, direct to dashboard

        // Nagsa-save na successfully or skip, kaya tapusin na ang login process papuntang dashboard:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        if (!mounted) return;
        showTopSnackBar(
          context,
          response['message'] ?? 'Login failed.',
          color: Colors.redAccent,
        );
      }
    } catch (e) {
      if (!mounted) return;
      showTopSnackBar(
        context,
        'Email and Password are not Match in our Database.',
        color: Colors.redAccent,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Handle Biometric Login via the saved token from SharedPreferences
  Future<void> _handleBiometricLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('saved_email');

    if (email == null || email.isEmpty) {
      if (!mounted) return;
      showTopSnackBar(
        context,
        'Please login with your Email & Password first to register this device.',
        color: Colors.orange,
      );
      return;
    }

    try {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (canCheckBiometrics && isDeviceSupported) {
        bool didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Scan Fingerprint or use PIN to Login',
          biometricOnly: false,
        );

        if (didAuthenticate) {
          setState(() {
            _isLoading = true;
          });

          // Pumasok ang fingerprint natin, ask laravel to give us token
          var response = await ApiServices().loginUser(
            email,
            'BIOMETRIC_LOGIN',
          );

          if (!mounted) return;

          if (response['success'] == true) {
            String token = response['token'];
            var user = response['user'];

            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('auth_token', token);
            await prefs.setInt('user_id', user['user_id']);
            await prefs.setString('user_name', user['fullname']);

            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          } else {
            showTopSnackBar(
              context,
              response['message'] ?? 'Biometric login failed.',
              color: Colors.redAccent,
            );
          }
        }
      } else {
        if (!mounted) return;
        showTopSnackBar(
          context,
          'Device not supported for Biometrics.',
          color: Colors.redAccent,
        );
      }
    } catch (e) {
      debugPrint('Error handling biometric login: $e');
      if (!mounted) return;
      showTopSnackBar(
        context,
        'Biometric authentication cancelled or failed. Try to login via Email and Password',
        color: Colors.redAccent,
      );
    } finally {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kukunin natin ang screen size
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GlobalBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            // May smooth bouncy effect kapag nai-scroll
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Naka-left align by default
              children: [
                const SizedBox(height: 30),

                // Logo sa taas, naka-center
                Center(
                  child: Image.asset(
                    'assets/images/Logo.png',
                    width: size.width * 0.25, // Binawasan ang laki
                  ),
                ),
                const SizedBox(height: 20),

                // Elegant Welcome Back text
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 0),

                // Subtitle na binagong size 10 at color black
                const Text(
                  "Let's login to continue",
                  style: TextStyle(
                    fontSize: 10,
                    color: Color.fromARGB(123, 0, 0, 0),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 15),

                // Frosted Glassmorphism Email Field
                _buildModernTextField(
                  controller: _emailController,
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),

                // Frosted Glassmorphism Password Field
                _buildModernPasswordField(),
                const SizedBox(height: 30),

                // Modern Gradient Sign In Button
                _buildModernSignInButton(),
                const SizedBox(height: 30),

                // Fingerprint Logic (Naka auto-fit depende sa phone gamit ang width: double.infinity at FittedBox)
                Center(
                  child: InkWell(
                    onTap: _handleBiometricLogin,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: double.infinity, // Sasakop sa allowed width
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Igitna ang content
                        children: [
                          Icon(
                            Icons.fingerprint,
                            color: Colors.white,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Login with Finger Print',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Legend Line: "You can connect with"
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.white.withValues(alpha: 0.4),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'You can connect with',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.white.withValues(alpha: 0.4),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Solid Clean Google Button
                _buildGoogleButton(),
                const SizedBox(height: 10),

                // Button to Test Laravel Connection
                Center(child: _buildTestBackendButton()),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPERS PARA MAS MALINIS ANG CODE ---

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    // Styling the modern input as Frosted Glassmorphism to pop elegantly on top of the background image
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              prefixIcon: Icon(prefixIcon, color: Colors.white),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernPasswordField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword, // Dito nagbabase kung hide/show
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernSignInButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        // Modern gradient effect para sa Premium feel
        gradient: const LinearGradient(
          colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0072FF).withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors
              .transparent, // Pinapagana natin yung mismong linear gradient sa likod
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'SIGN IN',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  // Logic for Google Sign-In and checking Email logic na nasa API Services
  Future<void> _handleGoogleSignIn() async {
    ApiServices apiServices = ApiServices();
    Map<String, dynamic> result = await apiServices.signInWithGoogleAndCheck();

    if (!mounted) return; // safety check

    if (result['status'] == 'exists') {
      // IPapakita yung message na requested mo sa bandang bottom
      showTopSnackBar(
        context,
        'This email is already in use, please use another email.',
        color: Colors.redAccent,
      );
    } else if (result['status'] == 'new_user') {
      // Hindi pa existing ang email, ididiretso na natin siya sa Registration Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegistrationScreen(
            prefilledEmail: result['email'],
            prefilledName: result['displayName'],
            googleId: result['id'], // Ipasa ang googleId dito
          ),
        ),
      );
    } else if (result['status'] == 'error') {
      // Magpakita ng generic error if connection fail to avoid app crash silently
      showTopSnackBar(
        context,
        'An error occurred: ${result['message']}',
        color: Colors.redAccent,
      );
    }
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity, // Auto fit depende sa padding constraint ng phone
      height: 55, // Niresize nang konti para katamtaman
      child: ElevatedButton(
        onPressed: _handleGoogleSignIn, // Nakakabit na sa logic!
        style: ElevatedButton.styleFrom(
          backgroundColor:
              Colors.white, // Solid white contrast against your background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
          shadowColor: Colors.black.withValues(alpha: 0.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/google.png', height: 26),
            const SizedBox(width: 14),
            const Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Sign Up  with Google',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestBackendButton() {
    return TextButton(
      onPressed: () async {
        ApiServices apiServices = ApiServices();
        try {
          final response = await apiServices.getData('test-message');
          if (mounted) {
            showTopSnackBar(
              context,
              'Connected to Data Center! Message: ${response['message'] ?? 'Success'}',
              color: Colors.green,
            );
          }
        } catch (e) {
          if (mounted) {
            showTopSnackBar(
              context,
              'Failed to connect: $e',
              color: Colors.redAccent,
            );
          }
        }
      },
      child: const Text(
        'Test Backend Connection',
        style: TextStyle(
          color: Colors.white,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}
