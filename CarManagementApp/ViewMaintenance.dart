import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ViewMaintenance extends StatefulWidget {
  @override
  _ViewMaintenanceState createState() => _ViewMaintenanceState();
}

class _ViewMaintenanceState extends State<ViewMaintenance> {
  late Database database;
  List<Map<String, dynamic>> maintenanceRecords = [];
  List<Map<String, dynamic>> filteredRecords = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  _initDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'car_maintenance.db'),
      version: 1,
    );
    _loadMaintenanceRecords();
  }

  _loadMaintenanceRecords() async {
    final List<Map<String, dynamic>> records = await database.query('maintenance');
    setState(() {
      maintenanceRecords = records;
      filteredRecords = records;
    });
  }

  _deleteMaintenanceRecord(int id) async {
    await database.delete(
      'maintenance',
      where: 'id = ?',
      whereArgs: [id],
    );
    _loadMaintenanceRecords(); // Reload the records after deletion
  }

  _searchRecords(String query) async {
    final results = await database.rawQuery(
        'SELECT * FROM maintenance WHERE carName LIKE ? OR partServiced LIKE ?',
        ['%$query%', '%$query%']
    );

    setState(() {
      filteredRecords = results;
    });
  }

  _updateRecord(BuildContext context, Map<String, dynamic> record) async {
    // Navigate to update screen and pass the record to be updated
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateMaintenanceScreen(record: record),
      ),
    );
    _loadMaintenanceRecords(); // Reload records after update
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Maintenance Records'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: MaintenanceSearchDelegate(
                  onSearch: _searchRecords,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredRecords.length,
        itemBuilder: (context, index) {
          final record = filteredRecords[index];
          return ListTile(
            title: Text(record['carName']),
            subtitle: Text(
              'Part Serviced: ${record['partServiced']}\n'
                  'Current Service Date: ${record['currentServiceDate']}\n'
                  'Next Service Date: ${record['nextServiceDate']}\n'
                  'Mechanic: ${record['mechanicName']}\n'
                  'Location: ${record['location']}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _updateRecord(context, record);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    bool? confirmDelete = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Delete Record'),
                          content: Text('Are you sure you want to delete this record?'),
                          actions: [
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                            ),
                            TextButton(
                              child: Text('Delete'),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmDelete == true) {
                      _deleteMaintenanceRecord(record['id']);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadMaintenanceRecords,
        child: Icon(Icons.refresh),
        tooltip: 'Refresh Records',
      ),
    );
  }
}

class MaintenanceSearchDelegate extends SearchDelegate {
  final Function(String) onSearch;

  MaintenanceSearchDelegate({
    required this.onSearch,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearch(query);
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    onSearch(query);
    return Container();
  }
}

class UpdateMaintenanceScreen extends StatefulWidget {
  final Map<String, dynamic> record;

  UpdateMaintenanceScreen({required this.record});

  @override
  _UpdateMaintenanceScreenState createState() => _UpdateMaintenanceScreenState();
}

class _UpdateMaintenanceScreenState extends State<UpdateMaintenanceScreen> {
  late Database database;
  final _formKey = GlobalKey<FormState>();

  late String carId;
  late String partServiced;
  late String currentServiceDate;
  late String nextServiceDate;
  late String mechanicName;
  late String location;

  @override
  void initState() {
    super.initState();
    _initDatabase();
    _initFields();
  }

  _initDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'car_maintenance.db'),
      version: 1,
    );
  }

  _initFields() {
    carId = widget.record['carId'];
    partServiced = widget.record['partServiced'];
    currentServiceDate = widget.record['currentServiceDate'];
    nextServiceDate = widget.record['nextServiceDate'];
    mechanicName = widget.record['mechanicName'];
    location = widget.record['location'];
  }

  _updateRecord() async {
    if (_formKey.currentState!.validate()) {
      await database.update(
        'maintenance',
        {
          'carId': carId,
          'partServiced': partServiced,
          'currentServiceDate': currentServiceDate,
          'nextServiceDate': nextServiceDate,
          'mechanicName': mechanicName,
          'location': location,
        },
        where: 'id = ?',
        whereArgs: [widget.record['id']],
      );

      Navigator.of(context as BuildContext).pop(); // Go back to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Maintenance Record'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: carId,
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
                initialValue: partServiced,
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
              TextFormField(
                initialValue: currentServiceDate,
                decoration: InputDecoration(labelText: 'Current Service Date'),
                onChanged: (value) {
                  currentServiceDate = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Current Service Date';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: nextServiceDate,
                decoration: InputDecoration(labelText: 'Next Service Date'),
                onChanged: (value) {
                  nextServiceDate = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Next Service Date';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: mechanicName,
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
                initialValue: location,
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
                onPressed: _updateRecord,
                child: Text('Update Record'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
