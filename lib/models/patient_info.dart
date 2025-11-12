/// Patient information model
class PatientInfo {
  final String name;
  final int age;
  final String gender;
  final String phoneNumber;
  final DateTime timestamp;

  PatientInfo({
    required this.name,
    required this.age,
    required this.gender,
    required this.phoneNumber,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'gender': gender,
        'phoneNumber': phoneNumber,
        'timestamp': timestamp.toIso8601String(),
      };

  factory PatientInfo.fromJson(Map<String, dynamic> json) => PatientInfo(
        name: json['name'],
        age: json['age'],
        gender: json['gender'],
        phoneNumber: json['phoneNumber'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}
