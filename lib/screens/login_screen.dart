import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/responsive.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import 'home_screen.dart';

/// Login Screen — Premium dark theme with glassmorphism

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A1A),
              AppTheme.primaryDark,
              Color(0xFF0D1B2A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: r.screenPadding,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      _buildLogo(r),
                      SizedBox(height: r.spacingLG * 1.5),

                      // Login Card
                      _buildLoginCard(r),
                      SizedBox(height: r.spacingMD),

                      // Register link
                      _buildRegisterLink(r),
                      SizedBox(height: r.spacingMD),

                      // Skip button
                      _buildSkipButton(r),
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

  Widget _buildLogo(Responsive r) {
    return Column(
      children: [
        Container(
          width: r.adaptive(small: 70.0, medium: 80.0),
          height: r.adaptive(small: 70.0, medium: 80.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppTheme.accentCyan, Color(0xFF00B4D8)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentCyan.withAlpha(80),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.shield_outlined,
            size: r.adaptive(small: 36.0, medium: 42.0),
            color: AppTheme.primaryDark,
          ),
        ),
        SizedBox(height: r.spacingMD),
        Text(
          'AndroBlight',
          style: TextStyle(
            fontSize: r.sp(28),
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: r.spacingXS),
        Text(
          'Secure your Android world',
          style: TextStyle(
            fontSize: r.sp(13),
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(Responsive r) {
    return Container(
      padding: EdgeInsets.all(r.spacingLG),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withAlpha(120),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.accentCyan.withAlpha(30),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: r.sp(22),
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: r.spacingXS),
            Text(
              'Sign in to sync your scan history',
              style: TextStyle(
                fontSize: r.sp(13),
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: r.spacingLG),

            // Error message
            Consumer<AuthProvider>(
              builder: (context, provider, _) {
                if (provider.errorMessage != null) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: r.spacingSM),
                    child: Container(
                      padding: EdgeInsets.all(r.spacingSM),
                      decoration: BoxDecoration(
                        color: AppTheme.malwareRed.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.malwareRed.withAlpha(60),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: AppTheme.malwareRed,
                              size: r.sp(18)),
                          SizedBox(width: r.spacingXS),
                          Expanded(
                            child: Text(
                              provider.errorMessage!,
                              style: TextStyle(
                                color: AppTheme.malwareRed,
                                fontSize: r.sp(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),

            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                  color: AppTheme.textPrimary, fontSize: r.sp(14)),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle:
                    TextStyle(color: AppTheme.textMuted, fontSize: r.sp(13)),
                prefixIcon: const Icon(Icons.email_outlined,
                    color: AppTheme.accentCyan),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!v.contains('@') || !v.contains('.'))
                  return 'Enter a valid email';
                return null;
              },
            ),
            SizedBox(height: r.spacingMD),

            // Password
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: TextStyle(
                  color: AppTheme.textPrimary, fontSize: r.sp(14)),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle:
                    TextStyle(color: AppTheme.textMuted, fontSize: r.sp(13)),
                prefixIcon: const Icon(Icons.lock_outline,
                    color: AppTheme.accentCyan),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppTheme.textMuted,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) return 'Minimum 6 characters';
                return null;
              },
            ),
            SizedBox(height: r.spacingLG),

            // Login button
            Consumer<AuthProvider>(
              builder: (context, provider, _) {
                return SizedBox(
                  width: double.infinity,
                  height: r.adaptive(small: 50.0, medium: 54.0),
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentCyan,
                      foregroundColor: AppTheme.primaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: provider.isLoading
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppTheme.primaryDark,
                            ),
                          )
                        : Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: r.sp(16),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink(Responsive r) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: r.sp(13),
          ),
        ),
        GestureDetector(
          onTap: () {
            context.read<AuthProvider>().clearError();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            );
          },
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: AppTheme.accentCyan,
              fontSize: r.sp(13),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkipButton(Responsive r) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      },
      child: Text(
        'Skip for now →',
        style: TextStyle(
          color: AppTheme.textMuted,
          fontSize: r.sp(13),
        ),
      ),
    );
  }
}
