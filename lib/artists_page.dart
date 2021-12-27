import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'artist_item.dart';

class ArtistsPage extends StatefulWidget {
  final User user;
  final Map<String, dynamic> datas;

  ArtistsPage(this.user, this.datas);

  @override
  _ArtistsPageState createState() => _ArtistsPageState();
}

class _ArtistsPageState extends State<ArtistsPage> {
  List _allResult = [];
  List _resultsList = [];
  TextEditingController _searchController = TextEditingController();
  Future _resultLoaded;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resultLoaded = buildStream();
  }

  void _onSearchChanged() {
    searchResultsList();
  }

  searchResultsList() {
    var showResults = [];
    if (_searchController.text != "") {
      for (var music in _allResult) {
        var name = music["name"].toLowerCase();
        if (name.contains(_searchController.text.toLowerCase())) {
          showResults.add(music);
        }
      }
    } else {
      showResults = List.from(_allResult);
    }
    setState(() {
      _resultsList = showResults;
    });
  }

  buildStream() async {
    var data = await FirebaseFirestore.instance
        .collection("users")
        .where("userMusics", isNotEqualTo: null)
        .get();
    setState(() {
      _allResult = data.docs;
    });
    searchResultsList();
    return "complete";
  }

  /*Stream<QuerySnapshot> buildStream() {
    return FirebaseFirestore.instance.collection("users").snapshots();
  }*/

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.only(top: 50, left: 15, right: 15, bottom: 20),
            child: Column(children: [
              Row(
                children: [
                  Text("Sanatçılar",
                      style: TextStyle(fontSize: 32, color: Colors.black)),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "Aramak istediğiniz sanatçının adını giriniz..."),
                style: TextStyle(fontSize: 14),
              ),
              (_resultsList.isNotEmpty && _resultsList.length != 0)
                  ? Container(
                      width: 500,
                      height: 600,
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return ArtistItem(
                              _resultsList[index].id,
                              _resultsList[index].data()["artist"],
                              _resultsList[index].data()["image"],
                              _resultsList[index].data()["listenNumber"],
                              (index + 1),
                              _resultsList.length,
                              widget.datas);
                        },
                        itemCount: _resultsList.length,
                      ),
                    )
                  : Container(
                      margin: EdgeInsets.symmetric(vertical: 30),
                      child: Text("Sanatçı bulunamadı !"),
                    ),
            ])));
  }
}
