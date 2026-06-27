import 'package:ctt/utils/base_url.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  String name = "";
  String email = "";
  String userPassword = "";
  String userConfirmPassword = "";
  bool isObscuredA = true;
  bool isObscuredB = true;

  String baseUrl = BaseUrl.baseUrl;

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
        print('$baseUrl/auth/register');
        final response = await http.post(
          Uri.parse('$baseUrl/auth/register'),
          headers: {
            'Content-Type': 'application/json'
          },
          body: jsonEncode({
            "name": name,
            "email": email,
            "password": userPassword
          })
        );
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration successful")
          )
        );
        Navigator.pushReplacementNamed(context, '/login');
      } 
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'])
          )
        );
      }
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsetsGeometry.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/Ctt_logo.png',
                height: 200,
                width: 200,
              ),

              Container(
                padding: EdgeInsetsGeometry.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFD97941), width: .75),
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xFFFFFFFF),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        onChanged: (value) => name = value,
                        decoration: InputDecoration(
                          labelText: "Full Name",
                          hintText: "Jane Doe",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Full name is required!";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        onChanged: (value) => email = value,
                        decoration: InputDecoration(
                          labelText: "Email",
                          hintText: "you@example.com",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email is required!";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        onChanged: (value) => userPassword = value,
                        obscureText: isObscuredA,
                        decoration: InputDecoration(
                          labelText: "Password",
                          hintText: "••••••••",
                          suffixIcon: IconButton(
                            constraints: BoxConstraints(),
                            icon: FaIcon(
                              isObscuredA
                                  ? FontAwesomeIcons.eyeSlash
                                  : FontAwesomeIcons.eye,
                              color: Colors.grey.shade500,
                              size: 16,
                            ),
                            onPressed: () =>
                                setState(() => isObscuredA = !isObscuredA),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password is required!";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        onChanged: (value) => userConfirmPassword = value,
                        obscureText: isObscuredB,
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          hintText: "••••••••",
                          suffixIcon: IconButton(
                            constraints: BoxConstraints(),
                            icon: FaIcon(
                              isObscuredB
                                  ? FontAwesomeIcons.eyeSlash
                                  : FontAwesomeIcons.eye,
                              color: Colors.grey.shade500,
                              size: 16,
                            ),
                            onPressed: () =>
                                setState(() => isObscuredB = !isObscuredB),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password is required!";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: registerUser,
                          icon: FaIcon(FontAwesomeIcons.userPlus),
                          label: const Text("Create Account"),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Sign in",
                              style: TextStyle(color: Color(0xFFD97941)),
                            ),
                          ),
                        ],
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
}
