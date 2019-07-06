import 'dart:typed_data';
import 'package:luftinfo_app/models/station.dart';
import 'package:luftinfo_app/models/station_list.dart';
import 'package:rxdart/rxdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:luftinfo_app/bloc_provider.dart';
import 'package:luftinfo_app/services/measurementdata.serivce.dart';
import 'package:luftinfo_app/services/map_icon.service.dart';

class StationListBloc implements BlocBase {
  StationListBloc() {
    fetchStations();
  }

  final _stations = BehaviorSubject<Map<String, Station>>.seeded({});
  final _markers = BehaviorSubject<Map<MarkerId, Marker>>.seeded({});
  final _selectedStationId = BehaviorSubject<String>();
  String selectedMarkerId;

  ValueObservable<Map<String, Station>> get stations => _stations.stream;
  ValueObservable<Map<MarkerId, Marker>> get markers => _markers.stream;
  ValueObservable<String> get selectedStationId => _selectedStationId.stream;

  Observable<Station> get selectedStation =>
      selectedStationId.transform(WithLatestFromStreamTransformer(
          CombineLatestStream.list([markers, stations]), (id, data) {
        updateActiveMarker(id, data.first, data.last);
        return data.last[id];
      }));

  Future<void> fetchStations() async {
    StationsList stationList = await measurementDataService.fetchStations();

    Map<MarkerId, Marker> processedMarkers = <MarkerId, Marker>{};

    _stations.sink.add(stationList.stations);
    _selectedStationId.sink.add(stationList.stations.values.first.station);

    await Future.forEach(stationList.stations.values, (s) async {
      final Uint8List markerIcon = await MapIconService.createIcon(
          s.components[0].caqi,
          measurementDataService.caqiToColorRGBA(s.components[0].caqi));
      final MarkerId markerId = MarkerId(s.station);

      final Marker marker = Marker(
          markerId: markerId,
          position: LatLng(
            s.latitude,
            s.longitude,
          ),
          icon: BitmapDescriptor.fromBytes(markerIcon),
          onTap: () async {
            _selectedStationId.sink.add(markerId.value);
          });
      processedMarkers[markerId] = marker;
      _markers.sink.add(processedMarkers);
    });

    _selectedStationId.sink.add(stationList.stations.values.first.station);
  }

  void updateActiveMarker(String id, Map<MarkerId, Marker> markers,
      Map<String, Station> stations) async {
    final MarkerId tappedMarkerId = MarkerId(id);
    final Marker tappedMarker = markers[tappedMarkerId];
    if (tappedMarker == null) {
      return;
    }

    final Station tappedStation = stations[id];
    if (selectedMarkerId != null &&
        markers.containsKey(MarkerId(selectedMarkerId))) {
      final oldMarkerId = MarkerId(selectedMarkerId);
      final oldStation = stations[selectedMarkerId];
      final Marker resetOld = markers[oldMarkerId]
          .copyWith(iconParam: await createIcon(oldStation));
      markers[oldMarkerId] = resetOld;
    }

    selectedMarkerId = id;
    final Marker newMarker = markers[tappedMarkerId]
        .copyWith(iconParam: await createIcon(tappedStation, true));
    markers[tappedMarkerId] = newMarker;
    _markers.sink.add(markers);
  }

  Future<BitmapDescriptor> createIcon(Station station,
      [bool isActive = false]) async {
    final icon = await MapIconService.createIcon(
        station.components[0].caqi,
        measurementDataService.caqiToColorRGBA(station.components[0].caqi),
        isActive);
    return BitmapDescriptor.fromBytes(icon);
  }

  void dispose() {
    _stations.close();
    _markers.close();
    _selectedStationId.close();
  }
}
