import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plan2shop/screens/grocery_list_screen.dart';
import 'package:plan2shop/screens/settings_screen.dart';
import 'package:plan2shop/screens/add_recipe_screen.dart';
import 'package:plan2shop/widgets/recipe_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    RecipeScreen(),
    GroceryListScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      // Display FAB only on the RecipeScreen (index 0)
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddRecipeScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Recipes'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.cartShopping), label: 'Grocery List'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class RecipeScreen extends StatelessWidget {
  const RecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text("Recipes")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('recipes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No recipes found"));
          }

          final allRecipes = snapshot.data!.docs;
          final yourRecipes =
              allRecipes.where((doc) => doc['createdBy'] == user?.uid).toList();
          final recommendedRecipes =
              allRecipes.where((doc) => doc['createdBy'] != user?.uid).toList();

          return ListView(
            children: [
              if (yourRecipes.isNotEmpty)
                _buildSection("Your Recipes", yourRecipes),
              if (recommendedRecipes.isNotEmpty)
                _buildSection("Recommended Recipes", recommendedRecipes),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
      String sectionTitle, List<QueryDocumentSnapshot> recipes) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 250, // Adjust height based on RecipeCard design
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index].data() as Map<String, dynamic>;
                return RecipeCard(recipeData: recipe);
              },
            ),
          ),
        ],
      ),
    );
  }
}
