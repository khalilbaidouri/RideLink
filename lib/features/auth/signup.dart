import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
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

  late final FTextFieldControl _fullNameControl;
  late final FTextFieldControl _emailControl;
  late final FTextFieldControl _phoneControl;
  late final FTextFieldControl _passwordControl;

  UserRole _role = UserRole.passenger;
  bool _isLoading = false;
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _fullNameControl = FTextFieldControl.managed(
      controller: _fullNameController,
    );
    _emailControl = FTextFieldControl.managed(
      controller: _emailController,
    );
    _phoneControl = FTextFieldControl.managed(
      controller: _phoneController,
    );
    _passwordControl = FTextFieldControl.managed(
      controller: _passwordController,
    );
  }

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
      default:
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
      Navigator.of(context).pushReplacementNamed('/home');
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
    showFToast(
      context: context,
      icon: const Icon(FIcons.triangleAlert),
      title: Text(message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final colors = theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return FScaffold(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.background, colors.muted],
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
                      color: colors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sustainable travel starts with your first shared ride.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 18),
                  FCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FTextFormField(
                          control: _fullNameControl,
                          label: const Text('Full Name'),
                          hint: 'John Doe',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        FTextFormField.email(
                          control: _emailControl,
                          label: const Text('Email'),
                          hint: 'john@example.com',
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
                        FTextFormField(
                          control: _phoneControl,
                          label: const Text('Phone Number'),
                          hint: '+212 6 000-0000',
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'I want to travel as',
                          style: textTheme.labelLarge?.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _RolePill(
                              label: 'PASSENGER',
                              selected: _role == UserRole.passenger,
                              onPress: () => setState(() {
                                _role = UserRole.passenger;
                              }),
                            ),
                            _RolePill(
                              label: 'DRIVER',
                              selected: _role == UserRole.driver,
                              onPress: () => setState(() {
                                _role = UserRole.driver;
                              }),
                            ),
                            _RolePill(
                              label: 'BOTH',
                              selected: _role == UserRole.both,
                              onPress: () => setState(() {
                                _role = UserRole.both;
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FTextFormField.password(
                          control: _passwordControl,
                          label: const Text('Password'),
                          hint: 'Min. 6 characters',
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
                          builder: (state) => FCheckbox(
                            leadingLabel: true,
                            label: const Text(
                              'I agree to the Terms of Service and Privacy Policy',
                            ),
                            error: state.errorText == null
                                ? null
                                : Text(state.errorText!),
                            value: state.value ?? false,
                            onChange: (value) {
                              state.didChange(value);
                              setState(() {
                                _acceptedTerms = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        FButton(
                          variant: FButtonVariant.secondary,
                          onPress: _isLoading ? null : _submit,
                          child: _isLoading
                              ? const FCircularProgress()
                              : const Text('Create Account'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: FButton(
                      variant: FButtonVariant.ghost,
                      mainAxisSize: MainAxisSize.min,
                      onPress: () {
                        Navigator.of(context).pushReplacementNamed('/login');
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
  });

  final String label;
  final bool selected;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return FButton(
      variant: FButtonVariant.outline,
      size: FButtonSizeVariant.sm,
      mainAxisSize: MainAxisSize.min,
      selected: selected,
      onPress: onPress,
      child: Text(label),
    );
  }
}
