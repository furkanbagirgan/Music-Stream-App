import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'landing_page.dart';
import 'music_item.dart';

class UserPage extends StatefulWidget {
  final User user;
  final Map<String, dynamic> datas;

  UserPage(this.user, this.datas);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  File _image;
  bool _changeImage = false;
  String _email = "";
  String _name = "";
  String _surname = "";
  String _artist = "";
  String _imageUrl;

  @override
  void initState() {
    super.initState();
    _name = widget.datas["name"];
    _surname = widget.datas["surname"];
    _email = widget.datas["email"];
    _imageUrl = widget.datas["image"];
    _artist = widget.datas["artist"];
  }

  void _saveImage() async {
    if (_changeImage) {
      if (_image != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child("userImages")
            .child(widget.user.uid + ".png");
        await ref.putFile(_image).whenComplete(() => null);
        _imageUrl = await ref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.user.uid)
            .update({"image": _imageUrl});
      } else {
        final ref = FirebaseStorage.instance
            .ref()
            .child("userImages")
            .child(widget.user.uid + ".png");
        await ref.delete();
        await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.user.uid)
            .update({"image": ""});
      }
    }
  }

  void _deleteAccount(BuildContext ctx) async {
    String sifre = "";
    bool hataVar = false;
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: Text("Hesabı Sil"),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Text("Size ait tüm veriler silinecektir!\n"
                  " Hesabınızı silmek için hesap şifrenizi giriniz"),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    hintText: "Hesap Şifresi",
                    border: OutlineInputBorder()),
                onChanged: (girilenDeger) async {
                  sifre = girilenDeger.trim();
                },
              )
            ]),
            actions: [
              FlatButton(
                  onPressed: hataVar
                      ? () {}
                      : () async {
                          hataVar = false;
                          try {
                            AuthCredential credentialss =
                                EmailAuthProvider.credential(
                                    email: _email, password: sifre);
                            UserCredential resultt = await widget.user
                                .reauthenticateWithCredential(credentialss);
                          } catch (err) {
                            hataVar = true;
                          }
                          if (!hataVar) {
                            final ref = FirebaseStorage.instance
                                .ref()
                                .child("userImages")
                                .child(widget.user.uid + ".png");
                            await ref.delete();
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(widget.user.uid)
                                .delete();
                            final AuthCredential credentials =
                                EmailAuthProvider.credential(
                                    email: _email, password: sifre);
                            final UserCredential result = await widget.user
                                .reauthenticateWithCredential(credentials);
                            await result.user.delete().whenComplete(() => null);
                            await FirebaseAuth.instance.signOut();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => LandingPage(),
                              ),
                            );
                          }
                        },
                  child: Text("Sil")),
              FlatButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text("İptal")),
            ],
          );
        });
  }

  void _pickImage() async {
    _changeImage = true;
    final pickedImage = await ImagePicker.platform.pickImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 150);
    setState(() {
      _image = File(pickedImage.path);
    });
  }

  void _deleteImage() {
    setState(() {
      _changeImage = true;
      _image = null;
      _imageUrl = null;
    });
  }

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
        List<Map<String, dynamic>> datas = [];
        List<String> ids = [];
        if (snapshot.hasData && widget.datas["userMusics"].isNotEmpty) {
          snapshot.data.docs.forEach((element) {
            if (widget.datas["userMusics"].contains(element.id)) {
              ids.add(element.id);
              datas.add(element.data());
            }
          });
        }
        return Container(
            padding: EdgeInsets.only(top: 50, left: 15, right: 15, bottom: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Bilgilerim",
                        style: TextStyle(fontSize: 32, color: Colors.black),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.account_box,
                          color: Colors.white,
                          size: _changeImage
                              ? (_image == null ? 70 : 0)
                              : ((_imageUrl == null || _imageUrl.isEmpty)
                                  ? 70
                                  : 0),
                        ),
                        backgroundImage: _changeImage
                            ? (_image == null ? null : FileImage(_image))
                            : ((_imageUrl == null || _imageUrl.isEmpty)
                                ? null
                                : NetworkImage(_imageUrl)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FlatButton.icon(
                            textColor: Theme.of(context).primaryColor,
                            onPressed: _pickImage,
                            label: Text("Değiştir"),
                            icon: Icon(Icons.add_a_photo),
                          ),
                          FlatButton.icon(
                            textColor: Theme.of(context).primaryColor,
                            onPressed: _deleteImage,
                            label: Text("Kaldır"),
                            icon: Icon(Icons.image_not_supported),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 40,
                    color: Colors.white,
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Text("Ad:"),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          _name,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black38),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    height: 40,
                    color: Colors.white,
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Text("Soyad:"),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          _surname,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black38),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    height: 40,
                    color: Colors.white,
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Text("Email:"),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          _email,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black38),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    height: 40,
                    color: Colors.white,
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Text("Artist:"),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          _artist,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black38),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Müziklerim",
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
                          height: 450,
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
                                  1,
                                  widget.datas,null,null);
                            },
                            itemCount: datas.length,
                          ),
                        )
                      : Text("Henüz bir müzik eklemediniz..."),
                  (snapshot.hasData && datas.isNotEmpty)
                      ? SizedBox(
                          height: 50,
                        )
                      : SizedBox(
                          height: 60,
                        ),
                  RaisedButton(
                    onPressed: _saveImage,
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Container(
                      width: 150,
                      height: 40,
                      alignment: Alignment.center,
                      child: Text(
                        "Değişiklikleri Kaydet",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  RaisedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => LandingPage(),
                        ),
                      );
                    },
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Container(
                      width: 150,
                      height: 40,
                      alignment: Alignment.center,
                      child: Text(
                        "Çıkış Yap",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  RaisedButton(
                    onPressed: () => _deleteAccount(context),
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Container(
                      width: 150,
                      height: 40,
                      alignment: Alignment.center,
                      child: Text(
                        "Hesabı Sil",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }
}
