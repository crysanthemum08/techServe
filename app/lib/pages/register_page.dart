import 'package:app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterModel extends ChangeNotifier {
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  late bool passwordVisibility;

  void initState(BuildContext context) {
    passwordVisibility = false;
    textFieldFocusNode1 = FocusNode();
    textFieldFocusNode2 = FocusNode();
    textController1 = TextEditingController();
    textController2 = TextEditingController();
  }

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();
    textFieldFocusNode2?.dispose();
    textController2?.dispose();
  }
}

class RegisterPage extends StatefulWidget {
  final void Function() onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late RegisterModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // New variable for selected role
  String selectedRole = 'User'; // Default role is 'User'

  //register method
  void register() async {
    final authService = AuthService();
    if (_formKey.currentState!.validate()) {
      if (passwordController.text == confirmPasswordController.text) {
        try {
          await authService.signUpWithEmailAndPassword(
            emailController.text,
            passwordController.text,
            confirmPasswordController.text,
            selectedRole, // Pass the selected role
          );

          // Navigate to DispatcherPage if role is Admin
          if (selectedRole == 'Admin') {
            Navigator.pushReplacementNamed(
                context, '/admin_page'); // Adjust the route name accordingly
          } else {
            // Navigate to home page after successful registration for normal users
            Navigator.pushReplacementNamed(context, '/home_page');
          }
        } catch (e) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(e.toString()),
            ),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text("Passwords don't match!"),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _model = RegisterModel();
    _model.initState(context);
  }

  @override
  void dispose() {
    _model.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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
                    child: Form(
                      key: _formKey,
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
                                  'Create an account',
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
                                  controller: emailController,
                                  focusNode: _model.textFieldFocusNode1,
                                  label: 'Email',
                                  isPassword: false,
                                ),
                                _buildTextField(
                                  controller: passwordController,
                                  focusNode: _model.textFieldFocusNode2,
                                  label: 'Password',
                                  isPassword: true,
                                ),
                                _buildTextField(
                                  controller: confirmPasswordController,
                                  focusNode: null,
                                  label: 'Confirm Password',
                                  isPassword: true,
                                ),
                                // Role Dropdown
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: DropdownButtonFormField<String>(
                                    value: selectedRole,
                                    items: ['User', 'Admin']
                                        .map((role) => DropdownMenuItem(
                                              value: role,
                                              child: Text(role),
                                            ))
                                        .toList(),
                                    onChanged: (role) {
                                      setState(() {
                                        selectedRole = role!;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Role',
                                      filled: true,
                                      fillColor: const Color(0xFFF1F4F8),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                    ),
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF101213),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: ElevatedButton(
                                    onPressed: register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 239, 57, 118),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Sign Up',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Already have an account? '),
                                    GestureDetector(
                                      onTap: widget.onTap,
                                      child: Text(
                                        'Sign In',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: const Color.fromARGB(
                                              255, 239, 57, 157),
                                          fontWeight: FontWeight.w600,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
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
}
