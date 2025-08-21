import 'package:flutter/material.dart';
import '../../config/app_color.dart';
import '../../utils/validators.dart';
import '../common/custom_text_field.dart';
import '../common/custom_button.dart';

class LoginForm extends StatefulWidget {
  final Function(String email, String password) onSubmit;
  final bool isLoading;

  const LoginForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            label: 'University Email',
            hint: 'Enter your university email',
            controller: _emailController,
            validator: Validators.validateCampusEmail,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textHint),
            enabled: !widget.isLoading,
          ),
          const SizedBox(height: 16),
          PasswordTextField(
            controller: _passwordController,
            validator: Validators.validatePassword,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Sign In',
            onPressed: _canSubmit() ? _handleSubmit : null,
            isLoading: widget.isLoading,
            isFullWidth: true,
            size: ButtonSize.large,
          ),
        ],
      ),
    );
  }

  bool _canSubmit() {
    return _emailController.text.isNotEmpty && 
           _passwordController.text.isNotEmpty &&
           !widget.isLoading;
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(_emailController.text, _passwordController.text);
    }
  }
}

class SignupForm extends StatefulWidget {
  final Function(String email, String password, String username, String campus) onSubmit;
  final bool isLoading;

  const SignupForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            label: 'University Email',
            hint: 'Enter your university email',
            controller: _emailController,
            validator: Validators.validateCampusEmail,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textHint),
            enabled: !widget.isLoading,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Username',
            hint: 'Choose a unique username',
            controller: _usernameController,
            validator: Validators.validateUsername,
            prefixIcon: const Icon(Icons.person_outline, color: AppColors.textHint),
            enabled: !widget.isLoading,
            maxLength: 30,
          ),
          const SizedBox(height: 16),
          PasswordTextField(
            label: 'Password',
            hint: 'Create a strong password',
            controller: _passwordController,
            validator: Validators.validatePassword,
          ),
          const SizedBox(height: 16),
          PasswordTextField(
            label: 'Confirm Password',
            hint: 'Confirm your password',
            controller: _confirmPasswordController,
            validator: (value) => Validators.validateConfirmPassword(
              value, 
              _passwordController.text,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Create Account',
            onPressed: _canSubmit() ? _handleSubmit : null,
            isLoading: widget.isLoading,
            isFullWidth: true,
            size: ButtonSize.large,
          ),
        ],
      ),
    );
  }

  bool _canSubmit() {
    return _emailController.text.isNotEmpty && 
           _passwordController.text.isNotEmpty &&
           _confirmPasswordController.text.isNotEmpty &&
           _usernameController.text.isNotEmpty &&
           !widget.isLoading;
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final campus = _extractCampusFromEmail(_emailController.text);
      widget.onSubmit(
        _emailController.text,
        _passwordController.text,
        _usernameController.text,
        campus,
      );
    }
  }

  String _extractCampusFromEmail(String email) {
    final domain = email.split('@').last;
    return domain.split('.').first;
  }
}