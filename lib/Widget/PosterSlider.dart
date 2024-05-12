import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';



class PosterSliderWidget extends StatefulWidget {
  @override
  _PosterSliderWidgetState createState() => _PosterSliderWidgetState();
}

class _PosterSliderWidgetState extends State<PosterSliderWidget> {
  List<String> mediaUrls = [];
  List<String> eventList = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    fetchDataFromFirebase();
  }

  Future<void> fetchDataFromFirebase() async {
    try {
      final databaseReference =
      FirebaseDatabase.instance.reference().child('GangaKoshi/Slider');
      DataSnapshot dataSnapshot =
      await databaseReference.once().then((event) => event.snapshot);

      Map<dynamic, dynamic>? sliderData =
      dataSnapshot.value as Map<dynamic, dynamic>?;

      if (sliderData != null) {
        for (var entry in sliderData.entries) {
          String mediaUrl = entry.value['posterurl'];
          String mediaType = entry.value['mediatype'];
          String eventText = entry.value['posterevent'];

          if (mediaType == 'image' || mediaType == 'video') {
            mediaUrls.add(mediaUrl);
            eventList.add(eventText);
          }
        }

        setState(() {});
      } else {
        // Handle the case where the data is not in the expected format.
        print('Data is not in the expected format');
        // You can display an error message to the user or take appropriate action.
      }
    } catch (e) {
      // Handle exceptions here.
      print('Error accessing Firebase: $e');
      // You can display an error message to the user or take appropriate action.
    }
  }

  Widget buildCarouselItem(int index) {
    String mediaUrl = mediaUrls[index];
    String eventText = eventList[index];

    return Builder(
      builder: (BuildContext context) {
        return InkWell(
          child: Card(
            surfaceTintColor: Colors.white,
            margin: EdgeInsets.all(4),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: mediaUrl.contains('.mp4')
                  ? VideoWidget(videoUrl: mediaUrl)
                  : Image.network(
                mediaUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          onTap: () {
            if (eventText != "no") {
             // Navigator.push(context, customPageRoute(SubCateogoryServiceList(subcatlistref:eventText,title: 'Kosi Service',)));
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 170,
        autoPlay: true,
        aspectRatio: 21 / 9,
        enlargeCenterPage: true,
        disableCenter: true,
        enableInfiniteScroll: true,
        autoPlayInterval: const Duration(seconds: 3),
      ),
      items: mediaUrls.asMap().entries.map((entry) {
        int index = entry.key;
        return buildCarouselItem(index);
      }).toList(),
    );
  }
}

class VideoWidget extends StatefulWidget {
  final String videoUrl;

  VideoWidget({required this.videoUrl});

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        _controller.play();
        _controller.setVolume(0);
        _controller.setLooping(true);
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    )
        : Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
