import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ApiServices {
  // Environment Flag: Set to true when uploading to PlayStore
  static const bool isProduction = false;

  // Base URL configuration
  static const String devBaseUrl = 'http://192.168.0.143:8000/api';
  static const String prodBaseUrl = 'https://your-hostinger-domain.com/api';

  static const String baseUrl = isProduction ? prodBaseUrl : devBaseUrl;

  /// Helper method na ginagamit natin pampuno ng HTTP headers,
  /// tinutukoy nito na application/json ang format ng dadaloy pabalik at papasok.
  Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Ginagamit ito para humugot ng listahan (GET method) mula sa Database via Laravel API hook.
  /// Madalas itong isinasampa doon sa mga dropdown (ex. fetching Towns at Barangays)
  Future<dynamic> getData(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final response = await http
          .get(url, headers: _getHeaders())
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Successful parse
      } else {
        throw Exception(
          'Failed to load data. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in GET request: $e');
      throw Exception('Network error or server unavailable');
    }
  }

  /// Same as getData but includes authentication token header
  Future<dynamic> getDataWithToken(String endpoint, String token) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final response = await http
          .get(url, headers: _getHeaders(token: token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 404) {
        return jsonDecode(response.body); // Successful parse
      } else {
        throw Exception(
          'Failed to load protected data. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in GET request with token: $e');
      throw Exception('Network error or server unavailable');
    }
  }

  /// Ginagamit ito sa pagpo-post ng mga normal JSON data (POST method) strings.
  /// Simpleng insert / update command sa backend gamit encoded JSON object.
  Future<dynamic> postData(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final response = await http
          .post(url, headers: _getHeaders(), body: jsonEncode(data))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to post data. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in POST request: $e');
      throw Exception('Network error or server unavailable');
    }
  }

  /// Special multipart HTTP Request method.
  /// Kailangan natin ito para maka-pasa hindi lang mga text, kundi pati na rin
  /// yung malalaking File blobs (tulad ng in-upload na ID Image o tapos na PDF).
  Future<dynamic> registerUser(Map<String, String> fields, XFile file) async {
    try {
      final url = Uri.parse('$baseUrl/registration');
      var request = http.MultipartRequest('POST', url);

      // Lagay lahat ng json fields strings
      request.fields.addAll(fields);

      // Ikabit yung in-upload na ID ng user bilang attachment
      request.files.add(
        http.MultipartFile.fromBytes(
          'file', // Ito 'yung pangalan sa backend validation ($request->file('file'))
          await file.readAsBytes(),
          filename: file.name,
        ),
      );

      // Pindot send at maghihintay sa sagot ng server
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 10),
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        debugPrint("Registration Error Body: ${response.body}");
        return jsonDecode(
          response.body,
        ); // Ibato pabalik errors na ginawa ng Validator (e.g. format issues)
      }
    } catch (e) {
      debugPrint('Error in Multi-part Register request: $e');
      throw Exception('Network error or server unavailable');
    }
  }

  /// Espesyal na method kapag magla-login gamit ang Local Database
  Future<dynamic> loginUser(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/login');

      final response = await http
          .post(
            url,
            headers: _getHeaders(),
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      debugPrint('Error in login POST request: $e');
      throw Exception('Network error or server unavailable');
    }
  }

  /// Api endpoint para ma-toggle yung Biometric_enable column natin.
  /// Kailangan ng Token mula sa successful na paglo-login. Humihingi rin ng password kapag enable = true.
  Future<dynamic> toggleBiometric(
    String token,
    bool enable, {
    String? password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/toggle-biometric');
      final Map<String, dynamic> body = {'enable': enable};
      if (enable && password != null) {
        body['password'] = password;
      }

      final response = await http
          .post(
            url,
            headers: _getHeaders(token: token),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error in biometric toggle request: $e');
      throw Exception('Network error or server unavailable');
    }
  }

  /// Api endpoint para makapagpalit ng password.
  Future<dynamic> changePassword(
    String token,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/change-password');
      final response = await http
          .post(
            url,
            headers: _getHeaders(token: token),
            body: jsonEncode({
              'old_password': oldPassword,
              'new_password': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 10));

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error in change password request: $e');
      throw Exception('Network error or server unavailable');
    }
  }

  /// Isang espesyal na simpleng checking API hook papuntang database
  /// para i-verify kung sakaling ginagamit na ba ng iba 'yung in-input na email pa lang.
  Future<bool> checkEmailExists(String email) async {
    try {
      final url = Uri.parse('$baseUrl/check-email');
      final response = await http
          .post(url, headers: _getHeaders(), body: jsonEncode({'email': email}))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['exists'] ??
            false; // ibabalik ay True kung nahanap sa DBMS, False kung wala
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error checking email: $e');
      return false;
    }
  }

  /// Ginagamit ito pam-bukas sa built-in Android Prompt para pumili si Client
  /// ng Google account, matapos makapili kukunin natin ang ID, tapos ite-test
  /// via Backend checkEmailExists kung nagre-rehistro na ba ito.
  Future<Map<String, dynamic>> signInWithGoogleAndCheck() async {
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email']);

      // 🧹 Force log-out kapag pinindot ulit para mapili nila ang gusto nilang account (Hindi auto-login sa luma)
      await googleSignIn.signOut();

      final GoogleSignInAccount? account = await googleSignIn.signIn();

      if (account != null) {
        final String email = account.email;
        final String displayName = account.displayName ?? '';

        bool isExist = await checkEmailExists(email);

        if (isExist) {
          // Kung nandyan na pala user sa db, mag-a-auto redirect 'yan bilang tapos na
          await googleSignIn.signOut();
          return {'status': 'exists', 'email': email};
        } else {
          // Kung bago siya, papasa natin 'yung credentials papuntang Registration Screen
          // pampuno nung UI textfields automatically.
          return {
            'status': 'new_user',
            'email': email,
            'displayName': displayName,
            'id': account.id,
          };
        }
      } else {
        return {
          'status': 'cancelled',
        }; // Kung binack ni user yung google menu list
      }
    } catch (e) {
      debugPrint('Error sa Google Sign-In backend process: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Fetch user profile details from database
  Future<dynamic> fetchUserProfile(String token) async {
    try {
      final url = Uri.parse('$baseUrl/user');
      final response = await http
          .get(url, headers: _getHeaders(token: token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      throw Exception('Network error or server unavailable');
    }
  }

  /// Api endpoint para kunin ang listahan ng mga hotlines mula sa database.
  /// Kailangan ng Token bilang proteksyon (auth:sanctum middleware).
  Future<dynamic> fetchContacts(String token) async {
    try {
      final url = Uri.parse('$baseUrl/contacts');
      final response = await http
          .get(url, headers: _getHeaders(token: token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(
          response.body,
        ); // Dapat may kasamang 'success' at 'data'
      } else {
        throw Exception(
          'Failed to load contacts. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in fetching contacts: $e');
      throw Exception('Network error or server unavailable');
    }
  }

  /// Api endpoint para kunin ang listahan ng directories (Board of Directors / Management).
  /// Required din ang Token (auth:sanctum).
  Future<dynamic> fetchDirectory(String token, String category) async {
    try {
      final url = Uri.parse('$baseUrl/directories/$category');
      final response = await http
          .get(url, headers: _getHeaders(token: token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // json data array
      } else {
        throw Exception(
          'Failed to load directory. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in fetching directory for category $category: $e');
      throw Exception('Network error or server unavailable');
    }
  }

  /// Api endpoint para kunin ang listahan ng management personnel.
  /// Kailangan ng Token bilang proteksyon (auth:sanctum middleware).
  Future<dynamic> fetchManagement(String token) async {
    try {
      final url = Uri.parse('$baseUrl/management');
      final response = await http
          .get(url, headers: _getHeaders(token: token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // json data object or array
      } else {
        throw Exception(
          'Failed to load management. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in fetching management: $e');
      throw Exception('Network error or server unavailable');
    }
  }

  /// Api endpoint para sa brownout and incident report
  Future<dynamic> submitIncidentReport(
    String token,
    Map<String, String> fields,
    XFile? file,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/incidents');
      var request = http.MultipartRequest('POST', url);

      // Add auth header
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add text fields
      request.fields.addAll(fields);

      // Add file if it exists
      if (file != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            await file.readAsBytes(),
            filename: file.name,
          ),
        );
      }

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        debugPrint("Incident Report Error Body: ${response.body}");
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error in Multi-part Incident request: $e');
      throw Exception('Network error or server unavailable');
    }
  }
}
