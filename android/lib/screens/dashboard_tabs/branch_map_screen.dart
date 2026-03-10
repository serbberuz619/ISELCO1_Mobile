import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_services.dart';

class BranchMapScreen extends StatefulWidget {
  const BranchMapScreen({super.key});

  @override
  State<BranchMapScreen> createState() => _BranchMapScreenState();
}

class _BranchMapScreenState extends State<BranchMapScreen> {
  final MapController _mapController = MapController();
  List<dynamic> _branches = [];
  String _selectedBranch = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBranches();
  }

  Future<void> _fetchBranches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      var response = await ApiServices().getDataWithToken('branches', token);
      if (response != null && response['success'] == true) {
        setState(() {
          _branches = response['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching branches: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtered branches for markers
    List<dynamic> displayedBranches = _selectedBranch == 'All'
        ? _branches
        : _branches.where((b) => b['office_name'] == _selectedBranch).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Branch Offices',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 1,
      ),
      body: Column(
        children: [
          // Dropdown filter at the top
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.filter_list, color: Colors.blueAccent),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedBranch,
                    isExpanded: true,
                    underline: Container(
                      height: 1,
                      color: Colors.grey.shade300,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: 'All',
                        child: Text('All Branches'),
                      ),
                      ..._branches.map(
                        (b) => DropdownMenuItem<String>(
                          value: b['office_name'],
                          child: Text(b['office_name']),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedBranch = val;
                        });

                        // Zoom/Pan behavior
                        if (val != 'All') {
                          var branch = _branches.firstWhere(
                            (b) => b['office_name'] == val,
                          );
                          double lat =
                              double.tryParse(branch['latitude'].toString()) ??
                              17.1;
                          double lng =
                              double.tryParse(branch['longitude'].toString()) ??
                              121.7;
                          _mapController.move(LatLng(lat, lng), 14.0);
                        } else {
                          // generic zoom out somewhere central
                          _mapController.move(const LatLng(17.0, 121.7), 9.5);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: const LatLng(17.0, 121.7),
                      initialZoom: 9.5,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'ph.iselco.mobileapp',
                      ),
                      MarkerLayer(
                        markers: displayedBranches.map((b) {
                          double lat =
                              double.tryParse(b['latitude'].toString()) ?? 0.0;
                          double lng =
                              double.tryParse(b['longitude'].toString()) ?? 0.0;
                          return Marker(
                            point: LatLng(lat, lng),
                            width: 60,
                            height: 60,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.redAccent,
                              size: 40,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
