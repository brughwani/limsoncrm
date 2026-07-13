import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
//import 'package:';
import 'package:http/http.dart' as http;

import 'authservice.dart';

//import 'package:lmrepaircrmadmin/Admindashboard.dart';
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? selectedValue;
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    selectedValue = 'Admin';
    username.addListener(_clearError);
    password.addListener(_clearError);
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  @override
  void dispose() {
    username.removeListener(_clearError);
    password.removeListener(_clearError);
    username.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (username.text.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Please enter phone and password'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService(baseUrl: 'https://limsonvercelapi2.vercel.app')
          .authenticate(
              username.text, password.text, selectedValue.toString(), context);
    } catch (e) {
      String errorMessage = 'Login failed';
      if (e.toString().contains('401') ||
          e.toString().toLowerCase().contains('invalid')) {
        errorMessage = 'Incorrect phone or password';
      } else if (e.toString().contains('network') ||
          e.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection.';
      } else {
        errorMessage = 'Login failed. Please try again.';
      }

      setState(() {
        _errorMessage = errorMessage;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: username,
              decoration: InputDecoration(
                labelText: "Phone",
                errorText: _errorMessage != null ? '' : null,
              ),
              keyboardType: TextInputType.phone,
            ),
            TextFormField(
              obscureText: true,
              controller: password,
              decoration: InputDecoration(
                labelText: "Password",
                errorText: _errorMessage,
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text('Login'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
