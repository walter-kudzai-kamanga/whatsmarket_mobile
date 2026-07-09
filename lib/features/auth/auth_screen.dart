import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/api/whatsmarket_api.dart';
import '../../core/auth/session.dart';
import '../../core/theme/app_colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.onSignedIn});

  final VoidCallback onSignedIn;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final WhatsMarketApi _api = WhatsMarketApi();
  final Session _session = Session();

  bool _isLogin = true;
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
    if (_formKey.currentState?.validate() ?? false) {
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
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.beigeLight,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 20,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo/Brand Section
                          _buildBrandSection(),

                          const SizedBox(height: 24),

                          // Toggle between Login/Register
                          //      _buildToggleButtons(),
                          const SizedBox(height: 20),

                          // Form Container
                          Form(
                            key: _formKey,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryGreen.withOpacity(
                                      0.08,
                                    ),
                                    blurRadius: 30,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                                border: Border.all(
                                  color: AppColors.beigeDark.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Welcome Text
                                  _buildWelcomeText(),

                                  const SizedBox(height: 20),

                                  // Name Field (Register only)
                                  if (!_isLogin) ...[
                                    _buildField(
                                      label: 'Full Name',
                                      controller: _name,
                                      icon: CupertinoIcons.person,
                                      keyboardType: TextInputType.name,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().length < 2) {
                                          return 'Enter your full name';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 14),
                                    _buildField(
                                      label: 'Email Address',
                                      controller: _email,
                                      icon: CupertinoIcons.mail,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Enter your email';
                                        }
                                        if (!RegExp(
                                          r'^[^@]+@[^@]+\.[^@]+$',
                                        ).hasMatch(value)) {
                                          return 'Enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 14),
                                  ],

                                  // Phone Field
                                  _buildField(
                                    label: 'Phone Number',
                                    controller: _phone,
                                    icon: CupertinoIcons.phone,
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Enter your phone number';
                                      }
                                      if (value.trim().length < 8) {
                                        return 'Phone number too short';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 14),

                                  // Password Field
                                  _buildPasswordField(),

                                  const SizedBox(height: 12),

                                  // Remember Me & Forgot Password
                                  _buildOptionsRow(),

                                  const SizedBox(height: 8),

                                  // Error message
                                  if (_error != null) _buildErrorWidget(),

                                  const SizedBox(height: 8),

                                  // Submit Button
                                  _buildSubmitButton(),

                                  const SizedBox(height: 16),

                                  // Divider
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Divider(thickness: 0.5),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Text(
                                          'or continue with',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        child: Divider(thickness: 0.5),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Social Login Buttons
                                  _buildSocialButtons(),

                                  const SizedBox(height: 12),

                                  // Switch between Login/Register
                                  _buildSwitchAccountButton(),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Footer
                          _buildFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBrandSection() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryGreen,
                AppColors.primaryGreen.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              CupertinoIcons.shopping_cart,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WhatsMarket',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryGreen,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Local Marketplace',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildToggleOption('Sign In', true, _isLogin),
          _buildToggleOption('Register', false, !_isLogin),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, bool isLogin, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!_loading) {
            setState(() {
              _isLogin = isLogin;
              _error = null;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isLogin ? 'Welcome Back! ' : 'Create Account ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryGreen,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _isLogin
              ? 'Sign in to access your dashboard'
              : 'Start your journey with WhatsMarket',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
        filled: true,
        fillColor: AppColors.beigeLight.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.beigeDark.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _password,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: const Icon(
          CupertinoIcons.lock,
          color: AppColors.primaryGreen,
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
            color: Colors.grey[500],
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: AppColors.beigeLight.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.beigeDark.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _rememberMe = !_rememberMe),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _rememberMe
                          ? AppColors.primaryGreen
                          : Colors.transparent,
                      border: Border.all(
                        color: _rememberMe
                            ? AppColors.primaryGreen
                            : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: _rememberMe
                        ? const Icon(Icons.check, color: Colors.white, size: 12)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Remember me',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_isLogin)
          GestureDetector(
            onTap: () {
              // TODO: Implement forgot password
            },
            child: Text(
              'Forgot password?',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: CupertinoButton(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(14),
        onPressed: _loading ? null : _submit,
        child: _loading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isLogin ? 'Signing in...' : 'Creating account...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                _isLogin ? 'Sign In' : 'Create Account',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          icon: CupertinoIcons.phone,
          color: Colors.red,
          label: 'Google',
          onTap: () {
            // TODO: Implement Google Sign In
          },
        ),
        const SizedBox(width: 16),
        _buildSocialButton(
          icon: CupertinoIcons.wand_rays,
          color: Color(0xFF1877F2),
          label: 'Facebook',
          onTap: () {
            // TODO: Implement Facebook Sign In
          },
        ),
        const SizedBox(width: 16),
        _buildSocialButton(
          icon: CupertinoIcons.app,
          color: Colors.black,
          label: 'Apple',
          onTap: () {
            // TODO: Implement Apple Sign In
          },
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: Icon(icon, color: color, size: 24)),
      ),
    );
  }

  Widget _buildSwitchAccountButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin ? "Don't have an account?" : 'Already have an account?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: _loading
              ? null
              : () => setState(() {
                  _isLogin = !_isLogin;
                  _error = null;
                  _formKey.currentState?.reset();
                }),
          child: Text(
            _isLogin ? 'Sign Up' : 'Sign In',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        'By continuing, you agree to our Terms of Service\nand Privacy Policy',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, color: Colors.grey[500], height: 1.5),
      ),
    );
  }
}
