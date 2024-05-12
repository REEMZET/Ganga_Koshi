import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ganga_kosi/Pages/MyBooking.dart';
import 'package:ganga_kosi/Pages/Profile.dart';
import 'package:ganga_kosi/Pages/TestRequest.dart';
import 'package:ganga_kosi/Utils/Toast.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

import '../Utils/AppColors.dart';
import '../Widget/ProductList.dart';
import '../Widget/Posts.dart';
import '../Widget/Services.dart';
import '../Widget/WebPageView.dart';
import 'Pagerouter.dart';
import 'ProductDetails.dart';
import 'SigninBottomSheetWidget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key); // Providing a proper constructor

  @override
  State<HomePage> createState() => _HomePageState();
}

late User? user;
class _HomePageState extends State<HomePage> {


  void launchEnquiryWhatsApp() async {
    String enquirymsg = '''
🌾 *GangaKoshi* 🌱

Hello there! 👋

Subject: Inquiry Regarding Crop Prediction and Fertilizer Advice

Dear GangaKoshi Team,

I hope this message finds you well. My name is [Your Name], and I am a user of the Ganga Koshi mobile application.
 I am writing to inquire about the crop prediction and fertilizer advice services provided by your company.

As a farmer, I have been using your app to analyze soil test reports and receive recommendations for 
crop selection and fertilizer application. I must say that I am impressed with the accuracy 
and efficiency of the predictions provided by your platform.🌾
''';

    final link = WhatsAppUnilink(
      phoneNumber: '+91-8448359780', // Replace with the appropriate phone number
      text: enquirymsg,
    );

    await launch('$link');
  }
  void _makePhoneCall() {
    final String phoneNumber = '8448359780';
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    launch(phoneUri.toString());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user=FirebaseAuth.instance.currentUser;
  }
  int _backButtonCounter = 0;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_backButtonCounter == 1) {
          ToastWidget.showToast(context, 'Exiting app');
          return true;
        } else {
          _backButtonCounter++;
          ToastWidget.showToast(context, 'Press back again to exit');
          return false;
        }
      },
      child: DefaultTabController(
        length: 3, // Number of tabs
        child: Scaffold(
          appBar: AppBar(
            elevation: 2,
            title:  Container(
              height: 40,
              child: Image.asset("assets/images/logo.png"),
            ),
            backgroundColor: Colors.white,
            bottom: TabBar(
              labelColor: Colors.black,
              labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
              tabs: [
                Tab(text: 'सेवाएं',),
                Tab(text: 'मार्केट'),
                Tab(text: 'मार्गदर्शन',)
              ],
            ),
            actions: [
              Row(
                children: [
                  TextButton(onPressed: () async {
                    {
                      user=FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await FirebaseAuth.instance.signOut();
                        setState(() {
                          user=FirebaseAuth.instance.currentUser;
                        });
                        ToastWidget.showToast(context, 'Logut success');
                      } else {
                        {
                          {

                            showModalBottomSheet<void>(
                              context: context,
                              useSafeArea: true,
                              elevation: 4,
                              isScrollControlled: true,
                              enableDrag: true,
                              showDragHandle:true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(40.0),
                                ),
                              ),
                              builder: (BuildContext context) {
                                return Container(

                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        SignInBottomSheet(onSuccessLogin: (){
                                          setState(() {
                                            user=FirebaseAuth.instance.currentUser;
                                          });
                                        },)
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        }
                      }
                    }
                  }, child: Text(user!=null?'Logout':'Login',style: TextStyle(color:Colors.green),)),
                ],
              ),
            ],

          ),
          body: TabBarView(
            children: [
              Services(), // Widget for Services tab
              ProductsList(),  // Widget for Market tab
              FeedList()
            ],
          ),
          drawer: DrawerWidget(),
          floatingActionButton: SpeedDial(
            backgroundColor: AppColors.greenColor,
            activeIcon: Icons.support_agent ,
            icon:  Icons.support_agent,
            iconTheme: IconThemeData(color: Colors.white),
            label: Text('Support',style: TextStyle(color: Colors.white),),
            children: [
              SpeedDialChild(
                onTap: () {
                  _makePhoneCall();
                },
                child: Icon(FontAwesomeIcons.phone),
                label: 'Call', // Help text for making a phone call
              ),
              SpeedDialChild(
                onTap: () {
                  launchEnquiryWhatsApp();
                },
                child: Icon(FontAwesomeIcons.whatsapp),
                label: 'WhatsApp', // Help text for launching WhatsApp
              ),
              // Add more SpeedDialChild widgets as needed
            ],
          ),

        ),
      ),
    );
  }
  Widget DrawerWidget(){
    return Drawer(
      width: 270,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[

          Container(
            color: Colors.green,
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20,top: 0),
                      child: Container(
                        padding: EdgeInsets.all(4), // Border width
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.green, width: 2.0), // Adjust width as needed
                        ),
                        child: ClipOval(
                          child: SizedBox.fromSize(
                            size: Size.fromRadius(50), // Image radius
                            child: Image.asset('assets/images/farmer.png', fit: BoxFit.cover),
                          ),
                        ),
                      )

                  ),
                  Image.asset('assets/images/logo.png',height: 50,),
                ],
              ),
            ),
          ),

          ListTile(
            leading: Icon(Icons.list_alt),
            title: Text('My Order'),
            onTap: () {
              user=FirebaseAuth.instance.currentUser;
              if(user!=null){
                Navigator.pop(context);
                Navigator.push(context, customPageRoute(MyBooking()));
              }else{
                Navigator.pop(context);
                ToastWidget.showToast(context, 'please Login');
                showModalBottomSheet<void>(
                  context: context,
                  useSafeArea: true,
                  elevation: 4,
                  isScrollControlled: true,
                  enableDrag: true,
                  showDragHandle:true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(40.0),
                    ),
                  ),
                  builder: (BuildContext context) {
                    return Container(
                      
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SignInBottomSheet(onSuccessLogin: (){
                              setState(() {
                                user=FirebaseAuth.instance.currentUser;
                              });
                            },)
                          ],
                        ),
                      ),
                    );
                  },
                );
              }


            },
          ),
          ListTile(
            leading: Icon(Icons.science_rounded),
            title: Text('Test Request'),
            onTap: () {
              user=FirebaseAuth.instance.currentUser;
              if(user!=null){
                Navigator.pop(context);
                Navigator.push(context, customPageRoute(TestRequest()));
              }else{
                Navigator.pop(context);
                ToastWidget.showToast(context, 'please Login');
                showModalBottomSheet<void>(
                  context: context,
                  useSafeArea: true,
                  elevation: 4,
                  isScrollControlled: true,
                  enableDrag: true,
                  showDragHandle:true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(40.0),
                    ),
                  ),
                  builder: (BuildContext context) {
                    return Container(

                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SignInBottomSheet(onSuccessLogin: (){
                              setState(() {
                                user=FirebaseAuth.instance.currentUser;
                              });
                            },)
                          ],
                        ),
                      ),
                    );
                  },
                );
              }


            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
          user=FirebaseAuth.instance.currentUser;
    if(user!=null){
    Navigator.pop(context);
    Navigator.push(context, customPageRoute(Profile()));
    }else {
      Navigator.pop(context);
      ToastWidget.showToast(context, 'please Login');
      showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        elevation: 4,
        isScrollControlled: true,
        enableDrag: true,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(40.0),
          ),
        ),
        builder: (BuildContext context) {
          return Container(

            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SignInBottomSheet(onSuccessLogin: () {
                    setState(() {
                      user = FirebaseAuth.instance.currentUser;
                    });
                  },)
                ],
              ),
            ),
          );
        },
      );
    }
    },
          ),
          ListTile(
            leading: Icon(Icons.local_florist,),
            title: Text('Fashal-beema'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, customPageRoute(WebViewApp(url:'https://www.gangakoshi.com/fashal-beema')));
            },
          ),

          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, customPageRoute(WebViewApp(url:'https://www.gangakoshi.com/about')));
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              setState(() {
                user=FirebaseAuth.instance.currentUser;
              });
            },
          ),
        ],
      ),
    );
  }



}
