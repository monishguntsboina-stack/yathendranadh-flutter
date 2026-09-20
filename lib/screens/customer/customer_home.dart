import 'package:flutter/material.dart';
import '../../models/food_model.dart';
import '../../services/firestore_service.dart';
import '../../services/cart_service.dart';
import '../../utils/constants.dart';
import '../../widgets/food_card.dart';
import 'food_details.dart';
import 'cart_screen.dart';
import 'order_history.dart';
import 'profile_screen.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int _currentIndex = 0;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Restaurant Menu'),
        actions: [
          // Cart Icon with Badge
          ValueListenableBuilder(
            valueListenable: CartService.instance.cartNotifier,
            builder: (context, items, _) {
              final count = CartService.instance.totalItemCount;
              return Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartScreen()),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildCurrentTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 1:
        return const CartScreen();
      case 2:
        return const OrderHistoryScreen();
      case 3:
        return const ProfileScreen();
      case 0:
      default:
        return _buildMenuTab();
    }
  }

  Widget _buildMenuTab() {
    return StreamBuilder<List<FoodModel>>(
      stream: FirestoreService.instance.streamFoods(),
      builder: (context, snapshot) {
        final allFoods = snapshot.data ?? [];

        // Apply Category and Search filtering
        final filteredFoods = allFoods.where((food) {
          final matchesCategory = _selectedCategory == 'All' || food.category == _selectedCategory;
          final matchesSearch = _searchQuery.isEmpty ||
              food.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              food.description.toLowerCase().contains(_searchQuery.toLowerCase());
          return matchesCategory && matchesSearch;
        }).toList();

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search food dishes, beverages...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) {
                      setState(() => _searchQuery = val.trim());
                    },
                  ),
                ),

                // Category Chips Selector
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: FoodCategories.allCategories.length,
                    separatorBuilder: (ctx, idx) => const SizedBox(width: 8),
                    itemBuilder: (ctx, idx) {
                      final category = FoodCategories.allCategories[idx];
                      final isSelected = _selectedCategory == category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = category);
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Foods List
                Expanded(
                  child: filteredFoods.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey),
                              SizedBox(height: 12),
                              Text('No food items found matching your filter.'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredFoods.length,
                          itemBuilder: (context, index) {
                            final food = filteredFoods[index];
                            return FoodCard(
                              food: food,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FoodDetailsScreen(food: food),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
