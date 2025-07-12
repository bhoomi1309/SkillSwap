import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'package:glassmorphism/glassmorphism.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _skillsOfferedController = TextEditingController();
  final _skillsWantedController = TextEditingController();
  
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _skillsOfferedController.dispose();
    _skillsWantedController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = false;

    if (_isLogin) {
      success = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      success = await authProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        skillsOffered: _skillsOfferedController.text.trim(),
        skillsWanted: _skillsWantedController.text.trim(),
      );
    }

    if (success && mounted) {
      // The AuthWrapper will automatically navigate to Dashboard when isAuthenticated becomes true
      // No need to manually navigate
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: GlassmorphicContainer(
                width: double.infinity,
                height: 500,
                borderRadius: 20,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                border: 2,
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.5),
                    Colors.white.withOpacity(0.3),
                  ],
                ),
                blur: 20,
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Logo/Title
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Image.asset(
                            'assets/images/logo_login_page.jpg',
                            width: 180,
                            height: 180,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Text(
                          _isLogin ? 'Welcome back!' : 'Create your account',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Form Fields
                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: const Icon(Icons.person),
                              border: const OutlineInputBorder(),
                              labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[700],
                              ),
                              prefixIconColor: AppColors.primary,
                              floatingLabelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            border: const OutlineInputBorder(),
                            labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[700],
                            ),
                            prefixIconColor: AppColors.primary,
                            floatingLabelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(),
                            labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[700],
                            ),
                            prefixIconColor: AppColors.primary,
                            floatingLabelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (!_isLogin && value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _skillsOfferedController,
                            decoration: InputDecoration(
                              labelText: 'Skills Offered (comma-separated)',
                              hintText: 'e.g., Flutter, Photography, Cooking',
                              prefixIcon: const Icon(Icons.work),
                              border: const OutlineInputBorder(),
                              labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[700],
                              ),
                              prefixIconColor: AppColors.primary,
                              floatingLabelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your skills';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _skillsWantedController,
                            decoration: InputDecoration(
                              labelText: 'Skills Wanted (comma-separated)',
                              hintText: 'e.g., React, Drawing, Cooking',
                              prefixIcon: const Icon(Icons.favorite),
                              border: const OutlineInputBorder(),
                              labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[700],
                              ),
                              prefixIconColor: AppColors.primary,
                              floatingLabelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your skills';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Error Message
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            if (authProvider.error != null) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red[200]!),
                                ),
                                child: Text(
                                  authProvider.error!,
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return ElevatedButton(
                                onPressed: authProvider.isLoading ? null : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: authProvider.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        _isLogin ? 'Login' : 'Register',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Toggle Button
                        TextButton(
                          onPressed: _toggleAuthMode,
                          child: Text(
                            _isLogin
                                ? 'Don\'t have an account? Register'
                                : 'Already have an account? Login',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 