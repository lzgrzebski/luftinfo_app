import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

import 'package:tinycolor/tinycolor.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'models/station_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: MapWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), 
    );
  }
}

class MapWidget extends StatefulWidget {
  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  static const CACHING_SERVER_URL = 'https://probably.one:4433/ttl3600?';
  static const NILU_LAST_HOUR = 'https://api.nilu.no/obs/utd?components=no2;pm10;so2;co;o3;pm2.5';

  static final CameraPosition _cameraPosition = CameraPosition(
    target: LatLng(59.927454, 10.733687),
    zoom: 11,
  );

  String _mapStyle;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;
  int _markerIdCounter = 1;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    _mapStyle = await rootBundle.loadString('assets/map_style.txt');
    fetchStations();
  }

  void fetchStations() async {
    final response = await http.get(CACHING_SERVER_URL + NILU_LAST_HOUR);
    if (response.statusCode == 200) {
      StationsList stationsList = StationsList.fromJson(json.decode(response.body));
      stationsList.stations.forEach((s) async {
        final Uint8List markerIcon = await createIcon(s.value.round(), caqiToColorRGBA(s.value));
        final String markerIdVal = 'marker_id_$_markerIdCounter';
        print(markerIdVal);
        _markerIdCounter++;
        final MarkerId markerId = MarkerId(markerIdVal);

        final Marker marker = Marker(
          markerId: markerId,
          position: LatLng(
            s.latitude,
            s.longitude,
          ),
          icon: BitmapDescriptor.fromBytes(markerIcon),
        );

        setState(() {
          markers[markerId] = marker;
        });
      });

    } else {
      throw Exception('Failed to fetch stations');
    }
  }

  Future<Uint8List> createIcon(int value, String color) async {
    final double width = 120;
    final double height = 120;
    final colorBackground = Color(int.parse(color.substring(1, 7), radix: 16) + 0xFF000000);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromPoints(Offset(0.0, 0.0), Offset(width, height)));
    final paint = Paint()
      ..color = colorBackground
      ..style = PaintingStyle.fill;
    final paintStroke = Paint()
      ..color = TinyColor(colorBackground).darken(5).color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final painter = TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.center);
    final center  = new Offset(width/2, height/2);
    final radius  = min(width/2, height/2);

    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius - 2, paintStroke);
    painter.text = TextSpan(
      text: value.toString(),
      style: TextStyle(fontSize: 45.0, color: Colors.white, fontWeight: FontWeight.bold),
    );

    painter.layout(minWidth: width, maxWidth: width);
    painter.paint(
      canvas,
      Offset((width * 0.5) - painter.width * 0.5,
        (height * .5) - painter.height * 0.5)
    );

    final img = await recorder.endRecording().toImage(width.round(), height.round());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data.buffer.asUint8List();
  }

  caqiToColorRGBA(double caqi) {
    if (caqi < 25) return '#78ba6a';
    if (caqi < 50) return '#acbc53';
    if (caqi < 75) return '#e6b628';
    if (caqi < 100) return '#fa780a';
    return '#95001e';
}

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: _cameraPosition,
      onMapCreated: (GoogleMapController controller) {
        controller.setMapStyle(_mapStyle);
      },
      markers: Set<Marker>.of(markers.values),
    );
  }
}