import 'package:flutter/material.dart';
import '../../../../services/api_services.dart';

import 'package:shared_preferences/shared_preferences.dart';

/// Isang reusable screen para i-display ang Board of Directors o ISELCO-I Management
/// base sa ibibigay na category parameter at title string.
class DirectoryScreen extends StatefulWidget {
  final String title;
  final String category;

  const DirectoryScreen({
    super.key,
    required this.title,
    required this.category,
  });

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  bool _isLoading = true;
  List<dynamic> _directories = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDirectory();
  }

  /// Pagtawag sa backend para kunin ang records
  Future<void> _loadDirectory() async {
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

      final response = await ApiServices().fetchDirectory(
        token,
        widget.category,
      );

      if (response['success'] == true) {
        setState(() {
          _directories = response['data'] ?? [];
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.black.withValues(alpha: 0.1), height: 1.0),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blueAccent),
      );
    }

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
                  _loadDirectory();
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

    if (_directories.isEmpty) {
      return const Center(
        child: Text(
          'Walang nakitang records.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    // Modern listview na may Card layout, shadow at border radius para mukhang solid at malinis
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: _directories.length,
      itemBuilder: (context, index) {
        final item = _directories[index];
        final bool isBoard = widget.category == 'board';

        return Card(
          elevation: 2,
          shadowColor: Colors.black12,
          margin: const EdgeInsets.only(bottom: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icon avatar or placeholder image
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isBoard
                      ? Colors.amber.withValues(alpha: 0.2)
                      : Colors.blue.withValues(alpha: 0.2),
                  child: Icon(
                    isBoard ? Icons.person_pin : Icons.badge_outlined,
                    size: 30,
                    color: isBoard ? Colors.amber[800] : Colors.blueAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['director_name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 12,

                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['position'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      if (item['area'] != null &&
                          item['area'].toString().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item['area'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
