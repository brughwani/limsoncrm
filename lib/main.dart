import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lmrepaircrmadmin/complaintdatanotifier.dart';
import 'package:provider/provider.dart';
import 'loginpage.dart';
import 'firebase_options.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'employeeprovider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(providers:
      [
        ChangeNotifierProvider(
          create: (_) => ComplaintDataNotifier(),
        ),
        ChangeNotifierProvider(
          create: (_) => EmployeeProvider(),
        ),
      ],



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