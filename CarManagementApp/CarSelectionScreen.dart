import 'package:flutter/material.dart';
import 'AddMaintenance.dart';


class CarSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2F3E4A),
      appBar: AppBar(
        title: Text('Choose Your Car Type'),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: carTypes.length,
        itemBuilder: (context, index) {
          final carType = carTypes[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNewMaintenance(carName: carType.name),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.asset(
                      carType.imagePath,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    padding: EdgeInsets.all(4.0),
                    color: Colors.black.withOpacity(0.5), // Semi-transparent background for text
                    child: Text(
                      carType.name,
                      style: TextStyle(
                        color: Colors.white, // Ensure the text color contrasts with the background
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CarType {
  final String name;
  final String imagePath;

  CarType({required this.name, required this.imagePath});
}

final List<CarType> carTypes = [
  CarType(name: 'TOYOTA', imagePath: 'assets/img/TOYOTA.jpg'),
  CarType(name: 'KIA', imagePath: 'assets/img/KIA.jpg'),
  CarType(name: 'MERCEDES', imagePath: 'assets/img/MERCEDES.jpg'),
  CarType(name: 'BMW', imagePath: 'assets/img/BMW.jpg'),
  CarType(name: 'VOLKSWAGEN', imagePath: 'assets/img/VOLKSWAGEN.jpg'),
  CarType(name: 'CHEVROLET', imagePath: 'assets/img/CHEVROLET.jpg'),
  CarType(name: 'SKODA', imagePath: 'assets/img/SKODA.jpg'),
  CarType(name: 'MITSUBISHI', imagePath: 'assets/img/MITSUBISHI.jpg')
];
