import 'package:flutter/material.dart';
import 'package:music_stream/category_musics_page.dart';

class CategoryItem extends StatelessWidget {
  final String title;
  final Map<String, dynamic> datass;

  CategoryItem(this.title, this.datass);

  void selectCategory(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(CategoryMusicsPage.routeName,
        arguments: {"title": title, "datas": datass});
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => selectCategory(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 35,
            /*child: Icon(
              Icons.music_note,
              size: 30,
            ),
            backgroundColor: Colors.grey,*/
            backgroundImage: AssetImage("assets/" + title + ".png"),
          ),
          SizedBox(
            height: 5,
          ),
          Text(title),
        ],
      ),
    );
  }
}
