import 'package:flutter/material.dart';
import 'CarSelectionScreen.dart';
import 'ViewMaintenance.dart';
import 'DeleteMaintenance.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2F3E4A),
      appBar: AppBar(
        title: Text('Car Management Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add the circular image above the buttons
            ClipOval(
              child: Image.asset(
                'assets/img/Ccar.png',
                height: 200, // Adjust height as needed
                width: 200,  // Adjust width to match height for a perfect circle
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20), // Space between the image and buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CarSelectionScreen()),
                );
              },
              child: Text('Add Maintenance'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), backgroundColor: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewMaintenance()),
                );
              },
              child: Text('View Maintenance Records'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), backgroundColor: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteMaintenance()),
                );
              },
              child: Text('Delete Maintenance Record'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
