import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_services.dart';
import '../../services/notification_service.dart';
import 'branch_map_screen.dart';
import '../more_screen/contact_us/contact_us_screen.dart';
import '../more_screen/about_us/vision_mission/vision_mission_screen.dart';
import '../more_screen/about_us/corporate_values/corporate_values_screen.dart';
import '../more_screen/about_us/history/history_screen.dart';
import '../more_screen/about_us/board_of_directors/directory_screen.dart';
import '../more_screen/about_us/management/management_screen.dart';
import '../more_screen/incident_report/incident_report_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isBiometricEnabled = false;
  String _authToken = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _authToken = prefs.getString('auth_token') ?? '';
      _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    });
  }

  void _showUpdatePasswordDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black45, // Slightly dim the background too
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: const _UpdatePasswordDialog(),
        );
      },
    );
  }

  Future<void> _handleMenuItemTap(VoidCallback onSuccess) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );

    // Simulate network or processing delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    // Dismiss loading indicator
    Navigator.of(context).pop();

    // Execute the action
    onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 25.0, bottom: 85.0),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          // Biometric Enable/Disable
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Enable Biometric Login'),
            secondary: const Icon(Icons.fingerprint, color: Colors.blueAccent),
            value: _isBiometricEnabled,
            onChanged: (bool value) async {
              if (value) {
                // If turning ON, show password prompt
                _promptBiometricPassword(value);
              } else {
                // If turning OFF, just toggle it
                _toggleBiometric(value, null);
              }
            },
          ),
          Divider(
            color: Colors.black.withValues(alpha: 0.5),
            height: 1,
            thickness: 1,
          ),
          // Update Password
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lock_outline, color: Colors.blueAccent),
            title: const Text('Reset Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _handleMenuItemTap(() {
                _showUpdatePasswordDialog();
              });
            },
          ),
          Divider(
            color: Colors.black.withValues(alpha: 0.5),
            height: 1,
            thickness: 1,
          ),
          const SizedBox(height: 20),
          const Text(
            'Information & Support',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          // ISELCO-I Branch Office
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.location_on_outlined,
              color: Colors.blueAccent,
            ),
            title: const Text('ISELCO-I Branch Office'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _handleMenuItemTap(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BranchMapScreen(),
                  ),
                );
              });
            },
          ),
          Divider(
            color: Colors.black.withValues(alpha: 0.5),
            height: 1,
            thickness: 1,
          ),
          // Brownout and Incidents
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.warning_amber_outlined,
              color: Colors.amber,
            ),
            title: const Text('Brownout and Incidents'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _handleMenuItemTap(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IncidentReportScreen(),
                  ),
                );
              });
            },
          ),
          Divider(
            color: Colors.black.withValues(alpha: 0.5),
            height: 1,
            thickness: 1,
          ),
          // Contact Us
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.contact_support_outlined,
              color: Colors.blueAccent,
            ),
            title: const Text('Contact Us'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _handleMenuItemTap(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactUsScreen(),
                  ),
                );
              });
            },
          ),
          Divider(
            color: Colors.black.withValues(alpha: 0.5),
            height: 1,
            thickness: 1,
          ),
          // About Us Menu -- Naging Dropdown ulit pero mas maganda
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              leading: const Icon(Icons.info_outline, color: Colors.blueAccent),
              title: const Text('About Us'),
              childrenPadding: const EdgeInsets.only(left: 10, bottom: 8),
              children: [
                _buildSubMenuItem(
                  title: 'History',
                  icon: Icons.history_edu,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryScreen(),
                    ),
                  ),
                ),
                _buildSubMenuItem(
                  title: 'Vision Mission',
                  icon: Icons.visibility_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VisionMissionScreen(),
                    ),
                  ),
                ),
                _buildSubMenuItem(
                  title: 'Corporate Values',
                  icon: Icons.diamond_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CorporateValuesScreen(),
                    ),
                  ),
                ),
                _buildSubMenuItem(
                  title: 'Board of Directors',
                  icon: Icons.groups_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DirectoryScreen(
                        title: "Board of Directors",
                        category: "board",
                      ),
                    ),
                  ),
                ),
                _buildSubMenuItem(
                  title: 'ISELCO-I Management',
                  icon: Icons.manage_accounts_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManagementScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.black.withValues(alpha: 0.5),
            height: 1,
            thickness: 1,
          ),
          // Payment Center
          Tooltip(
            message: 'Soon',
            triggerMode: TooltipTriggerMode.tap,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.grey.shade400,
              ),
              title: Text(
                'Payment Center',
                style: TextStyle(color: Colors.grey.shade500),
              ),
              trailing: Icon(Icons.chevron_right, color: Colors.grey.shade300),
              onTap: null, // Disabled
            ),
          ),
        ],
      ),
    );
  }

  void _promptBiometricPassword(bool enable) {
    TextEditingController passwordController = TextEditingController();
    bool isObscured = true;

    showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: AlertDialog(
                title: const Text('Confirm Password'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Please enter your password to enable biometric login.',
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: isObscured,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isObscured
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setModalState(() {
                              isObscured = !isObscured;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      String pwd = passwordController.text;
                      if (pwd.isEmpty) return;
                      Navigator.pop(context);
                      _toggleBiometric(enable, pwd);
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _toggleBiometric(bool enable, String? password) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );

    try {
      var response = await ApiServices().toggleBiometric(
        _authToken,
        enable,
        password: password,
      );
      if (mounted) Navigator.of(context).pop(); // Close loading

      if (response['success'] == true) {
        setState(() {
          _isBiometricEnabled = enable;
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('biometric_enabled', enable);

        if (mounted) {
          NotificationService().addNotification(
            response['message'] ?? 'Successfully updated.',
          );
        }
      } else {
        if (mounted) {
          if (response['message'] == 'Incorrect password.') {
            NotificationService().addNotification(
              'Incorrect password. Please try again.',
            );
          } else {
            NotificationService().addNotification(
              response['message'] ?? 'Failed to update.',
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        NotificationService().addNotification('Network error.');
      }
    }
  }

  // Helper widget para sa magagandang sub menu ng About Us dropdown
  Widget _buildSubMenuItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      minLeadingWidth: 20,
      leading: Icon(icon, size: 20, color: Colors.black54),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(
        Icons.chevron_right,
        size: 16,
        color: Colors.black26,
      ),
      onTap: () {
        _handleMenuItemTap(onTap);
      },
    );
  }
}

class _UpdatePasswordDialog extends StatefulWidget {
  const _UpdatePasswordDialog();

  @override
  State<_UpdatePasswordDialog> createState() => _UpdatePasswordDialogState();
}

class _UpdatePasswordDialogState extends State<_UpdatePasswordDialog> {
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureRetype = true;
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _retypePasswordController =
      TextEditingController();
  bool _isLoading = false;

  void _submitUpdate() async {
    if (_newPasswordController.text != _retypePasswordController.text) {
      NotificationService().addNotification('New passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      var response = await ApiServices().changePassword(
        token,
        _oldPasswordController.text,
        _newPasswordController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response['success'] == true) {
          Navigator.of(context).pop();
          NotificationService().addNotification(
            'Password updated successfully.',
          );
        } else {
          NotificationService().addNotification(
            response['message'] ?? 'Failed to update password.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        NotificationService().addNotification(
          'Network error. Please try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Update Password',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Old Password
            TextField(
              controller: _oldPasswordController,
              obscureText: _obscureOld,
              decoration: InputDecoration(
                labelText: 'Old Password',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureOld ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureOld = !_obscureOld;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            // New Password
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNew = !_obscureNew;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Re-type Password
            TextField(
              controller: _retypePasswordController,
              obscureText: _obscureRetype,
              decoration: InputDecoration(
                labelText: 'Re-type Password',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureRetype ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureRetype = !_obscureRetype;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: const BorderSide(color: Colors.grey),
                  foregroundColor: Colors.black87,
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitUpdate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Reset Password', textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
