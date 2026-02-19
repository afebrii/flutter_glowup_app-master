import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/responses/loyalty_reward_model.dart';

class LoyaltyRewardsGrid extends StatelessWidget {
  final List<LoyaltyRewardModel> rewards;
  final int currentPoints;
  final bool isLoading;
  final Function(LoyaltyRewardModel)? onRewardTap;

  const LoyaltyRewardsGrid({
    super.key,
    required this.rewards,
    required this.currentPoints,
    this.isLoading = false,
    this.onRewardTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (rewards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard_outlined,
              size: 64,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada reward tersedia',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final reward = rewards[index];
        return LoyaltyRewardCard(
          reward: reward,
          currentPoints: currentPoints,
          onTap: () => onRewardTap?.call(reward),
        );
      },
    );
  }
}

class LoyaltyRewardCard extends StatelessWidget {
  final LoyaltyRewardModel reward;
  final int currentPoints;
  final VoidCallback? onTap;

  const LoyaltyRewardCard({
    super.key,
    required this.reward,
    required this.currentPoints,
    this.onTap,
  });

  bool get canRedeem => currentPoints >= reward.pointsRequired && reward.isActive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: canRedeem ? AppColors.primary : AppColors.border,
            width: canRedeem ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image/Icon section
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: canRedeem
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.borderLight,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(11),
                ),
              ),
              child: Center(
                child: Icon(
                  _getRewardIcon(reward.rewardType),
                  size: 36,
                  color: canRedeem ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (reward.description != null)
                      Text(
                        reward.description!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.stars,
                          size: 16,
                          color: canRedeem ? AppColors.primary : AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${reward.pointsRequired} poin',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: canRedeem ? AppColors.primary : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRewardIcon(String rewardType) {
    switch (rewardType.toLowerCase()) {
      case 'discount_percent':
      case 'discount_amount':
        return Icons.local_offer_outlined;
      case 'free_product':
        return Icons.inventory_2_outlined;
      case 'free_service':
        return Icons.spa_outlined;
      default:
        return Icons.card_giftcard_outlined;
    }
  }
}

/// Horizontal scrollable list for rewards preview
class LoyaltyRewardsPreview extends StatelessWidget {
  final List<LoyaltyRewardModel> rewards;
  final int currentPoints;
  final Function(LoyaltyRewardModel)? onRewardTap;
  final VoidCallback? onViewAll;

  const LoyaltyRewardsPreview({
    super.key,
    required this.rewards,
    required this.currentPoints,
    this.onRewardTap,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reward Tersedia',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('Lihat Semua'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: rewards.length,
            itemBuilder: (context, index) {
              final reward = rewards[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < rewards.length - 1 ? 12 : 0,
                ),
                child: SizedBox(
                  width: 140,
                  child: LoyaltyRewardCard(
                    reward: reward,
                    currentPoints: currentPoints,
                    onTap: () => onRewardTap?.call(reward),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
