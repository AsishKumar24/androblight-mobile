import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/responsive.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

/// Register Screen — Premium dark theme with glassmorphism

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : null,
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
                      SizedBox(height: r.spacingLG),

                      // Register Card
                      _buildRegisterCard(r),
                      SizedBox(height: r.spacingMD),

                      // Login link
                      _buildLoginLink(r),
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
          width: r.adaptive(small: 60.0, medium: 70.0),
          height: r.adaptive(small: 60.0, medium: 70.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppTheme.accentCyan, Color(0xFF00B4D8)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentCyan.withAlpha(60),
                blurRadius: 25,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Icon(
            Icons.person_add_outlined,
            size: r.adaptive(small: 30.0, medium: 36.0),
            color: AppTheme.primaryDark,
          ),
        ),
        SizedBox(height: r.spacingSM),
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: r.sp(24),
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: r.spacingXS),
        Text(
          'Join AndroBlight to sync your scans',
          style: TextStyle(
            fontSize: r.sp(13),
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterCard(Responsive r) {
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
          children: [
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
                              color: AppTheme.malwareRed, size: r.sp(18)),
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

            // Display Name
            TextFormField(
              controller: _nameController,
              style: TextStyle(
                  color: AppTheme.textPrimary, fontSize: r.sp(14)),
              decoration: InputDecoration(
                labelText: 'Display Name (optional)',
                labelStyle:
                    TextStyle(color: AppTheme.textMuted, fontSize: r.sp(13)),
                prefixIcon: const Icon(Icons.person_outline,
                    color: AppTheme.accentCyan),
              ),
            ),
            SizedBox(height: r.spacingMD),

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
            SizedBox(height: r.spacingMD),

            // Confirm Password
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              style: TextStyle(
                  color: AppTheme.textPrimary, fontSize: r.sp(14)),
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle:
                    TextStyle(color: AppTheme.textMuted, fontSize: r.sp(13)),
                prefixIcon: const Icon(Icons.lock_outline,
                    color: AppTheme.accentCyan),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppTheme.textMuted,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (v) {
                if (v != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            SizedBox(height: r.spacingLG),

            // Register button
            Consumer<AuthProvider>(
              builder: (context, provider, _) {
                return SizedBox(
                  width: double.infinity,
                  height: r.adaptive(small: 50.0, medium: 54.0),
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentCyan,
                      foregroundColor: AppTheme.primaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppTheme.primaryDark,
                            ),
                          )
                        : Text(
                            'Create Account',
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

  Widget _buildLoginLink(Responsive r) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: r.sp(13),
          ),
        ),
        GestureDetector(
          onTap: () {
            context.read<AuthProvider>().clearError();
            Navigator.of(context).pop();
          },
          child: Text(
            'Sign In',
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
}
