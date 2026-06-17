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

  @override
  void initState() {
    super.initState();
    selectedValue = 'Admin';
  }

  @override
  void dispose() {
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
//
// Future<void> validate(String phone,String password) async {
//   // final apiKey = dotenv.env['AIRTABLE_API_KEY'];
//   // final baseId = dotenv.env['AIRTABLE_BASE_ID'];
//   // final tableName = dotenv.env['AIRTABLE_TABLE_NAME']; // Replace with your Airtable table name
//
//  // final url = 'https://api.airtable.com/v0/$baseId/$tableName?filterByFormula={empcode}="$employeeCode"'; // Use a filter formula to check the employee code
// final url='https://limsonvercelapi2.vercel.app/api/fsauth';
//   final response = await http.post(
//     Uri.parse(url),
//     headers: {
//       'Content-Type': 'application/json',
//     },
//     body: json.encode({
//       'phone': phone,
//       'password': password,
//       'app': selectedValue?.toLowerCase(),
//     }),
//   );
//   print(response.statusCode);
//
//
//   if (response.statusCode == 200) {
//     print('User logged in successfully.');
//     var token=jsonDecode(response.body)['token'];
//   //  Navigator.push(context, MaterialPageRoute(builder: (context) => Admindashboard()));
//   Navigator.push(context, MaterialPageRoute(builder: (context) => CRMDashboard(token: token)));
//     }
//    else {
//      print(response.body);
//   print('Failed to fetch data: ${response.statusCode}');
//
//   }
//      // Error during Airtable fetch
//   }

// Future<bool> signInWithEmployeeCode(String phone, String password) async {
//   String username = phone+"@lmcrm.in";
//   try {
//     // Step 1: Sign in with Firebase
//     // UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//     //   email: username,
//     //   password: password,
//     // );
//
//     User? user = userCredential.user;
//     if (user != null) {
//       // Step 2: Validate the employee code against Airtable
//       bool isValidCode = await validate(username, password);
//
//       if (isValidCode) {
//         print('User logged in successfully.');
//         return true; // Login successful
//       } else {
//         print('Invalid employee code.');
//         return false; // Invalid employee code
//       }
//     } else {
//       print('User not found.');
//       return false; // User not found
//     }
//   } on FirebaseAuthException catch (e) {
//     print('Error: ${e.message}');
//     return false; // Error during authentication
//   }
// }

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
          Text("1"),
          TextFormField(
            controller: username,
            decoration: InputDecoration(labelText: "Phone"),
            keyboardType: TextInputType.phone,
          ),
          TextFormField(
            obscureText: true,
            controller: password,
            decoration: InputDecoration(labelText: "Password"),
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
      )),
    );
  }
}
