import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddMusicPage extends StatefulWidget {
  static const String routeName = "/add-music";

  @override
  _AddMusicPageState createState() => _AddMusicPageState();
}

class _AddMusicPageState extends State<AddMusicPage> {
  final _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  File _image;
  File _audio;
  bool _changeImage = false;
  bool _changeMusic = false;
  String _duration;
  String _category = "R&B";
  String _name;
  Map<String, dynamic> _datas;

  void _saveMusic(BuildContext ctx) async {
    bool hataVar = false;

    String name;
    if (!hataVar) {
      if (_name != null && !_name.isEmpty) {
        name = _name;
      } else {
        hataVar = true;
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Müzik adı girilmedi!"),
          backgroundColor: Theme.of(ctx).errorColor,
        ));
      }
    }
    double duration;
    if (!hataVar) {
      if (_duration != null && _duration.isNotEmpty) {
        duration = double.parse(_duration);
      } else {
        hataVar = true;
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Müzik süresi girilmedi!"),
          backgroundColor: Theme.of(ctx).errorColor,
        ));
      }
    }
    String image = "";
    if (!hataVar) {
      if (_changeImage) {
        if (_image == null) {
          image = "";
        } else {
          image = _image.path;
        }
      } else {
        image = "";
      }
    }
    String music = "";
    if (!hataVar) {
      if (_changeMusic) {
        if (_audio == null) {
          hataVar = true;
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Müzik seçilmedi!"),
            backgroundColor: Theme.of(ctx).errorColor,
          ));
        } else {
          music = _audio.path;
        }
      } else {
        hataVar = true;
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Müzik seçilmedi!"),
          backgroundColor: Theme.of(ctx).errorColor,
        ));
      }
    }
    if (!hataVar) {
      DocumentReference df =
          await FirebaseFirestore.instance.collection("musics").add({
        "image": "",
        "music": "",
        "name": name,
        "duration": duration,
        "addingUser": _datas["id"],
        "artist": _datas["artist"],
        "listenNumber": 0,
        "category": _category,
      });
      String musicId = df.id;
      List<dynamic> musics = _datas["userMusics"];
      musics.add(musicId);
      await FirebaseFirestore.instance
          .collection("users")
          .doc(_datas["id"])
          .update({"userMusics": musics});
      if (image != "" && image.isNotEmpty) {
        String _imageUrl;
        final ref = FirebaseStorage.instance
            .ref()
            .child("musics")
            .child("musicImages")
            .child(musicId + ".png");
        await ref.putFile(_image).whenComplete(() => null);
        _imageUrl = await ref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection("musics")
            .doc(musicId)
            .update({"image": _imageUrl});
      }
      if (music != "" && music.isNotEmpty) {
        String _musicUrl;
        final ref = FirebaseStorage.instance
            .ref()
            .child("musics")
            .child("musicFiles")
            .child(musicId + ".mp3");
        await ref.putFile(_audio).whenComplete(() => null);
        _musicUrl = await ref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection("musics")
            .doc(musicId)
            .update({"music": _musicUrl});
      }
      Navigator.of(ctx).pop();
    }
  }

  void _openAudioPicker() async {
    _changeMusic = true;
    FilePickerResult result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ["mp3"]);
    if (result != null) {
      setState(() {
        _audio = File(result.files.single.path);
      });
    }
  }

  void _imagePick() async {
    _changeImage = true;
    final pickedImage = await ImagePicker.platform.pickImage(
        source: ImageSource.gallery, imageQuality: 100, maxWidth: 150);
    setState(() {
      _image = File(pickedImage.path);
    });
  }

  void _deleteImage() {
    setState(() {
      _changeImage = true;
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    _datas = args["datas"];
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 50, left: 15, right: 15, bottom: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Müzik Ekle",
                    style: TextStyle(fontSize: 32, color: Colors.black),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 150,
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.music_video,
                      color: Colors.white,
                      size: _changeImage ? (_image == null ? 150 : 0) : 150,
                    ),
                    backgroundImage: _changeImage
                        ? (_image == null ? null : FileImage(_image))
                        : null,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlatButton.icon(
                        textColor: Theme.of(context).primaryColor,
                        onPressed: _imagePick,
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
              Padding(
                padding:
                    const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Müzik:",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          RaisedButton(
                            onPressed: () {
                              _openAudioPicker();
                            },
                            color: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Container(
                              width: 100,
                              height: 40,
                              alignment: Alignment.center,
                              child: Text(
                                "Müzik Seç",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            (_audio != null) ? Icons.check_circle : null,
                            color: Colors.green,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Text(
                            "Müzik Adı:",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                              width: 225,
                              height: 50,
                              child: TextFormField(
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.only(top: 18, left: 10),
                                    hintText: "Müzik Adı",
                                    border: OutlineInputBorder()),
                                onSaved: (girilenDeger) {
                                  _name = girilenDeger;
                                },
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Text(
                            "Müzik Süresi (dk.sn):",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                              width: 100,
                              height: 50,
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(top: 18),
                                    prefixIcon: Icon(Icons.schedule),
                                    hintText: "3.12",
                                    border: OutlineInputBorder()),
                                onSaved: (girilenDeger) {
                                  _duration = girilenDeger;
                                },
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Text(
                            "Kategori:",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                              width: 100,
                              height: 50,
                              child: DropdownButton(
                                items: [
                                  DropdownMenuItem(
                                    child: Text("R&B"),
                                    value: "R&B",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("Caz"),
                                    value: "Caz",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("Blues"),
                                    value: "Blues",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("Rap"),
                                    value: "Rap",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("Pop"),
                                    value: "Pop",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("Rock"),
                                    value: "Rock",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("Elektronik"),
                                    value: "Elektronik",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("Klasik"),
                                    value: "Klasik",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("Halk"),
                                    value: "Halk",
                                  ),
                                ],
                                onChanged: (secilenDeger) {
                                  setState(() {
                                    _category = secilenDeger;
                                  });
                                },
                                value: _category,
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      RaisedButton(
                        onPressed: () {
                          _formKey.currentState.save();
                          _saveMusic(context);
                        },
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Container(
                          width: 150,
                          height: 40,
                          alignment: Alignment.center,
                          child: Text(
                            "Ekle",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
