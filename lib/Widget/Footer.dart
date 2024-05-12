import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class FooterWidget extends StatefulWidget {
  const FooterWidget({super.key});

  @override
  State<FooterWidget> createState() => _FooterWidgetState();
}

class _FooterWidgetState extends State<FooterWidget> {



  void openWebsite() async {
    var whatsappURl_android = "https://www.gangakoshi.com/";
    await launch(whatsappURl_android );
  }

  openyoutube() async{
    var whatsappURl_android = "https://www.youtube.com/@GangaKoshi";
    await launch(whatsappURl_android );
  }
  openfb() async{
    var whatsappURl_android = "https://www.facebook.com/profile.php?id=61554664866169";
    await launch(whatsappURl_android );
  }
  openinsta() async{
    var whatsappURl_android = "https://www.instagram.com/gangakoshi_agritech";
    await launch(whatsappURl_android );
  }



  @override
  Widget build(BuildContext context) {
    return Container(
       color: Colors.grey.shade50,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 50,
            child: Image.asset("assets/images/logo.png"),
          ),
          Text(
            'Follow Us:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              SocialButton(
                iconUrl: 'https://firebasestorage.googleapis.com/v0/b/firstandfast-781dd.appspot.com/o/Social%20png%2Fweb-link.png?alt=media&token=2be25c46-6d62-4671-8460-062204932f2c',
                label: 'Ganga Koshi',
                onTap: () {
                  openWebsite();
                },
              ),
              SocialButton(
                iconUrl: 'https://firebasestorage.googleapis.com/v0/b/firstandfast-781dd.appspot.com/o/Social%20png%2Ffacebook.png?alt=media&token=9bc512d2-c988-4f09-a911-7c35b011306e',
                label: 'Facebook',
                onTap: () {
                  openfb();
                },
              ),
              SocialButton(
                iconUrl: 'https://firebasestorage.googleapis.com/v0/b/firstandfast-781dd.appspot.com/o/Social%20png%2Finstagram.png?alt=media&token=cafdc199-0baa-404b-8f94-6055bbaafd3e',
                label: 'Instagram',
                onTap: () {
                  openinsta();
                },
              ),
              SocialButton(
                iconUrl: 'https://firebasestorage.googleapis.com/v0/b/firstandfast-781dd.appspot.com/o/Social%20png%2Fyoutube%20(1).png?alt=media&token=edd97296-b933-4b23-a733-e8561be7e4d8',
                label: 'YouTube',
                onTap: () {
                  openyoutube();
                },
              ),
            ],
          ),SizedBox(height: 8,),
          Text('(गंगाकोशी एग्रीटेक प्राइवेट लिमिटेड)',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green,fontSize: 18),),
          SizedBox(height: 8,),
          Center(
            child: Text(
              'घर संख्या 1, एनएच 28, बंकट PO - बड़ा बरियारपुर \nPS - मुफस्सिल बरियारपुर, मोतिहारी  पूर्वी चंपारण, बिहार (845401)',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: 50,)

        ],
      ),
    );
  }
}
class SocialButton extends StatelessWidget {
  final String iconUrl; // Change IconData to String for URL
  final String label;
  final Function onTap;

  SocialButton({
    required this.iconUrl, // Change IconData to String for URL
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Image.network( // Using Image.network to fetch icon from URL
              iconUrl,
              width: 36,
              height: 36,
              // You can add color if needed
            ),
            SizedBox(height: 5),
            Text(label),
          ],
        ),
      ),
    );
  }
}


