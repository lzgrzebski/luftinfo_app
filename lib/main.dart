import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:tinycolor/tinycolor.dart';

import 'package:luftinfo_app/bloc_provider.dart';
import 'package:luftinfo_app/blocs/station_list.bloc.dart';
import 'package:luftinfo_app/services/measurementdata.serivce.dart';

import 'models/station.dart';

Future<void> main() async {
  return runApp(
      BlocProvider<StationListBloc>(bloc: StationListBloc(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LuftinfoApp',
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
  double _panelHeightOpen = 310.0;
  double _panelHeightClosed = 110.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          SlidingUpPanel(
            maxHeight: _panelHeightOpen,
            minHeight: _panelHeightClosed,
            parallaxEnabled: true,
            parallaxOffset: .5,
            body: MapWidget(),
            panel: OverlayWidget(),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.0), topRight: Radius.circular(4.0)),
          ),
        ],
      ),
    );
  }
}

class MapWidget extends StatefulWidget {
  MapWidget({this.setStation});
  final setStation;

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  static final CameraPosition _cameraPosition = CameraPosition(
    target: LatLng(59.927454, 10.733687),
    zoom: 11,
  );

  String _mapStyle;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    _mapStyle = await rootBundle.loadString('assets/map_style.txt');
  }

  @override
  Widget build(BuildContext context) {
    final StationListBloc bloc = BlocProvider.of<StationListBloc>(context);
    return StreamBuilder<Map<MarkerId, Marker>>(
        stream: bloc.markers,
        builder: (context, snapshot) {
          return GoogleMap(
            initialCameraPosition: _cameraPosition,
            onMapCreated: (GoogleMapController controller) {
              controller.setMapStyle(_mapStyle);
            },
            markers: Set<Marker>.of(snapshot?.data?.values ?? []),
          );
        });
  }
}

class OverlayWidget extends StatefulWidget {
  @override
  _OverlayWidgetState createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {
  var data = [0.0, 1.0, 1.5, 2.0, 0.0, 0.0, -0.5, -1.0, -0.5, 0.0, 0.0];
  @override
  Widget build(BuildContext context) {
    final StationListBloc bloc = BlocProvider.of<StationListBloc>(context);
    return StreamBuilder<Station>(
        stream: bloc.selectedStation,
        builder: (context, snapshot) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 19.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 18,
                      height: 3,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        snapshot?.data?.station ?? '',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.3,
                            fontSize: 17.0,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        measurementDataService.caqiToText(
                            snapshot?.data?.components?.first?.caqi ?? 0),
                        style: TextStyle(
                            fontWeight: FontWeight.w200,
                            fontSize: 34.0,
                            color: TinyColor.fromString(measurementDataService
                                    .caqiToColorRGBA(snapshot
                                            ?.data?.components?.first?.caqi ??
                                        0))
                                .color),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 15, 0, 0),
                        child: Text(
                          'air quality',
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              letterSpacing: 0.6,
                              fontSize: 14.0,
                              color: TinyColor.fromString('#a5a5a5').color),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Divider(
                  color: TinyColor.fromString('#e5e5e5').color,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 0, 0),
                  child: Text(
                    'PM2.5',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.6,
                        fontSize: 14.0,
                        color: TinyColor.fromString('#333').color),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Sparkline(
                    data: data,
                    fillMode: FillMode.below,
                    lineColor: TinyColor.fromString(
                            measurementDataService.caqiToColorRGBA(
                                snapshot?.data?.components?.first?.caqi ?? 0))
                        .darken(5)
                        .color,
                    fillColor: TinyColor.fromString(
                            measurementDataService.caqiToColorRGBA(
                                snapshot?.data?.components?.first?.caqi ?? 0))
                        .color,
                  ),
                )
              ]);
        });
  }
}
