import 'package:flutter/material.dart';
import 'package:plan2shop/services/grocery_service.dart';

class RecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipeData;

  const RecipeCard({
    Key? key,
    required this.recipeData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String title = recipeData['title'] ?? 'No Title';
    final String imageUrl =
        recipeData['imageUrl'] ?? 'https://via.placeholder.com/150';
    final List<dynamic> ingredients = recipeData['ingredients'] ?? [];
    // Get the service instance inside the build method
    final groceryService = GroceryService();

    return SizedBox(
      width: 200, // Fixed width for horizontal lists
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Recipe image
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            // Column with recipe title and plus button below it
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.blue),
                    onPressed: () {
                      // Add ingredients to grocery list
                      for (var ingredient in ingredients) {
                        // Ensure the ingredient is a string
                        final String ingredientStr = ingredient is Map
                            ? ingredient['name']
                            : ingredient.toString();
                        groceryService.addItem(ingredientStr);
                      }

                      // Show a confirmation to the user
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Added ${ingredients.length} ingredients from $title to your grocery list"),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
