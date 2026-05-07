import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
	bool _obscurePassword = true;
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
			default:
				return 'PASSENGER';
		}
	}

	Future<void> _submit() async {
		final isValid = _formKey.currentState?.validate() ?? false;
		if (!isValid) return;
		if (!_acceptedTerms) {
			_showMessage('Please accept the Terms of Service and Privacy Policy.');
			return;
		}

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
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(content: Text(message)),
		);
	}

	@override
	Widget build(BuildContext context) {
		final textTheme = GoogleFonts.manropeTextTheme(Theme.of(context).textTheme);
		final roleTextStyle = textTheme.labelLarge?.copyWith(
			fontWeight: FontWeight.w700,
			letterSpacing: 0.4,
		);

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
											'Join the community',
											style: textTheme.headlineSmall?.copyWith(
												fontWeight: FontWeight.w800,
												color: const Color(0xFF1D3322),
											),
										),
										const SizedBox(height: 4),
										Text(
											'Sustainable travel starts with your first shared ride.',
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
														label: 'Full Name',
														hintText: 'John Doe',
														controller: _fullNameController,
														icon: Icons.person_outline,
														validator: (value) {
															if (value == null || value.trim().isEmpty) {
																return 'Please enter your full name';
															}
															return null;
														},
													),
													const SizedBox(height: 12),
													_InputField(
														label: 'Email',
														hintText: 'john@example.com',
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
														label: 'Phone Number',
														hintText: '+212 6 000-0000',
														controller: _phoneController,
														icon: Icons.phone_outlined,
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
															color: const Color(0xFF5E6B60),
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
																onTap: () => setState(() {
																	_role = UserRole.passenger;
																}),
																textStyle: roleTextStyle,
															),
															_RolePill(
																label: 'DRIVER',
																selected: _role == UserRole.driver,
																onTap: () => setState(() {
																	_role = UserRole.driver;
																}),
																textStyle: roleTextStyle,
															),
															_RolePill(
																label: 'BOTH',
																selected: _role == UserRole.both,
																onTap: () => setState(() {
																	_role = UserRole.both;
																}),
																textStyle: roleTextStyle,
															),
														],
													),
													const SizedBox(height: 12),
													_InputField(
														label: 'Password',
														hintText: 'Min. 6 characters',
														controller: _passwordController,
														icon: Icons.lock_outline,
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
																return 'Please enter a password';
															}
															if (value.trim().length < 6) {
																return 'Password must be at least 6 characters';
															}
															return null;
														},
													),
													const SizedBox(height: 10),
													Row(
														crossAxisAlignment: CrossAxisAlignment.start,
														children: [
															Checkbox(
																value: _acceptedTerms,
																onChanged: (value) {
																	setState(() {
																		_acceptedTerms = value ?? false;
																	});
																},
															),
															Expanded(
																child: Text(
																	'I agree to the Terms of Service and Privacy Policy',
																	style: textTheme.bodySmall?.copyWith(
																		color: const Color(0xFF5E6B60),
																	),
																),
															),
														],
													),
													const SizedBox(height: 6),
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
																	: const Text('Create Account'),
														),
													),
												],
											),
										),
										const SizedBox(height: 18),
										Center(
											child: Text(
												'Already have an account? Log in',
												style: textTheme.bodyMedium?.copyWith(
													color: const Color(0xFF5E6B60),
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

class _RolePill extends StatelessWidget {
	const _RolePill({
		required this.label,
		required this.selected,
		required this.onTap,
		this.textStyle,
	});

	final String label;
	final bool selected;
	final VoidCallback onTap;
	final TextStyle? textStyle;

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: onTap,
			borderRadius: BorderRadius.circular(20),
			child: Container(
				padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
				decoration: BoxDecoration(
					color: selected ? const Color(0xFF2E7D32) : const Color(0xFFF0F2ED),
					borderRadius: BorderRadius.circular(20),
				),
				child: Text(
					label,
					style: textStyle?.copyWith(
								color: selected ? Colors.white : const Color(0xFF5E6B60),
							) ??
							TextStyle(
								color: selected ? Colors.white : const Color(0xFF5E6B60),
								fontWeight: FontWeight.w600,
							),
				),
			),
		);
	}
}
