import 'dart:convert';

import 'package:appbuscagif/ui/gif_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Variables to use for convenience
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
          "https://api.giphy.com/v1/gifs/search?api_key=Z9Tq5QMwF8Xskk3E7DQ8ylwpjui6PyXr&q=$_search&limit=19&offset=$_offset&rating=R&lang=pt");
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
                  labelText: "Digite sua busca aqui! (Exibindo os Trendings)",
                  labelStyle: TextStyle(color: Colors.white, fontSize: 16.0)),
              onSubmitted: (search) {
                setState(() {
                  _search = search;
                  _offset = 0;
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
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Erro ao buscar os dados!",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16.0),
                              ),
                              Divider(),
                              Container(
                                color: Colors.white,
                                width: 200.0,
                                height: 50.0,
                                child: RaisedButton(
                                  color: Colors.white,
                                  child: Icon(
                                    Icons.refresh,
                                    color: Colors.black,
                                    size: 30.0,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _search = "";
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
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

  int _getCount(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  void _clickMore() {
    setState(() {
      _offset += 19;
    });
  }

//Function that create a gif table widget
  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
      itemCount: _getCount(snapshot.data["data"]),
      itemBuilder: (context, index) {
        if (_search == null || index < snapshot.data["data"].length) {
          return GestureDetector(
            child: Image.network(
              snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300.0,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          GifPage(snapshot.data["data"][index])));
            },
            onLongPress: () {
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]
                  ["url"]);
            },
          );
        } else {
          return Container(
            color: Colors.black,
            child: GestureDetector(
              onTap: _clickMore,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 70.0,
                  ),
                  Text(
                    "Carregar mais",
                    style: TextStyle(color: Colors.white, fontSize: 22.0),
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
