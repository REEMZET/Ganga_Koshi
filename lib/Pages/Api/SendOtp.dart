import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendOtp(String phoneNumber) async {
  final url = Uri.parse("https://us-central1-instant-text-413611.cloudfunctions.net/Send_Otp");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"phoneNumber": phoneNumber}),
    );

    if (response.statusCode == 200) {
      // Success
      final responseData = json.decode(response.body);
      print("OTP sent successfully: ${responseData['message']}");
    } else {
      // Error
      print("Failed to send OTP: ${response.body}");
    }
  } catch (error) {
    print("Error sending OTP: $error");
  }
}
