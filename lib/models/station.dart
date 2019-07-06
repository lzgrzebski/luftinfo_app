import 'package:luftinfo_app/models/station_component.dart';

class Station {
  final String name;
  final double latitude;
  final double longitude;
  final List<StationComponent> components;

  //NILU
  final String station;
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

  Station(
      {this.name,
      this.latitude,
      this.longitude,
      this.components,
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
      this.version});

  factory Station.fromJson(Map<String, dynamic> json) {
    return new Station(
      name: json['station'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      components: json['components'],
      zone: json['zone'],
      municipality: json['municipality'],
      area: json['area'],
      station: json['station'],
      eoi: json['eoi'],
      fromTime: json['fromTime'],
      toTime: json['toTime'],
      timestep: json['timestep'],
    );
  }
}
