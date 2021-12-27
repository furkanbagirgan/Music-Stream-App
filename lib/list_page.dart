import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'music_item.dart';

class ListPage extends StatefulWidget {
  final User user;
  final Map<String, dynamic> datas;

  ListPage(this.user, this.datas);

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  Stream<QuerySnapshot> buildStream() {
    return FirebaseFirestore.instance
        .collection("musics")
        .orderBy("listenNumber", descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: buildStream(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasData) {
          List<Map<String, dynamic>> datas = [];
          List<String> ids = [];
          if (widget.datas["musicList"].isNotEmpty) {
            snapshot.data.docs.forEach((element) {
              if (widget.datas["musicList"].contains(element.id)) {
                ids.add(element.id);
                datas.add(element.data());
              }
            });
          }
          if (datas.length == 0) {
            return Center(
                child: Text("Henüz listenize bir müzik eklemediniz..."));
          } else {
            return Container(
                padding:
                    EdgeInsets.only(top: 50, left: 15, right: 15, bottom: 20),
                child: Column(children: [
                  Row(
                    children: [
                      Text("Listem",
                          style: TextStyle(fontSize: 32, color: Colors.black)),
                    ],
                  ),
                  (snapshot.hasData && datas.isNotEmpty)
                      ? Container(
                          width: 500,
                          height: 610,
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
                                  2,
                                  widget.datas,
                                  ids,
                                  datas);
                            },
                            itemCount: datas.length,
                          ),
                        )
                      : Text("Henüz bir sanatçı eklenmedi..."),
                ]));
          }
        } else {
          return Center(
              child: Text("Henüz listenize bir müzik eklemediniz..."));
        }
      },
    );
  }
}
