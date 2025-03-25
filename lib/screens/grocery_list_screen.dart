import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Helper function to compute category based on item name.
String getCategory(String itemName) {
  final lowerName = itemName.toLowerCase();
  if (lowerName.contains("lettuce") ||
      lowerName.contains("spinach") ||
      lowerName.contains("tomatoes") ||
      lowerName.contains("tomato") ||
      lowerName.contains("coriander") ||
      lowerName.contains("lemon") ||
      lowerName.contains("bell") ||
      lowerName.contains("chickpeas") ||
      lowerName.contains("onion") ||
      lowerName.contains("carrot") ||
      lowerName.contains("veggies")) {
    return "Veggies";
  } else if (lowerName.contains("milk") ||
      lowerName.contains("cheese") ||
      lowerName.contains("butter") ||
      lowerName.contains("yogurt")) {
    return "Dairy";
  } else if (lowerName.contains("chicken") ||
      lowerName.contains("beef") ||
      lowerName.contains("pork") ||
      lowerName.contains("meat")) {
    return "Meat";
  } else if (lowerName.contains("bread") ||
      lowerName.contains("pizza") ||
      lowerName.contains("lasagna")) {
    return "Bakery";
  } else if (lowerName.contains("mayonnaise") ||
      lowerName.contains("ketchup") ||
      lowerName.contains("red")) {
    return "Sauces";
  } else {
    return "Others";
  }
}

class GroceryListScreen extends StatelessWidget {
  const GroceryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Grocery List"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('groceryItems')
              .where('createdBy', isEqualTo: user?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text("Your grocery list is empty"),
              );
            }

            final groceryDocs = snapshot.data!.docs;
            // Group items by computed category.
            Map<String, List<QueryDocumentSnapshot>> categorizedItems = {};
            for (var doc in groceryDocs) {
              final data = doc.data() as Map<String, dynamic>;
              final itemName = data['name'] ?? 'Unnamed Item';
              final category = getCategory(itemName);
              if (!categorizedItems.containsKey(category)) {
                categorizedItems[category] = [];
              }
              categorizedItems[category]!.add(doc);
            }

            // Sort categories with "Others" always at the top.
            List<String> sortedCategories = categorizedItems.keys.toList();
            if (sortedCategories.contains("Others")) {
              sortedCategories.remove("Others");
              sortedCategories.sort();
              sortedCategories.insert(0, "Others");
            } else {
              sortedCategories.sort();
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: sortedCategories.map((category) {
                  final items = categorizedItems[category]!;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category header.
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // List of items in this category.
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final data =
                                items[index].data() as Map<String, dynamic>;
                            final itemName = data['name'] ?? 'Unnamed Item';
                            return CheckboxListTile(
                              title: Text(itemName),
                              value:
                                  false, // Always unchecked; tap to remove item.
                              onChanged: (_) async {
                                await FirebaseFirestore.instance
                                    .collection('groceryItems')
                                    .doc(items[index].id)
                                    .delete();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
