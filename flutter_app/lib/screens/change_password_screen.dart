/**
 * ============================================================================
 * CHANGE PASSWORD SCREEN - First-Time Login Password Setup
 * ============================================================================
 *
 * WHAT THIS FILE DOES:
 * - Forces new users to change their default password on first login
 * - Validates password strength (minimum 8 characters)
 * - Confirms password matches
 * - Calls backend API to update password
 *
 * WHY IT EXISTS:
 * - Security: Default passwords are insecure
 * - Forces users to set a personal, secure password
 * - Prevents unauthorized access with default credentials
 *
 * WHERE IT'S USED:
 * - Called from login_screen.dart when isFirstLogin or mustChangePassword is true
 * - Blocks access to member dashboard until password is changed
 *
 * HOW IT WORKS:
 * 1. User logs in with default password
 * 2. Backend returns isFirstLogin: true
 * 3. This screen is shown instead of dashboard
 * 4. User enters current (default) password and new password
 * 5. Validates and submits to /v1/auth/change-password
 * 6. On success, redirects to member dashboard
 * ============================================================================
 */

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'booking_history_screen.dart';

/// Change Password Screen for first-time login users
class ChangePasswordScreen extends StatefulWidget {
  // "JWT token for authentication"
  // WHAT: Authentication token received from login
  // WHY: Required to call protected API endpoints
  // WHERE: Passed from login_screen.dart
  final String token;

  // "Default password user used to log in"
  // WHAT: The current password (default password)
  // WHY: Required by backend to verify user before password change
  // WHERE: Passed from login_screen.dart
  final String defaultPassword;

  const ChangePasswordScreen({
    Key? key,
    required this.token,
    required this.defaultPassword,
  }) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // "Form key for validation"
  // WHAT: GlobalKey to manage form state and validation
  // WHY: Enables form.validate() to check all fields at once
  final _formKey = GlobalKey<FormState>();

  // "Text controllers for input fields"
  // WHAT: Controllers to get text from TextFormField widgets
  // WHY: Needed to read user input when submitting form
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // "Password visibility toggles"
  // WHAT: Boolean flags to show/hide password text
  // WHY: Security - hide passwords by default, allow user to reveal
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // "Submission state flag"
  // WHAT: Boolean to track if form is being submitted
  // WHY: Show loading indicator and prevent double-submission
  bool _isSubmitting = false;

  @override
  void dispose() {
    // "Clean up controllers when screen is disposed"
    // WHAT: Release memory used by text controllers
    // WHY: Prevents memory leaks in Flutter
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Submit password change to backend API
  Future<void> _submitPasswordChange() async {
    // "Validate form before submission"
    // WHAT: Runs all validators in the form
    // WHY: Ensure all fields are valid before API call
    // RETURNS: false if any field is invalid
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // "Set loading state"
    // WHAT: Update UI to show loading indicator
    // WHY: Provides feedback to user that submission is in progress
    setState(() {
      _isSubmitting = true;
    });

    try {
      // "Make HTTP POST request to change password endpoint"
      // WHAT: Calls backend API at /v1/auth/change-password
      // WHY: Updates user password in database
      // HEADERS: Authorization with JWT token, Content-Type JSON
      // BODY: currentPassword (default) and newPassword
      final response = await http.post(
        Uri.parse('http://localhost:3000/v1/auth/change-password'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'currentPassword': widget.defaultPassword,
          'newPassword': _newPasswordController.text,
        }),
      );

      // "Stop loading state"
      setState(() {
        _isSubmitting = false;
      });

      // "Check if password change was successful"
      // WHAT: Checks HTTP status code
      // WHY: 200 = success, anything else = error
      if (response.statusCode == 200) {
        // "Show success message"
        // WHAT: Display green snackbar with success message
        // WHY: User feedback that operation completed
        _showSuccess('Password changed successfully! Redirecting to dashboard...');

        // "Wait 1.5 seconds then navigate to member dashboard"
        // WHAT: Delay to let user read success message
        // WHY: Better UX than instant redirect
        await Future.delayed(Duration(milliseconds: 1500));

        // "Navigate to member dashboard"
        // WHAT: Replace current screen with dashboard
        // WHY: User has completed first-time setup, can now access app
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingHistoryScreen(token: widget.token),
          ),
        );
      } else {
        // "Parse error response"
        // WHAT: Extract error message from JSON response
        // WHY: Show specific error to user
        final error = jsonDecode(response.body);
        _showError(error['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      // "Handle network or unexpected errors"
      // WHAT: Catch any errors during API call
      // WHY: Prevents app crash, shows user-friendly message
      setState(() {
        _isSubmitting = false;
      });
      _showError('Error: $e');
    }
  }

  /// Show success message as green snackbar
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Show error message as red snackbar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // "Dark background color matching app theme"
      backgroundColor: Color(0xFF0a0e1a),

      // "App bar with title"
      appBar: AppBar(
        backgroundColor: Color(0xFF1a1f35),
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.lock_reset, color: Color(0xFFff6b00)),
            SizedBox(width: 12),
            Text(
              'Set New Password',
              style: TextStyle(
                color: Color(0xFFff6b00),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        // "Disable back button"
        // WHY: User must change password before accessing app
        automaticallyImplyLeading: false,
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Container(
            constraints: BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // "Security icon"
                  Icon(
                    Icons.security,
                    size: 80,
                    color: Color(0xFFff6b00),
                  ),
                  SizedBox(height: 24),

                  // "Title"
                  Text(
                    'FIRST-TIME LOGIN',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFff6b00),
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),

                  // "Instructions"
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFff6b00).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFFff6b00).withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFFff6b00)),
                        SizedBox(height: 8),
                        Text(
                          'For security reasons, you must change your default password before accessing your account.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),

                  // "New Password field"
                  _buildLabel('New Password'),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter new password (min 8 characters)',
                      hintStyle: TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Color(0xFF1a1f35),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFFff6b00).withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFFff6b00).withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFFff6b00)),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                          color: Color(0xFFff6b00),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'New password is required';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // "Confirm Password field"
                  _buildLabel('Confirm New Password'),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Re-enter new password',
                      hintStyle: TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Color(0xFF1a1f35),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFFff6b00).withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFFff6b00).withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFFff6b00)),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          color: Color(0xFFff6b00),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32),

                  // "Password requirements info"
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: Colors.blue, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Password Requirements:',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        _buildRequirement('Minimum 8 characters'),
                        _buildRequirement('Must match in both fields'),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),

                  // "Submit button"
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitPasswordChange,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFff6b00),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'SET NEW PASSWORD',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
    );
  }

  /// Build label widget for form fields
  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Color(0xFFff6b00),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Build password requirement item
  Widget _buildRequirement(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 24, top: 4),
      child: Row(
        children: [
          Icon(Icons.fiber_manual_record, size: 8, color: Colors.blue),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.blue,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
