import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tinycolor/tinycolor.dart';

import 'package:luftinfo_app/bloc_provider.dart';
import 'package:luftinfo_app/blocs/station_list.bloc.dart';

class LocationBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final StationListBloc bloc = BlocProvider.of<StationListBloc>(context);
    return StreamBuilder<LatLng>(
        stream: bloc.currentLocation,
        builder: (context, snapshot) {
          return FloatingActionButton(
            child: Icon(
              Icons.gps_fixed,
              color: TinyColor.fromString('#444').color,
            ),
            onPressed: () {
              if (snapshot?.data == null) {
                bloc.getLocation();
              } else {
                bloc.addLocation.add(snapshot?.data);
              }
            },
            backgroundColor: Colors.white,
          );
        });
  }
}
