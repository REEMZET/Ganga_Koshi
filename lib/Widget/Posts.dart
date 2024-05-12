
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:ganga_kosi/Pages/PostRead.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:http/http.dart' as http;

import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

import '../Pages/Pagerouter.dart';
import '../Pages/ProductCateogoryList.dart';

class FeedList extends StatefulWidget {
  @override
  _FeedListState createState() => _FeedListState();
}

class _FeedListState extends State<FeedList> {
  late DatabaseReference _databaseReference;

  @override
  void initState() {
    super.initState();

    _databaseReference = FirebaseDatabase.instance.reference().child('/GangaKoshi/Post');
  }

  @override
  Widget build(BuildContext context) {

    return  _buildFeedItem();
  }

  Widget _buildFeedItem() {
    return FirebaseAnimatedList(

        query: _databaseReference,
        sort: (a, b) {
          String timestampA = a.child('timestamp').value.toString();
          String timestampB = b.child('timestamp').value.toString();
          return timestampB.compareTo(timestampA); // Sorting in descending order
        },
        itemBuilder: (context, snapshot, animation, index) {
          String mediaurl = snapshot
              .child('mediaurl')
              .value
              .toString();
          String title = snapshot
              .child('title')
              .value
              .toString();
          String desc = snapshot
              .child('desc')
              .value
              .toString();
          String id = snapshot
              .child('id')
              .value
              .toString();
          String timestamp = snapshot
              .child('timestamp')
              .value
              .toString();
          String posthtmlcode = snapshot
              .child('posthtmlcode')
              .value
              .toString();
          int like = int.parse(snapshot
              .child('like')
              .value
              .toString());
          bool isVideo = mediaurl.toLowerCase().contains('.mp4');

          return InkWell(
            onTap: (){
              Navigator.push(context, customPageRoute(PostReader(title: title, posthtmlcode: posthtmlcode,)));
            },
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              elevation: 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Display image or video
                  isVideo
                      ? VideoWidget(videoUrl: mediaurl)
                      : mediaurl.isNotEmpty
                      ? Image.network(mediaurl)
                      : Placeholder(), // Placeholder for image
                  // Display title
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Display like and share options
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.favorite_border, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _increaseLike(id,like);
                                });
                              },
                            ),
                            Text(like.toString()),
                          ],
                        ), // Display like count
                        IconButton(
                          icon: Icon(Icons.share),
                          onPressed: () {Sharecontent(desc,mediaurl);},
                        ),
                        Text(timeAgo(timestamp)), // Display share count
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(desc.substring(0,100)),
                  ),

                ],
              ),
            ),
          );
        },
    );
  }
  void _increaseLike(String postId, int like) {
    _databaseReference.child(postId).update({
      "like":like+1
    });
  }


Future<void> Sharecontent(String textmsg,String imageurl) async {
    try {
      String currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final uri = Uri.parse(imageurl);
      final temp = await getTemporaryDirectory();
      final path = '${temp.path}/${currentTimestamp}.png';

      if (await File(path).exists()) {
        await Share.shareXFiles(
            [XFile(path)],
            subject: 'Share Ganga Post',
            text: textmsg,
        );
      } else {
        final response = await http.get(uri);
        final bytes = response.bodyBytes;
        await File(path).writeAsBytes(bytes);

        // Share the newly saved image
        await Share.shareXFiles(
            [XFile(path)],
            subject: 'Share Voter details',
            text: textmsg
        );
      }
    } on SocketException catch (e) {
      print(e);
    }
  }

}

  String timeAgo(String timestamp) {
    int postTimestamp = int.parse(timestamp);
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch;

    Duration difference = Duration(milliseconds: currentTimestamp - postTimestamp);

    if (difference.inDays > 365) {
      int years = difference.inDays ~/ 365;
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays >= 30) {
      int months = difference.inDays ~/ 30;
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays >= 7) {
      int weeks = difference.inDays ~/ 7;
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'just now';
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
