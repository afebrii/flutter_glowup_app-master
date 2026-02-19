import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/responses/user_model.dart';

class BeauticianPicker extends StatelessWidget {
  final List<UserModel> beauticians;
  final UserModel? selectedBeautician;
  final Function(UserModel?)? onBeauticianSelected;
  final bool isLoading;
  final bool allowDeselect;
  final String? emptyMessage;

  const BeauticianPicker({
    super.key,
    required this.beauticians,
    this.selectedBeautician,
    this.onBeauticianSelected,
    this.isLoading = false,
    this.allowDeselect = true,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (beauticians.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 48,
                color: AppColors.textMuted.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                emptyMessage ?? 'Tidak ada beautician tersedia',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: beauticians.length,
            itemBuilder: (context, index) {
              final beautician = beauticians[index];
              final isSelected = selectedBeautician?.id == beautician.id;

              return Padding(
                padding: EdgeInsets.only(
                  right: index < beauticians.length - 1 ? 12 : 0,
                ),
                child: BeauticianAvatar(
                  beautician: beautician,
                  isSelected: isSelected,
                  onTap: () {
                    if (isSelected && allowDeselect) {
                      onBeauticianSelected?.call(null);
                    } else {
                      onBeauticianSelected?.call(beautician);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class BeauticianAvatar extends StatelessWidget {
  final UserModel beautician;
  final bool isSelected;
  final VoidCallback? onTap;
  final double size;

  const BeauticianAvatar({
    super.key,
    required this.beautician,
    this.isSelected = false,
    this.onTap,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: size / 2,
              backgroundColor: isSelected
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: beautician.avatar != null
                  ? NetworkImage(beautician.avatar!)
                  : null,
              child: beautician.avatar == null
                  ? Text(
                      beautician.initials,
                      style: TextStyle(
                        fontSize: size / 3,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: size + 20,
            child: Text(
              beautician.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// List version for selection in modal
class BeauticianListPicker extends StatelessWidget {
  final List<UserModel> beauticians;
  final UserModel? selectedBeautician;
  final Function(UserModel?)? onBeauticianSelected;
  final bool isLoading;

  const BeauticianListPicker({
    super.key,
    required this.beauticians,
    this.selectedBeautician,
    this.onBeauticianSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (beauticians.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 64,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada beautician tersedia',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: beauticians.length,
      itemBuilder: (context, index) {
        final beautician = beauticians[index];
        final isSelected = selectedBeautician?.id == beautician.id;

        return BeauticianListTile(
          beautician: beautician,
          isSelected: isSelected,
          onTap: () => onBeauticianSelected?.call(beautician),
        );
      },
    );
  }
}

class BeauticianListTile extends StatelessWidget {
  final UserModel beautician;
  final bool isSelected;
  final VoidCallback? onTap;

  const BeauticianListTile({
    super.key,
    required this.beautician,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isSelected
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: beautician.avatar != null
                  ? NetworkImage(beautician.avatar!)
                  : null,
              child: beautician.avatar == null
                  ? Text(
                      beautician.initials,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    beautician.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    beautician.roleDisplayName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet helper for selecting beautician
Future<UserModel?> showBeauticianPicker(
  BuildContext context, {
  required List<UserModel> beauticians,
  UserModel? selectedBeautician,
}) async {
  return showModalBottomSheet<UserModel>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.person_outline, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Pilih Beautician',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: beauticians.length,
              itemBuilder: (context, index) {
                final beautician = beauticians[index];
                final isSelected = selectedBeautician?.id == beautician.id;

                return BeauticianListTile(
                  beautician: beautician,
                  isSelected: isSelected,
                  onTap: () => Navigator.of(context).pop(beautician),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
