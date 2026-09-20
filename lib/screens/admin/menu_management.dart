import 'package:flutter/material.dart';
import '../../models/food_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';

class MenuManagementScreen extends StatelessWidget {
  const MenuManagementScreen({super.key});

  void _showAddEditDialog(BuildContext context, {FoodModel? existingFood}) {
    final nameController = TextEditingController(text: existingFood?.name ?? '');
    final descController = TextEditingController(text: existingFood?.description ?? '');
    final priceController = TextEditingController(text: existingFood != null ? existingFood.price.toStringAsFixed(0) : '');
    final imageController = TextEditingController(text: existingFood?.imageUrl ?? '');
    String selectedCategory = existingFood?.category ?? FoodCategories.mainCourse;
    bool available = existingFood?.available ?? true;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(existingFood != null ? 'Edit Food Item' : 'Add New Food Item'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Food Name'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter food name' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: FoodCategories.allCategories.where((c) => c != 'All').map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price (₹)'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter price';
                      if (double.tryParse(v) == null) return 'Enter valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: imageController,
                    decoration: const InputDecoration(labelText: 'Image URL (optional)'),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Available for Ordering'),
                    value: available,
                    onChanged: (v) => setDialogState(() => available = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newFood = FoodModel(
                    id: existingFood?.id ?? 'food_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                    price: double.parse(priceController.text.trim()),
                    category: selectedCategory,
                    imageUrl: imageController.text.trim(),
                    available: available,
                    createdAt: existingFood?.createdAt ?? DateTime.now(),
                  );

                  if (existingFood != null) {
                    await FirestoreService.instance.updateFood(newFood);
                  } else {
                    await FirestoreService.instance.addFood(newFood);
                  }

                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(existingFood != null ? 'Food item updated' : 'Food item added'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: Text(existingFood != null ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Food'),
        onPressed: () => _showAddEditDialog(context),
      ),
      body: StreamBuilder<List<FoodModel>>(
        stream: FirestoreService.instance.streamFoods(),
        builder: (context, snapshot) {
          final foods = snapshot.data ?? [];

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: foods.length,
                separatorBuilder: (ctx, idx) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final food = foods[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: const Icon(Icons.fastfood, color: AppColors.primary),
                      ),
                      title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${food.category} • ${AppConstants.currency}${food.price.toStringAsFixed(0)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showAddEditDialog(context, existingFood: food),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Food Item?'),
                                  content: Text('Are you sure you want to delete "${food.name}"?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await FirestoreService.instance.deleteFood(food.id);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
