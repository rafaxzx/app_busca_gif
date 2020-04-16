import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _getGifs().then((content){
      print(content);
    });
  }

  Future<Map> _getGifs() async {
    http.Response response;

    if(_search == null || _search.isEmpty) response = await http.get(
        "https://api.giphy.com/v1/gifs/trending?api_key=Z9Tq5QMwF8Xskk3E7DQ8ylwpjui6PyXr&limit=20&rating=R");
    else response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=Z9Tq5QMwF8Xskk3E7DQ8ylwpjui6PyXr&q=$_search&limit=20&offset=$_offset&rating=R&lang=pt");
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(),
    );
  }
}
