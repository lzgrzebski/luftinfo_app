import 'package:luftinfo_app/bloc_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:typed_data';

import 'package:luftinfo_app/models/processed_station.dart';
import 'package:luftinfo_app/services/measurementdata.serivce.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:luftinfo_app/services/map_icon.service.dart';

class StationListBloc implements BlocBase {
  StationListBloc() {
    fetchStations();
  }

  final _stations = BehaviorSubject<List<ProcessedStation>>.seeded([]);
  final _markers = BehaviorSubject<Map<MarkerId, Marker>>.seeded({});

  ValueObservable<List<ProcessedStation>> get stations => _stations.stream;
  ValueObservable<Map<MarkerId, Marker>> get markers => _markers.stream;

  Future<void> fetchStations() async {
    List<ProcessedStation> processedStations =
        await measurementDataService.fetchAndProcessStations();

    Map<MarkerId, Marker> processedMarkers = <MarkerId, Marker>{};

    await Future.forEach(processedStations, (s) async {
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
          onTap: () {});

      processedMarkers[markerId] = marker;
    });

    _markers.sink.add(processedMarkers);
    _stations.sink.add(processedStations);
  }

  void dispose() {
    _stations.close();
    _markers.close();
  }
}
