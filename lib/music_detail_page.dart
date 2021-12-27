import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MusicDetailPage extends StatefulWidget {
  static const String routeName = "/music-detail";

  @override
  _MusicDetailPageState createState() => _MusicDetailPageState();
}

class _MusicDetailPageState extends State<MusicDetailPage> {
  AudioPlayer _ap = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  String _id;
  String _name;
  String _artist;
  String _image;
  String _audio;
  int _listenNumber;
  int _isComingFrom;
  bool _isStarting = true;
  bool _adding = true;
  bool _playing = false;
  Map<String, dynamic> _datas;
  List<String> _ids;
  List<Map<String, dynamic>> _datass;
  int _rank;
  int _rank1;

  @override
  void dispose() async{
    await _ap.dispose();
    super.dispose();
  }

  void _addingListenNumber() async {
    if (_isComingFrom != 1 && _artist != _datas["artist"]) {
      _adding = false;
      String id = "";
      int listenNumber = 0;
      await FirebaseFirestore.instance
          .collection("users")
          .where("artist", isEqualTo: _artist)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          id = element.id;
          listenNumber = element.data()["listenNumber"];
        });
      });
      listenNumber++;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(id)
          .update({"listenNumber": (listenNumber)});
      _listenNumber++;
      await FirebaseFirestore.instance
          .collection("musics")
          .doc(_id)
          .update({"listenNumber": _listenNumber});
    }
  }

  void _getMusic() async {
    if (_playing) {
      var res = await _ap.pause();
      if (res == 1) {
        setState(() {
          _playing = false;
        });
      }
    } else {
      var res = await _ap.play(_audio, isLocal: true);
      if (res == 1) {
        setState(() {
          _playing = true;
        });
      }
    }
    _ap.onDurationChanged.listen((Duration dd) {
      setState(() {
        _duration = dd;
      });
    });
    _ap.onAudioPositionChanged.listen((Duration dd) {
      setState(() {
        _position = dd;
      });
    });
  }

  void _nextMusic() async {
    _ap.stop();
    if (_rank == _rank1) {
      _rank = 0;
      _rank--;
    }
    _rank++;
    _artist = _datass[_rank]["artist"];
    _name = _datass[_rank]["name"];
    _image = _datass[_rank]["image"];
    _audio = _datass[_rank]["music"];
    _id = _ids[_rank];
    _addingListenNumber();
    var res = await _ap.play(_audio, isLocal: true);
    if (res == 1) {
      setState(() {
        _playing = true;
      });
    }
  }

  void _previousMusic() async {
    _ap.stop();
    if (_rank == 0) {
      _rank = _rank1 + 1;
    }
    _rank--;
    _artist = _datass[_rank]["artist"];
    _name = _datass[_rank]["name"];
    _image = _datass[_rank]["image"];
    _audio = _datass[_rank]["music"];
    _id = _ids[_rank];
    _addingListenNumber();
    var res = await _ap.play(_audio, isLocal: true);
    if (res == 1) {
      setState(() {
        _playing = true;
      });
    }
  }

  Widget _slider() {
    return Slider.adaptive(
      min: 0.0,
      activeColor: Colors.grey,
      inactiveColor: Colors.grey,
      max: _duration.inSeconds.toDouble(),
      value: _position.inSeconds.toDouble(),
      onChanged: (double value) {
        setState(() {
          _ap.seek(new Duration(seconds: value.toInt()));
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isStarting) {
      final Map<String, dynamic> args =
          ModalRoute.of(context).settings.arguments;
      _name = args["name"];
      _artist = args["artist"];
      _image = args["image"];
      _audio = args["audio"];
      _id = args["id"];
      _listenNumber = args["listenNumber"];
      _isComingFrom = args["isComingFrom"];
      _datas = args["datas"];
      _rank = args["rank"];
      _rank--;
      _rank1 = args["rank1"];
      _rank1--;
      _ids = args["ids"];
      _datass = args["datass"];
      debugPrint("$_rank");
      debugPrint("$_rank1");
      _isStarting = false;
    }
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(top: 50, left: 15, right: 15, bottom: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Müzik Detayı",
                  style: TextStyle(fontSize: 32, color: Colors.black),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            SizedBox(
              height: 60,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 130,
                  backgroundColor: Colors.grey,
                  child: Icon(
                    Icons.music_video,
                    color: Colors.white,
                    size: (_image != null && _image.isNotEmpty) ? 0 : 100,
                  ),
                  backgroundImage: (_image != null && _image.isNotEmpty)
                      ? NetworkImage(_image)
                      : null,
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  _artist,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 80,
                ),
                _slider(),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    (_isComingFrom == 2)
                        ? InkWell(
                            onTap: _previousMusic,
                            child: Icon(
                              Icons.skip_previous,
                              size: 50,
                              color: Colors.grey,
                            ),
                          )
                        : Container(),
                    SizedBox(
                      width: 20,
                    ),
                    InkWell(
                      onTap: _adding
                          ? () async {
                              _addingListenNumber();
                              _getMusic();
                            }
                          : () {
                              _getMusic();
                            },
                      child: Icon(
                        (_playing == false)
                            ? Icons.play_circle_fill
                            : Icons.pause_circle_filled,
                        size: 70,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    (_isComingFrom == 2)
                        ? InkWell(
                            onTap: _nextMusic,
                            child: Icon(
                              Icons.skip_next,
                              size: 50,
                              color: Colors.grey,
                            ),
                          )
                        : Container(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
