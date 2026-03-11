import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/global_background.dart';
import '../services/api_services.dart';
import '../utils/top_snackbar.dart';
import 'login_screen.dart'; // Pandagdag pabalik sa login kapag success

class RegistrationScreen extends StatefulWidget {
  final String? prefilledEmail;
  final String? prefilledName;
  final String? googleId;

  const RegistrationScreen({
    super.key,
    this.prefilledEmail,
    this.prefilledName,
    this.googleId,
  });

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // Page Controller for Tabbing mechanism
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  // TAB 1 Controllers (Basic Info)
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  // TAB 2 Variables (Location Dropdowns)
  List<dynamic> _towns = [];
  List<dynamic> _barangays = [];
  String? _selectedTownId;
  String? _selectedBarangayId;
  final TextEditingController _sitioController = TextEditingController();
  bool _isLoadingTowns = true;
  bool _isLoadingBarangays = false;

  // TAB 3 Controllers (Security)
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // TAB 4 States (Upload & Policy)
  XFile? _selectedFile;
  String? _fileName;
  bool _agreedToPolicy = false;
  bool _agreedToTerms = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.prefilledEmail ?? '');
    _nameController = TextEditingController(text: widget.prefilledName ?? '');

    // Add listeners to trigger reactive UI updates for "NEXT" button enabling
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _accountNumberController.addListener(_validateForm);
    _phoneNumberController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);

    _fetchTowns();
  }

  void _validateForm() {
    setState(() {}); // Unlocks UI state dependencies (e.g., active Next button)
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
      setState(() {
        _isLoadingTowns = false;
      });
      debugPrint('Error fetching towns: $e');
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
      setState(() {
        _isLoadingBarangays = false;
      });
      debugPrint('Error fetching barangays: $e');
    }
    _validateForm(); // Re-validate once lists are fully populated
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _accountNumberController.dispose();
    _phoneNumberController.dispose();
    _sitioController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Passive check validating current tab properties dynamically preventing "Next"
  bool _isCurrentTabValid() {
    if (_currentPage == 0) {
      return _nameController.text.trim().isNotEmpty &&
          _emailController.text.trim().isNotEmpty &&
          _accountNumberController.text.length == 10 &&
          _phoneNumberController.text.length == 11;
    } else if (_currentPage == 1) {
      return _selectedTownId != null && _selectedBarangayId != null;
    } else if (_currentPage == 2) {
      return _passwordController.text.isNotEmpty &&
          _passwordController.text.length >= 8 &&
          _passwordController.text == _confirmPasswordController.text;
    }
    return true; // Kapag nasa Page 4 or undefined
  }

  void _nextPage() {
    FocusScope.of(context).unfocus(); // itago ang keyboard
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

  void _showError(String msg) {
    showTopSnackBar(context, msg, color: Colors.redAccent);
  }

  // Permission and Image/File Picker Logic (Max size: 5MB)
  Future<void> _pickImage(ImageSource source) async {
    source == ImageSource.camera
        ? await Permission.camera.request()
        : await Permission.photos.request();
    final ImagePicker picker = ImagePicker();
    try {
      // Enhanced compression: 85% is the sweet spot for high visual quality (looks original) but low size.
      // Scaling down to 1800px reduces MBs without losing visible crispness.
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1800,
        maxHeight: 1800,
      );
      if (image != null) {
        int sizeInBytes = await image.length();
        double sizeInMb = sizeInBytes / (1024 * 1024);

        if (sizeInMb > 5) {
          _showError('Image file is too large. Maximum size is 5MB.');
          return;
        }

        setState(() {
          _selectedFile = image;
          _fileName = image.name;
        });
        _validateForm();
      }
    } catch (e) {
      _showError('Permission required or action denied: $e');
    }
  }

  Future<void> _pickFile() async {
    await Permission.storage.request();
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );
      if (result != null) {
        PlatformFile pFile = result.files.single;
        int sizeInBytes = pFile.size;
        double sizeInMb = sizeInBytes / (1024 * 1024);

        if (sizeInMb > 5) {
          _showError('Document file is too large. Maximum size is 5MB.');
          return;
        }

        setState(() {
          if (pFile.bytes != null) {
            _selectedFile = XFile.fromData(pFile.bytes!, name: pFile.name);
          } else {
            _selectedFile = XFile(pFile.path!);
          }
          _fileName = pFile.name;
        });
        _validateForm();
      }
    } catch (e) {
      _showError('Storage permission required or action denied: $e');
    }
  }

  // Pang-display ng mga tab page indicators
  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalPages, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 30 : 12,
          height: 10,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Colors.cyanAccent
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
            boxShadow: _currentPage == index
                ? [
                    const BoxShadow(
                      color: Colors.cyanAccent,
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }

  // Main UI
  @override
  Widget build(BuildContext context) {
    bool tabValid = _isCurrentTabValid();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GlobalBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Step Indicators Futuristic
                      _buildStepIndicator(),
                      const SizedBox(height: 20),

                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics:
                              const NeverScrollableScrollPhysics(), // Bawal mag-swipe, Next/Back button pilitin
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
                          ],
                        ),
                      ),

                      // Navigation Buttons at Bottom
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back Button
                            if (_currentPage > 0)
                              TextButton(
                                onPressed: _prevPage,
                                child: const Text(
                                  'BACK',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              const SizedBox(width: 60),

                            // Next or Submit Button
                            if (_currentPage < _totalPages - 1)
                              ElevatedButton(
                                onPressed: tabValid ? _nextPage : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: tabValid
                                      ? Colors.white
                                      : Colors.white12,
                                  foregroundColor: tabValid
                                      ? Colors.blueAccent
                                      : Colors.white30,
                                  elevation: tabValid ? 8 : 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  'NEXT',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              )
                            else
                              ElevatedButton(
                                onPressed:
                                    (_agreedToPolicy &&
                                        _agreedToTerms &&
                                        _selectedFile != null &&
                                        !_isSubmitting)
                                    ? () async {
                                        setState(() {
                                          _isSubmitting = true;
                                        });

                                        Map<String, String> mappedData = {
                                          'fullname': _nameController.text
                                              .trim(),
                                          'email': _emailController.text.trim(),
                                          'account_number':
                                              _accountNumberController.text
                                                  .trim(),
                                          'phone_number': _phoneNumberController
                                              .text
                                              .trim(),
                                          'password': _passwordController.text,
                                          'password_confirmation':
                                              _confirmPasswordController.text,
                                          'town': _selectedTownId ?? '',
                                          'barangay': _selectedBarangayId ?? '',
                                          'sitio': _sitioController.text.trim(),
                                        };

                                        if (widget.googleId != null) {
                                          mappedData['google_id'] =
                                              widget.googleId!;
                                        }

                                        try {
                                          var res = await ApiServices()
                                              .registerUser(
                                                mappedData,
                                                _selectedFile!,
                                              );

                                          if (res['success'] == true) {
                                            if (!mounted) return;
                                            showTopSnackBar(
                                              context,
                                              'Registration submitted! Please wait for approval of your account.',
                                              color: Colors.green,
                                            );
                                            // Clear backstack and Go to Login Screen kapag tapos na
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const LoginScreen(),
                                              ),
                                              (route) => false,
                                            );
                                          } else {
                                            _showError(
                                              res['message'] ??
                                                  'Validation Error',
                                            );
                                          }
                                        } catch (e) {
                                          _showError(
                                            'Failed to register. Please try again.',
                                          );
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              _isSubmitting = false;
                                            });
                                          }
                                        }
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      (_agreedToPolicy &&
                                          _agreedToTerms &&
                                          _selectedFile != null &&
                                          !_isSubmitting)
                                      ? Colors.cyanAccent.shade700
                                      : Colors.white12,
                                  foregroundColor: Colors.white,
                                  elevation:
                                      (_agreedToPolicy &&
                                          _agreedToTerms &&
                                          _selectedFile != null &&
                                          !_isSubmitting)
                                      ? 10
                                      : 0,
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ----------- TABS BUILDERS ----------- //

  Widget _buildTab1() {
    return _pageWrapper(
      title: 'Identification',
      children: [
        _buildField(
          controller: _nameController,
          hint: 'Full Name',
          icon: Icons.person_outline,
          readOnly: true,
        ),
        const SizedBox(height: 15),
        _buildField(
          controller: _emailController,
          hint: 'Email Address',
          icon: Icons.email_outlined,
          readOnly: true,
        ),
        const SizedBox(height: 15),
        _buildField(
          controller: _accountNumberController,
          hint: 'Account Number (10 digits)',
          icon: Icons.numbers_outlined,
          inputType: TextInputType.number,
          formatter: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        const SizedBox(height: 15),
        _buildField(
          controller: _phoneNumberController,
          hint: 'Phone Number (11 digits)',
          icon: Icons.phone_android_outlined,
          inputType: TextInputType.phone,
          formatter: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
        ),
      ],
    );
  }

  Widget _buildTab2() {
    return _pageWrapper(
      title: 'Location',
      children: [
        // Dropdown para sa Town
        _buildDropdown(
          hint: _isLoadingTowns ? 'Loading towns...' : 'Select Town',
          icon: Icons.location_city_outlined,
          value: _selectedTownId,
          items: _towns.map<DropdownMenuItem<String>>((val) {
            bool isSelected = val['id'].toString() == _selectedTownId;
            return DropdownMenuItem<String>(
              value: val['id'].toString(),
              child: Text(
                val['townName'] ?? '',
                style: TextStyle(
                  color: isSelected ? Colors.blueAccent : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
          onChanged: (newVal) {
            if (newVal != null && newVal != _selectedTownId) {
              setState(() {
                _selectedTownId = newVal;
              });
              _fetchBarangays(newVal);
            }
          },
          disabled: _isLoadingTowns,
        ),

        const SizedBox(height: 15),

        // Dropdown para sa Barangay
        _buildDropdown(
          hint: _isLoadingBarangays
              ? 'Loading barangays...'
              : 'Select Barangay',
          icon: Icons.map_outlined,
          value: _selectedBarangayId,
          items: _barangays.map<DropdownMenuItem<String>>((val) {
            bool isSelected = val['id'].toString() == _selectedBarangayId;
            return DropdownMenuItem<String>(
              value: val['id'].toString(),
              child: Text(
                val['barangayName'] ?? '',
                style: TextStyle(
                  color: isSelected ? Colors.blueAccent : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
          onChanged: (newVal) {
            if (newVal != null) {
              setState(() {
                _selectedBarangayId = newVal;
              });
              _validateForm();
            }
          },
          disabled: _selectedTownId == null || _isLoadingBarangays,
        ),

        const SizedBox(height: 15),
        _buildField(
          controller: _sitioController,
          hint: 'Sitio (Optional)',
          icon: Icons.streetview_outlined,
        ),
      ],
    );
  }

  Widget _buildTab3() {
    return _pageWrapper(
      title: 'Security Sync',
      children: [
        _buildField(
          controller: _passwordController,
          hint: 'Enter Password',
          icon: Icons.lock_outline,
          obscure: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.white54,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        const SizedBox(height: 15),
        _buildField(
          controller: _confirmPasswordController,
          hint: 'Re-enter Password',
          icon: Icons.lock_reset_outlined,
          obscure: _obscureConfirm,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirm ? Icons.visibility_off : Icons.visibility,
              color: Colors.white54,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirm = !_obscureConfirm;
              });
            },
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: const [
              Icon(Icons.shield_outlined, color: Colors.cyanAccent, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Password must be at least 8 characters long for optimal protection.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab4() {
    return _pageWrapper(
      title: 'Finalize',
      children: [
        const Text(
          'Please upload a valid ID Photo/File (.jpg, .png, .pdf)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 15),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildUploadButton(
              icon: Icons.camera_alt,
              label: 'Camera',
              onTap: () => _pickImage(ImageSource.camera),
            ),
            _buildUploadButton(
              icon: Icons.photo,
              label: 'Gallery',
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            _buildUploadButton(
              icon: Icons.attach_file,
              label: 'Files',
              onTap: () => _pickFile(),
            ),
          ],
        ),

        const SizedBox(height: 15),
        if (_fileName != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.cyanAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.cyanAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _fileName!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  child: const Icon(Icons.cancel, color: Colors.white54),
                  onTap: () {
                    setState(() {
                      _selectedFile = null;
                      _fileName = null;
                    });
                    _validateForm();
                  },
                ),
              ],
            ),
          ),

        const SizedBox(height: 30),

        // Terms and Conditions Checkbox
        Theme(
          data: ThemeData(unselectedWidgetColor: Colors.white54),
          child: Column(
            children: [
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'I agree to the Terms and Conditions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                value: _agreedToTerms,
                activeColor: Colors.cyanAccent,
                checkColor: Colors.black,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (bool? val) {
                  setState(() {
                    _agreedToTerms = val ?? false;
                  });
                  _validateForm();
                },
              ),
              // ISELCO-I Policy Checkbox
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'I agree to the ISELCO-I Data Privacy Policy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                value: _agreedToPolicy,
                activeColor: Colors.cyanAccent,
                checkColor: Colors.black,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (bool? val) {
                  setState(() {
                    _agreedToPolicy = val ?? false;
                  });
                  _validateForm();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper Widget for consistent padding and titles per tab
  Widget _pageWrapper({required String title, required List<Widget> children}) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 25),
          ...children,
        ],
      ),
    );
  }

  // Upload Buttons Futuristic
  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.cyanAccent, size: 28),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // Custom FormField for consistent UI styling Dropdowns
  Widget _buildDropdown({
    required String hint,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    bool disabled = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: disabled
            ? Colors.black.withOpacity(0.1)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: disabled ? Colors.transparent : Colors.white.withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.any((e) => e.value == value) ? value : null,
          isExpanded: true,
          hint: Row(
            children: [
              Icon(icon, color: disabled ? Colors.white30 : Colors.white70),
              const SizedBox(width: 15),
              Text(
                hint,
                style: TextStyle(
                  color: disabled
                      ? Colors.white30
                      : Colors.white.withOpacity(0.7),
                  fontSize: 15,
                ),
              ),
            ],
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: disabled ? Colors.white30 : Colors.cyanAccent,
          ),
          dropdownColor: Colors.white, // White futuristic dropdown menu
          items: disabled ? [] : items,
          onChanged: disabled ? null : onChanged,
          selectedItemBuilder: (BuildContext context) {
            return items.map<Widget>((DropdownMenuItem<String> item) {
              return Row(
                children: [
                  Icon(icon, color: Colors.cyanAccent),
                  const SizedBox(width: 15),
                  Text(
                    (item.child as Text).data!,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ),
    );
  }

  // Text inputs
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    bool obscure = false,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? formatter,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: readOnly
            ? Colors.black.withOpacity(0.1)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: readOnly ? Colors.transparent : Colors.white.withOpacity(0.3),
        ),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        obscureText: obscure,
        keyboardType: inputType,
        inputFormatters: formatter,
        style: TextStyle(
          color: readOnly ? Colors.white54 : Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(
            icon,
            color: readOnly ? Colors.white30 : Colors.cyanAccent,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
} // End Class
