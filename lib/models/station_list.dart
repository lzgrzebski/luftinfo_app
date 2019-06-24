import 'package:luftinfo_app/models/processed_station.dart';
import 'package:luftinfo_app/models/station.dart';

class StationsList {
  final List<Station> stations;
  List<ProcessedStation> processedStations = [];

  StationsList({
    this.stations,
  });

  factory StationsList.fromJson(List<dynamic> parsedJson) {
    List<Station> stations = new List<Station>();
    stations = parsedJson.map((i) => Station.fromJson(i)).toList();

    return new StationsList(
      stations: stations,
    );
  }
}
