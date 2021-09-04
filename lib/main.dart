// Disabled null safety for this file:
// @dart=2.9

import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:here_flexpoly_flutter/here_flexpoly/flexible_polyline.dart';
import 'package:here_flexpoly_flutter/here_flexpoly/latlngz.dart';

void main() {
  SdkContext.init(IsolateOrigin.main);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  // Use _context only within the scope of this widget.
  BuildContext _context;

  @override
  Widget build(BuildContext context) {
    context = _context;

    return MaterialApp(
        title: 'HERE Flex-Poly Flutter test',
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
          primarySwatch: Colors.blue,
          // This makes the visual density adapt to the platform that you run
          // the app on. For desktop platforms, the controls will be smaller and
          // closer together (more dense) than on mobile platforms.
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HereMap(onMapCreated: _onMapCreated)
        // home: MyHomePage(title: 'Flutter Demo Home Page'),
        );
  }

  void _onMapCreated(HereMapController hereMapController) {
    hereMapController.mapScene.loadSceneForMapScheme(MapScheme.normalDay,
        (MapError mapError) {
      if (mapError != null) {
        print(
            'WaliedCheeetos: Map scene has NOT been loaded. HERE mSDK Error: ${mapError.toString()}');
        return;
      }

      hereMapController.camera.flyToWithOptionsAndDistance(
          GeoCoordinates(25.09935, 55.16341),
          7000,
          MapCameraFlyToOptions.withDefaults());

      // hereMapController.camera
      //     .lookAtPointWithDistance(GeoCoordinates(25.09935, 55.16341), 7000);

      _request_HERERouting_v8(
          'https://router.hereapi.com/v8/routes?apiKey=zqXX556h4qRUgZyA-PtL9CgTohrfxmFIwVSugJwou9w&routingMode=fast&transportMode=car&alternatives=2&return=polyline,travelSummary&spans=length&origin=45.5,-100.7&destination=34.698,-108.6',
          hereMapController);
    });
  }

  void _request_HERERouting_v8(
      String hereRouting_v8_URL, HereMapController hereMapCont) async {
    try {
      print('WaliedCheetos: ${hereRouting_v8_URL.toString()}');

      http.Response response = await http.get(Uri.parse(hereRouting_v8_URL));

      if (response.statusCode == 200) {
        print('WaliedCheetos: ${response.body}');
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final responseBody = jsonDecode(response.body);

        String encodedFlexPolyline =
            responseBody['routes'][0]['sections'][0]['polyline'];

        print('WaliedCheetos: ${encodedFlexPolyline.toString()}');

        if (encodedFlexPolyline.isNotEmpty) {
          List<LatLngZ> computedLatLngZs =
              FlexiblePolyline.decode(encodedFlexPolyline);

          List<GeoCoordinates> listGeoCoordinates = [];

          for (var item in computedLatLngZs) {
            listGeoCoordinates.add(GeoCoordinates(item.lat, item.lng));
          }

          GeoPolyline geoPolyline = new GeoPolyline(listGeoCoordinates);

          hereMapCont.mapScene.addMapPolyline(
              new MapPolyline(geoPolyline, 3, Color.fromRGBO(255, 0, 0, 50)));

          hereMapCont.camera.flyToWithOptionsAndDistance(
              (new GeoCoordinates(
                  computedLatLngZs[0].lat, computedLatLngZs[0].lng)),
              13000,
              MapCameraFlyToOptions.withDefaults());
        } else {
          showDialog(
              context: _context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('WaliedCheetos says Hollla ...!!!'),
                  content: Text(
                      'We can NOT process HERE routing v8 flexible polyline request'),
                );
              });
        }
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to request HERE routingg v8: ${response.body}');
      }
    } catch (exception) {
      throw new Exception(exception);
    }
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
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
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
