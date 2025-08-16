import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_color.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';
import '../../utils/validators.dart';
import '../../widgets/common/premium_button.dart';
import '../../widgets/common/premium_input.dart';

class EnhancedSignupScreen extends ConsumerStatefulWidget {
  const EnhancedSignupScreen({super.key});

  @override
  ConsumerState<EnhancedSignupScreen> createState() => _EnhancedSignupScreenState();
}

class _EnhancedSignupScreenState extends ConsumerState<EnhancedSignupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      _showSnackBar('Please agree to Terms & Conditions');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match');
      return;
    }

    try {
      await ref.read(authProvider.notifier).signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _nameController.text.trim(),
        campus: 'University Campus', // Default for MVP
      );

      if (mounted) {
        context.go(AppRoutes.profileSetup);
      }
    } catch (e) {
      _showSnackBar(e.toString());
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.lightDestructive,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.lightBackground,
              AppColors.lightPrimary.withValues(alpha: 0.02),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        _buildHeader(),
                        
                        const SizedBox(height: 48),
                        
                        // Sign up form
                        _buildSignUpForm(isLoading),
                        
                        const SizedBox(height: 32),
                        
                        // Login link
                        _buildLoginLink(),
                      ],
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.lightBorder,
              width: 1,
            ),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
            ),
            color: AppColors.lightForeground,
            padding: const EdgeInsets.all(12),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Title
        Text(
          'Join ChowChat',
          style: GoogleFonts.montserrat(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.lightForeground,
            letterSpacing: -0.5,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Subtitle
        Text(
          'Connect with your campus food community',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.lightMutedForeground,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Name field
          PremiumInput(
            controller: _nameController,
            label: 'Full Name',
            placeholder: 'Enter your full name',
            prefixIcon: Icon(Icons.person_outline_rounded),
            validator: Validators.validateName,
            enabled: !isLoading,
          ),
          
          const SizedBox(height: 20),
          
          // Email field
          PremiumInput(
            controller: _emailController,
            label: 'Email Address',
            placeholder: 'your.email@university.edu',
            prefixIcon: Icon(Icons.email_outlined),
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
            enabled: !isLoading,
          ),
          
          const SizedBox(height: 20),
          
          // Password field
          PremiumInput(
            controller: _passwordController,
            label: 'Password',
            placeholder: 'Create a strong password',
            prefixIcon: Icon(Icons.lock_outline_rounded),
            obscureText: !_isPasswordVisible,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.lightMutedForeground,
                size: 20,
              ),
            ),
            validator: Validators.validatePassword,
            enabled: !isLoading,
          ),
          
          const SizedBox(height: 20),
          
          // Confirm password field
          PremiumInput(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            placeholder: 'Re-enter your password',
            prefixIcon: Icon(Icons.lock_outline_rounded),
            obscureText: !_isConfirmPasswordVisible,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.lightMutedForeground,
                size: 20,
              ),
            ),
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            enabled: !isLoading,
          ),
          
          const SizedBox(height: 24),
          
          // Terms checkbox
          _buildTermsCheckbox(),
          
          const SizedBox(height: 32),
          
          // Sign up button
          SizedBox(
            width: double.infinity,
            child: PremiumButton(
              onPressed: isLoading ? null : _signUp,
              text: 'Create Account',
              isLoading: isLoading,
              variant: PremiumButtonVariant.primary,
              size: PremiumButtonSize.lg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          child: Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: _agreeToTerms,
              onChanged: (value) {
                setState(() {
                  _agreeToTerms = value ?? false;
                });
              },
              activeColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.lightMutedForeground,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms & Conditions',
                  style: TextStyle(
                    color: AppColors.lightPrimary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: AppColors.lightPrimary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.lightMutedForeground,
          ),
          children: [
            const TextSpan(text: 'Already have an account? '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () => context.go(AppRoutes.login),
                child: Text(
                  'Sign In',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}