import 'package:flutter/material.dart';

import 'artist_detail_page.dart';

class ArtistItem extends StatelessWidget {
  final String id;
  final String image;
  final int listenNumber;
  final String artist;
  final int rank;
  final int rank1;
  final Map<String, dynamic> datass;

  ArtistItem(this.id, this.artist, this.image, this.listenNumber, this.rank,
      this.rank1, this.datass);

  void selectArtist(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(ArtistDetailPage.routeName, arguments: {
      "image": image,
      "artist": artist,
      "listenNumber": listenNumber,
      "datas": datass
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => selectArtist(context),
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
                    Icons.supervisor_account,
                    size: (image == null || image.isEmpty) ? 20 : 0,
                  ),
                  backgroundImage: (image == null || image.isEmpty)
                      ? null
                      : NetworkImage(image),
                ),
                title: Text(artist),
                trailing: Text("$listenNumber")),
            if (rank != rank1)
              Divider(
                height: 10,
                thickness: 1,
                color: Colors.black38,
              ),
          ],
        ));
  }
}
