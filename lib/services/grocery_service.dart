// First, create a service to manage grocery items
import 'dart:collection';

class GroceryService {
  // Singleton pattern
  static final GroceryService _instance = GroceryService._internal();
  factory GroceryService() => _instance;
  GroceryService._internal();

  // HashSet to store unique grocery items
  final Set<String> _groceryItems = HashSet<String>();

  // Getter for grocery items
  Set<String> get groceryItems => _groceryItems;

  // Method to add an item
  void addItem(String item) {
    _groceryItems.add(item);
  }

  // Method to remove an item
  void removeItem(String item) {
    _groceryItems.remove(item);
  }

  // Method to clear all items
  void clearItems() {
    _groceryItems.clear();
  }
}
