import 'package:luftinfo_app/models/station.dart';
import 'package:luftinfo_app/models/station_component.dart';
import 'package:luftinfo_app/services/measurementdata.serivce.dart';

class StationsList {
  final Map<String, Station> stations;

  StationsList({
    this.stations,
  });

  factory StationsList.fromJson(List<dynamic> parsedNiluJson) {
    final Map<String, Station> normalizedNiluStations =
        parsedNiluJson.fold(<Station>[], (List<Station> stationsAcc, s) {
      int c = measurementDataService.caqi(s['component'], s['value']);
      StationComponent stationComponent =
          StationComponent(name: s['component'], value: s['value'], caqi: c);
      int x = stationsAcc.indexWhere((y) => y.station == s['station']);
      if (x == -1) {
        s['components'] = [stationComponent];
        stationsAcc.add(Station.fromJson(s));
        return stationsAcc;
      }

      if (c > stationsAcc[x].components[0].caqi) {
        stationsAcc[x].components.insert(0, stationComponent);
      } else {
        stationsAcc[x].components.add(stationComponent);
      }
      return stationsAcc;
    }).fold({}, (Map<String, Station> stationsAcc, Station s) {
      stationsAcc[s.station] = s;
      return stationsAcc;
    });

    return new StationsList(
      stations: normalizedNiluStations,
    );
  }
}
