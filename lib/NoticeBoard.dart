import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NoticeboardUpload extends StatefulWidget {
  const NoticeboardUpload({super.key});

  @override
  State<NoticeboardUpload> createState() => _NoticeboardUploadState();
}

class _NoticeboardUploadState extends State<NoticeboardUpload> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _employeeNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _headerDescriptionController = TextEditingController();
  DateTime? _selectedDate;
  XFile? _selectedImage;
  String? _eventType;
  final ImagePicker _picker = ImagePicker();

  Future<void> _submitNotice() async {
    if (_formKey.currentState!.validate()) {
      // Prepare the request body
      final requestBody = {
        "grpCode": "BeesDev",
        "colCode": "0001",
        "collegeId": 1,
        "id": 0,
        "employeeId": 1,
        "noticeTitle": _titleController.text,
        "description": _descriptionController.text,
        "eventType": _eventType ?? '',
        "requestDate": DateTime.now().toIso8601String(),
        "eventDate": _selectedDate?.toIso8601String() ?? '',
        "startTime": _startTimeController.text,
        "endTime": _endTimeController.text,
        "uploadPhoto": _selectedImage != null ? base64Encode(await _selectedImage!.readAsBytes()) : '',
        "employeeName": _employeeNameController.text,
        "location": _locationController.text,
        "headerDescription": _headerDescriptionController.text,
      };
      print(requestBody);

      // Make the API call
      final response = await http.post(
        Uri.parse('https://beessoftware.cloud/CoreAPIPreprod/CloudilyaMobileAPP/NoticeBoardSaving'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      // Handle the response
      if (response.statusCode == 200) {
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notice Uploaded Successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload notice')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticeboard Upload'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Notice Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _eventType,
                  items: const [
                    DropdownMenuItem(value: 'Placement', child: Text('Placement')),
                    DropdownMenuItem(value: 'Sports Meet', child: Text('Sports Meet')),
                    DropdownMenuItem(value: 'College Event', child: Text('College Event')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _eventType = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Event Type',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an event type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'Select Event Date'
                            : 'Selected Date: ${_selectedDate!.toLocal()}'.split(' ')[0],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _selectedDate = pickedDate;
                          });
                        }
                      },
                      child: const Text('Pick Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _startTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Start Time (e.g., 10:00 AM)',
                    border: OutlineInputBorder(),
                  ),

                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _endTimeController,
                  decoration: const InputDecoration(
                    labelText: 'End Time (e.g., 1:00 PM)',
                    border: OutlineInputBorder(),
                  ),

                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _employeeNameController,
                  decoration: const InputDecoration(
                    labelText: 'Employee Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an employee name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _headerDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Header Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a header description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedImage == null
                            ? 'No image selected'
                            : 'Image Selected: ${_selectedImage!.name}',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                        if (pickedImage != null) {
                          setState(() {
                            _selectedImage = pickedImage;
                          });
                        }
                      },
                      child: const Text('Upload Photo'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitNotice,
                    child: const Text('Upload Notice'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() => runApp(const MaterialApp(home: NoticeboardUpload()));
