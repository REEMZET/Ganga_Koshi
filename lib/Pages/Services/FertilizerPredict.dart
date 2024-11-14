import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mime/mime.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
class NutrientInfo {
  final int nitrogen;
  final int phosphorus;
  final int potassium;
  final String cropName;

  NutrientInfo({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.cropName,
  });

  Map<String, dynamic> toJson() {
    return {
      "nitrogen": nitrogen,
      "phosphorous": phosphorus,
      "potassium": potassium,
      "cropname": cropName,
    };
  }
}

class FertilizerForm extends StatefulWidget {
  @override
  _FertilizerFormState createState() => _FertilizerFormState();
}

class _FertilizerFormState extends State<FertilizerForm> {
  TextEditingController nitrogenController = TextEditingController();
  TextEditingController phosphorousController = TextEditingController();
  TextEditingController potassiumController = TextEditingController();
  TextEditingController cropController = TextEditingController();
  bool isLoading = false;
  String? selectedLanguage = 'english';
  File? _image;
  final List<String> languages = ['hindi', 'english', 'both'];

  bool _validateFields() {
    if (nitrogenController.text.isEmpty ||
        phosphorousController.text.isEmpty ||
        potassiumController.text.isEmpty ||
        cropController.text.isEmpty ||
        selectedLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> predictFertilizer() async {
    if (!_validateFields()) return;

    setState(() {
      isLoading = true;
    });

    var data = json.encode({
      "cropname": cropController.text,
      "nitrogen": int.tryParse(nitrogenController.text) ?? 0,
      "phosphorous": int.tryParse(phosphorousController.text) ?? 0,
      "pottasium": int.tryParse(potassiumController.text) ?? 0,
    });

    var headers = {
      'Content-Type': 'application/json',
    };

    var dio = Dio();

    try {
      var response = await dio.post(
        'https://ml-api-0rbc.onrender.com/fertilizer-predict',
        options: Options(headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        String recommendation = response.data['recommendation'] ??
            'No recommendation available.';
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HtmlRecommendationView(htmlContent: recommendation),
          ),
        );
      } else {
        print(response.statusMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response.statusMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get recommendation. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }



  Future<File> compressImage(File file) async {
    // Read the image file
    final image = img.decodeImage(await file.readAsBytes());

    // Compress the image to a specific quality (e.g., 70)
    final compressedImage = img.encodeJpg(image!, quality: 70);

    // Save the compressed image to a temporary file
    final tempDir = await getTemporaryDirectory();
    final compressedImagePath = '${tempDir.path}/compressed_image.jpg';
    final compressedFile = File(compressedImagePath)..writeAsBytesSync(compressedImage);

    return compressedFile;
  }

  Future<void> _pickImage(picker.ImageSource source) async {
    final imagePicker = picker.ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: source);

    if (pickedImage != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 4.5),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Choose Report Image',
            toolbarColor: Colors.green,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
          ),
          IOSUiSettings(title: 'Crop Image'),
          WebUiSettings(context: context),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _image = File(croppedFile.path);
        });
      }
    }
  }

  Future<void> uploadFertilizerData({
    required String imagePath,
    required String language,
    required String cropName,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://ml-api-0rbc.onrender.com/fertilizer-predict'),
    );

    request.fields.addAll({
      // 'language': language,
      'cropname': cropName,
    });

    try {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseData = await response.stream.bytesToString();
        final jsonData = json.decode(responseData);

        setState(() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HtmlRecommendationView(htmlContent:jsonData['prediction']?.toString() ?? 'Prediction failed.'),
            ),
          );
        });
      } else {
        setState(() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HtmlRecommendationView(htmlContent:'Error: ${response.statusCode} - ${response.reasonPhrase}'),
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HtmlRecommendationView(htmlContent:'Exception caught: $e'),
          ),
        );
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Text('खाद सुझाव'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                  'assets/images/fertiliser.png', width: 100, height: 120),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'फ़सलों के सलाह के लिए \nअपनी मिटी परीक्षण रिपोर्ट अपलोड करें',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              SizedBox(height: 5),
              InkWell(
                onTap: () => _pickImage(picker.ImageSource.gallery),
                child: Container(
                  margin: EdgeInsets.all(6),
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        if (_image != null)
                          Container(
                            height: 200,
                            width: 80,
                            child: Image.file(_image!, fit: BoxFit.fill),
                          )
                        else
                          Image.asset('assets/images/upload.png', width: 100,
                              height: 100),
                        Text('Soil report', style: TextStyle(color: Colors
                            .green)),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextFormField(
                  controller: cropController,
                  decoration: InputDecoration(
                    labelText: 'फ़सल का नाम',
                    labelStyle: TextStyle(fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'भाषा चुने',
                    labelStyle: TextStyle(fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green)),
                  ),
                  value: selectedLanguage,
                  items: languages.map((language) {
                    return DropdownMenuItem(
                      value: language,
                      child: Text(language),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedLanguage = newValue;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_image != null) {
                      setState(() {
                        isLoading = true;
                      });
                      uploadFertilizerData(
                        imagePath: _image!.path,
                        language: selectedLanguage.toString(),
                        cropName: cropController.text,
                      ).then((_) {
                        setState(() {
                          isLoading = false;
                        });
                      });
                    }
                  },
                  child: isLoading
                      ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : Text(
                      'Submit Image', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green),
                ),
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: Text('या फ़िर', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.red)),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: Text('खाद सुझाव के लिए 👇 मात्रा दर्ज करे',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: nitrogenController,
                        maxLength: 5,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'नाइट्रोजन मात्रा',
                          labelStyle: TextStyle(fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(borderSide: BorderSide(
                              color: Colors.green)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: phosphorousController,
                        maxLength: 5,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'फॉस्फोरस मात्रा',
                          labelStyle: TextStyle(fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(borderSide: BorderSide(
                              color: Colors.green)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: potassiumController,
                        maxLength: 5,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'पोटैशियम मात्रा',
                          labelStyle: TextStyle(fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(borderSide: BorderSide(
                              color: Colors.green)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: predictFertilizer,
                  child: isLoading
                      ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : Text('खाद का सुझाव प्राप्त करें',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green),
                ),
              ),

            ],
          ),
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
    // Initialize the WebView controller
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..loadRequest(Uri.dataFromString(
        '''
        <html>
          <head>
            <style>
              body { font-size: 35px; } /* Adjust font size as desired */
            </style>
          </head>
          <body>$htmlContent</body>
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
                Navigator.pop(context);
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
