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

// Map of category icons
Map<String, IconData> categoryIcons = {
  "Veggies": Icons.eco,
  "Dairy": Icons.egg,
  "Meat": Icons.fastfood,
  "Bakery": Icons.breakfast_dining,
  "Sauces": Icons.local_drink,
  "Others": Icons.shopping_basket,
};

// Map of category colors
Map<String, Color> categoryColors = {
  "Veggies": Colors.green.shade100,
  "Dairy": Colors.blue.shade100,
  "Meat": Colors.red.shade100,
  "Bakery": Colors.brown.shade100,
  "Sauces": Colors.orange.shade100,
  "Others": Colors.grey.shade100,
};

class GroceryListScreen extends StatelessWidget {
  const GroceryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Grocery List"),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
        ),
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Your grocery list is empty",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
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

            // Sort categories with "Others" always at the end
            List<String> sortedCategories = categorizedItems.keys.toList();
            if (sortedCategories.contains("Others")) {
              sortedCategories.remove("Others");
              sortedCategories.sort();
              sortedCategories.add("Others");
            } else {
              sortedCategories.sort();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats summary
                    Container(
                      margin: const EdgeInsets.only(bottom: 16, top: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            context, 
                            groceryDocs.length.toString(), 
                            "Total Items", 
                            Icons.list_alt
                          ),
                          _buildStatItem(
                            context, 
                            categorizedItems.length.toString(), 
                            "Categories", 
                            Icons.category
                          ),
                        ],
                      ),
                    ),
                    
                    // Categories list
                    ...sortedCategories.map((category) {
                      final items = categorizedItems[category]!;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          backgroundColor: Colors.transparent,
                          collapsedBackgroundColor: Colors.transparent,
                          leading: CircleAvatar(
                            backgroundColor: categoryColors[category] ?? Colors.grey.shade100,
                            child: Icon(
                              categoryIcons[category] ?? Icons.shopping_basket,
                              color: Colors.black54,
                            ),
                          ),
                          title: Text(
                            category,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            "${items.length} item${items.length != 1 ? 's' : ''}",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          trailing: const Icon(Icons.expand_more),
                          children: [
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: Colors.grey.shade200,
                              ),
                              itemBuilder: (context, index) {
                                final data = items[index].data() as Map<String, dynamic>;
                                final itemName = data['name'] ?? 'Unnamed Item';
                                final quantity = data['quantity']?.toString() ?? '';
                                
                                return Dismissible(
                                  key: Key(items[index].id),
                                  background: Container(
                                    color: Colors.red.shade100,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20.0),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (direction) async {
                                    await FirebaseFirestore.instance
                                        .collection('groceryItems')
                                        .doc(items[index].id)
                                        .delete();
                                  },
                                  child: ListTile(
                                    title: Text(
                                      itemName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: quantity.isNotEmpty
                                        ? Text(
                                            "Qty: $quantity",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          )
                                        : null,
                                    trailing: IconButton(
                                      icon: const Icon(Icons.check_circle_outline),
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('groceryItems')
                                            .doc(items[index].id)
                                            .delete();
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildStatItem(BuildContext context, String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
