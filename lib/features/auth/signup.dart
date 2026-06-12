import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum UserRole { passenger, driver, both }

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _role = UserRole.passenger;
  bool _isLoading = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _roleToDb(UserRole role) {
    switch (role) {
      case UserRole.driver:
        return 'DRIVER';
      case UserRole.both:
        return 'BOTH';
      case UserRole.passenger:
        return 'PASSENGER';
    }
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final client = Supabase.instance.client;
      final response = await client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Signup failed. Please try again.');
      }

      await client.from('users').insert({
        'id': user.id,
        'full_name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': _roleToDb(_role),
      });

      if (!mounted) return;
      final isDriver = _role == UserRole.driver || _role == UserRole.both;
      context.go(isDriver ? '/driver/dashboard' : '/passenger/home');
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (error) {
      _showMessage('Unexpected error: ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.surface, colors.surfaceContainerHighest],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    'RideLink',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Join the community',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sustainable travel starts with your first shared ride.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _fullNameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              hintText: 'John Doe',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'john@example.com',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              hintText: '+212 6 000-0000',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'I want to',
                            style: textTheme.labelLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _RolePill(
                                label: 'PASSENGER',
                                subtitle: 'Book rides',
                                selected: _role == UserRole.passenger,
                                onPress: () => setState(() {
                                  _role = UserRole.passenger;
                                }),
                              ),
                              _RolePill(
                                label: 'DRIVER',
                                subtitle: 'Offer rides',
                                selected: _role == UserRole.driver,
                                onPress: () => setState(() {
                                  _role = UserRole.driver;
                                }),
                              ),
                              _RolePill(
                                label: 'BOTH',
                                subtitle: 'Ride & Drive',
                                selected: _role == UserRole.both,
                                onPress: () => setState(() {
                                  _role = UserRole.both;
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            autofillHints: const [AutofillHints.newPassword],
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              hintText: 'Min. 6 characters',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.trim().length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          FormField<bool>(
                            initialValue: _acceptedTerms,
                            validator: (value) => (value ?? false)
                                ? null
                                : 'Please accept the Terms of Service and Privacy Policy.',
                            builder: (state) => CheckboxListTile(
                              value: state.value ?? false,
                              onChanged: (value) {
                                state.didChange(value);
                                setState(() {
                                  _acceptedTerms = value ?? false;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: const Text(
                                'I agree to the Terms of Service and Privacy Policy',
                              ),
                              subtitle: state.errorText == null
                                  ? null
                                  : Text(state.errorText!),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Create Account'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      child: const Text('Already have an account? Log in'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({
    required this.label,
    required this.selected,
    required this.onPress,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? colors.primaryContainer : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? colors.onPrimaryContainer : colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(
                  color: selected ? colors.onPrimaryContainer : colors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
