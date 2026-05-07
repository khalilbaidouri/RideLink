import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

	bool _isLoading = false;
	bool _obscurePassword = true;

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
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(content: Text(message)),
		);
	}

	@override
	Widget build(BuildContext context) {
		final textTheme = GoogleFonts.manropeTextTheme(Theme.of(context).textTheme);

		return Theme(
			data: Theme.of(context).copyWith(textTheme: textTheme),
			child: Scaffold(
				body: Container(
					decoration: const BoxDecoration(
						gradient: LinearGradient(
							colors: [Color(0xFFF6F7F2), Color(0xFFFDFCF6)],
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
												color: const Color(0xFF2E7D32),
											),
										),
										const SizedBox(height: 10),
										Text(
											'Welcome back',
											style: textTheme.headlineSmall?.copyWith(
												fontWeight: FontWeight.w800,
												color: const Color(0xFF1D3322),
											),
										),
										const SizedBox(height: 4),
										Text(
											'Access your community carpool network.',
											style: textTheme.bodyMedium?.copyWith(
												color: const Color(0xFF5E6B60),
											),
										),
										const SizedBox(height: 18),
										Container(
											padding: const EdgeInsets.symmetric(
												horizontal: 18,
												vertical: 16,
											),
											decoration: BoxDecoration(
												color: Colors.white,
												borderRadius: BorderRadius.circular(22),
												boxShadow: [
													BoxShadow(
														color: Colors.black.withOpacity(0.08),
														blurRadius: 20,
														offset: const Offset(0, 10),
													),
												],
											),
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													_InputField(
														label: 'Email',
														hintText: 'john.doe@example.com',
														controller: _emailController,
														icon: Icons.email_outlined,
														keyboardType: TextInputType.emailAddress,
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
													_InputField(
														label: 'Password',
														hintText: '••••••••',
														controller: _passwordController,
														icon: Icons.lock_outlined,
														obscureText: _obscurePassword,
														suffixIcon: IconButton(
															onPressed: () {
																setState(() {
																	_obscurePassword = !_obscurePassword;
																});
															},
															icon: Icon(
																_obscurePassword
																		? Icons.visibility_off_outlined
																		: Icons.visibility_outlined,
																color: const Color(0xFF7A8A7D),
															),
														),
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
													SizedBox(
														width: double.infinity,
														child: ElevatedButton(
															onPressed: _isLoading ? null : _submit,
															style: ElevatedButton.styleFrom(
																backgroundColor: const Color(0xFFF6B63C),
																foregroundColor: const Color(0xFF2D2D2D),
																padding: const EdgeInsets.symmetric(
																	vertical: 14,
																),
																textStyle: textTheme.titleMedium?.copyWith(
																	fontWeight: FontWeight.w700,
																),
																shape: RoundedRectangleBorder(
																	borderRadius: BorderRadius.circular(16),
																),
															),
															child: _isLoading
																	? const SizedBox(
																			height: 20,
																			width: 20,
																			child: CircularProgressIndicator(
																				strokeWidth: 2,
																			),
																		)
																	: const Text('Log In'),
														),
													),
												],
											),
										),
										const SizedBox(height: 18),
										Center(
											child: TextButton(
												onPressed: () {
													Navigator.of(context).pushReplacementNamed('/');
												},
												child: Text(
													'Don\'t have an account? Sign up',
													style: textTheme.bodyMedium?.copyWith(
														color: const Color(0xFF5E6B60),
													),
												),
											),
										),
									],
								),
							),
						),
					),
				),
			),
		);
	}
}


class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: const Color(0xFF5E6B60),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: const Color(0xFF7A8A7D)),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF3F6F0),
            hintStyle: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF9BAAA0),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}