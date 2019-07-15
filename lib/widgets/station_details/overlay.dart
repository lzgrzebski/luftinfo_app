import 'package:flutter/material.dart';

import 'package:tinycolor/tinycolor.dart';

import 'package:luftinfo_app/models/station.dart';
import 'package:luftinfo_app/services/measurementdata.serivce.dart';
import 'package:luftinfo_app/widgets/station_details/graph.dart';
import 'package:luftinfo_app/bloc_provider.dart';
import 'package:luftinfo_app/blocs/station_list.bloc.dart';

class OverlayWidget extends StatefulWidget {
  @override
  _OverlayWidgetState createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {
  @override
  Widget build(BuildContext context) {
    final StationListBloc bloc = BlocProvider.of<StationListBloc>(context);
    return StreamBuilder<Station>(
        stream: bloc.selectedStation,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('error');
          } else if (!snapshot.hasData) {
            return Column(
              children: <Widget>[
                SizedBox(
                  height: 40.0,
                ),
                Center(
                    child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      TinyColor.fromString(
                              measurementDataService.caqiToColorRGBA(0))
                          .color),
                )),
              ],
            );
          }

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
                        snapshot?.data?.statusText ?? '',
                        style: TextStyle(
                            fontWeight: FontWeight.w200,
                            fontSize: 34.0,
                            color: snapshot?.data?.statusColor ?? Colors.grey),
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
                Graph(snapshot?.data)
              ]);
        });
  }
}
