import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:music_stream/user_page.dart';

import 'add_music_page.dart';
import 'artists_page.dart';
import 'list_page.dart';
import 'musics_page.dart';

class TabsPage extends StatefulWidget {
  final User user;
  final VoidCallback signOut;
  final FirebaseAuth auth;

  TabsPage(this.user, this.signOut, this.auth);

  @override
  _TabsPageState createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  List<Map<String, Object>> _pages;
  int _selectedPageIndex = 0;
  Map<String, dynamic> _datas;
  bool _isStart = false;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  void initState() {
    _isStart = false;
    super.initState();
  }

  Stream<QuerySnapshot> buildStream() {
    return FirebaseFirestore.instance.collection("users").snapshots();
  }

  @override
  Widget build(BuildContext context) {
    String title = "";
    if (_isStart) {
      title = _pages[_selectedPageIndex]["title"];
    } else {
      title = "Müzikler";
    }
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: buildStream(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            snapshot.data.docs.forEach((element) {
              String userEmail = element.data()["email"];
              if (userEmail == widget.user.email) {
                _datas = element.data();
                _datas["id"] = element.id;
              }
            });
            _isStart = true;
            _pages = [
              {"page": MusicsPage(widget.user, _datas), "title": "Müzikler"},
              {"page": ArtistsPage(widget.user, _datas), "title": "Sanatçılar"},
              {"page": ListPage(widget.user, _datas), "title": "Listem"},
              {"page": UserPage(widget.user, _datas), "title": "Ben"}
            ];
            return _pages[_selectedPageIndex]["page"];
          } else {
            return Center(child: Text("Ana Ekran Yüklenemedi !"));
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        showUnselectedLabels: true,
        backgroundColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.black,
        currentIndex: _selectedPageIndex,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.library_music_outlined), label: "Müzikler"),
          BottomNavigationBarItem(
              icon: Icon(Icons.supervisor_account_outlined),
              label: "Sanatçılar"),
          BottomNavigationBarItem(
              icon: Icon(Icons.queue_music_outlined), label: "Listem"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined), label: "Ben"),
        ],
      ),
      floatingActionButton: _selectedPageIndex == 3
          ? FloatingActionButton(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              backgroundColor: Colors.grey,
              onPressed: () {
                setState(() {
                  Navigator.of(context).pushNamed(AddMusicPage.routeName,
                      arguments: {"datas": _datas});
                });
              },
            )
          : null,
    );
  }
}
