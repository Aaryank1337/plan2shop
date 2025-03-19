import 'package:flutter/material.dart';
import 'package:plan2shop/services/grocery_service.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  _GroceryListScreenState createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  final GroceryService _groceryService = GroceryService();

  @override
  Widget build(BuildContext context) {
    // Convert the HashSet to a List for ListView
    final groceryItems = _groceryService.groceryItems.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Grocery List"),
      ),
      body: groceryItems.isEmpty
          ? const Center(child: Text("Your grocery list is empty"))
          : ListView.builder(
              itemCount: groceryItems.length,
              itemBuilder: (context, index) {
                final item = groceryItems[index];
                
                return CheckboxListTile(
                  title: Text(item),
                  value: false, // Always unchecked since we remove items when checked
                  onChanged: (_) {
                    setState(() {
                      // Remove item from the HashSet when checked
                      _groceryService.removeItem(item);
                    });
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dialog to add new item manually
          showDialog(
            context: context,
            builder: (context) => _buildAddItemDialog(context),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAddItemDialog(BuildContext context) {
    final textController = TextEditingController();

    return AlertDialog(
      title: const Text("Add Item"),
      content: TextField(
        controller: textController,
        decoration: const InputDecoration(
          hintText: "Enter grocery item",
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            if (textController.text.isNotEmpty) {
              setState(() {
                _groceryService.addItem(textController.text.trim());
              });
              Navigator.pop(context);
            }
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}