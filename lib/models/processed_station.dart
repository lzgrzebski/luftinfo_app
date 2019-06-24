import 'package:luftinfo_app/models/station_component.dart';

class ProcessedStation {
  final String station;
  final double latitude;
  final double longitude;
  final List<StationComponent> components;

  ProcessedStation({
    this.station,
    this.latitude,
    this.longitude,
    this.components,
  });
}
