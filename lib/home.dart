import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:openapi/api.dart';
import 'package:latlong/latlong.dart';

import 'spotpage.dart';

// TODO OIDCログイン,ログアウト用パラメータ（環境にあわせて値をセットしてください）
final String _clientName = ""; // クライアント名
final String _customSchemeCallback = ""; // カスタムスキーマ
final String _clientSecret = ""; // クライアントシークレット
final String _discoveryUrl = ""; // ディスカバリーURL
final List<String> _scopes = ['email', 'profile']; // オプトインで提供可能なスコープ
final String _logoutEndpoint = ""; // ログアウトエンドポイント
final String _tokenEndopint = ""; // トークンエンドポイント

// ログイン用AurhorizationTokenRequest
final AuthorizationTokenRequest loginRequest = AuthorizationTokenRequest(
  _clientName,
  _customSchemeCallback,
  clientSecret: _clientSecret,
  discoveryUrl: _discoveryUrl,
  scopes: _scopes,
);

// ログアウト用AuthorizationTokenRequest
AuthorizationTokenRequest getLogoutRequest(
    AuthorizationTokenResponse response) {
  return AuthorizationTokenRequest(
    _clientName,
    _customSchemeCallback,
    clientSecret: _clientSecret,
    discoveryUrl: _discoveryUrl,
    scopes: _scopes,
    additionalParameters: {
      "id_token_hint": response.idToken,
      "client_id": _clientName,
      "refresh_token": response.refreshToken,
    },
    serviceConfiguration:
        AuthorizationServiceConfiguration(_logoutEndpoint, _tokenEndopint),
  );
}

// Flutter用AppAuth
final auth = FlutterAppAuth();

// 観光APIから取得する観光スポットリスト
final clientProvider = Provider((ref) => DefaultApi());
final spotListProvider = FutureProvider<List<Spot>>((ref) async {
  final client = ref.read(clientProvider);
  return client.spotsGet();
});

List menuItems = [
  {"icon": Icons.landscape, "name": "観光地"},
  {"icon": Icons.map, "name": "地図"},
  {"icon": Icons.person, "name": "プロファイル"}
];

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController _pageController;
  int _index = 0;
  String _title = menuItems[0]["name"];

  // 地図上のマーカ
  LatLng markerCoords = LatLng(37.489983, 139.927749);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: auth.authorizeAndExchangeCode(loginRequest),
      builder: (
        BuildContext context,
        AsyncSnapshot<AuthorizationTokenResponse> authResponse,
      ) {
        if (authResponse.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_title),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () => auth.authorizeAndExchangeCode(
                    getLogoutRequest(authResponse.data),
                  ),
                ),
              ],
            ),
            body: PageView(
              controller: _pageController,
              children: <Widget>[
                Consumer(
                  builder: (context, watch, child) {
                    final spotListAsyncValue = watch(spotListProvider);
                    return spotListAsyncValue.map(
                      data: (_) => SpotPage(spots: _.value),
                      loading: (_) =>
                          Center(child: CircularProgressIndicator()),
                      error: (_) => Text(
                        _.error.toString(),
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  },
                ),
                Consumer(builder: (context, watch, child) {
                  final spotListAsyncValue = watch(spotListProvider);
                  return spotListAsyncValue.map(
                    data: (_) {
                      List<Marker> markerList = _.value.map((spot) {
                        return Marker(
                          point: LatLng(
                            spot.lat,
                            spot.lng,
                          ),
                          builder: (BuildContext context) {
                            return Icon(
                              Icons.location_on,
                              size: 50.0,
                            );
                          },
                        );
                      }).toList();
                      return FlutterMap(
                        options: MapOptions(
                          center: markerCoords,
                          zoom: 12,
                        ),
                        layers: [
                          TileLayerOptions(
                            urlTemplate:
                                "https://cyberjapandata.gsi.go.jp/xyz/std/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c'],
                          ),
                          MarkerLayerOptions(markers: markerList),
                        ],
                      );
                    },
                    loading: (_) => Center(child: CircularProgressIndicator()),
                    error: (_) => Text(
                      _.error.toString(),
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }),
                Container(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 50, horizontal: 30),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Email: ${JwtDecoder.decode(authResponse.data.accessToken)['email']}",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            "氏名: " +
                                "${JwtDecoder.decode(authResponse.data.accessToken)['family_name']} " +
                                "${JwtDecoder.decode(authResponse.data.accessToken)['given_name']}",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ]),
                  ),
                ),
              ],
              physics: NeverScrollableScrollPhysics(),
            ),
            bottomNavigationBar: BottomNavigationBar(
              selectedItemColor: Colors.indigo,
              unselectedItemColor: Colors.grey,
              currentIndex: _index,
              items: menuItems.map((menu) {
                return BottomNavigationBarItem(
                  icon: Icon(menu["icon"]),
                  label: menu["name"],
                );
              }).toList(),
              onTap: (index) {
                setState(() {
                  _index = index;
                  _title = menuItems[index]["name"];
                  _pageController.jumpToPage(index);
                });
              },
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
