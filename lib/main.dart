import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'add_music_page.dart';
import 'artist_detail_page.dart';
import 'category_musics_page.dart';
import 'landing_page.dart';
import 'music_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MusicStream());
}

class MusicStream extends StatefulWidget {
  @override
  _MusicStreamState createState() => _MusicStreamState();
}

class _MusicStreamState extends State<MusicStream> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Stream',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        primaryColor: Colors.grey,
        accentColor: Colors.white,
        canvasColor: Colors.white,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => LandingPage(),
        CategoryMusicsPage.routeName: (context) => CategoryMusicsPage(),
        ArtistDetailPage.routeName: (context) => ArtistDetailPage(),
        AddMusicPage.routeName: (context) => AddMusicPage(),
        MusicDetailPage.routeName: (context) => MusicDetailPage(),
      },
    );
  }
}
