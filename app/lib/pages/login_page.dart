// ignore_for_file: use_build_context_synchronously

import 'package:app/pages/admin_home_page.dart';
import 'package:app/pages/home_page.dart';
import 'package:app/services/auth/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Import your RegisterPage here

class LoginModel {
  FocusNode emailAddressFocusNode = FocusNode();
  TextEditingController emailAddressTextController = TextEditingController();
  FocusNode passwordFocusNode = FocusNode();
  TextEditingController passwordTextController = TextEditingController();
  bool passwordVisibility = false;

  void initState(BuildContext context) {
    // Initialization logic if needed
  }

  void dispose() {
    emailAddressFocusNode.dispose();
    emailAddressTextController.dispose();
    passwordFocusNode.dispose();
    passwordTextController.dispose();
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onTap});

  final void Function() onTap; // Define the onTap parameter

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LoginModel _model; // Initialize model

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // Initialize the model and controllers
    _model = LoginModel();
    _model.initState(context);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  //login method
  void login() async {
    final authService = AuthService();
    String email = _model.emailAddressTextController.text;
    String password = _model.passwordTextController.text;

    // Validate email format
    if (!isValidEmail(email)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Invalid Email"),
          content: const Text("Please enter a valid email address."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    try {
      await authService.signInWithEmailAndPassword(email, password);

      // Check if the logged-in user is an admin
      bool isAdmin = await authService.isAdmin();
      print("Is admin: $isAdmin");

      if (!mounted) return;

      // Navigate based on the user's role
      if (isAdmin) {
        print("Navigating to DispatcherHomePage");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminWidget()),
        );
      } else {
        print("Navigating to HomepageWidget");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomepageWidget()),
        );
      }
    } catch (e) {
      print("Login error: $e");
      String errorMessage;
      if (e.toString().contains("invalid-email")) {
        errorMessage = "The email address is not valid.";
      } else if (e.toString().contains("user-not-found")) {
        errorMessage = "No user found for that email.";
      } else if (e.toString().contains("wrong-password")) {
        errorMessage = "Incorrect password.";
      } else {
        errorMessage = "An unknown error occurred. Please try again.";
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Login Failed"),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 8,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(color: Colors.white),
                  alignment: Alignment.topLeft,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 140,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          alignment: const AlignmentDirectional(-1, 0),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(32, 0, 0, 0),
                            child: Text(
                              'Lobot',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF101213),
                                fontSize: 36,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome Back',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF101213),
                                  fontSize: 36,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  'Let\'s get started by filling out the form below.',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFF57636C),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              _buildTextField(
                                controller: _model.emailAddressTextController,
                                focusNode: _model.emailAddressFocusNode,
                                label: 'Email',
                                isPassword: false,
                              ),
                              _buildTextField(
                                controller: _model.passwordTextController,
                                focusNode: _model.passwordFocusNode,
                                label: 'Password',
                                isPassword: true,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    login(); // Sign in logic here
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 239, 57, 118),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Sign In',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Don\'t have an account? ',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    TextSpan(
                                      text: 'Sign Up here',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color.fromARGB(
                                            255, 239, 57, 157),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          widget
                                              .onTap(); // Use onTap to navigate
                                        },
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required bool isPassword,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword && !_model.passwordVisibility,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF1F4F8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _model.passwordVisibility
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _model.passwordVisibility = !_model.passwordVisibility;
                    });
                  },
                )
              : null,
        ),
        style: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF101213),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  bool isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }
}
