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
  
  @override
  void initState() {
    super.initState();
    selectedValue = 'Admin';
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
    TextEditingController username=TextEditingController();
    TextEditingController password=TextEditingController();
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
              decoration: InputDecoration(labelText: "Phone"),
              keyboardType: TextInputType.phone,
            ),
            TextFormField(
              obscureText: true,
              controller: password,
              decoration: InputDecoration(
                labelText: "Password"),
            ),
         
            
            Row(
              children: [
          
            ElevatedButton(
              onPressed: ()=> AuthService(baseUrl: 'https://limsonvercelapi2.vercel.app').authenticate(username.text,password.text,selectedValue.toString(),context),
             // onPressed: () => validate(username.text, password.text),
              child: Text('Login'),
            ),
          ],
            ),
             ],
      )
         ),
         
    );
        
      
    
  }
}