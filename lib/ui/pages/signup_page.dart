import 'package:dail_bites/bloc/pocketbase/pocketbase_service_cubit.dart';
import 'package:dail_bites/ui/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:pocketbase/pocketbase.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool loading = false;
// text controllers
  final fullname = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> handleSignup() async {
    final state = context.read<PocketbaseServiceCubit>().state;
    final pb = state.pb;
    setState(() {
      loading = true;
    });
    await Future.delayed(const Duration(seconds: 4));
    try {
      final Map<String, dynamic> data = {
        'username': fullname.text.trim().replaceAll(' ', ''),
        'name': fullname.text.trim(),
        'email': email.text.trim(),
        'password': password.text.trim(),
        'passwordConfirm': confirm.text.trim(),
      };
      final record = await pb.collection('users').create(body: data);

      await pb
          .collection('users')
          .authWithPassword(data['username'], data['password']);
    } on ClientException catch (e) {
      if (e.statusCode == 400) {
        showError(context,
            title: 'Invalid Data', description: 'invalid login details');
        return;
      }
      showError(context,
          title: 'Unknown Error', description: 'An unknown error occured');
      print(e.response);
    }
// handle signup here

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<PocketbaseServiceCubit>().state;
    print(state.pb.authStore.isValid);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo and Welcome Text
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 40),
                                  Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.blue[900],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  Text(
                                    'Create Account',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Sign up to start shopping',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 48),

                            // Signup Form
                            SlideTransition(
                              position: _slideAnimation,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Card(
                                  elevation: 8,
                                  shadowColor: Colors.black26,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.zero,
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          // Full Name Field
                                          TextFormField(
                                            controller: fullname,
                                            decoration: InputDecoration(
                                              labelText: 'Full Name',
                                              hintText: 'Enter your full name',
                                              prefixIcon: const Icon(
                                                  Icons.person_outline),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: Colors.blue[900]!,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter your full name';
                                              }
                                              return null;
                                            },
                                          ),

                                          const SizedBox(height: 24),

                                          // Email Field
                                          TextFormField(
                                            controller: email,
                                            decoration: InputDecoration(
                                              labelText: 'Email',
                                              hintText: 'Enter your email',
                                              prefixIcon: const Icon(
                                                  Icons.email_outlined),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: Colors.blue[900]!,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter your email';
                                              }
                                              if (!RegExp(
                                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                                  .hasMatch(value)) {
                                                return 'Please enter a valid email';
                                              }
                                              return null;
                                            },
                                          ),

                                          const SizedBox(height: 24),

                                          // Password Field
                                          TextFormField(
                                            controller: password,
                                            obscureText: !_isPasswordVisible,
                                            decoration: InputDecoration(
                                              labelText: 'Password',
                                              hintText: 'Enter your password',
                                              prefixIcon: const Icon(
                                                  Icons.lock_outline),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _isPasswordVisible
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _isPasswordVisible =
                                                        !_isPasswordVisible;
                                                  });
                                                },
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: Colors.blue[900]!,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter your password';
                                              }
                                              if (value.length < 9) {
                                                return 'Password must be at least 9 characters';
                                              }
                                              return null;
                                            },
                                          ),

                                          const SizedBox(height: 24),

                                          // Confirm Password Field
                                          TextFormField(
                                            controller: confirm,
                                            obscureText:
                                                !_isConfirmPasswordVisible,
                                            decoration: InputDecoration(
                                              labelText: 'Confirm Password',
                                              hintText: 'Confirm your password',
                                              prefixIcon: const Icon(
                                                  Icons.lock_outline),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _isConfirmPasswordVisible
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _isConfirmPasswordVisible =
                                                        !_isConfirmPasswordVisible;
                                                  });
                                                },
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: Colors.blue[900]!,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please confirm your password';
                                              }
                                              print([
                                                value,
                                                password.text.trim()
                                              ]);
                                              if (value !=
                                                  password.text.trim()) {
                                                return 'Password doesnt match confirm password';
                                              }
                                              // Add password matching validation here
                                              return null;
                                            },
                                          ),

                                          const SizedBox(height: 16),

                                          // Terms and Conditions
                                          Row(
                                            children: [
                                              SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: Checkbox(
                                                  value: _acceptTerms,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _acceptTerms = value!;
                                                    });
                                                  },
                                                  activeColor: Colors.blue[900],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    // TODO LOAD AND OPEN TERMS AND CONDITIONS
                                                  },
                                                  child: Text(
                                                    'I accept the Terms and Conditions',
                                                    style: TextStyle(
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 24),

                                          // Sign Up Button
                                          ElevatedButton(
                                            onPressed: _acceptTerms
                                                ? () {
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      // Implement signup logic
                                                      handleSignup();
                                                    }
                                                  }
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue[900],
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 16,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 3,
                                            ),
                                            child: const Text(
                                              'Sign Up',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
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

                            const Spacer(),

                            // Social Sign Up and Login Link
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Already have an account? ',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Sign In',
                                          style: TextStyle(
                                            color: Colors.blue[900],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (loading)
                  Positioned(
                      top: 0,
                      right: 0,
                      left: 0,
                      bottom: 0,
                      child: Container(
                        color: Colors.white,
                        child: Center(
                          child: Lottie.asset('assets/lottie/anim1.json'),
                        ),
                      ))
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    String label,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        icon: Icon(
          label == 'Google'
              ? Icons.g_mobiledata
              : label == 'Facebook'
                  ? Icons.facebook
                  : Icons.apple,
          size: 24,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}
