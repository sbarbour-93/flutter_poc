import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

Future<List<Album>> fetchAlbums() async {
  var randomNumberBetweenOneAndTen = Random().nextInt(10) + 1;
  final response =
      await http.get('https://jsonplaceholder.typicode.com/albums/$randomNumberBetweenOneAndTen/photos');

  if (response.statusCode == 200) {
    var jsonAsList = json.decode(response.body) as List;
    return jsonAsList.map((e) => Album.fromJson(e)).toList();
  } else {
    throw Exception("Failed to load album");
  }
}

class Album {
  final int userId;
  final int id;
  final String title;
  final String url;
  final String thumbnailUrl;

  Album({this.userId, this.id, this.title, this.url, this.thumbnailUrl});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.pink,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: '#FailFastFriday'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Album>> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbums();
  }

  Future<void> refreshAlbums() async {
    var refreshedAlbums = fetchAlbums();

    setState(() {
      futureAlbum = refreshedAlbums;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
          child: FutureBuilder<List<Album>>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return GridView.count(
                  crossAxisCount: 2,
                  children: _getListData(snapshot.data),
                  // padding: EdgeInsets.fromLTRB(5, 10, 5, 20),
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
          onRefresh: refreshAlbums),
    );
  }

  _getListData(List<Album> albums) {
    List<Widget> cards = [];

    albums.forEach((element) {
      cards.add(
        Card(
          child: Column(children: [
            Expanded(
              flex: 6,
              child: Image.network(
                element.url,
              ),
            ),
            Expanded(
                flex: 4,
                child: Padding(
                    padding: EdgeInsets.all(10), child: Text(
                    element.title,
                  textAlign: TextAlign.center,
                )))
          ]),
        ),
      );
    });

    return cards;
  }
}
