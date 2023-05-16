import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatelessWidget {
  final TextEditingController _pinController = TextEditingController();

  void _authenticate(BuildContext context) async {
    final String enteredPin = _pinController.text;

    // Retrieve the stored PIN code from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String storedPin = prefs.getString('pinCode') ?? '';

    if (enteredPin == storedPin) {
      // Navigate to the home screen
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Authentication Failed'),
          content: Text('Invalid PIN code.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Authentication')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'PIN code'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _authenticate(context),
              child: Text('Authenticate'),
            ),
          ],
        ),
      ),
    );
  }
}
