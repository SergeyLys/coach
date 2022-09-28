import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/services/network_service.dart';
import 'package:flutter_app/providers/user_provider.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() {
    return _RegisterState();
  }
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  String _errorMessage = '';
  String userRoleValue = userRoles.first;

  Future<void> handleSubmit() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Processing Data'),
          duration: Duration(days: 365),
        ),
      );

      final response = await NetworkService()
          .post('$apiUrl/auth/registration', body: <String, String>{
        'email': emailController.text,
        'name': nameController.text,
        'password': passwordController.text,
        'role': userRoleValue.toUpperCase(),
      });

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
          title: Text('Please sign up'),
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
                    decoration: InputDecoration(labelText: "Name"),
                    controller: nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
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
                  DropdownButtonFormField<String>(
                    value: userRoleValue,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(labelText: "Role"),
                    onChanged: (String? value) {
                      setState(() {
                        userRoleValue = value!;
                      });
                    },
                    items: userRoles.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          handleSubmit();
                        }
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
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
