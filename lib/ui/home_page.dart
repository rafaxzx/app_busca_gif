import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;
  final _controllerSearch = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getGifs().then((content) {
      print(content);
    });
  }

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search == null || _search.isEmpty)
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=Z9Tq5QMwF8Xskk3E7DQ8ylwpjui6PyXr&limit=20&rating=R");
    else
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=Z9Tq5QMwF8Xskk3E7DQ8ylwpjui6PyXr&q=$_search&limit=20&offset=$_offset&rating=R&lang=pt");
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Image.network(
            "https://developers.giphy.com/branch/master/static/header-logo-8974b8ae658f704a5b48a2d039b8ad93.gif"),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              style: TextStyle(fontSize: 20.0, color: Colors.white),
              controller: _controllerSearch,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Digite sua busca aqui!",
                  labelStyle: TextStyle(color: Colors.white, fontSize: 20.0)),
              onSubmitted: (search) {
                setState(() {
                  _search = search;
                });
              },
            ),
            Expanded(
              child: FutureBuilder(
                future: _getGifs(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        height: 50.0,
                        width: 50.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      );
                    default:
                      if (snapshot.hasError) {
                        return Center(
                          child: Text("Erro ao buscar os dados!"),
                        );
                      } else {
                        return _createGifTable(context, snapshot);
                      }
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

//Funcao que cria a tabela de Gifs
  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
      itemCount: 20,
      itemBuilder: (context, index) {
        return GestureDetector(
          child: Image.network(
            snapshot.data["data"][index]["images"]["fixed_height"]["url"],
            height: 300.0,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
