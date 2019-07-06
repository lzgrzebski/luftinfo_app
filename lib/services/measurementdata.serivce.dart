import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:luftinfo_app/models/station_list.dart';
import 'package:luftinfo_app/models/caqi.dart';

class MeasurementDataService {
  static const CACHING_SERVER_URL = 'https://probably.one:4433/ttl3600?';
  static const NILU_LAST_HOUR =
      'https://api.nilu.no/obs/utd?components=no2;pm10;so2;co;o3;pm2.5';
  static const List<String> TS_KEYS = ['HAK5BXQD3XUH8ZL7', '8NRVSJZ6IZSEIKWN'];
  static const TS_URL_CHANNELS =
      'https://api.thingspeak.com/channels.json?api_key=';
  static const TS_URL0 = 'https://api.thingspeak.com/channels/';
  static const TS_URL1 = '/feeds.json?average=60&round=2&results=1';

  static final List<CAQI> caqiTable = [
    CAQI(
        pollutant: 'PM2.5',
        vlow: [0, 15, 0, 25],
        low: [15, 30, 25, 50],
        med: [30, 55, 50, 75],
        hi: [55, 110, 75, 100]),
    CAQI(
        pollutant: 'PM10',
        vlow: [0, 25, 0, 25],
        low: [25, 50, 25, 50],
        med: [50, 90, 50, 75],
        hi: [90, 180, 75, 100]),
    CAQI(
        pollutant: 'NO2',
        vlow: [0, 50, 0, 25],
        low: [50, 100, 25, 50],
        med: [100, 200, 50, 75],
        hi: [200, 400, 75, 100]),
    CAQI(
        pollutant: 'O3',
        vlow: [0, 60, 0, 25],
        low: [60, 120, 25, 50],
        med: [120, 180, 50, 75],
        hi: [180, 240, 75, 100]),
    CAQI(
        pollutant: 'CO',
        vlow: [0, 5000, 0, 25],
        low: [5000, 7500, 25, 50],
        med: [7500, 10000, 50, 75],
        hi: [10000, 20000, 75, 100]),
    CAQI(
        pollutant: 'SO2',
        vlow: [0, 50, 0, 25],
        low: [50, 100, 25, 50],
        med: [100, 350, 50, 75],
        hi: [350, 500, 75, 100]),
  ];

  Future<StationsList> fetchStations() async {
    final response = await http.get(CACHING_SERVER_URL + NILU_LAST_HOUR);
    if (response.statusCode == 200) {
      return StationsList.fromJson(
          json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to fetch NILU stations');
    }
  }

  Future<List> fetchTsStationsIds() async {
    return await Future.wait(
        TS_KEYS.map((k) => http.get(TS_URL_CHANNELS + k).then((response) {
              if (response.statusCode == 200) {
                return json
                    .decode(utf8.decode(response.bodyBytes))
                    .map((d) => d.id);
              } else {
                throw Exception('Failed to load TS data from $k channel');
              }
            }))).then((tsStations) => tsStations.expand((x) => x).toList());
  }

  fetchTsStations() async {
    final stationIds = await fetchTsStationsIds();
    Future.wait(stationIds.map((id) =>
        http.get(CACHING_SERVER_URL + TS_URL0 + id + TS_URL1).then((response) {
          if (response.statusCode == 200) {
            return json.decode(utf8.decode(response.bodyBytes));
          } else {
            throw Exception('Failed to load TS data for $id');
          }
        })));
  }

  int caqi(String pollutant, double value) {
    List<int> f = [];
    int idx = 0;

    for (int i = 0; i < caqiTable.length; i++) {
      if (caqiTable[i].pollutant == pollutant) {
        idx = i;
        break;
      }
    }

    if (value < caqiTable[idx].vlow[1]) {
      f = caqiTable[idx].vlow;
    } else if (value < caqiTable[idx].low[1]) {
      f = caqiTable[idx].low;
    } else if (value < caqiTable[idx].med[1]) {
      f = caqiTable[idx].med;
    } else if (value < caqiTable[idx].hi[1]) {
      f = caqiTable[idx].hi;
    } else
      return 100;

    return (((f[3] - f[2]) / (f[1] - f[0])) * (value - f[0]) + f[2]).floor();
  }

  caqiToColorRGBA(int caqi) {
    if (caqi < 25) return '#78ba6a';
    if (caqi < 50) return '#acbc53';
    if (caqi < 75) return '#e6b628';
    if (caqi < 100) return '#fa780a';
    return '#95001e';
  }

  caqiToText(int caqi) {
    if (caqi < 25) return 'Very good';
    if (caqi < 50) return 'Good';
    if (caqi < 75) return 'Moderate';
    if (caqi < 100) return 'Bad';
    return 'Very bad';
  }
}

final MeasurementDataService measurementDataService = MeasurementDataService();
