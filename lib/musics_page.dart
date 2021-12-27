import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'category_item.dart';
import 'music_item.dart';

class MusicsPage extends StatelessWidget {
  final User user;
  final Map<String, dynamic> datass;

  MusicsPage(this.user, this.datass);

  Stream<QuerySnapshot> buildStream() {
    return FirebaseFirestore.instance
        .collection("musics")
        .orderBy("listenNumber", descending: true)
        .limit(7)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> categories = [
      CategoryItem("R&B", datass),
      CategoryItem("Caz", datass),
      CategoryItem("Blues", datass),
      CategoryItem("Rap", datass),
      CategoryItem("Pop", datass),
      CategoryItem("Rock", datass),
      CategoryItem("Elektronik", datass),
      CategoryItem("Klasik", datass),
      CategoryItem("Halk", datass)
    ];
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
          snapshot.data.docs.forEach((element) {
            ids.add(element.id);
            datas.add(element.data());
          });
          return Container(
            padding: EdgeInsets.only(top: 50, left: 15, right: 15, bottom: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text("Müzik Türleri",
                          style: TextStyle(fontSize: 32, color: Colors.black)),
                    ],
                  ),
                  Container(
                    width: 500,
                    height: 380,
                    child: GridView(
                      primary: false,
                      children: categories,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 140,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text("En Çok Dinlenenler",
                          style: TextStyle(fontSize: 32, color: Colors.black)),
                    ],
                  ),
                  Container(
                    width: 500,
                    height: 610,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
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
                            datass,
                            null,
                            null);
                      },
                      itemCount: datas.length,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
