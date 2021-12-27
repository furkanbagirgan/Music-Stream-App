import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'music_item.dart';

class ArtistDetailPage extends StatefulWidget {
  static const String routeName = "/artist-detail";

  @override
  _ArtistDetailPageState createState() => _ArtistDetailPageState();
}

class _ArtistDetailPageState extends State<ArtistDetailPage> {
  String _artist = "";
  String _imageUrl = "";
  int _listenNumber = 0;
  Map<String, dynamic> _datas;

  @override
  void initState() {
    super.initState();
  }

  Stream<QuerySnapshot> buildStream() {
    return FirebaseFirestore.instance
        .collection("musics")
        .where("artist", isEqualTo: _artist)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    _imageUrl = args["image"];
    _artist = args["artist"];
    _listenNumber = args["listenNumber"];
    _datas = args["datas"];
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: buildStream(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          List<Map<String, dynamic>> datas = [];
          List<String> ids = [];
          snapshot.data.docs.forEach((element) {
            ids.add(element.id);
            datas.add(element.data());
          });
          return SingleChildScrollView(
              child: Padding(
            padding: EdgeInsets.only(top: 50, left: 15, right: 15, bottom: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey,
                          child: Icon(
                            Icons.account_box,
                            color: Colors.white,
                            size: (_imageUrl == null || _imageUrl.isEmpty)
                                ? 70
                                : 0,
                          ),
                          backgroundImage:
                              (_imageUrl == null || _imageUrl.isEmpty)
                                  ? null
                                  : NetworkImage(_imageUrl),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          _artist,
                          style: TextStyle(fontSize: 32, color: Colors.black),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    Text(
                      "$_listenNumber",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Müzikleri",
                      style: TextStyle(fontSize: 32, color: Colors.black),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                (snapshot.hasData && datas.isNotEmpty)
                    ? SizedBox(
                        height: 0,
                      )
                    : SizedBox(
                        height: 30,
                      ),
                (snapshot.hasData && datas.isNotEmpty)
                    ? Container(
                        width: 500,
                        height: 520,
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            return MusicItem(
                                ids[index],
                                datas[index]["name"],
                                datas[index]["image"],
                                datas[index]["music"],
                                datas[index]["listenNumber"],
                                datas[index]["artist"],
                                (index + 1),
                                datas.length,
                                0,
                                _datas,null,null);
                          },
                          itemCount: datas.length,
                        ),
                      )
                    : Text("Henüz bir müzik eklenmemiş..."),
                (snapshot.hasData && datas.isNotEmpty)
                    ? SizedBox(
                        height: 50,
                      )
                    : SizedBox(
                        height: 60,
                      ),
              ],
            ),
          ));
        },
      ),
    );
  }
}
