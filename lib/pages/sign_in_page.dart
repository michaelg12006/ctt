import 'package:ctt/pages/register_page.dart';
import 'package:ctt/utils/base_url.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<StatefulWidget> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  
  String email = "";
  String userPassword = "";
  bool isObscured = true;
  String baseUrl = BaseUrl.baseUrl;

  Future<void> signInUser() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "email": email,
          "password": userPassword
        })
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString(
          'token',
          data['token']
        );

        await prefs.setString(
          'role',
          data['user']['role']
        );

        await prefs.setString(
          'name',
          data['user']['name']
        );

        await prefs.setString(
          'email',
          data['user']['email']
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false
        );
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
        SnackBar(
          content: Text(e.toString())
        )
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
              Image.asset('assets/images/Ctt_logo.png', height: 200, width: 200),

              Container(
                padding: EdgeInsetsGeometry.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFFD97941),
                    width: .75,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xFFFFFFFF)
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sign In',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                      )),

                      const SizedBox(height: 20),

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
                        obscureText: isObscured,
                        decoration: InputDecoration(
                          labelText: "Password",
                          hintText: "••••••••",
                          suffixIcon: IconButton(
                            constraints: BoxConstraints(),
                            icon: FaIcon(isObscured
                              ? FontAwesomeIcons.eyeSlash
                              : FontAwesomeIcons.eye,
                              color: Colors.grey.shade500, size: 16
                            ),
                            onPressed: () => setState(() => isObscured = !isObscured),
                          )
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
                          onPressed: signInUser,
                          icon: Icon(Icons.login),
                          label: const Text("Sign In"),
                        ),
                      ),
                      
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                            child: const Text("Register",
                              style: TextStyle(
                                color: Color(0xFFD97941)
                            )),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Continue as guest →",
                  style: TextStyle(
                    color: Color(0xFF555555)
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
