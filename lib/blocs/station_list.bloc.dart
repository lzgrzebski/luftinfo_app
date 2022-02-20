import 'dart:typed_data';
import 'package:rxdart/rxdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:math' show cos, sqrt, asin;

import 'package:luftinfo_app/models/station.dart';
import 'package:luftinfo_app/models/station_details.dart';
import 'package:luftinfo_app/models/station_list.dart';
import 'package:luftinfo_app/bloc_provider.dart';
import 'package:luftinfo_app/services/measurementdata.serivce.dart';
import 'package:luftinfo_app/services/map_icon.service.dart';

class StationListBloc implements BlocBase {
  Location location = Location();

  StationListBloc() {
    fetchStations();
    getLocation();
  }

  final _stations = BehaviorSubject<Map<String, Station>>.seeded({});
  final _markers = BehaviorSubject<Map<MarkerId, Marker>>.seeded({});
  final _currentLocation = BehaviorSubject<LatLng>();
  final _selectedStationId = BehaviorSubject<String>();
  final _selectedStationDetails = BehaviorSubject<StationDetails>();
  String selectedMarkerId;

  Sink get addLocation => _currentLocation.sink;

  ValueObservable<Map<String, Station>> get stations => _stations.stream;
  ValueObservable<Map<MarkerId, Marker>> get markers => _markers.stream;
  ValueObservable<String> get selectedStationId => _selectedStationId.stream;
  ValueObservable<StationDetails> get selectedStationDetails =>
      _selectedStationDetails.stream;

  Observable<Station> get selectedStation =>
      selectedStationId.transform(WithLatestFromStreamTransformer.with1(
          CombineLatestStream.list([markers, stations]), (id, data) {
        updateActiveMarker(id, data.first, data.last);
        fetchStationDetails(data.last[id]);
        return data.last[id];
      }));

  Observable<LatLng> get currentLocation =>
      _currentLocation.stream.transform(WithLatestFromStreamTransformer.with1(
          CombineLatestStream.list([markers, stations]), (l, data) {
        selectClosestMarker(l, data.first, data.last);
        return l;
      }));

  Future<void> fetchStations() async {
    StationsList stationList = await measurementDataService.fetchStations();

    Map<MarkerId, Marker> processedMarkers = <MarkerId, Marker>{};

    _stations.sink.add(stationList.stations);
    // _selectedStationId.sink.add(stationList.stations.values.first.station);

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
    });
    _markers.sink.add(processedMarkers);

    if (_currentLocation.value != null) {
      selectClosestMarker(
          _currentLocation.value, processedMarkers, stationList.stations);
    } else {
      _selectedStationId.sink.add(stationList.stations.values.first.station);
    }
  }

  Future<void> fetchStationDetails(Station s) async {
    final data = await measurementDataService.fetchStationDetails(s);
    _selectedStationDetails.sink.add(data);
    // print(data);
  }

  void selectClosestMarker(
      LatLng l, Map<MarkerId, Marker> markers, Map<String, Station> stations) {
    Map<String, double> distances = {};
    String closest;
    markers.forEach((id, m) {
      double d = computeDistanceBetween(m.position, l);
      distances[id.value] = d;
      if (closest == null || d < distances[closest]) {
        closest = id.value;
      }
    });

    if (closest != null) {
      // updateActiveMarker(closest, markers, stations);
      _selectedStationId.sink.add(stations[closest].station);
    }
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

  double computeDistanceBetween(LatLng l1, LatLng l2) {
    double lat1 = l1.latitude;
    double lon1 = l1.longitude;
    double lat2 = l2.latitude;
    double lon2 = l2.longitude;

    double p = 0.017453292519943295;
    final c = cos;
    double a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void getLocation() async {
    LocationData gpsLocation;
    try {
      gpsLocation = await location.getLocation();
      _currentLocation.sink
          .add(LatLng(gpsLocation.latitude, gpsLocation.longitude));
    } catch (e) {
      gpsLocation = null;
    }
  }

  void dispose() {
    _stations.close();
    _markers.close();
    _selectedStationId.close();
    _currentLocation.close();
    _selectedStationDetails.close();
  }
}
