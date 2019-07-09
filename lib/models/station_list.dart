import 'package:luftinfo_app/models/station.dart';
import 'package:luftinfo_app/models/station_component.dart';
import 'package:luftinfo_app/services/measurementdata.serivce.dart';

class StationsList {
  final Map<String, Station> stations;

  StationsList({
    this.stations,
  });

  factory StationsList.fromJson(
      List<dynamic> parsedNiluJson, List<dynamic> parsedTsJson) {
    return new StationsList(
      stations: {
        ...normalizeTsStations(parsedTsJson),
        ...normalizeNiluStations(parsedNiluJson)
      },
    );
  }

  static Map<String, Station> normalizeNiluStations(
      List<dynamic> parsedNiluJson) {
    return parsedNiluJson.fold(<Station>[], (List<Station> stationsAcc, s) {
      int c = measurementDataService.caqi(s['component'], s['value']);
      StationComponent stationComponent =
          StationComponent(name: s['component'], value: s['value'], caqi: c);
      int x = stationsAcc.indexWhere((y) => y.station == s['station']);
      if (x == -1) {
        s['components'] = [stationComponent];
        stationsAcc.add(Station.fromNiluJson(s));
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
  }

  static Map<String, Station> normalizeTsStations(List<dynamic> parsedTsJson) {
    return parsedTsJson.fold({}, (Map<String, Station> stationsAcc, s) {
      if (s != -1 &&
          s['channel'] != null &&
          s['channel']['name'] != null &&
          s['feeds'].length > 0) {
        s['components'] = [
          StationComponent(
              name: s['channel']['field1'],
              value: double.parse(s['feeds'][s['feeds'].length - 1]['field1']),
              caqi: measurementDataService.caqi(s['channel']['field1'],
                  double.parse(s['feeds'][s['feeds'].length - 1]['field1']))),
          StationComponent(
              name: s['channel']['field2'],
              value: double.parse(s['feeds'][s['feeds'].length - 1]['field2']),
              caqi: measurementDataService.caqi(s['channel']['field2'],
                  double.parse(s['feeds'][s['feeds'].length - 1]['field2']))),
          // StationComponent(
          //     name: s['channel']['field3'],
          //     value: double.parse(s['feeds'][s['feeds'].length - 1]['field3']),
          //     caqi: measurementDataService.caqi(s['channel']['field3'],
          //         double.parse(s['feeds'][s['feeds'].length - 1]['field3']))),
          // StationComponent(
          //     name: s['channel']['field4'],
          //     value: double.parse(s['feeds'][s['feeds'].length - 1]['field4']),
          //     caqi: measurementDataService.caqi(s['channel']['field4'],
          //         double.parse(s['feeds'][s['feeds'].length - 1]['field4']))),
        ];
        stationsAcc[s['channel']['name']] = Station.fromTsJson(s);
      }
      return stationsAcc;
    });
  }
}
