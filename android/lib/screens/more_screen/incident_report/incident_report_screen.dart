import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_services.dart';
import '../../../utils/top_snackbar.dart';

class IncidentReportScreen extends StatefulWidget {
  const IncidentReportScreen({super.key});

  @override
  State<IncidentReportScreen> createState() => _IncidentReportScreenState();
}

class _IncidentReportScreenState extends State<IncidentReportScreen> {
  int _currentPage = 0;
  final int _totalPages = 5;
  final PageController _pageController = PageController();

  // Selected Items
  String? _selectedIncidentType;
  String? _isIselcoPole;
  String? _selectedSpecificConcern;
  String? _selectedReportType;

  // Controllers
  final TextEditingController _poleNumberController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _sitioController = TextEditingController();
  final TextEditingController _landmarksController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // User Info
  String _userName = 'Guest';
  String _userEmail = 'guest@example.com';
  String _userPhone = 'N/A';
  String _authToken = '';

  // Locations
  List<dynamic> _towns = [];
  List<dynamic> _barangays = [];
  String? _selectedTownId;
  String? _selectedBarangayId;
  bool _isLoadingTowns = true;
  bool _isLoadingBarangays = false;
  bool _isLoadingUser = true;

  bool _isSubmitting = false;

  XFile? _selectedImage;

  // Tab 1 Options
  final List<String> _incidentTypes = [
    'Street Light',
    'No Power - House',
    'No Power - Whole Block',
    'Social Safety',
  ];

  final List<String> _streetLightConcerns = [
    'Streetlight is always on even during daytime',
    'Streetlight is flickering',
    'Streetlight is not on or has no power',
    'Streetlight fixture is damaged or has broken bulbs',
  ];

  final List<String> _powerConcerns = [
    'None',
    'Pole is broken or fallen',
    'Wire is detached or has fallen from the pole',
    'Something blew up',
  ];

  final List<String> _safetyConcerns = [
    'Pole is broken',
    'Pole has fallen',
    'Wire is sparkling',
    'Wire has fallen',
    'Wire is loose',
    'Wire is damaged or detached',
    'Something blew up',
    'Foreign object on wire',
    'Pole obstruction',
    'Wire obstruction',
  ];

  final List<String> _reportTypes = [
    'Report using Customer Account Number',
    'Report Address',
  ];

  @override
  void initState() {
    super.initState();
    _loadAuthDataAndProfile();
    _fetchTowns();

    // Listeners for Validation
    _poleNumberController.addListener(_validateForm);
    _accountNumberController.addListener(_validateForm);
    _sitioController.addListener(_validateForm);
    _landmarksController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {});
  }

  Future<void> _loadAuthDataAndProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _authToken = prefs.getString('auth_token') ?? '';
    });

    if (_authToken.isNotEmpty) {
      try {
        var userProfile = await ApiServices().fetchUserProfile(_authToken);
        if (userProfile != null) {
          setState(() {
            _userName =
                userProfile['Fullname'] ??
                userProfile['name'] ??
                prefs.getString('user_name') ??
                'Guest';
            _userEmail =
                userProfile['Email'] ??
                userProfile['email'] ??
                prefs.getString('user_email') ??
                'guest@example.com';
            _userPhone =
                userProfile['Phone_number'] ??
                userProfile['phone_number'] ??
                prefs.getString('user_phone') ??
                'N/A';
          });
        }
      } catch (e) {
        // Fallback to local
        setState(() {
          _userName = prefs.getString('user_name') ?? 'Guest';
          _userEmail = prefs.getString('user_email') ?? 'guest@example.com';
          _userPhone = prefs.getString('user_phone') ?? 'N/A';
        });
      }
    } else {
      // Token empty, load local only
      setState(() {
        _userName = prefs.getString('user_name') ?? 'Guest';
        _userEmail = prefs.getString('user_email') ?? 'guest@example.com';
        _userPhone = prefs.getString('user_phone') ?? 'N/A';
      });
    }

    setState(() {
      _isLoadingUser = false;
    });
  }

  Future<void> _fetchTowns() async {
    try {
      var response = await ApiServices().getData('towns');
      if (response != null && response['success'] == true) {
        setState(() {
          _towns = response['data'] ?? [];
          _isLoadingTowns = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTowns = false;
        });
      }
    }
  }

  Future<void> _fetchBarangays(String townId) async {
    setState(() {
      _isLoadingBarangays = true;
      _selectedBarangayId = null;
      _barangays = [];
    });
    try {
      var response = await ApiServices().getData('barangays/$townId');
      if (response != null && response['success'] == true) {
        setState(() {
          _barangays = response['data'] ?? [];
          _isLoadingBarangays = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingBarangays = false;
        });
      }
    }
    _validateForm();
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (image != null) {
        int sizeInBytes = await image.length();
        double sizeInMb = sizeInBytes / (1024 * 1024);

        if (sizeInMb > 5) {
          if (mounted) {
            showTopSnackBar(
              context,
              'Image is too large. Max 5MB.',
              color: Colors.orange,
            );
          }
          return;
        }

        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        showTopSnackBar(
          context,
          'Permission denied or action cancelled.',
          color: Colors.orange,
        );
      }
    }
  }

  bool _isNextButtonEnabled() {
    if (_currentPage == 0) {
      if (_selectedIncidentType == null) return false;
      if (_selectedIncidentType == 'Street Light') {
        if (_isIselcoPole == null) return false;
        if (_selectedSpecificConcern == null) return false;
        // The optional pole number is NOT required, proceed.
      } else {
        if (_selectedSpecificConcern == null) return false;
      }
      return true;
    } else if (_currentPage == 1) {
      if (_selectedReportType == null) return false;
      if (_selectedReportType == 'Report using Customer Account Number') {
        return _accountNumberController.text.trim().length == 10;
      } else {
        return _selectedTownId != null &&
            _selectedBarangayId != null; // Sitio is optional
      }
    } else if (_currentPage == 2) {
      return _landmarksController.text
          .trim()
          .isNotEmpty; // Landmarks is required
    } else if (_currentPage == 3) {
      return true; // Optional fields
    }
    return true;
  }

  void _nextPage() {
    FocusScope.of(context).unfocus();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    FocusScope.of(context).unfocus();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Placeholder for any future location logic if needed

  void _submitReport() async {
    setState(() {
      _isSubmitting = true;
    });

    Map<String, String> data = {
      'type_of_incident': _selectedIncidentType ?? '',
      'is_iselco_pole': _isIselcoPole ?? '',
      'pole_number': _poleNumberController.text.trim(),
      'specific_concern': _selectedSpecificConcern ?? '',
      'report_type': _selectedReportType ?? '',
      'account_number': _accountNumberController.text.trim(),
      'town': _selectedTownId ?? '',
      'barangay': _selectedBarangayId ?? '',
      'sitio': _sitioController.text.trim(),
      'landmarks': _landmarksController.text.trim(),
      'remarks': _messageController.text.trim(),
    };

    try {
      var res = await ApiServices().submitIncidentReport(
        _authToken,
        data,
        _selectedImage,
      );
      if (res['success'] == true) {
        if (mounted) {
          showTopSnackBar(
            context,
            'Report submitted successfully!',
            color: Colors.green,
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          showTopSnackBar(
            context,
            res['message'] ?? 'Failed to submit.',
            color: Colors.redAccent,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showTopSnackBar(
          context,
          'Failed to submit report. Error: $e',
          color: Colors.redAccent,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _poleNumberController.dispose();
    _accountNumberController.dispose();
    _sitioController.dispose();
    _landmarksController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool canProceed = _isNextButtonEnabled();

    // Determine banner text based on the tab
    String bannerText = "We’re improving our lines to serve you better.";
    if (_currentPage == 0) {
      bannerText = "Help us restore power quickly by describing the issue.";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Report a Brownout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: const BoxDecoration(color: Colors.orange),
              child: Text(
                bannerText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Step Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_totalPages, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 30 : 12,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.blueAccent
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),
            ),

            // Steps Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (idx) {
                  setState(() {
                    _currentPage = idx;
                  });
                  _validateForm();
                },
                children: [
                  _buildTab1(),
                  _buildTab2(),
                  _buildTab3(),
                  _buildTab4(),
                  _buildTab5(),
                ],
              ),
            ),

            // Navigation Buttons
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _prevPage,
                      child: const Text(
                        'BACK',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 60),

                  // Next or Submit
                  if (_currentPage < _totalPages - 1)
                    ElevatedButton(
                      onPressed: canProceed ? _nextPage : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        disabledBackgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.grey.shade600,
                        elevation: canProceed ? 5 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'CONTINUE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan.shade700,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'SUBMIT',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========== TAB 1 DETAILS =========== //
  Widget _buildTab1() {
    List<String> concernOptions = [];
    if (_selectedIncidentType == 'Street Light') {
      concernOptions = _streetLightConcerns;
    }
    if (_selectedIncidentType == 'No Power - House' ||
        _selectedIncidentType == 'No Power - Whole Block') {
      concernOptions = _powerConcerns;
    }
    if (_selectedIncidentType == 'Social Safety') {
      concernOptions = _safetyConcerns;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Concern Type'),
          _buildDropdown(
            hint: 'Select Concern',
            icon: Icons.flash_on_outlined,
            value: _selectedIncidentType,
            items: _incidentTypes,
            onChanged: (val) {
              setState(() {
                _selectedIncidentType = val;
                _selectedSpecificConcern = null;
                _isIselcoPole = null;
              });
            },
          ),

          if (_selectedIncidentType == 'Street Light') ...[
            const SizedBox(height: 20),
            _buildLabel('Is this streetlight connected to ISELCO-I Pole?'),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text(
                      'Yes',
                      style: TextStyle(color: Colors.black87),
                    ),
                    value: 'Yes',
                    groupValue: _isIselcoPole,
                    activeColor: Colors.blueAccent,
                    onChanged: (val) => setState(() {
                      _isIselcoPole = val;
                    }),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text(
                      'No',
                      style: TextStyle(color: Colors.black87),
                    ),
                    value: 'No',
                    groupValue: _isIselcoPole,
                    activeColor: Colors.blueAccent,
                    onChanged: (val) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text(
                            'Local Government Unit (LGU) Concern',
                          ),
                          content: const Text(
                            'Maaari po kayong humingi ng tulong sa inyong Local Government Unit (LGU) para sa ganitong uri ng streetlight concern.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                setState(() {
                                  _selectedIncidentType = null;
                                  _isIselcoPole = null;
                                  _selectedSpecificConcern = null;
                                  _poleNumberController.clear();
                                });
                              },
                              child: const Text(
                                'OK',
                                style: TextStyle(color: Colors.blueAccent),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            _buildLabel('ISELCO-I Pole Number (Optional)'),
            _buildTextField(
              controller: _poleNumberController,
              hint: 'e.g. 123456',
              icon: Icons.numbers,
            ),
          ],

          if (_selectedIncidentType != null) ...[
            const SizedBox(height: 20),
            _buildLabel(
              _selectedIncidentType == 'Street Light'
                  ? 'What\'s wrong with the ISELCO-I Street Light?'
                  : (_selectedIncidentType == 'Social Safety'
                        ? 'What is your specific safety concern?'
                        : 'What specific damage do you see or hear?'),
            ),
            _buildDropdown(
              hint: 'Select Specific Detail',
              icon: Icons.info_outline,
              value: _selectedSpecificConcern,
              items: concernOptions,
              onChanged: (val) =>
                  setState(() => _selectedSpecificConcern = val),
            ),
          ],
        ],
      ),
    );
  }

  // =========== TAB 2 LOCATION =========== //
  Widget _buildTab2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('How would you like to report?'),
          _buildDropdown(
            hint: 'Select Method',
            icon: Icons.how_to_reg_outlined,
            value: _selectedReportType,
            items: _reportTypes,
            onChanged: (val) => setState(() => _selectedReportType = val),
          ),

          if (_selectedReportType ==
              'Report using Customer Account Number') ...[
            const SizedBox(height: 20),
            _buildLabel('Customer Account Number'),
            _buildTextField(
              controller: _accountNumberController,
              hint: '10-digit account number',
              icon: Icons.person_outline,
              keyboardType: TextInputType.number,
            ),
          ],

          if (_selectedReportType == 'Report Address') ...[
            const SizedBox(height: 20),
            _buildLabel('Town/Municipality'),
            _buildDynamicDropdown(
              hint: _isLoadingTowns ? 'Loading towns...' : 'Select Town',
              icon: Icons.location_city_outlined,
              value: _selectedTownId,
              items: _towns.map<DropdownMenuItem<String>>((val) {
                return DropdownMenuItem<String>(
                  value: val['id'].toString(),
                  child: Text(
                    val['townName'] ?? '',
                    style: const TextStyle(color: Colors.black87),
                  ),
                );
              }).toList(),
              onChanged: (newVal) {
                if (newVal != null && newVal != _selectedTownId) {
                  setState(() => _selectedTownId = newVal);
                  _fetchBarangays(newVal);
                }
              },
            ),

            const SizedBox(height: 15),
            _buildLabel('Barangay'),
            _buildDynamicDropdown(
              hint: _isLoadingBarangays
                  ? 'Loading barangays...'
                  : 'Select Barangay',
              icon: Icons.map_outlined,
              value: _selectedBarangayId,
              items: _barangays.map<DropdownMenuItem<String>>((val) {
                return DropdownMenuItem<String>(
                  value: val['id'].toString(),
                  child: Text(
                    val['barangayName'] ?? '',
                    style: const TextStyle(color: Colors.black87),
                  ),
                );
              }).toList(),
              onChanged: (newVal) => setState(() {
                _selectedBarangayId = newVal;
                _validateForm();
              }),
              disabled: _selectedTownId == null || _isLoadingBarangays,
            ),

            const SizedBox(height: 15),
            _buildLabel('Sitio/Street (Optional)'),
            _buildTextField(
              controller: _sitioController,
              hint: 'Enter Sitio or Street',
              icon: Icons.streetview,
            ),
          ],
        ],
      ),
    );
  }

  // =========== TAB 3 MAP & LANDMARK =========== //
  Widget _buildTab3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'To better locate your concern, please provide at least one of the following. Providing this information will help our crew find your location.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          _buildLabel('Landmarks and Directions *'),
          _buildTextField(
            controller: _landmarksController,
            hint: 'Describe nearby landmarks...',
            maxLines: 4,
            maxLength: 1000,
          ),
        ],
      ),
    );
  }

  // =========== TAB 4 ATTACHMENT =========== //
  Widget _buildTab4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Write a message (Optional)'),
          _buildTextField(
            controller: _messageController,
            hint: 'Anything else we should know?',
            maxLines: 5,
            maxLength: 1000,
          ),
          const SizedBox(height: 20),
          _buildLabel('Add Attachment (Optional)'),
          InkWell(
            onTap: () => _pickImage(ImageSource.gallery),
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      _selectedImage != null
                          ? Icons.image_outlined
                          : Icons.upload_file,
                      color: _selectedImage != null
                          ? Colors.blueAccent
                          : Colors.black54,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _selectedImage != null
                          ? _selectedImage!.name
                          : 'Upload File / Image',
                      style: TextStyle(
                        color: _selectedImage != null
                            ? Colors.blueAccent
                            : Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_selectedImage != null)
            Container(
              margin: const EdgeInsets.only(top: 15),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.image, color: Colors.blueAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedImage!.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.redAccent),
                    onPressed: () => setState(() => _selectedImage = null),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // =========== TAB 5 CONTACT =========== //
  Widget _buildTab5() {
    if (_isLoadingUser) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Please review your contact details below. We will use this information to update you regarding your report.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 30),
          _buildContactInfoTile(Icons.person, 'Full Name', _userName),
          const SizedBox(height: 15),
          _buildContactInfoTile(Icons.email, 'Email Address', _userEmail),
          const SizedBox(height: 15),
          _buildContactInfoTile(Icons.phone, 'Mobile Number', _userPhone),
        ],
      ),
    );
  }

  Widget _buildContactInfoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========== WIDGET HELPERS =========== //
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 5),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blueAccent.withOpacity(0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DropdownButtonFormField<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          items: items.map((val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(
                val,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          icon: Icon(
            Icons.arrow_drop_down_circle_outlined,
            color: Colors.blueAccent.shade700,
            size: 20,
          ),
          isExpanded: true,
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.blueAccent.shade700, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicDropdown({
    required String hint,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    bool disabled = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: disabled ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: disabled
              ? Colors.grey.shade300
              : Colors.blueAccent.withOpacity(0.3),
          width: 1.2,
        ),
        boxShadow: disabled
            ? []
            : [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.05),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DropdownButtonFormField<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              color: disabled ? Colors.grey.shade400 : Colors.grey.shade400,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          items: items,
          onChanged: disabled ? null : onChanged,
          icon: Icon(
            Icons.arrow_drop_down_circle_outlined,
            color: disabled ? Colors.grey.shade400 : Colors.blueAccent.shade700,
            size: 20,
          ),
          isExpanded: true,
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: disabled
                  ? Colors.grey.shade400
                  : Colors.blueAccent.shade700,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black54),
          prefixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
          border: InputBorder.none,
          counterText: "", // Hide character counter below field
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
