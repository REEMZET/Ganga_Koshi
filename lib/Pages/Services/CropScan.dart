import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:webview_flutter/webview_flutter.dart';

import '../../Model/UserModel.dart'; // Make sure to include this dependency in your pubspec.yaml

class CropScan extends StatefulWidget {
  const CropScan({super.key});

  @override
  State<CropScan> createState() => _CropScanState();
}

class _CropScanState extends State<CropScan> {
  File? _image;
  UserModel? userModel;
  String selectedLanguage = 'both'; // Default language selection
  final List<String> languages = ['hindi', 'english', 'both']; // Language options
  String predictionResult = ''; // Variable to store the prediction result or error message
  bool isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  Future<void> getUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DatabaseReference userRef = FirebaseDatabase.instance.reference().child('GangaKoshi/User/${user.uid}');
    userRef.onValue.listen((event) {
      final udata = event.snapshot.value;
      if (udata != null) {
        Map<dynamic, dynamic> data = udata as Map<dynamic, dynamic>;
        userModel = UserModel(
          name: data['name'] ?? '',
          userPhone: data['userphone'] ?? '',
          uid: data['uid'] ?? '',
          regDate: data['regdate'] ?? '',
          deviceId: '',
        );
        setState(() {});
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final imagePicker = ImagePicker(); // Use alias for image_picker package
    final pickedImage = await imagePicker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    } else {
      Fluttertoast.showToast(
        msg: 'No image selected.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<File?> _compressImage(File imageFile) async {
    // Show a loading dialog while compressing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Read the image file
      final bytes = await imageFile.readAsBytes();

      // Decode the image
      img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        Navigator.of(context).pop(); // Close the dialog if image decoding fails
        Fluttertoast.showToast(
          msg: 'Image decoding failed.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return null;
      }

      // Compress the image
      final compressedBytes = img.encodeJpg(image, quality: 85); // Adjust quality (0-100)

      // Create a new file to store the compressed image
      final compressedImage = File('${imageFile.parent.path}/compressed_${imageFile.uri.pathSegments.last}');
      await compressedImage.writeAsBytes(compressedBytes);

      Navigator.of(context).pop(); // Close the loading dialog
      return compressedImage;
    } catch (e) {
      Navigator.of(context).pop(); // Close the dialog if any exception occurs
      Fluttertoast.showToast(
        msg: 'Error during image compression: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return null;
    }
  }

  Future<String?> uploadDiseaseData(String imagePath, String language) async {
    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse('http://51.20.3.105/disease-predict'));
    request.fields['language'] = language;

    // Attach the image file to the request
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    try {
      // Send the request
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // Decode the response
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);

        // Check if the response contains the expected fields
        if (jsonResponse['message'] == 'success' && jsonResponse.containsKey('prediction')) {
          String englishPrediction = jsonResponse['prediction']['english'];
          String hindiPrediction = jsonResponse['prediction']['hindi'];

          // Return the predictions in both languages
          return 'English Prediction: $englishPrediction\n\nHindi Prediction: $hindiPrediction';
        } else {
          return 'Error: Unexpected response format.';
        }
      } else {
        return 'Error: ${response.reasonPhrase}'; // Return error message in case of non-200 status code
      }
    } catch (e) {
      return 'Error: $e'; // Handle any other errors that may occur
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Text(
          'फसलों की सलाह',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'assets/images/camscan.png',
              width: 200,
              height: 250,
            ),
            SizedBox(height: 5),
            Align(
              alignment: Alignment.center,
              child: Text(
                'रोग का पता लगाने के लिए \nअपनी फसल के पत्ते की तस्वीर लें',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(height: 5),
            InkWell(
              onTap: () {
                // Open gallery instead of camera
                _pickImage(ImageSource.gallery);
              },
              child: (_image != null)
                  ? Container(
                height: 300,
                width: 200,
                child: Image.file(
                  _image!,
                  fit: BoxFit.cover,
                ),
              )
                  : Container(
                width: double.infinity,
                margin: EdgeInsets.all(15),
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.photo,
                        size: 150,
                      ),
                      Text(
                        'Leaf Photo',
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: selectedLanguage,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedLanguage = newValue!;
                  });
                },
                items: languages.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 120,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () async {
                    if (_image != null) {
                      setState(() {
                        isLoading = true; // Start loading
                      });

                      // Compress the image
                      File? compressedImage = await _compressImage(_image!);
                      if (compressedImage != null) {
                        // Call the upload function
                        String? result = await uploadDiseaseData(compressedImage.path, selectedLanguage);
                        setState(() {
                          predictionResult = result ?? 'Prediction failed. Please try again.';
                          isLoading = false; // Stop loading
                        });

                        // Navigate to the HtmlRecommendationView and pass the prediction result
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HtmlRecommendationView(
                              htmlContent: predictionResult, // Pass the prediction result here
                            ),
                          ),
                        );
                      } else {
                        setState(() {
                          predictionResult = 'Image compression failed. Please try again.';
                          isLoading = false; // Stop loading
                        });
                      }
                    } else {
                      Fluttertoast.showToast(
                        msg: 'Please select an image first!',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      setState(() {
                        predictionResult = 'Please select an image first!';
                      });
                    }
                  },
                  child: isLoading
                      ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                      : Text('Submit',style: TextStyle(color: Colors.white),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HtmlRecommendationView extends StatelessWidget {
  final String htmlContent;

  HtmlRecommendationView({required this.htmlContent});

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..loadRequest(Uri.dataFromString(
        '''
        <html>
          <head>
            <style>
              body { font-size: 30px; line-height: 1; padding: 25px; } /* Adjust font size and padding */
            </style>
          </head>
          <body>
            <h2>Prediction Result</h2>
            <p>$htmlContent</p>
          </body>
        </html>
        ''',
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ));

    return Scaffold(
      appBar: AppBar(title: Text("Fertilizer Recommendation")),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: WebViewWidget(controller: controller),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Navigate back to the previous screen
              },
              child: Text('Back to Prediction Page'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Button color
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
