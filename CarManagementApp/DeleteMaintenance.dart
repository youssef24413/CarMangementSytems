import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DeleteMaintenance extends StatefulWidget {
  @override
  _DeleteMaintenanceState createState() => _DeleteMaintenanceState();
}

class _DeleteMaintenanceState extends State<DeleteMaintenance> {
  late Database database;
  String carId = '';

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  _initDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'car_maintenance.db'),
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE maintenance (
            id TEXT PRIMARY KEY,
            carName TEXT,
            partServiced TEXT,
            currentServiceDate TEXT,
            nextServiceDate TEXT,
            mechanicName TEXT,
            location TEXT
          )
        ''');
      },
    );
  }

  _deleteMaintenanceRecord(BuildContext context, String id) async {
    int result = await database.delete('maintenance', where: 'id = ?', whereArgs: [id]);

    // Use `BuildContext` to show the dialog
    if (result > 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Car maintenance record deleted successfully'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.pop(context); // Navigate back to previous screen
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('No record found with ID $id'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
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
        title: Text('Delete Maintenance Record'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Car ID to Delete:',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            TextField(
              onChanged: (value) {
                setState(() {
                  carId = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Car ID',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                if (carId.isNotEmpty) {
                  _deleteMaintenanceRecord(context, carId);
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Please enter a valid Car ID'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
