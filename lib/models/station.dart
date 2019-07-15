import 'package:tinycolor/tinycolor.dart';

import 'package:luftinfo_app/models/station_component.dart';
import 'package:luftinfo_app/services/measurementdata.serivce.dart';

enum StationType { nilu, ts }

class Station {
  final String station;
  final double latitude;
  final double longitude;
  final List<StationComponent> components;
  final StationType type;
  final int id;

  //NILU
  final String zone;
  final String municipality;
  final String area;
  final String eoi;
  final String fromTime;
  final String toTime;
  final int timestep;

  //TS
  final String temperature;
  final String humidity;
  final String uptimeSeconds;
  final String version;

  get statusColor => TinyColor.fromString(measurementDataService
          .caqiToColorRGBA(this.components?.first?.caqi ?? 0))
      .color;

  get statusColorDarken => TinyColor.fromString(measurementDataService
          .caqiToColorRGBA(this.components?.first?.caqi ?? 0))
      .darken(5)
      .color;

  get statusText =>
      measurementDataService.caqiToText(this.components?.first?.caqi ?? 0);

  Station(
      {this.latitude,
      this.longitude,
      this.components,
      this.type,
      this.station,
      this.zone,
      this.municipality,
      this.area,
      this.eoi,
      this.fromTime,
      this.toTime,
      this.timestep,
      this.temperature,
      this.humidity,
      this.uptimeSeconds,
      this.version,
      this.id});

  factory Station.fromNiluJson(Map<String, dynamic> json) {
    return new Station(
      station: json['station'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      components: json['components'],
      type: StationType.nilu,
      zone: json['zone'],
      municipality: json['municipality'],
      area: json['area'],
      eoi: json['eoi'],
      fromTime: json['fromTime'],
      toTime: json['toTime'],
      timestep: json['timestep'],
    );
  }

  factory Station.fromTsJson(Map<String, dynamic> json) {
    return new Station(
        station: json['channel']['name'],
        latitude: double.parse(json['channel']['latitude']),
        longitude: double.parse(json['channel']['longitude']),
        components: json['components'],
        type: StationType.ts,
        id: json['channel']['id']);
  }
}
