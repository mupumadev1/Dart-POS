import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class CategoryTabs extends StatelessWidget {
  const CategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (ctx, productProvider, _) {
        if (productProvider.categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FilterChip(
                  label: const Text('All'),
                  selected: productProvider.selectedCategoryId == null,
                  onSelected: (_) => productProvider.selectCategory(null),
                ),
              ),
              ...productProvider.categories.map(
                    (category) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FilterChip(
                    label: Text(category.name),
                    selected: productProvider.selectedCategoryId == category.id,
                    onSelected: (_) => productProvider.selectCategory(category.id),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}