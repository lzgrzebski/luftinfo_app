class Station {
  final String zone;
  final String municipality;
  final String area;
  final String station;
  final String eoi;
  final String component;
  final String fromTime;
  final String toTime;
  final double value;
  final String unit;
  final double latitude;
  final double longitude;
  final int timestep;

  Station({
    this.zone,
    this.municipality,
    this.area,
    this.station,
    this.eoi,
    this.component,
    this.fromTime,
    this.toTime,
    this.value,
    this.unit,
    this.latitude,
    this.longitude,
    this.timestep,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return new Station(
      zone: json['zone'],
      municipality: json['municipality'],
      area: json['area'],
      station: json['station'],
      eoi: json['eoi'],
      component: json['component'],
      fromTime: json['fromTime'],
      toTime: json['toTime'],
      value: json['value'],
      unit: json['unit'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      timestep: json['timestep'],
    );
  }
}
