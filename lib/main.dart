import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jewellery App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFB8860B),
        useMaterial3: true,
      ),
      home: const TestScreen(),
    );
  }
}

// Temporary screen to confirm Firebase works. We delete this in Step 2.
class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  Future<void> _testFirestore(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('test').add({
        'message': 'Hello Firebase',
        'time': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Success! Check Firestore console.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Test')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _testFirestore(context),
          child: const Text('Test Firestore'),
        ),
      ),
    );
  }
}