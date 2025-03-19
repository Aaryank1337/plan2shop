import 'package:flutter/material.dart';

class MealDetailScreen extends StatelessWidget {
  final String mealType;

  const MealDetailScreen({super.key, required this.mealType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$mealType Recipes"),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(10),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: List.generate(6, (index) {
          return Card(
            elevation: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 120,
                  child: Image.asset(
                    'assets/images/recipe_placeholder.jpg',
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Recipe ${index + 1}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
