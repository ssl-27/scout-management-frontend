import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _authService = AuthService();
  bool _canResendOtp = false;
  Timer? _resendOtpTimer;
  bool _isOtpSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout
          if (constraints.maxWidth > 600) {
            return _buildWideLayout();
          } else {
            return _buildNarrowLayout();
          }
        },
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        // Left side - Image/Logo
        Expanded(
          flex: 1,
          child: Container(
            color: Theme.of(context).primaryColor,
            child: Center(
              child: Image.asset(
                'assets/logo.png', // You'll need to add this
                width: 200,
              ),
            ),
          ),
        ),
        // Right side - Login Form
        Expanded(
          flex: 1,
          child: _buildLoginForm(),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 200,
            color: Theme.of(context).primaryColor,
            child: Center(
              child: Image.asset(
                'assets/logo.png',
                width: 150,
              ),
            ),
          ),
          _buildLoginForm(),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome to Scout Management Information System',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            enabled: !_isOtpSent,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          if (_isOtpSent) ...[
            TextFormField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: 'OTP',
                prefixIcon: Icon(Icons.lock),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
          ],
          ElevatedButton(
            onPressed: _isOtpSent ? _verifyOtp : _requestOtp,
            child: Text(_isOtpSent ? 'Verify OTP' : 'Request OTP'),
          ),

          if (_isOtpSent && !_canResendOtp) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: null,
              child: const Text('Resend OTP (3 mins)'),
            ),
          ],
          if (_isOtpSent && _canResendOtp) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _requestOtp,
              child: const Text('Resend OTP'),
            ),
          ],
        ],
      ),
    );
  }


  Future<void> _requestOtp() async {
    try {
      await _authService.requestOtp(_emailController.text);
      setState(() {
        _isOtpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent to your email')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send OTP')),
      );
    }
  }

  Future<void> _verifyOtp() async {
    try {
      await context.read<AuthProvider>().verifyOtp(
        _emailController.text,
        _otpController.text,
      );
      // Navigation will be handled automatically by AuthWrapper
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}