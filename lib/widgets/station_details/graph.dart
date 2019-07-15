import 'package:flutter/material.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';

import 'package:luftinfo_app/bloc_provider.dart';
import 'package:luftinfo_app/services/measurementdata.serivce.dart';
import 'package:luftinfo_app/blocs/station_list.bloc.dart';
import 'package:luftinfo_app/models/station.dart';
import 'package:luftinfo_app/models/station_details.dart';

class Graph extends StatelessWidget {
  final Station station;
  Graph(this.station);

  @override
  Widget build(BuildContext context) {
    final StationListBloc bloc = BlocProvider.of<StationListBloc>(context);
    return StreamBuilder<StationDetails>(
        stream: bloc.selectedStationDetails,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('error');
          } else if (!snapshot.hasData) {
            return Column(
              children: <Widget>[
                SizedBox(
                  height: 70.0,
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
          } else if (snapshot?.data?.data?.first?.values?.length == 0) {
            return Column(
              children: <Widget>[
                SizedBox(
                  height: 70.0,
                ),
                Center(
                  child: Text('No elements'),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 0, 0),
                child: Text(
                  snapshot?.data?.data?.first?.pollutant,
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
                  data: snapshot?.data?.data?.first?.values,
                  fillMode: FillMode.below,
                  lineColor: station?.statusColorDarken ?? Colors.grey,
                  fillColor: station?.statusColor ?? Colors.grey,
                ),
              )
            ],
          );
        });
  }
}
