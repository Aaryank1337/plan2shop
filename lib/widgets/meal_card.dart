import 'package:flutter/material.dart';
import 'package:plan2shop/screens/meal_detail_screen.dart';

class MealCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final double width; // Added width parameter

  const MealCard({
    super.key,
    required this.title,
    required this.icon,
    this.width = 160.0, // Default width if not specified
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width, // Enforces a fixed width for the card
      child: Card(
        margin: const EdgeInsets.all(10),
        child: ListTile(
          leading: Icon(icon, size: 40, color: Colors.teal),
          title: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MealDetailScreen(mealType: title),
              ),
            );
          },
        ),
      ),
    );
  }
}
