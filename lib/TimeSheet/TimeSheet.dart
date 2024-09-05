import 'package:flutter/material.dart';

class TimeSheet extends StatefulWidget {
  const TimeSheet({super.key});

  @override
  State<TimeSheet> createState() => _TimeSheetState();
}

class _TimeSheetState extends State<TimeSheet> {
  List<TimeSheetEntry> entries = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Time Sheets',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              setState(() {
                entries.add(TimeSheetEntry());
              });
            },
          ),
        ],
      ),
      body: Container(
        child: ListView.builder(
          itemCount: entries.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TimeSheetWidget(
                entry: entries[index],
                onRemove: () {
                  setState(() {
                    entries.removeAt(index);
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class TimeSheetEntry {
  DateTime date = DateTime.now();
  TimeOfDay from = TimeOfDay.now();
  TimeOfDay to = TimeOfDay.now();
  String task = '';
}

class TimeSheetWidget extends StatefulWidget {
  final TimeSheetEntry entry;
  final VoidCallback onRemove;

  const TimeSheetWidget({
    Key? key,
    required this.entry,
    required this.onRemove,
  }) : super(key: key);

  @override
  _TimeSheetWidgetState createState() => _TimeSheetWidgetState();
}

class _TimeSheetWidgetState extends State<TimeSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blueGrey[900]!, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                final DateTime? selectedDate =
                await _selectDate(context, widget.entry.date);
                if (selectedDate != null) {
                  setState(() {
                    widget.entry.date = selectedDate;
                  });
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Select Date',
                  labelStyle: TextStyle(
                      color: Colors.blueGrey[700], fontWeight: FontWeight.bold),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.blueGrey[400]!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.entry.date.day}/${widget.entry.date.month}/${widget.entry.date.year}',
                      style: TextStyle(
                          color: Colors.blueGrey[900],
                          fontWeight: FontWeight.w600),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.blueGrey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Task: ${widget.entry.task.isEmpty ? 'No Task Selected' : widget.entry.task}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.blueGrey[900],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final TimeOfDay? selectedTime =
                      await _selectTime(context, widget.entry.from);
                      if (selectedTime != null &&
                          selectedTime != widget.entry.from) {
                        setState(() {
                          widget.entry.from = selectedTime;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'From Time',
                        labelStyle: TextStyle(
                            color: Colors.blueGrey[700],
                            fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.blueGrey[400]!),
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.entry.from.format(context),
                            style: TextStyle(
                                color: Colors.blueGrey[900],
                                fontWeight: FontWeight.w600),
                          ),
                          const Icon(Icons.access_time, color: Colors.blueGrey),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final TimeOfDay? selectedTime =
                      await _selectTime(context, widget.entry.to);
                      if (selectedTime != null &&
                          selectedTime != widget.entry.to) {
                        setState(() {
                          widget.entry.to = selectedTime;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'To Time',
                        labelStyle: TextStyle(
                            color: Colors.blueGrey[700],
                            fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.blueGrey[400]!),
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.entry.to.format(context),
                            style: TextStyle(
                                color: Colors.blueGrey[900],
                                fontWeight: FontWeight.w600),
                          ),
                          const Icon(Icons.access_time, color: Colors.blueGrey),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: widget.entry.task.isEmpty ? null : widget.entry.task,
              decoration: InputDecoration(
                labelText: 'Select Task',
                labelStyle: TextStyle(
                    color: Colors.blueGrey[700], fontWeight: FontWeight.bold),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.blueGrey[400]!),
                ),
              ),
              dropdownColor: Colors.white.withOpacity(0.9),
              items: <String>['Task 1', 'Task 2', 'Task 3'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value,
                      style: TextStyle(color: Colors.blueGrey[900])),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  widget.entry.task = newValue ?? '';
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Duration: ${_calculateDuration(widget.entry.from, widget.entry.to)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.blueGrey[900], fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: widget.onRemove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                  ),
                  child: const Text('Remove',style: TextStyle(color: Colors.white),),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle save logic here
                    // e.g., show a confirmation message, save to a database, etc.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('TimeSheet Saved!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                  ),
                  child: const Text('Save',style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _selectDate(BuildContext context, DateTime initialDate) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blueGrey[900]!, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.blueGrey[900]!, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueGrey[900], // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<TimeOfDay?> _selectTime(BuildContext context, TimeOfDay initialTime) async {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blueGrey[900]!, // dial background color
              onPrimary: Colors.white, // dial text color
              onSurface: Colors.blueGrey[900]!, // other text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueGrey[900], // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  String _calculateDuration(TimeOfDay from, TimeOfDay to) {
    final now = DateTime.now();
    final fromTime =
    DateTime(now.year, now.month, now.day, from.hour, from.minute);
    final toTime = DateTime(now.year, now.month, now.day, to.hour, to.minute);
    final difference = toTime.difference(fromTime);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}
