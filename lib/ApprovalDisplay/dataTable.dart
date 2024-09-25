class Approval {
  final int slNo;
  final String interfaceName;
  final String status;
  final String requestDate;
  final String roleName;

  Approval({
    required this.slNo,
    required this.interfaceName,
    required this.status,
    required this.requestDate,
    required this.roleName,
  });

  factory Approval.fromJson(Map<String, dynamic> json) {
    return Approval(
      slNo: json['slNo'],
      interfaceName: json['interfaceName'] ?? '',
      status: json['status'] ?? 'Unknown',
      requestDate: json['requestDate'] ?? '',
      roleName: json['roleName'] ?? 'Unknown',
    );
  }


}