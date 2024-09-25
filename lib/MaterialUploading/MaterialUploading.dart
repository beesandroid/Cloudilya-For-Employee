import 'package:cloudilyaemployee/MaterialUploading/view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ProgramDropdownScreen extends StatefulWidget {
  @override
  _ProgramDropdownScreenState createState() => _ProgramDropdownScreenState();
}

class _ProgramDropdownScreenState extends State<ProgramDropdownScreen> {
  String? _selectedProgram,
      _selectedBranch,
      _selectedSemester,
      _selectedSection,
      _selectedCourse,
      _selectedMaterialType,
      _selectedUnit,
      _selectedTopic;
  Map<String, int> _materialTypeMap = {};
  List<dynamic> _employeeMaterialList = [];
  bool _isLoading = true;

  int? _selectedMaterialTypeId;
  List<String> _materialTypeList = [];

  int? _unitId;
  List<PlatformFile>? _selectedFiles;

  List<Map<String, dynamic>> _programList = [];
  List<String> _branchList = [], _semesterList = [], _sectionList = [];
  List<Map<String, dynamic>> _unitList = [];
  List<Map<String, dynamic>> _topicList = [];

  List<Map<String, dynamic>> _courseList =
      []; // Updated to store both courseId and courseName
  bool _isLoadingPrograms = true,
      _isLoadingBranches = false,
      _isLoadingSemesters = false,
      _isLoadingSections = false,
      _isLoadingCourses = false,
      _isLoadingMaterialTypes = false,
      _isLoadingUnits = false,
      _isLoadingTopics = false;
  int? _selectedUnitId;
  String? _selectedUnitName;

  // Variables to store dynamic values
  String? _semId, _branchId, _sectionId, _courseId;
  String _todayDate = '';

  @override
  void initState() {
    super.initState();
    _fetchEmployeeMaterialData();
    _todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    _fetchData('ProgramDropdownForMaterial', {}, (data) {
      _programList = (data['programDropdownForMaterialList'] as List?)
              ?.map<Map<String, dynamic>>((item) => {
                    'programId': item['programId'],
                    'programName': item['programName']
                  })
              .toList() ??
          [];
      _isLoadingPrograms = false;
    });
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.files;
        });
      }
    } catch (e) {
      print('Error picking files: $e');
    }
  }

  Future<void> _fetchEmployeeMaterialData() async {
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeMaterialUploading'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "GrpCode": "Beesdev",
        "ColCode": "0001",
        "CollegeId": 1,
        "UserId": 1,
        "Id": 1,
        "Batch": "",
        "TopicId": 159,
        "ChooseFile": "23148_Regular.pdf",
        "UpdatedDate": "2024-09-18",
        "EmployeeId": 3,
        "ProgramId": 51,
        "BranchId": 62,
        "SemId": 47,
        "SectionId": 0,
        "CourseId": 1556,
        "MaterialType": 0,
        "Unit": 5652,
        "LoginIpAddress": "",
        "LoginSystemName": "",
        "Flag": "VIEW"
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print(responseData);
      setState(() {
        _employeeMaterialList = responseData['employeeMaterialUploadingList'];
        _isLoading = false;
      });
    } else {
      // Handle error response
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchData(String endpoint, Map<String, String> body,
      Function(Map) onSuccess) async {
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/$endpoint'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "GrpCode": "Beesdev",
        "ColCode": "0001",
        "EmployeeId": "3",
        ...body,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print(responseData);
      setState(() => onSuccess(responseData));
    }
  }

  Future<void> _saveData() async {
    if (_selectedProgram == null ||
        _selectedBranch == null ||
        _selectedSemester == null ||
        _selectedSection == null ||
        _selectedCourse == null ||
        _selectedMaterialType == null ||
        _selectedUnitId == null ||
        _selectedTopic == null ||
        _selectedFiles == null) {
      // Handle missing data or files
      print('Please fill in all required fields and select files.');
      return;
    }

    final requestBody = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "UserId": 1,
      "Id": 1,
      "Batch": "",
      "TopicId": int.parse(_selectedTopic!),
      "ChooseFile": _selectedFiles!.map((file) => file.name).join(', '),
      "UpdatedDate": _todayDate,
      "EmployeeId": "3",
      "ProgramId": int.parse(_selectedProgram!),
      "BranchId": _branchId,
      "SemId": int.parse(_semId!),
      "SectionId": int.parse(_sectionId!),
      "CourseId": int.parse(_courseId!),
      "MaterialType": _selectedMaterialTypeId!,
      "Unit": _selectedUnitId!,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "CREATE"
    };
    print(requestBody);
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeMaterialUploading'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('Save Response: $responseData');
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EmployeeMaterialScreen()), // Navigate to ProgramDropdownScreen
      );
      // Handle the response
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data saved successfully!'),
        ),
      );
    } else {
      print('Error saving data');
    }
  }

  Future<void> _fetchTopics() async {
    setState(() {
      _isLoadingTopics = true;
    });

    final requestBody = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "ProgramId": _selectedProgram!,
      "SemId": _semId!,
      "BranchId": _branchId!,
      "CourseId": _courseId!,
      "UnitId": _selectedUnitId,
    };
    print(requestBody);

    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/MaterialUploadingTopicDropdown'),
      body: json.encode(requestBody),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('Topic Dropdown Response: $responseData');

      final topics =
          (responseData['materialUploadingTopicDropdownList'] as List?)
                  ?.map<Map<String, dynamic>>((item) => {
                        'topicId': item['topicId'],
                        'topicName': item['topicName'],
                      })
                  .toList() ??
              [];

      setState(() {
        _topicList = topics;
        _isLoadingTopics = false;
      });
    } else {
      setState(() {
        _isLoadingTopics = false;
      });
      print('Error fetching topics');
    }
  }

  Future<void> _fetchMaterialTypes() async {
    setState(() {
      _isLoadingMaterialTypes = true;
    });

    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/CommonLookUpsDropDown'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "GrpCode": "Beesdev",
        "ColCode": "0001",
        "Flag": "97",
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final materialTypeList = responseData['materialTypeList'] as List?;

      final materialTypeMap = <String, int>{};
      for (var item in materialTypeList ?? []) {
        final materialType = item['meaning'] as String;
        final lookUpId = item['lookUpId'] as int?;
        if (lookUpId != null) {
          materialTypeMap[materialType] = lookUpId;
        }
      }

      setState(() {
        _materialTypeMap = materialTypeMap;
        _materialTypeList = _materialTypeMap.keys.toList();
        print('MaterialType Map: $_materialTypeMap');
        _isLoadingMaterialTypes = false;
      });
    } else {
      setState(() {
        _isLoadingMaterialTypes = false;
      });
    }
  }

  Future<void> _fetchUnits() async {
    setState(() {
      _isLoadingUnits = true;
    });

    final requestBody = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "ProgramId": _selectedProgram!,
      "SemId": _semId!,
      "BranchId": _branchId!,
      "CourseId": _courseId!,
    };

    // Print the request body before sending the request
    print('Request Body: ${json.encode(requestBody)}');

    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/MaterialUploadingForUnitsDropdown'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print(
          'Response Data: $responseData'); // Print the response to the console

      final units =
          (responseData['materialUploadingForUnitsDropdownList'] as List?)
                  ?.map((item) {
                return {
                  'unitId': item['unitId'] as int,
                  'unitName': item['unitName'] as String,
                };
              }).toList() ??
              [];

      setState(() {
        _unitList = units;
        _isLoadingUnits = false;
      });
    } else {
      setState(() {
        _isLoadingUnits = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Material',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdown(
              value: _selectedProgram,
              hint: 'Choose Program',
              items: _programList.map((program) {
                return DropdownMenuItem<String>(
                  value: program['programId'].toString(),
                  child: Text(program['programName']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProgram = value;
                  _selectedBranch = null;
                  _selectedSemester = null;
                  _selectedSection = null;
                  _selectedCourse = null;
                  _branchList.clear();
                  _semesterList.clear();
                  _sectionList.clear();
                  _courseList.clear();
                  _isLoadingBranches = true;
                });
                _fetchData(
                    'MaterialUploadingBranchDropdown', {'ProgramId': value!},
                    (data) {
                  setState(() {
                    _branchList =
                        (data['materialUploadingBranchDropdownList'] as List?)
                                ?.map<String>(
                                    (item) => item['branchName'] as String)
                                .toList() ??
                            [];
                    _branchId =
                        (data['materialUploadingBranchDropdownList'] as List?)
                            ?.first['branchId']
                            .toString();
                    _isLoadingBranches = false;
                  });
                });
              },
            ),
            if (_isLoadingBranches)
              _buildLoadingIndicator()
            else if (_branchList.isNotEmpty)
              _buildDropdown(
                value: _selectedBranch,
                hint: 'Choose Branch',
                items: _branchList
                    .map((branch) => DropdownMenuItem<String>(
                          value: branch,
                          child: Text(branch),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBranch = value;
                    _isLoadingSemesters = true;
                  });
                  _fetchData('MaterialUploadingSemesterDropdown',
                      {'ProgramId': _selectedProgram!}, (data) {
                    setState(() {
                      _semesterList =
                          (data['materialUploadingSemesterDropdownList']
                                      as List?)
                                  ?.map<String>(
                                      (item) => item['semester'] as String)
                                  .toList() ??
                              [];
                      _semId = (data['materialUploadingSemesterDropdownList']
                              as List?)
                          ?.first['semId']
                          .toString();
                      _isLoadingSemesters = false;
                    });
                  });
                },
              ),
            if (_isLoadingSemesters)
              _buildLoadingIndicator()
            else if (_semesterList.isNotEmpty)
              _buildDropdown(
                value: _selectedSemester,
                hint: 'Choose Semester',
                items: _semesterList
                    .map((semester) => DropdownMenuItem<String>(
                          value: semester,
                          child: Text(semester),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSemester = value;
                    _isLoadingSections = true;
                  });
                  _fetchData('MaterialUploadingSectionDropdown', {}, (data) {
                    setState(() {
                      _sectionList =
                          (data['materialUploadingSectionDropdownList']
                                      as List?)
                                  ?.map<String>(
                                      (item) => item['sectionName'] as String)
                                  .toList() ??
                              [];
                      _sectionId = (data['materialUploadingSectionDropdownList']
                              as List?)
                          ?.first['sectionId']
                          .toString();
                      _isLoadingSections = false;
                    });
                  });
                },
              ),
            if (_isLoadingSections)
              _buildLoadingIndicator()
            else if (_sectionList.isNotEmpty)
              _buildDropdown(
                value: _selectedSection,
                hint: 'Choose Section',
                items: _sectionList
                    .map((section) => DropdownMenuItem<String>(
                          value: section,
                          child: Text(section),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSection = value;
                    _isLoadingCourses = true;
                  });
                  final requestBody = {
                    "GrpCode": "Beesdev",
                    "ColCode": "0001",
                    "CollegeId": "1",
                    "ProgramId": _selectedProgram!,
                    "SemId": _semId!,
                    "BranchId": _branchId!,
                    "SectionId": _sectionId!,
                  };
                  _fetchData('MaterialUploadingCourseDropDown', requestBody,
                      (data) {
                    setState(() {
                      _courseList =
                          (data['materialUploadingCourseDropDownList'] as List?)
                                  ?.map<Map<String, dynamic>>((item) => {
                                        'courseId': item['courseId'],
                                        'courseName': item['courseName']
                                      })
                                  .toList() ??
                              [];
                      _isLoadingCourses = false;
                    });
                  });
                },
              ),
            if (_isLoadingCourses)
              _buildLoadingIndicator()
            else if (_courseList.isNotEmpty)
              _buildDropdown(
                value: _selectedCourse,
                hint: 'Choose Course',
                items: _courseList.map((course) {
                  return DropdownMenuItem<String>(
                    value: course['courseName'],
                    child: Text(course['courseName']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCourse = value;
                    _courseId = _courseList
                        .firstWhere(
                          (course) => course['courseName'] == value,
                        )['courseId']
                        .toString();
                    print('Selected Course ID: $_courseId');
                    _isLoadingMaterialTypes = true;
                  });
                  _fetchMaterialTypes();
                },
              ),
            if (_isLoadingMaterialTypes)
              _buildLoadingIndicator()
            else if (_materialTypeList.isNotEmpty)
              _buildDropdown(
                value: _selectedMaterialType,
                hint: 'Choose Material Type',
                items: _materialTypeList
                    .map((materialType) => DropdownMenuItem<String>(
                          value: materialType,
                          child: Text(materialType),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMaterialType = value;
                    _selectedMaterialTypeId = _materialTypeMap[value];
                  });
                  print('Selected MaterialType: $value');
                  print('Selected LookUpId: $_selectedMaterialTypeId');
                  _fetchUnits();
                },
              ),
            if (_isLoadingUnits)
              _buildLoadingIndicator()
            else if (_unitList.isNotEmpty)
              _buildDropdown(
                value: _selectedUnitId,
                hint: 'Choose Unit',
                items: _unitList.map((unit) {
                  return DropdownMenuItem<int>(
                    value: unit['unitId'],
                    child: Text(unit['unitName']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUnitId = value;
                    print('Selected Unit ID: $_selectedUnitId');
                  });
                  _fetchTopics();
                },
              ),
            if (_isLoadingTopics)
              _buildLoadingIndicator()
            else if (_topicList.isNotEmpty)
              _buildDropdown(
                value: _selectedTopic,
                hint: 'Choose Topic',
                items: _topicList
                    .map((topic) => DropdownMenuItem<String>(
                          value: topic['topicId'].toString(),
                          child: Text(topic['topicName']),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTopic = value;
                    print(_selectedTopic);
                  });
                },
              ),
            if (_topicList.isNotEmpty) ...[
              Text(
                'Today\'s Date: $_todayDate',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 180,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      onPressed: _pickFiles,
                      child: Text(
                        'Pick Files',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              if (_selectedFiles != null)
                ..._selectedFiles!.map((file) => Text(file.name)).toList(),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 180,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      onPressed: _saveData,
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        isExpanded: true,
        value: value,
        hint: Text(hint),
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(child: CircularProgressIndicator());
  }
}
