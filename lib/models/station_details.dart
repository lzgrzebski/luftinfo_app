import 'package:luftinfo_app/models/station_data.dart';

class StationDetails {
  final List<StationData> data;

  StationDetails({this.data});

  factory StationDetails.fromTsJson(Map<dynamic, dynamic> parsedJson) {
    List<String> labels = [];
    List<double> dataset1 = [];
    List<double> dataset2 = [];
    parsedJson['feeds'].forEach((data) {
      if (data['field1'] != null) {
        labels.add(data['created_at']);
        dataset1.add(double.parse(data['field1']));
      }
      if (data['field2'] != null) {
        dataset2.add(double.parse(data['field2']));
      }
    });
    return new StationDetails(data: [
      StationData(
          pollutant: parsedJson['channel']['field1'],
          labels: labels,
          values: dataset1),
      StationData(
          pollutant: parsedJson['channel']['field2'],
          labels: labels,
          values: dataset2),
    ]);
  }

  factory StationDetails.fromNiluJson(List<dynamic> parsedJson) {
    return new StationDetails(
        data: parsedJson.map<StationData>((s) {
      final normalized = s['values'].fold({}, (valuesAcc, v) {
        String label;
        if (v['fromTime'] != null) {
          label = v['fromTime'];
        } else if (v['dateTime'] != null) {
          label = v['dateTime'];
        } else {
          return valuesAcc;
        }

        if (valuesAcc['labels'] == null) {
          valuesAcc['labels'] = <String>[];
        }

        if (valuesAcc['values'] == null) {
          valuesAcc['values'] = <double>[];
        }

        valuesAcc['labels'].add(label);
        valuesAcc['values'].add(v['value']);
        return valuesAcc;
      });
      return StationData(
          pollutant: s['component'],
          labels: normalized['labels'],
          values: normalized['values']);
    }).toList());
  }
}
