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