import 'package:crypto/crypto.dart';
import 'package:crypto/homescreen-crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String title = 'loading....';
  @override
  void initState() {
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[800],
        body: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage('assets/images/logo.png')),
            SpinKitWave(
              color: Colors.white,
              size: 30.0,
            ),
          ],
        )),
      ),
    );
  }

  Future _getData() async {
    Response response = await Dio().get('https://api.coincap.io/v2/assets');
    List<Crypto> cryptoList =
        response.data['data'].map<Crypto>((jsonMapObject) {
      return Crypto.fromMapJson(jsonMapObject);
    }).toList();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CoinList(coinList: cryptoList)));
  }


}
