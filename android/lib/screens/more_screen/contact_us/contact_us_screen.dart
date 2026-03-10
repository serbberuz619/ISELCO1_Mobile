import 'package:flutter/material.dart';
import '../../../../services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen kung saan idinidisplay ang listahan ng mga contact hotlines
/// ng iba't ibang branch ng ISELCO UNO.
class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  // Flag para malaman kung umiikot pa ba ang loading indicator
  bool _isLoading = true;
  // Dito natin ise-save ang listahan galing database
  List<dynamic> _contacts = [];
  // Kung sakaling may maging error sa connection, dito ilalagay
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  /// Function para humingi sa Laravel backend ng mga hotlines.
  /// Tatawagin nito ang fetchContacts() sa api_services.dart.
  Future<void> _loadContacts() async {
    try {
      // Kunin muna ang na-save na token para sa auth:sanctum
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      if (token.isEmpty) {
        setState(() {
          _errorMessage = "Walang token na nakita. Mag-login muli.";
          _isLoading = false;
        });
        return;
      }

      // Tawagin ang backend API
      final response = await ApiServices().fetchContacts(token);

      if (response['success'] == true) {
        // Kung tagumpay, ipasa sa state variable ang data list
        setState(() {
          _contacts = response['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              response['message'] ?? "Hindi makuha ang mga hotlines.";
          _isLoading = false;
        });
      }
    } catch (e) {
      // Catch network errors dito
      setState(() {
        _errorMessage =
            "Nagkaroon ng problema sa network connection. Subukang muli.";
        _isLoading = false;
      });
    }
  }

  /// Function para buksan ang device dialer
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Kung hindi ma-launch (eg. simulator na walang dialer)
      // Ipapasa natin sana sa user interface error toast pero mostly di mangyayari ito sa totoong device.
      debugPrint("Could not launch $launchUri");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // Titulo ng Screen
        title: const Text(
          'ISELCO UNO Hotlines',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        // Back Button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        // Divider sa ilalim ng appbar para hindi nakadikit ang content
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.black.withOpacity(0.1), height: 1.0),
        ),
      ),
      body: _buildBody(),
    );
  }

  /// Piliin kung anong view ang ipapakita depende sa state: Load, Error, o Data
  Widget _buildBody() {
    // Pag-load state
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blueAccent),
      );
    }

    // Pag may error state
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadContacts();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Subukan Ulit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Kung walang data na galing server
    if (_contacts.isEmpty) {
      return const Center(
        child: Text(
          'Walang nakitang hotline records.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    // Modern card style layout gamit listview para sa data
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];

        // Modern card style layout gamit listview para sa data, nilagyan natin ng InkWell para clickable
        return Card(
          elevation: 5,
          shadowColor: Colors.black26,
          margin: const EdgeInsets.only(bottom: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              // Direct dialing pag na click ang card
              if (contact['contact_no'] != null) {
                _makePhoneCall(contact['contact_no']);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 24.0,
              ),
              child: Row(
                children: [
                  // Lined Phone Icon sa loob ng rounded rectangle container bilang indicator
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.phone_in_talk_rounded,
                      color: Colors.blueAccent,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Expanded list layout para magamit buong space
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pangalan ng Branch
                        Text(
                          contact['branch_office'] ?? 'Unknown Branch',
                          style: const TextStyle(
                            fontSize: 12,
                            // fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Numero na pwedeng tawagan
                        Row(
                          children: [
                            const Icon(
                              Icons.dialpad,
                              size: 16,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              contact['contact_no'] ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Chevron icon or call action indicator
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.black26,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
