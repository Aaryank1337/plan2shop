import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeCard extends StatefulWidget {
  final Map<String, dynamic> recipeData;

  const RecipeCard({
    super.key,
    required this.recipeData,
  });

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  Future<void> _addIngredientsToGroceryList(
      BuildContext context, List<dynamic> ingredients, String title) async {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final groceryItemsCollection =
        FirebaseFirestore.instance.collection('groceryItems');

    // Query existing grocery items for the current user.
    final existingSnapshot = await groceryItemsCollection
        .where('createdBy', isEqualTo: userId)
        .get();
    final List<String> existingItems = existingSnapshot.docs.map((doc) {
      final data = doc.data(); // Already a Map<String, dynamic>
      return data['name'] as String;
    }).toList();

    final batch = FirebaseFirestore.instance.batch();
    int addedCount = 0;

    // Loop through each ingredient and add only if it's not already present.
    for (var ingredient in ingredients) {
      final String ingredientStr =
          ingredient is Map ? ingredient['name'] : ingredient.toString();

      if (existingItems.contains(ingredientStr)) {
        continue; // Skip if already added.
      }

      final docRef = groceryItemsCollection.doc();
      batch.set(docRef, {
        'name': ingredientStr,
        'createdBy': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      addedCount++;
    }

    // Commit the batch if there are new items to add.
    if (addedCount > 0) {
      await batch.commit();
      if (!mounted) return;
      // Schedule the snackbar display after the current frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Added $addedCount new ingredient${addedCount > 1 ? 's' : ''} from $title to your grocery list"),
            duration: const Duration(seconds: 2),
          ),
        );
      });
    } else {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "All ingredients from $title are already in your grocery list"),
            duration: const Duration(seconds: 2),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.recipeData['title'] ?? 'No Title';
    final String imageUrl =
        widget.recipeData['imageUrl'] ?? 'https://via.placeholder.com/150';
    final List<dynamic> ingredients = widget.recipeData['ingredients'] ?? [];

    return SizedBox(
      width: 200, // Fixed width for horizontal lists.
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Recipe image.
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
            // Column with recipe title and plus button below it.
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
                      _addIngredientsToGroceryList(context, ingredients, title);
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
