import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/api/whatsmarket_api.dart';
import '../../core/auth/session.dart';
import '../../core/theme/app_colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.onSignedIn});

  final VoidCallback onSignedIn;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final WhatsMarketApi _api = WhatsMarketApi();
  final Session _session = Session();

  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _validate() {
    final phone = _phone.text.trim();
    final password = _password.text;

    if (!_isLogin) {
      if (_name.text.trim().length < 2) {
        return 'Enter your full name.';
      }
      final email = _email.text.trim();
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
        return 'Enter a valid email address.';
      }
    }

    if (phone.length < 8 || !RegExp(r'^\+?[0-9 ]+$').hasMatch(phone)) {
      return 'Enter a valid phone number.';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    return null;
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('401')) {
      return 'Invalid phone or password.';
    }
    if (msg.contains('409') || msg.toLowerCase().contains('already')) {
      return 'This account already exists. Try signing in.';
    }
    if (msg.contains('400')) {
      return 'Please check your details and try again.';
    }
    return 'Could not connect right now. Please try again.';
  }

  Future<void> _submit() async {
    final validationError = _validate();
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isLogin) {
        final res = await _api.login(
          phone: _phone.text.trim(),
          password: _password.text,
        );
        final token = '${res['token'] ?? ''}';
        final user = (res['user'] as Map?)?.cast<String, dynamic>();
        await _session.save(
          token: token,
          phone: '${user?['phone'] ?? _phone.text.trim()}',
          name: '${user?['name'] ?? ''}',
        );
      } else {
        final res = await _api.register(
          name: _name.text.trim(),
          phone: _phone.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
          role: 'customer',
        );
        final token = '${res['token'] ?? ''}';
        final user = (res['user'] as Map?)?.cast<String, dynamic>();
        await _session.save(
          token: token,
          phone: '${user?['phone'] ?? _phone.text.trim()}',
          name: '${user?['name'] ?? _name.text.trim()}',
        );
      }

      if (!mounted) return;
      widget.onSignedIn();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beigeLight,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLogin ? 'Welcome back' : 'Create your account',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isLogin
                        ? 'Sign in to view your bookings and marketplace.'
                        : 'Register to book nearby services and compare products.',
                    style: TextStyle(color: Colors.white.withOpacity(0.85)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.beigeDark),
              ),
              child: Column(
                children: [
                  if (!_isLogin) ...[
                    _Field(label: 'Full name', controller: _name, icon: CupertinoIcons.person),
                    const SizedBox(height: 10),
                    _Field(label: 'Email', controller: _email, icon: CupertinoIcons.mail),
                    const SizedBox(height: 10),
                  ],
                  _Field(label: 'Phone', controller: _phone, icon: CupertinoIcons.phone),
                  const SizedBox(height: 10),
                  _Field(
                    label: 'Password',
                    controller: _password,
                    icon: CupertinoIcons.lock,
                    obscure: true,
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(14),
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(_isLogin ? 'Sign in' : 'Create account'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => setState(() {
                              _isLogin = !_isLogin;
                              _error = null;
                            }),
                    child: Text(
                      _isLogin ? 'No account? Register' : 'Already have an account? Sign in',
                      style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700),
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
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.icon,
    this.obscure = false,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryGreen),
        filled: true,
        fillColor: AppColors.beigeLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}

