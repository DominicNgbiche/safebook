import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as https;
import 'package:safebook/constants/api_constants.dart';
import 'package:safebook/screens/authentication_screen.dart';
import 'package:safebook/widgets/continuation_button.dart';
import 'package:safebook/widgets/input_field.dart';

class ConfirmEmail extends StatefulWidget {
  const ConfirmEmail({super.key, required this.email});
  final String email;

  @override
  State<ConfirmEmail> createState() => _ConfirmEmailState();
}

class _ConfirmEmailState extends State<ConfirmEmail> {
  final _codeController = TextEditingController();

  final _confirmationKey = GlobalKey<FormState>();

  bool _isVerifying = false;

  void _verify() async {
    final code = _codeController.text.trim();

    final validVerification = _confirmationKey.currentState!.validate();

    if (!validVerification) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      final verifyResponse = await https.post(
        Uri.parse(ApiConstants.verifyEmail),
        headers: {'Content-Type': 'application/json'},

        body: jsonEncode({'email': widget.email, 'code': code}),
      );

      print('Status: ${verifyResponse.statusCode}');
      print('Body: ${verifyResponse.body}');

      //Successful verification
      if (verifyResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Email verified successfully!"),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthenticationScreen()),
        );
      }
      // Unsuccessful verification
      else {
        final data = jsonDecode(verifyResponse.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Verification failed."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    // Error verifying email
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Something went wrong. Please check your connection and try again.",
          ),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
      );
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Form(
            key: _confirmationKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/FeedbackFlow Logo.png',
                  width: 70,
                  height: 70,
                ),

                SizedBox(height: 20),
                Text(
                  'A 6-digit verification code has been sent to your email. Enter the code below to verify your email address.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: 20),

                //Email input box
                InputField(
                  title: "",
                  hintText: "Enter code here",
                  prefixIcon: null,
                  controller: _codeController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the code here";
                    }
                    return null;
                  },
                ),

                // Verify Button
                ContinuationButton(
                  continuationText: _isVerifying ? 'Verifying...' : 'Verify',
                  onTap: _isVerifying ? null : _verify,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
