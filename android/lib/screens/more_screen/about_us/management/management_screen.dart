import 'package:flutter/material.dart';
import '../../../../services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Screen kung saan idinidisplay ang listahan ng Management Employees.
/// Gamit ay ang mas eleganteng design kaysa sa Board of Directors.
class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  bool _isLoading = true;
  List<dynamic> _managementList = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadManagement();
  }

  /// Pagtawag sa backend para kunin ang records ng management
  Future<void> _loadManagement() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      if (token.isEmpty) {
        setState(() {
          _errorMessage = "Walang token na nakita. Mag-login muli.";
          _isLoading = false;
        });
        return;
      }

      final response = await ApiServices().fetchManagement(token);

      if (response['success'] == true) {
        setState(() {
          _managementList = response['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              response['message'] ?? "Hindi makuha ang mga impormasyon.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            "Nagkaroon ng problema sa network connection. Subukang muli.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF7F9FC,
      ), // Slightly gray background para umangat ang cards
      appBar: AppBar(
        title: const Text(
          'ISELCO-I Management',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.black.withValues(alpha: 0.05), height: 1.0),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.indigo),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 70,
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
                  _loadManagement();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Subukan Ulit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_managementList.isEmpty) {
      return const Center(
        child: Text(
          'Walang nakitang management records.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      itemCount: _managementList.length,
      itemBuilder: (context, index) {
        final item = _managementList[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Elegant Avatar Placeholder
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_outline,
                      size: 30,
                      color: Colors.indigo,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['employee_name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 14,

                          color: Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['position'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.indigo,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Department Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.corporate_fare,
                              size: 14,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                item['department'] ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
