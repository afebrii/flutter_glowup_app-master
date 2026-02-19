import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/responses/product_model.dart';

class ProductCategoryChips extends StatelessWidget {
  final List<ProductCategoryModel> categories;
  final int? selectedCategoryId;
  final Function(int?)? onCategorySelected;
  final bool showAll;

  const ProductCategoryChips({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    this.onCategorySelected,
    this.showAll = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + (showAll ? 1 : 0),
        itemBuilder: (context, index) {
          if (showAll && index == 0) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _CategoryChip(
                label: 'Semua',
                isSelected: selectedCategoryId == null,
                onTap: () => onCategorySelected?.call(null),
              ),
            );
          }

          final categoryIndex = showAll ? index - 1 : index;
          final category = categories[categoryIndex];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _CategoryChip(
              label: category.name,
              count: category.productsCount,
              isSelected: selectedCategoryId == category.id,
              onTap: () => onCategorySelected?.call(category.id),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback? onTap;

  const _CategoryChip({
    required this.label,
    this.count,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Vertical list version for sidebar
class ProductCategoryList extends StatelessWidget {
  final List<ProductCategoryModel> categories;
  final int? selectedCategoryId;
  final Function(int?)? onCategorySelected;

  const ProductCategoryList({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _CategoryListTile(
            label: 'Semua Produk',
            isSelected: selectedCategoryId == null,
            onTap: () => onCategorySelected?.call(null),
          );
        }

        final category = categories[index - 1];
        return _CategoryListTile(
          label: category.name,
          count: category.productsCount,
          isSelected: selectedCategoryId == category.id,
          onTap: () => onCategorySelected?.call(category.id),
        );
      },
    );
  }
}

class _CategoryListTile extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback? onTap;

  const _CategoryListTile({
    required this.label,
    this.count,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Icon(
        isSelected ? Icons.folder : Icons.folder_outlined,
        color: isSelected ? AppColors.primary : AppColors.textMuted,
        size: 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      trailing: count != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.borderLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            )
          : null,
    );
  }
}
