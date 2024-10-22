class ConferenceModel {
  String nameOfConference;
  String date;
  String organizingInstitutions;
  String placeOfConference;
  int id;
  int internationalNational;

  ConferenceModel({
    required this.nameOfConference,
    required this.date,
    required this.organizingInstitutions,
    required this.placeOfConference,
    required this.id,
    required this.internationalNational,
  });

  factory ConferenceModel.fromJson(Map<String, dynamic> json) {
    return ConferenceModel(
      nameOfConference: json['nameoftheconference'] ?? '',
      date: json['date'] ?? '',
      organizingInstitutions: json['organizingInstitutions'] ?? '',
      placeOfConference: json['placeOfConference'] ?? '',
      id: json['id'] ?? 0,
      internationalNational: json['internationalorNational'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nameoftheconference': nameOfConference,
      'date': date,
      'organizingInstitutions': organizingInstitutions,
      'placeOfConference': placeOfConference,
      'id': id,
      'internationalorNational': internationalNational,
    };
  }
}
class DropdownOption {
  final int lookUpId;
  final String meaning;
  final String code;

  DropdownOption({
    required this.lookUpId,
    required this.meaning,
    required this.code,
  });

  factory DropdownOption.fromJson(Map<String, dynamic> json) {
    return DropdownOption(
      lookUpId: json['lookUpId'],
      meaning: json['meaning'],
      code: json['code'],
    );
  }
}
