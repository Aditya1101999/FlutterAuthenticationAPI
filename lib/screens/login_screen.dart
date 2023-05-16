import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _pinController = TextEditingController();

  void _storePin(BuildContext context) async {
    final String pinCode = _pinController.text;

    // Store the PIN code in SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('pinCode', pinCode);

    // Navigate to the authentication screen
    Navigator.pushReplacementNamed(context, '/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
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
              onPressed: () => _storePin(context),
              child: Text('Log in'),
            ),
          ],
        ),
      ),
    );
  }
}

