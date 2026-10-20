import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:safebook/constants/api_constants.dart';
import 'package:safebook/screens/admin_home_page.dart';
import 'package:safebook/screens/confirm_email.dart';

import 'package:safebook/screens/forgot_password_screen.dart';
import 'package:safebook/screens/user_home_page.dart';
import 'package:safebook/widgets/continuation_button.dart';
import 'package:safebook/widgets/input_field.dart';

import 'package:http/http.dart' as https;

class AuthenticationScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  bool isSignIn = true;
  bool passwordObscure = false;
  bool confirmpasswordObscure = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _authenticationKey = GlobalKey<FormState>();

  bool _isAuthenticating = false;

  Future<void> _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password.')),
      );
      return;
    }

    try {
      final response = await https.post(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/signup'),
        headers: {'Content-Type': 'application/json', 'Accept': 'text/plain'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      debugPrint('SIGNUP STATUS: ${response.statusCode}');
      debugPrint('SIGNUP BODY: ${response.body}');
      print('SIGNUP URL: ${ApiConstants.signup}');
      print('SIGNUP METHOD: POST');

      if (!mounted) return;

      if (response.statusCode == 201) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ConfirmEmail(email: email)),
        );
      } else {
        final message = response.body.trim().isNotEmpty
            ? response.body
            : 'Signup failed. Please try again.';

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      debugPrint('SIGNUP ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not connect to the server. Check your connection.',
          ),
        ),
      );
    }
  }

  Future<void> _signin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password.')),
      );
      return;
    }

    try {
      final response = await https.post(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      debugPrint('SIGNIN STATUS: ${response.statusCode}');
      debugPrint('SIGNIN BODY: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        final token = data['token'] as String?;
        final role = data['role'] as String?;

        if (token == null || token.isEmpty || role == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid response from server.')),
          );
          return;
        }

        // Store the token securely before accessing protected endpoints.

        if (role == 'ADMIN' || role == 'SUPER_ADMIN') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminHomePage(token: token),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UserHomePage(token: token)),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.body.trim().isNotEmpty
                  ? response.body
                  : 'Sign in failed. Please check your credentials.',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('SIGNIN ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not connect to the server.')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Form(
            key: _authenticationKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/SafeBook Logo.png',
                  width: 100,
                  height: 100,
                ),

                SizedBox(height: 20),
                Text('SafeBook', style: Theme.of(context).textTheme.bodyMedium),
                SizedBox(height: 20),

                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(3),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isSignIn = true;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSignIn
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.all(6),
                            child: Text("Sign In", textAlign: TextAlign.center),
                          ),
                        ),
                      ),

                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isSignIn = false;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSignIn
                                  ? Colors.transparent
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.all(6),
                            child: Text("Sign Up", textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),

                //Email input box
                InputField(
                  title: "Email",
                  hintText: "feedbackarena@gmail.com",
                  prefixIcon: Icons.email_outlined,
                  controller: _emailController,
                  validator: (value) {
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (value == null || value.isEmpty) {
                      return "Please enter your email";
                    }
                    if (!emailRegex.hasMatch(value)) {
                      return "Please enter a valid email";
                    }
                    return null;
                  },
                ),

                //Create Password and password for login Box
                InputField(
                  title: isSignIn ? "Password" : "Create Password",
                  hintText: "password",
                  prefixIcon: Icons.lock_clock_outlined,
                  isPassword: true,
                  controller: _passwordController,
                  furtherActionRequired: isSignIn,
                  furtherAction: "Forgot Password?",
                  obscureText: passwordObscure,
                  iconOnPressed: () {
                    setState(() {
                      passwordObscure = !passwordObscure;
                    });
                  },
                  action: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotPasswordScreen(),
                      ),
                    );
                  },
                  validator: (value) {
                    final capitalLetterRegex = RegExp(r'[A-Z]');
                    final smallLetterRegex = RegExp(r'[a-z]');
                    final numberRegex = RegExp(r'[0-9]');
                    final symbolRexegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
                    if (value == null || value.isEmpty) {
                      return "Please enter your password";
                    }
                    if (value.length < 8) {
                      return "Password must be at least 8 characters long";
                    }
                    if (!capitalLetterRegex.hasMatch(value)) {
                      return "Capital letter required in password";
                    }
                    if (!smallLetterRegex.hasMatch(value)) {
                      return "Small letter required in password";
                    }
                    if (!numberRegex.hasMatch(value)) {
                      return "Number required in password";
                    }
                    if (!symbolRexegex.hasMatch(value)) {
                      return "Symbol required in password";
                    }
                    return null;
                  },
                ),

                //Confirm Password Box
                !isSignIn
                    ? InputField(
                        title: "Confirm Password",
                        hintText: "password",
                        prefixIcon: Icons.lock_clock_outlined,
                        controller: _confirmPasswordController,
                        obscureText: confirmpasswordObscure,
                        iconOnPressed: () {
                          setState(() {
                            confirmpasswordObscure = !confirmpasswordObscure;
                          });
                        },
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Confirm your password";
                          }
                          if (value != _passwordController.text.trim()) {
                            return "Passwords are not matching";
                          }
                          return null;
                        },
                      )
                    : SizedBox.shrink(),

                SizedBox(height: 20),

                // Sign up or Sign In Button
                ContinuationButton(
                  continuationText: _isAuthenticating
                      ? (isSignIn ? 'Signing In...' : 'Signing Up...')
                      : (isSignIn ? 'Sign In' : 'Sign Up'),

                  onTap: _isAuthenticating
                      ? null
                      : isSignIn
                      ? _signin
                      : _signup,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
