import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'loginpage.dart';
import 'firebase_options.dart';
import 'Admindashboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'employeeprovider.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // final firebaseOptions = FirebaseOptions(
  //   apiKey: dotenv.env['FIREBASE_API_KEY']!,
  //   projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
  //  //appId: dotenv.env['FIREBASE_APP_ID']!,
  //   messagingSenderId:dotenv.env['FIREBASE_MESSENGING_SENDER_ID']!,
  //   appId: '',
  // );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
      ChangeNotifierProvider(
        create: (_) => EmployeeProvider(),

      child: MyWidget()));
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      home:MyHomePage()
    );
  }
}