class Section {
  final int sectionId;
  final String section;
  final double maxLimit;

  Section(
      {required this.sectionId, required this.section, this.maxLimit = 0.0});

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      sectionId: json['sectionId'],
      section: json['section'],
      maxLimit: json.containsKey('maxLimit') && json['maxLimit'] != null
          ? json['maxLimit'].toDouble()
          : 0.0,
    );
  }
}

class Deduction {
  final int deductionId;
  final String deductionName;
  final double maxLimit; // Add this line
  Deduction(
      {required this.deductionId,
        required this.deductionName,
        this.maxLimit = 0.0}); // Update constructor
  factory Deduction.fromJson(Map<String, dynamic> json) {
    return Deduction(
      deductionId: json['deductionId'],
      deductionName: json['deductionName'],
      maxLimit: json.containsKey('maxLimit') && json['maxLimit'] != null
          ? json['maxLimit'].toDouble()
          : 0.0, // Handle null or missing values
    );
  }
}
