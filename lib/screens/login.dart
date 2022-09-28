import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/services/network_service.dart';
import 'package:flutter_app/providers/user_provider.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> handleSubmit() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Processing Data'),
          duration: Duration(days: 365),
        ),
      );

      final response = await NetworkService()
          .post('$apiUrl/auth/login', body: <String, String>{
        'email': emailController.text.toString(),
        'password': passwordController.text.toString(),
      });

      print(response);

      context.read<UserProvider>().setUser(response['user']);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      Navigator.pushReplacementNamed(context, '/home');
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Please sign in'),
        ),
        body: Container(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: "Email"),
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Password"),
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              handleSubmit();
                            }
                          },
                          child: const Text(
                            'Sign in',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Dont have an account?"),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              child: const Text(
                                'Create one',
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  ),
                  Container(
                      margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: Text(
                        _errorMessage.isNotEmpty ? _errorMessage : '',
                        style: TextStyle(color: Colors.red),
                      ))
                ],
              ),
            )
        )
      );
  }
}
