import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'music_item.dart';

class CategoryMusicsPage extends StatefulWidget {
  static const String routeName = "/category-meals";

  @override
  _CategoryMusicsPageState createState() => _CategoryMusicsPageState();
}

class _CategoryMusicsPageState extends State<CategoryMusicsPage> {
  String _categoryTitle;
  Map<String, dynamic> _datas;
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
    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    _categoryTitle = args["title"];
    _datas = args["datas"];
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
        .collection("musics")
        .where("category", isEqualTo: _categoryTitle)
        .get();
    setState(() {
      _allResult = data.docs;
    });
    searchResultsList();
    return "complete";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(top: 50, left: 15, right: 15, bottom: 20),
        child: Column(children: [
          Row(
            children: [
              Text(_categoryTitle,
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
                hintText: "Aramak istediğiniz şarkının adını giriniz..."),
            style: TextStyle(fontSize: 14),
          ),
          (_resultsList.isNotEmpty && _resultsList.length != 0)
              ? Container(
                  width: 500,
                  height: 600,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return MusicItem(
                          _resultsList[index].id,
                          _resultsList[index].data()["name"],
                          _resultsList[index].data()["image"],
                          _resultsList[index].data()["music"],
                          _resultsList[index].data()["listenNumber"],
                          _resultsList[index].data()["artist"],
                          (index + 1),
                          _resultsList.length,
                          0,
                          _datas,null,null);
                    },
                    itemCount: _resultsList.length,
                  ),
                )
              : Container(
                  margin: EdgeInsets.symmetric(vertical: 30),
                  child: Text("Şarkı bulunamadı !"),
                ),
        ]),
      ),
    ));
  }
}
