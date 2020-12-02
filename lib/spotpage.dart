import 'package:flutter/material.dart';
import 'package:openapi/api.dart';

// 観光地のGridView
class SpotPage extends StatelessWidget {
  final List<Spot> spots;
  const SpotPage({@required this.spots});

  @override
  Widget build(BuildContext context) {
    if (spots.isNotEmpty) {
      return GridView(
        children: spots.map((spot) => SpotCard(spot: spot)).toList(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
      );
    } else {
      return Container(child: Center(child: Text("Empty...")));
    }
  }
}

// 観光地のGridViewのカード画面
class SpotCard extends StatelessWidget {
  SpotCard({@required this.spot});
  final Spot spot;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => SpotDetail(spot: spot)),
      ),
      splashColor: Colors.blue.withAlpha(30),
      child: Card(
        child: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(spot.imgUrl),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: null),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            spot.name,
                            style: Theme.of(context).textTheme.subtitle2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        spot.desc,
                        style: Theme.of(context).textTheme.caption,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 観光地詳細画面
class SpotDetail extends StatefulWidget {
  SpotDetail({@required this.spot});
  final Spot spot;

  @override
  _SpotDetailState createState() => _SpotDetailState();
}

class _SpotDetailState extends State<SpotDetail> {
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(children: <Widget>[
        // 全体の背景
        Container(
            height: screenHeight,
            width: screenWidth,
            color: Colors.transparent),
        // 上半分はお店のロゴ
        Container(
          height: screenHeight / 2,
          width: screenWidth,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(widget.spot.imgUrl), fit: BoxFit.cover),
          ),
        ),
        Align(
            // 画面左上は戻るボタン
            alignment: Alignment.topLeft,
            child: Padding(
                padding: EdgeInsets.only(left: 15.0, top: 20.0),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                      height: 40.0,
                      width: 40.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: Center(
                          child: Icon(Icons.arrow_back,
                              size: 20.0, color: Colors.white))),
                ))),
        Positioned(
            // 下半分は観光地名と説明
            top: screenHeight / 2,
            child: Container(
              padding: EdgeInsets.all(20),
              width: screenWidth,
              height: screenHeight / 2,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    // 観光地名
                    Text(widget.spot.name,
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w900)),
                    SizedBox(height: 3),
                    // 観光地の説明
                    Text(widget.spot.desc,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500)),
                  ]),
            ))
      ]),
    );
  }
}
