import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final FTextFieldControl _emailControl;
  late final FTextFieldControl _passwordControl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailControl = FTextFieldControl.managed(controller: _emailController);
    _passwordControl =
        FTextFieldControl.managed(controller: _passwordController);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final client = Supabase.instance.client;
      await client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

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
                    'Welcome back',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Access your community carpool network.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 18),
                  FCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FTextFormField.email(
                          control: _emailControl,
                          label: const Text('Email'),
                          hint: 'john.doe@example.com',
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
                        FTextFormField.password(
                          control: _passwordControl,
                          label: const Text('Password'),
                          hint: '••••••••',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.trim().length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        FButton(
                          variant: FButtonVariant.secondary,
                          onPress: _isLoading ? null : _submit,
                          child: _isLoading
                              ? const FCircularProgress()
                              : const Text('Log In'),
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
                        Navigator.of(context).pushReplacementNamed('/');
                      },
                      child: const Text('Don\'t have an account? Sign up'),
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
