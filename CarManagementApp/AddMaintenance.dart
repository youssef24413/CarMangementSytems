import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'HomePage.dart';

class AddNewMaintenance extends StatefulWidget {
  final String carName;

  AddNewMaintenance({required this.carName});

  @override
  _AddNewMaintenanceState createState() => _AddNewMaintenanceState();
}

class _AddNewMaintenanceState extends State<AddNewMaintenance> {
  final _formKey = GlobalKey<FormState>();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  String carId = '';
  String partServiced = '';
  DateTime? currentServiceDate;
  DateTime? nextServiceDate;
  String mechanicName = '';
  String location = '';

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification(DateTime scheduledDate) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'maintenance_channel_id',
      'Maintenance Notifications',
      channelDescription: 'Notification channel for maintenance reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.schedule(
      0,
      'Maintenance Reminder',
      'Your car is due for maintenance.',
      scheduledDate,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
    );
  }

  Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'car_maintenance.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE maintenance(id INTEGER PRIMARY KEY, carId TEXT, carName TEXT, partServiced TEXT, currentServiceDate TEXT, nextServiceDate TEXT, mechanicName TEXT, location TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> _selectDate(BuildContext context, bool isCurrentServiceDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isCurrentServiceDate) {
          currentServiceDate = picked;
        } else {
          nextServiceDate = picked;
        }
      });
    }
  }

  _saveMaintenance(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final Database db = await _initDatabase();

      await db.insert(
        'maintenance',
        {
          'carId': carId,
          'carName': widget.carName,
          'partServiced': partServiced,
          'currentServiceDate': currentServiceDate?.toIso8601String(),
          'nextServiceDate': nextServiceDate?.toIso8601String(),
          'mechanicName': mechanicName,
          'location': location,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Schedule notification
      if (nextServiceDate != null) {
        await _scheduleNotification(nextServiceDate!);
      }

      // Show alert instead of Snackbar
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Maintenance record added successfully!'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Maintenance for ${widget.carName}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Car ID'),
                onChanged: (value) {
                  carId = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Car ID';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Part Serviced'),
                onChanged: (value) {
                  partServiced = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Part Serviced';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text('Current Service Date'),
                subtitle: Text(currentServiceDate == null
                    ? 'Select Date'
                    : currentServiceDate!.toLocal().toString().split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              if (currentServiceDate == null)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Text(
                    'Please select Current Service Date',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ListTile(
                title: Text('Next Service Date'),
                subtitle: Text(nextServiceDate == null
                    ? 'Select Date'
                    : nextServiceDate!.toLocal().toString().split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              if (nextServiceDate == null)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Text(
                    'Please select Next Service Date',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Mechanic Name'),
                onChanged: (value) {
                  mechanicName = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Mechanic Name';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Location'),
                onChanged: (value) {
                  location = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (currentServiceDate == null || nextServiceDate == null) {
                    // Show validation error
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Error'),
                          content: Text('Please select both service dates'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    _saveMaintenance(context); // Pass context here
                  }
                },
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
