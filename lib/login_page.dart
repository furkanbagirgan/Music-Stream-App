import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

enum FormType { Register, Login }

class LoginPage extends StatefulWidget {
  final Function(User) onSignIn;
  final FirebaseAuth auth;
  LoginPage(this.onSignIn, this.auth);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email, _sifre;
  String _name = "", _surname = "", _artist = "";
  String _buttonText, _linkText;
  var _formType = FormType.Login;
  final _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  File _image;

  void addUser(User user, String email, String name, String surname,
      String artist) async {
    String image = "";
    List<String> musicList = [];
    List<String> userMusics = [];
    int listenNumber = 0;

    if (_image != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child("userImages")
          .child(user.uid + ".png");
      await ref.putFile(_image).whenComplete(() => null);
      image = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "email": email,
      "musicList": musicList,
      "name": name,
      "surname": surname,
      "artist": artist,
      "userMusics": userMusics,
      "image": image,
      "listenNumber": listenNumber
    });
  }

  void signInEmail(BuildContext ctx) async {
    if (_email.contains("@")) {
      if (_sifre.length >= 6) {
        bool userVar = false;
        await FirebaseFirestore.instance
            .collection("users")
            .where("email", isEqualTo: _email)
            .get()
            .then((value) {
          value.docs.forEach((element) {
            userVar = true;
          });
        });
        if (!userVar) {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Bu Mail Adresine Sahip Bir Hesap Bulunmamakta!"),
            backgroundColor: Theme.of(ctx).errorColor,
          ));
        } else {
          try {
            UserCredential result = await widget.auth
                .signInWithEmailAndPassword(email: _email, password: _sifre);
            widget.onSignIn(result.user);
          } catch (err) {
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text("Girilen Şifre Hatalı!"),
              backgroundColor: Theme.of(ctx).errorColor,
            ));
          }
        }
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Şifre En Az 6 Karakter Uzunluğunda Olmalıdır!"),
          backgroundColor: Theme.of(ctx).errorColor,
        ));
      }
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Email Adresi Uygun Formatta Değil!"),
        backgroundColor: Theme.of(ctx).errorColor,
      ));
    }
  }

  void createEmail(BuildContext ctx) async {
    if (_email != "") {
      if (_sifre != "") {
        if (_name != "") {
          if (_surname != "") {
            if (_artist != "") {
              if (_email.contains("@")) {
                if (_sifre.length >= 6) {
                  bool userVar = false;
                  await FirebaseFirestore.instance
                      .collection("users")
                      .where("email", isEqualTo: _email)
                      .get()
                      .then((value) {
                    value.docs.forEach((element) {
                      userVar = true;
                    });
                  });
                  if (!userVar) {
                    UserCredential result = await widget.auth
                        .createUserWithEmailAndPassword(
                            email: _email, password: _sifre);
                    addUser(result.user, _email, _name, _surname, _artist);
                    widget.onSignIn(result.user);
                  } else {
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text(
                          "Bu Mail Adresine Sahip Bir Hesap Zaten Bulunmakta!"),
                      backgroundColor: Theme.of(ctx).errorColor,
                    ));
                  }
                } else {
                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                    content:
                        Text("Şifre En Az 6 Karakter Uzunluğunda Olmalıdır!"),
                    backgroundColor: Theme.of(ctx).errorColor,
                  ));
                }
              } else {
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text("Email Adresi Uygun Formatta Değil!"),
                  backgroundColor: Theme.of(ctx).errorColor,
                ));
              }
            } else {
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text("Artist Boş Bırakılamaz!"),
                backgroundColor: Theme.of(ctx).errorColor,
              ));
            }
          } else {
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text("Soyad Boş Bırakılamaz!"),
              backgroundColor: Theme.of(ctx).errorColor,
            ));
          }
        } else {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Ad Boş Bırakılamaz!"),
            backgroundColor: Theme.of(ctx).errorColor,
          ));
        }
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Şifre Boş Bırakılamaz!"),
          backgroundColor: Theme.of(ctx).errorColor,
        ));
      }
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Email Boş Bırakılamaz!"),
        backgroundColor: Theme.of(ctx).errorColor,
      ));
    }
  }

  void _degistir() {
    setState(() {
      _formType =
          _formType == FormType.Login ? FormType.Register : FormType.Login;
    });
  }

  void _pickImage() async {
    final pickedImage = await ImagePicker.platform.pickImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 150);
    setState(() {
      _image = File(pickedImage.path);
    });
  }

  void _deleteImage() {
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    _buttonText = _formType == FormType.Login ? "Giriş Yap" : "Kayıt Ol";
    _linkText = _formType == FormType.Login ? "Kayıt Ol" : "Giriş Yap";

    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Form(
              key: _formKey,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _formType == FormType.Login ? "Giriş Yap" : "Kayıt Ol",
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    _formType == FormType.Register
                        ? Column(
                            children: [
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
                                      size: _image == null ? 70 : 0,
                                    ),
                                    backgroundImage: _image == null
                                        ? null
                                        : FileImage(_image),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      FlatButton.icon(
                                        textColor:
                                            Theme.of(context).primaryColor,
                                        onPressed: _pickImage,
                                        label: Text("Ekle"),
                                        icon: Icon(Icons.add_a_photo),
                                      ),
                                      FlatButton.icon(
                                        textColor:
                                            Theme.of(context).primaryColor,
                                        onPressed: _deleteImage,
                                        label: Text("Kaldır"),
                                        icon: Icon(Icons.image_not_supported),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              )
                            ],
                          )
                        : SizedBox(
                            height: 0,
                          ),
                    _formType == FormType.Register
                        ? TextFormField(
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.account_box),
                                hintText: "Ad",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            onSaved: (girilenDeger) {
                              _name = girilenDeger;
                            },
                          )
                        : SizedBox(
                            height: 0,
                          ),
                    _formType == FormType.Register
                        ? SizedBox(
                            height: 10,
                          )
                        : SizedBox(
                            height: 0,
                          ),
                    _formType == FormType.Register
                        ? TextFormField(
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.account_box),
                                hintText: "Soyad",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            onSaved: (girilenDeger) {
                              _surname = girilenDeger;
                            },
                          )
                        : SizedBox(
                            height: 0,
                          ),
                    _formType == FormType.Register
                        ? SizedBox(
                            height: 10,
                          )
                        : SizedBox(
                            height: 0,
                          ),
                    _formType == FormType.Register
                        ? TextFormField(
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.supervisor_account),
                                hintText: "Artist",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            onSaved: (girilenDeger) {
                              _artist = girilenDeger;
                            },
                          )
                        : SizedBox(
                            height: 0,
                          ),
                    _formType == FormType.Register
                        ? SizedBox(
                            height: 10,
                          )
                        : SizedBox(
                            height: 0,
                          ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.mail),
                          hintText: "Email",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30))),
                      onSaved: (girilenDeger) {
                        _email = girilenDeger.trim();
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        hintText: "Şifre",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onSaved: (girilenDeger) {
                        _sifre = girilenDeger.trim();
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RaisedButton(
                      onPressed: () {
                        _formKey.currentState.save();
                        if (_formType == FormType.Login) {
                          signInEmail(context);
                        } else {
                          createEmail(context);
                        }
                      },
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: Container(
                        width: 150,
                        height: 40,
                        alignment: Alignment.center,
                        child: Text(
                          _buttonText,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _degistir(),
                      child: Text(
                        _linkText,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
