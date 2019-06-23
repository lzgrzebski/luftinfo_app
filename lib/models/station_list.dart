import 'station.dart';

class StationsList {
  final List<Station> stations;

  StationsList({
    this.stations,
  });

  factory StationsList.fromJson(List<dynamic> parsedJson) {

    List<Station> stations = new List<Station>();
    stations = parsedJson.map((i)=>Station.fromJson(i)).toList();

    return new StationsList(
      stations: stations,
    );
  }
}