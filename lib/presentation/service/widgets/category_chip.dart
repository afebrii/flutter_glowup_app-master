import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/responses/service_category_model.dart';

class CategoryChipList extends StatelessWidget {
  final List<ServiceCategoryModel> categories;
  final int? selectedCategoryId;
  final Function(int?) onCategorySelected;
  final bool showAllOption;

  const CategoryChipList({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
    this.showAllOption = true,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (showAllOption) ...[
            CategoryChip(
              label: 'Semua',
              isSelected: selectedCategoryId == null,
              onTap: () => onCategorySelected(null),
            ),
            const SizedBox(width: 8),
          ],
          ...categories.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CategoryChip(
                  label: category.name,
                  isSelected: selectedCategoryId == category.id,
                  onTap: () => onCategorySelected(category.id),
                ),
              )),
        ],
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryTabBar extends StatelessWidget {
  final List<ServiceCategoryModel> categories;
  final int? selectedCategoryId;
  final Function(int?) onCategorySelected;

  const CategoryTabBar({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildTab('Semua', null),
            ...categories.map((c) => _buildTab(c.name, c.id)),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int? categoryId) {
    final isSelected = selectedCategoryId == categoryId;
    return InkWell(
      onTap: () => onCategorySelected(categoryId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
