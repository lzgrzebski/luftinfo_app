import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:luftinfo_app/widgets/map/location_btn.dart';
import 'package:luftinfo_app/widgets/station_details/overlay.dart';
import 'package:luftinfo_app/bloc_provider.dart';
import 'package:luftinfo_app/blocs/station_list.bloc.dart';

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
          Positioned(
            right: 20.0,
            top: 60.0,
            child: LocationBtn(),
          ),
        ],
      ),
    );
  }
}

class MapWidget extends StatefulWidget {
  MapWidget();

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  String _mapStyle;
  LatLng _currentLocation;

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
    final Completer<GoogleMapController> _mapControllerCompleter = Completer();

    bloc.currentLocation.listen((location) async {
      _currentLocation = location;
      GoogleMapController mapController = await _mapControllerCompleter.future;
      mapController.moveCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: location, zoom: 13)));
    });
    return StreamBuilder<Map<MarkerId, Marker>>(
        stream: bloc.markers,
        builder: (context, snapshot) {
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation ?? LatLng(59.927454, 10.733687),
              zoom: 11,
            ),
            onMapCreated: (GoogleMapController controller) {
              controller.setMapStyle(_mapStyle);
              if (!_mapControllerCompleter.isCompleted) {
                _mapControllerCompleter.complete(controller);
              }
            },
            markers: Set<Marker>.of(snapshot?.data?.values ?? []),
          );
        });
  }
}
