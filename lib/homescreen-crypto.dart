import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'constants.dart';

// ignore: must_be_immutable
class CoinList extends StatefulWidget {
  CoinList({super.key, required this.coinList});
  List<Crypto>? coinList;
  @override
  State<CoinList> createState() => _CoinListState();
}

class _CoinListState extends State<CoinList> {
  bool isLoeadingRefresh = false;
  List<Crypto>? coinList;
  @override
  void initState() {
    coinList = widget.coinList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      appBar: AppBar(
        backgroundColor: blackColor,
        title: Text(
          'کیریپتو بازار',
          style: TextStyle(fontFamily: 'mh'),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: TextField(
                onChanged: (value) {
                  _searchFilter(value);
                },
                decoration: InputDecoration(
                    hintText: '   اسم  رمزارز  را سرچ کنید',
                    hintStyle: TextStyle(fontFamily: 'mh', color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(width: 0, style: BorderStyle.none),
                    ),
                    filled: true,
                    fillColor: greenColor),
              ),
            ),
          ),
          Visibility(
            visible: isLoeadingRefresh,
            child: Text(
              '...در حال اپدیت اطلاعات رمز ارزها',
              style: TextStyle(color: greenColor, fontFamily: 'mh'),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              backgroundColor: greenColor,
              color: blackColor,
              onRefresh: () async {
                var resualt = await _getData();
                setState(() {
                  coinList = resualt;
                });
              },
              child: ListView.builder(
                itemCount: coinList!.length,
                itemBuilder: (context, index) {
                  return _getListTileItem(coinList![index]);
                },
              ),
            ),
          )
        ],
      )),
    );
  }

  Widget _getListTileItem(Crypto crypto) {
    return ListTile(
      title: Text(
        crypto.name,
        style: TextStyle(color: greenColor),
      ),
      subtitle: Text(
        crypto.symbol,
        style: TextStyle(color: greyColor),
      ),
      leading: SizedBox(
        width: 30.0,
        child: Center(
          child: Text(
            crypto.rank.toString(),
            style: TextStyle(color: greyColor, fontSize: 16),
          ),
        ),
      ),
      trailing: SizedBox(
        width: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  crypto.priceUsd.toStringAsFixed(2),
                  style: TextStyle(color: greyColor, fontSize: 15),
                ),
                SizedBox(height: 2),
                Text(
                  crypto.changePercent24hr.toStringAsFixed(2),
                  style: TextStyle(
                    color: _getColorChangeText(crypto.changePercent24hr),
                  ),
                )
              ],
            ),
            SizedBox(
                width: 50,
                child: Center(
                  child: _getIconChangePercent(crypto.changePercent24hr),
                )),
          ],
        ),
      ),
    );
  }

  Color _getColorChangeText(double value) {
    return value >= 0 ? greenColor : redColor;
  }

  Widget _getIconChangePercent(double value) {
    return value >= 0
        ? Icon(
            Icons.trending_up,
            size: 24,
            color: greenColor,
          )
        : Icon(
            Icons.trending_down,
            size: 24,
            color: redColor,
          );
  }

  Future<List<Crypto>> _getData() async {
    var response = await Dio().get('https://api.coincap.io/v2/assets');
    List<Crypto> cryptoList = response.data['data']
        .map<Crypto>((jsonMapObject) => Crypto.fromMapJson(jsonMapObject))
        .toList();
    return cryptoList;
  }

  _searchFilter(String enteredWords) async {
    if (enteredWords.isEmpty) {
      setState(() {
        isLoeadingRefresh = true;
      });
      var response = await _getData();
      setState(() {
        coinList = response;
        isLoeadingRefresh = false;
      });
      return;
    }

    List<Crypto> coinResualtList = coinList!.where((element) {
      return element.name.toLowerCase().contains(enteredWords.toString());
    }).toList();

    setState(() {
      coinList = coinResualtList;
    });
  }
}
