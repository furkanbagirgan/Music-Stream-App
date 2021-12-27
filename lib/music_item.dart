import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';

import 'music_detail_page.dart';

class MusicItem extends StatelessWidget {
  final String id;
  final String name;
  final String image;
  final String music;
  final int listenNumber;
  final String artist;
  final int rank;
  final int rank1;
  final int isComingFrom;
  final Map<String, dynamic> datas;
  final List<String> ids;
  final List<Map<String, dynamic>> datass;

  MusicItem(
      this.id,
      this.name,
      this.image,
      this.music,
      this.listenNumber,
      this.artist,
      this.rank,
      this.rank1,
      this.isComingFrom,
      this.datas,
      this.ids,
      this.datass);

  void selectMusic(BuildContext ctx) async {
    Navigator.of(ctx).pushNamed(MusicDetailPage.routeName, arguments: {
      "name": name,
      "artist": artist,
      "image": image,
      "audio": music,
      "id": id,
      "listenNumber": listenNumber,
      "isComingFrom": isComingFrom,
      "datas": datas,
      "rank": rank,
      "rank1": rank1,
      "ids": ids,
      "datass": datass,
    });
  }

  void addMusicToList(BuildContext ctx) async {
    datas["musicList"].add(id);
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({"musicList": datas["musicList"]});
  }

  void deleteMusic() async {
    datas["userMusics"].remove(id);
    await FirebaseFirestore.instance.collection("musics").doc(id).delete();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({"userMusics": datas["userMusics"]});
    if (image != null && image.isNotEmpty) {
      final ref = FirebaseStorage.instance
          .ref()
          .child("musics")
          .child("musicImages")
          .child(id + ".png");
      await ref.delete();
    }
    if (music != null && music.isNotEmpty) {
      final ref = FirebaseStorage.instance
          .ref()
          .child("musics")
          .child("musicFiles")
          .child(id + ".mp3");
      await ref.delete();
    }
  }

  void deleteMusicFromList() async {
    datas["musicList"].remove(id);
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({"musicList": datas["musicList"]});
  }

  @override
  Widget build(BuildContext context) {
    return FocusedMenuHolder(
      onPressed: () => selectMusic(context),
      menuItems: [
        FocusedMenuItem(
            title: Text("Oynat"),
            onPressed: () => selectMusic(context),
            trailingIcon: Icon(Icons.play_circle_fill)),
        (isComingFrom == 1)
            ? FocusedMenuItem(
                title: Text("Sil"),
                onPressed: () => deleteMusic(),
                trailingIcon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ))
            : (isComingFrom == 2)
                ? FocusedMenuItem(
                    title: Text("Listemden Sil"),
                    onPressed: () => deleteMusicFromList(),
                    trailingIcon: Icon(
                      Icons.delete_sweep,
                      color: Colors.red,
                    ))
                : (datas["musicList"].contains(id))
                    ? FocusedMenuItem(
                        title: Text("Listemden Sil"),
                        onPressed: () => deleteMusicFromList(),
                        trailingIcon: Icon(
                          Icons.delete_sweep,
                          color: Colors.red,
                        ))
                    : FocusedMenuItem(
                        title: Text("Listeme Ekle"),
                        onPressed: () => addMusicToList(context),
                        trailingIcon: Icon(Icons.playlist_add))
      ],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: (image == null || image.isEmpty)
                    ? Colors.grey
                    : Colors.white,
                child: Icon(
                  Icons.music_note,
                  size: (image == null || image.isEmpty) ? 20 : 0,
                ),
                backgroundImage: (image == null || image.isEmpty)
                    ? null
                    : NetworkImage(image),
              ),
              title: Text(name),
              subtitle: Text(artist),
              trailing: Text("$listenNumber")),
          if (rank != rank1)
            Divider(
              height: 10,
              thickness: 1,
              color: Colors.black38,
            ),
        ],
      ),
    );
  }
}
