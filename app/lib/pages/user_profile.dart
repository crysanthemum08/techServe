import 'package:app/pages/home_page.dart';
import 'package:app/services/auth/login_or_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileUserWidget extends StatefulWidget {
  const ProfileUserWidget({super.key});

  @override
  State<ProfileUserWidget> createState() => _ProfileUserWidgetState();
}

class _ProfileUserWidgetState extends State<ProfileUserWidget> {
  late ProfileAdminModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = ProfileAdminModel();

    _model.switchValue1 = true;
    _model.switchValue2 = true;
    _model.switchValue3 = true;
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white, // Replace secondaryBackground
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4B39EF), Color(0xFF39D2C0)],
                    stops: [0, 1],
                    begin: AlignmentDirectional(0, -1),
                    end: AlignmentDirectional(0, 1),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Material(
                          color: Colors.transparent,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color:
                                  Colors.white, // Replace secondaryBackground
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Image.network(
                                'https://images.unsplash.com/photo-1515488825947-f1c0842d7953?w=500&h=500',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Sarah Johnson',
                          style: TextStyle(
                            fontFamily: 'Inter Tight',
                            color: Colors.black, // Replace info color
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Lead Dispatcher',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.black, // Replace info color
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.white, // Replace secondaryBackground
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        color: Colors.transparent,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color:
                                Colors.grey[200], // Replace primaryBackground
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Profile Information',
                                  style: TextStyle(
                                    fontFamily: 'Inter Tight',
                                    color: Colors.black, // Replace primaryText
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                _buildProfileRow(
                                    'Email', 'sarah.johnson@dispatch.com'),
                                _buildProfileRow(
                                    'Role', 'Admin / Lead Dispatcher'),
                                _buildProfileRow('Employee ID', 'DSP-1234'),
                              ].divide(const SizedBox(height: 16)),
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color:
                                Colors.grey[200], // Replace primaryBackground
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 16, 16, 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Notification Settings',
                                  style: TextStyle(
                                    fontFamily: 'Inter Tight',
                                    color: Colors.black, // Replace primaryText
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                _buildSwitchRow(
                                    'Push Notifications', _model.switchValue1,
                                    (newValue) {
                                  setState(
                                      () => _model.switchValue1 = newValue);
                                }),
                                _buildSwitchRow(
                                    'Email Alerts', _model.switchValue2,
                                    (newValue) {
                                  setState(
                                      () => _model.switchValue2 = newValue);
                                }),
                                _buildSwitchRow(
                                    'SMS Notifications', _model.switchValue3,
                                    (newValue) {
                                  setState(
                                      () => _model.switchValue3 = newValue);
                                }),
                              ].divide(const SizedBox(height: 16)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance
                                .signOut(); // Sign out the user
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const LoginOrRegister()), // Navigate back to the login page
                            );
                          } catch (e) {
                            print(
                                'Error signing out: $e'); // Handle sign-out error if needed
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          minimumSize:
                              Size(MediaQuery.of(context).size.width, 56),
                        ),
                        child: const Text(
                          'Log Out',
                          style: TextStyle(
                            fontFamily: 'Inter Tight',
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.grey[600], // Replace secondaryText
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Colors.black, // Replace primaryText
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchRow(String label, bool? value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Colors.black, // Replace primaryText
            fontSize: 16,
          ),
        ),
        Switch(
          value: value ?? false,
          onChanged: onChanged,
          activeColor: Colors.blue, // Replace primary color
          activeTrackColor: Colors.grey[400], // Replace secondary text
        ),
      ],
    );
  }
}

class ProfileAdminModel {
  bool? switchValue1;
  bool? switchValue2;
  bool? switchValue3;

  void dispose() {}
}
