import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';



class PostReader extends StatefulWidget {
  final String title;
  final String posthtmlcode;

   PostReader({ required this.title, required this.posthtmlcode});

  @override
  State<PostReader> createState() => _PostReaderState();
}

class _PostReaderState extends State<PostReader> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text(widget.title),elevation: 2,),
      body: SingleChildScrollView(
           child:Padding(
             padding: const EdgeInsets.only(left: 10,right: 10,top: 2,bottom: 2),
             child: HtmlWidget(widget.posthtmlcode),
           ),
      )
    );
  }
}
