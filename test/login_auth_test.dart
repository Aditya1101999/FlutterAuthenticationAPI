import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  group('Login and Authentication Tests', () {
    setUpAll(() async {
      // Initialize SharedPreferences mock
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Entering and storing PIN code', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: LoginScreen()));

      // Enter PIN code and tap the login button
      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify if the PIN code is stored correctly
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedPin = prefs.getString('pinCode');
      expect(storedPin, '1234');
    });

    testWidgets('Authenticating with correct PIN code',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(
          {'pinCode': '1234'}); // Set a stored PIN code

      await tester.pumpWidget(MaterialApp(home: AuthScreen()));

      // Enter correct PIN code and tap the authenticate button
      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify if the navigation to the home screen occurred
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Authenticating with incorrect PIN code',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(
          {'pinCode': '1234'}); // Set a stored PIN code

      await tester.pumpWidget(MaterialApp(home: AuthScreen()));

      // Enter incorrect PIN code and tap the authenticate button
      await tester.enterText(find.byType(TextField), '5678');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify if the error dialog is displayed
      expect(find.text('Authentication Failed'), findsOneWidget);
    });
  });

  group('Home Screen Tests', () {
    testWidgets('Fetching and displaying data from API',
        (WidgetTester tester) async {
      final String responseData = '{"data": "Sample Data"}';
      final http.Response mockResponse = http.Response(responseData, 200);
      final Future<ApiResponse> mockFuture =
          Future.value(ApiResponse(jsonDecode(responseData)['data']));

      // Mocking the HTTP response
      MockClient client = MockClient((http.BaseRequest request) async {
        return mockResponse;
      });

      await tester.pumpWidget(MaterialApp(
          home: HomeScreen(client: client, fetchApiData: () => mockFuture)));

      // Verify if the data from the API is displayed correctly
      expect(find.text('Sample Data'), findsOneWidget);
    });
  });
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(),
            ElevatedButton(
              onPressed: () {},
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(),
            ElevatedButton(
              onPressed: () {},
              child: Text('Authenticate'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final MockClient client;
  final Future<ApiResponse> Function() fetchApiData;

  HomeScreen({required this.client, required this.fetchApiData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<ApiResponse>(
          future: fetchApiData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasData) {
              return Text(snapshot.data!.data);
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Text('No data available');
            }
          },
        ),
      ),
    );
  }
}

class ApiResponse {
  final String data;

  ApiResponse(this.data);
}

class MockClient extends http.BaseClient {
  final http.Client _inner;
  final Future<http.Response> Function(http.BaseRequest) _handler;

  MockClient(this._handler) : _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _handler(request);
    return http.StreamedResponse(
      http.ByteStream.fromBytes(utf8.encode(response.body)),
      response.statusCode,
      contentLength: response.contentLength,
    );
  }

  @override
  void close() {
    _inner.close();
  }
}

class MockClientRequest extends http.Request {
  final http.Request _request;

  MockClientRequest(this._request)
      : super(_request.method, _request.url) {
    headers.addAll(_request.headers);
    contentLength = _request.contentLength;
    encoding = _request.encoding;
    followRedirects = _request.followRedirects;
    persistentConnection = _request.persistentConnection;
  }

  @override
  http.ByteStream finalize() {
    var bodyBytes = utf8.encode(_request.body);
    var stream = http.ByteStream.fromBytes(bodyBytes);
    headers['content-length'] = bodyBytes.length.toString();
    return stream;
  }

  @override
  void write(Object? bytes) {
    _request.bodyBytes.addAll(bytes as List<int>);
  }

  @override
  void writeAll(Iterable<Object?> bytes, [String separator = '']) {
    _request.bodyBytes.addAll(bytes.join(separator).codeUnits);
  }
}



