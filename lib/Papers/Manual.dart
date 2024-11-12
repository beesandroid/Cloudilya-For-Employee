import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// Model class for dropdown options
class DropdownOption {
  final int lookUpId;
  final String meaning;

  DropdownOption({required this.lookUpId, required this.meaning});

  factory DropdownOption.fromJson(Map<String, dynamic> json) {
    return DropdownOption(
      lookUpId: json['lookUpId'],
      meaning: json['meaning'],
    );
  }
}

class EmployeePapersConferencesScreen extends StatefulWidget {
  const EmployeePapersConferencesScreen({Key? key}) : super(key: key);

  @override
  State<EmployeePapersConferencesScreen> createState() =>
      _EmployeePapersConferencesScreenState();
}

class _EmployeePapersConferencesScreenState
    extends State<EmployeePapersConferencesScreen> {
  List<dynamic> titlesList = [];
  bool isLoading = true;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController impactController = TextEditingController();
  final TextEditingController pagesController = TextEditingController();
  final TextEditingController publisherController = TextEditingController();
  final TextEditingController isbnController = TextEditingController();
  final TextEditingController copiesSoldController = TextEditingController();
  final TextEditingController ebookUrlController = TextEditingController();

  String? selectedBookCategory;
  String? selectedLanguage;
  String? selectedVolume;
  String? selectedAuthorRole;
  String? selectedPlaceOfPublication;

  List<DropdownOption> bookCategoryList = [];
  List<DropdownOption> languageList = [];
  List<DropdownOption> volumeList = [];
  List<DropdownOption> authorRoleList = [];
  List<DropdownOption> placeOfPublicationList = [];

  int? editingIndex;

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    await Future.wait([
      fetchTitles(),
      fetchDropdownData(42, (data) {
        bookCategoryList = data;
      }),
      fetchDropdownData(44, (data) {
        languageList = data;
      }),
      fetchDropdownData(43, (data) {
        volumeList = data;
      }),
      fetchDropdownData(53, (data) {
        authorRoleList = data;
      }),
      fetchDropdownData(46, (data) {
        placeOfPublicationList = data;
      }),
    ]);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchTitles() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('userType');
    final finYearId = prefs.getInt('finYearId');
    final acYearId = prefs.getInt('acYearId');
    final adminUserId = prefs.getString('adminUserId');
    final acYear = prefs.getString('acYear');
    final finYear = prefs.getString('finYear');
    final employeeId = prefs.getInt('employeeId');
    final collegeId = prefs.getString('collegeId');
    final colCode = prefs.getString('colCode');
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeePaperTitles'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "GrpCode": "Beesdev",
        "ColCode": colCode,
        "CollegeId": collegeId,
        "EmployeeId": employeeId,
        "TitleId": 0,
        "UserId": adminUserId,
        "LoginIpAddress": "",
        "LoginSystemName": "",
        "Flag": "VIEW",
        "AcYear": acYear,
        "TitlesVariable": [
          {
            "TitleId": 0,
            "Title": "",
            "Impact": "",
            "Category": 0,
            "Language": 0,
            "Volume": 0,
            "Pages": 0,
            "Publisher": "",
            "YearofPublishing": 0,
            "PlaceofPublication": 0,
            "ISBNNO": "",
            "CopiedSold": "",
            "eBookURL": "",
            "AuthorRole": ""
          }
        ]
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        titlesList = data['displayandSaveEmployeePaperTitlesList'] ?? [];
      });
    } else {
      print('Failed to load titles: ${response.statusCode}');
    }
  }

  Future<void> fetchDropdownData(
      int flag, Function(List<DropdownOption>) onDataFetched) async {
    final response = await http.post(
      Uri.parse(
          "https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/CommonLookUpsDropDown"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"GrpCode": "Beesdev", "ColCode": "0001", "Flag": flag}),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      List<DropdownOption> options = [];
      switch (flag) {
        case 42:
          options = (jsonResponse['bookCategoryList'] as List)
              .map((item) => DropdownOption.fromJson(item))
              .toList();
          break;
        case 44:
          options = (jsonResponse['languageList'] as List)
              .map((item) => DropdownOption.fromJson(item))
              .toList();
          break;
        case 43:
          options = (jsonResponse['volumeList'] as List)
              .map((item) => DropdownOption.fromJson(item))
              .toList();
          break;
        case 53:
          options = (jsonResponse['autherRoleList'] as List)
              .map((item) => DropdownOption.fromJson(item))
              .toList();
          break;
        case 46:
          options = (jsonResponse['placeOfPublicationList'] as List)
              .map((item) => DropdownOption.fromJson(item))
              .toList();
          break;
      }
      setState(() {
        onDataFetched(options);
      });
    } else {
      print('Error fetching data: ${response.statusCode}');
    }
  }

  String _getDropdownName(int id, List<DropdownOption> options) {
    final option = options.firstWhere((element) => element.lookUpId == id,
        orElse: () => DropdownOption(lookUpId: 0, meaning: 'Unknown'));
    return option.meaning;
  }

  void populateFormFields(dynamic titleData) {
    setState(() {
      print('Populating form with: $titleData'); // Debugging statement
      titleController.text = titleData['title'] ?? '';
      impactController.text = titleData['impact'] ?? '';
      pagesController.text = titleData['pages']?.toString() ?? '';
      publisherController.text = titleData['publisher'] ?? '';
      isbnController.text = titleData['isbnno'] ?? '';
      copiesSoldController.text = titleData['copiedSold']?.toString() ?? '';
      ebookUrlController.text = titleData['eBookURL'] ?? '';

      selectedBookCategory = titleData['bookCategory']?.toString();
      selectedLanguage = titleData['language']?.toString();
      selectedVolume = titleData['volume']?.toString();
      selectedAuthorRole = titleData['authorRole']?.toString();
      selectedPlaceOfPublication = titleData['placeOfPublication']?.toString();
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    impactController.dispose();
    pagesController.dispose();
    publisherController.dispose();
    isbnController.dispose();
    copiesSoldController.dispose();
    ebookUrlController.dispose();
    super.dispose();
  }

  Future<void> updateTitle(int titleId) async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('userType');
    final finYearId = prefs.getInt('finYearId');
    final acYearId = prefs.getInt('acYearId');
    final adminUserId = prefs.getString('adminUserId');
    final acYear = prefs.getString('acYear');
    final finYear = prefs.getString('finYear');
    final employeeId = prefs.getInt('employeeId');
    final collegeId = prefs.getString('collegeId');
    final colCode = prefs.getString('colCode');
    final requestBody = {
      "GrpCode": "Beesdev",
      "ColCode": colCode,
      "CollegeId": collegeId,
      "EmployeeId": employeeId,
      "TitleId": titleId,
      "UserId": adminUserId,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "OVERWRITE",
      "AcYear": acYear,
      "TitlesVariable": [
        {
          "TitleId": titleId,
          "Title": titleController.text,
          "Impact": impactController.text,
          "Category": selectedBookCategory != null
              ? int.parse(selectedBookCategory!)
              : 0,
          "Language":
          selectedLanguage != null ? int.parse(selectedLanguage!) : 0,
          "Volume": selectedVolume != null ? int.parse(selectedVolume!) : 0,
          "Pages": int.tryParse(pagesController.text) ?? 0,
          "Publisher": publisherController.text,
          "YearofPublishing": 0, // Update as needed
          "PlaceofPublication": selectedPlaceOfPublication != null
              ? int.parse(selectedPlaceOfPublication!)
              : 0,
          "ISBNNO": isbnController.text,
          "CopiedSold": copiesSoldController.text,
          "eBookURL": ebookUrlController.text,
          "AuthorRole": selectedAuthorRole.toString()
        }
      ]
    };
    print('Update Request Body: ${jsonEncode(requestBody)}');
    try {
      final response = await http.post(
        Uri.parse(
            "https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeePaperTitles"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final data = json.decode(response.body);
        final message = responseBody['message'] ;
        if (data.containsKey('message')) {
          // Show Toast with the message
          Fluttertoast.showToast(
            msg: data['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }

        print('Successfully updated: ${response.body}');
        await fetchTitles(); // Update the titlesList after update
        setState(() {
          editingIndex = null; // Reset editingIndex after update
        });
        clearFormFields();
      } else {
        print('Error updating form: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to update title: $e');
    }
  }

  Future<void> submitForm() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('userType');
    final finYearId = prefs.getInt('finYearId');
    final acYearId = prefs.getInt('acYearId');
    final adminUserId = prefs.getString('adminUserId');
    final acYear = prefs.getString('acYear');
    final finYear = prefs.getString('finYear');
    final employeeId = prefs.getInt('employeeId');
    final collegeId = prefs.getString('collegeId');
    final colCode = prefs.getString('colCode');
    final requestBody = {
      "GrpCode": "Beesdev",
      "ColCode": colCode,
      "CollegeId": collegeId,
      "EmployeeId":employeeId,
      "TitleId": 0,
      "UserId": adminUserId,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "CREATE",
      "AcYear": acYear,
      "TitlesVariable": [
        {
          "TitleId": 0,
          "Title": titleController.text,
          "Impact": impactController.text,
          "Category": selectedBookCategory != null
              ? int.parse(selectedBookCategory!)
              : 0,
          "Language":
          selectedLanguage != null ? int.parse(selectedLanguage!) : 0,
          "Volume": selectedVolume != null ? int.parse(selectedVolume!) : 0,
          "Pages": int.tryParse(pagesController.text) ?? 0,
          "Publisher": publisherController.text,
          "YearofPublishing": 0, // Update as needed
          "PlaceofPublication": selectedPlaceOfPublication != null
              ? int.parse(selectedPlaceOfPublication!)
              : 0,
          "ISBNNO": isbnController.text,
          "CopiedSold": copiesSoldController.text,
          "eBookURL": ebookUrlController.text,
          "AuthorRole": selectedAuthorRole.toString()
        }
      ]
    };
    print('Request Body: ${jsonEncode(requestBody)}');
    final response = await http.post(
      Uri.parse(
          "https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeePaperTitles"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {




      print('Successfully submitted: ${response.body}');
      await fetchTitles(); // Refresh the titles list
      clearFormFields();
      final responseBody = json.decode(response.body);
      final data = json.decode(response.body);
      final message = responseBody['message'] ;
      if (data.containsKey('message')) {
        // Show Toast with the message
        Fluttertoast.showToast(
          msg: data['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }


    } else {
      print('Error submitting form: ${response.statusCode}');
    }
  }

  void clearFormFields() {
    setState(() {
      titleController.clear();
      impactController.clear();
      pagesController.clear();
      publisherController.clear();
      isbnController.clear();
      copiesSoldController.clear();
      ebookUrlController.clear();

      selectedBookCategory = null;
      selectedLanguage = null;
      selectedVolume = null;
      selectedAuthorRole = null;
      selectedPlaceOfPublication = null;

      editingIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Papers",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _buildTextField(titleController, "Title of the Book"),
                    _buildDropdown(bookCategoryList, selectedBookCategory,
                            (newValue) {
                          setState(() {
                            selectedBookCategory = newValue;
                          });
                        }, "Select Book Category"),
                    _buildDropdown(languageList, selectedLanguage,
                            (newValue) {
                          setState(() {
                            selectedLanguage = newValue;
                          });
                        }, "Select Language"),
                    _buildTextField(impactController, "Impact"),
                    _buildTextField(pagesController, "Pages"),
                    _buildTextField(publisherController, "Publisher"),
                    _buildTextField(isbnController, "ISBN No."),
                    _buildTextField(copiesSoldController, "Copies Sold"),
                    _buildTextField(ebookUrlController, "eBook URL"),
                    _buildDropdown(volumeList, selectedVolume, (newValue) {
                      setState(() {
                        selectedVolume = newValue;
                      });
                    }, "Select Volume"),
                    _buildDropdown(authorRoleList, selectedAuthorRole,
                            (newValue) {
                          setState(() {
                            selectedAuthorRole = newValue;
                          });
                        }, "Select Author Role"),
                    _buildDropdown(placeOfPublicationList,
                        selectedPlaceOfPublication, (newValue) {
                          setState(() {
                            selectedPlaceOfPublication = newValue;
                          });
                        }, "Select Place of Publication"),
                    const SizedBox(height: 20),
                    editingIndex != null
                        ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      onPressed: () {
                        updateTitle(
                            titlesList[editingIndex!]['titleId']);
                      },
                      child: const Text(
                        "Update",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                        : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      onPressed: () {
                        submitForm();
                      },
                      child: const Text(
                        "Submit",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Published Titles",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 22),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: titlesList.length,
                  itemBuilder: (context, index) {
                    final titleData = titlesList[index];

                    print(
                        'titleData at index $index: $titleData'); // Debugging

                    int bookCategoryId = int.tryParse(
                        titleData['bookCategory']?.toString() ?? '') ??
                        0;
                    int placeOfPublicationId = int.tryParse(
                        titleData['placeOfPublication']
                            ?.toString() ??
                            '') ??
                        0;
                    int languageId = int.tryParse(
                        titleData['language']?.toString() ?? '') ??
                        0;
                    int volumeId = int.tryParse(
                        titleData['volume']?.toString() ?? '') ??
                        0;
                    int authorRoleId = int.tryParse(
                        titleData['authorRole']?.toString() ?? '') ??
                        0;

                    return Card(
                      color: Colors.white,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titleData['title'] ?? 'No Title',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Impact: ${titleData['impact'] ?? 'Unknown'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Category: ${_getDropdownName(bookCategoryId, bookCategoryList)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Place of Publication: ${_getDropdownName(placeOfPublicationId, placeOfPublicationList)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Language: ${_getDropdownName(languageId, languageList)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Volume: ${_getDropdownName(volumeId, volumeList)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Author Role: ${_getDropdownName(authorRoleId, authorRoleList)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Status: ${titleData['status'] ?? 'Unknown'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                onPressed: () {
                                  // Get the status of the title
                                  final String status = titleData['status']?.toString() ?? '';

                                  if (status.toLowerCase() == 'pending') {
                                    // Show a toast message if the status is pending
                                    Fluttertoast.showToast(
                                      msg: "Changes sent for approval cannot be edited now",
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                  } else {
                                    // Allow editing if the status is not pending
                                    populateFormFields(titleData);
                                    setState(() {
                                      editingIndex = index;
                                    });
                                  }
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                              ),
                            )

                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown(List<DropdownOption> options, String? selectedValue,
      ValueChanged<String?> onChanged, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: hint,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
        items: options.map((option) {
          return DropdownMenuItem(
            value: option.lookUpId.toString(),
            child: Text(option.meaning),
          );
        }).toList(),
      ),
    );
  }
}
