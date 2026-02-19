import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/responses/loyalty_point_model.dart';

class LoyaltyPointsHistory extends StatelessWidget {
  final List<LoyaltyPointModel> points;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final bool hasMore;

  const LoyaltyPointsHistory({
    super.key,
    required this.points,
    this.isLoading = false,
    this.onLoadMore,
    this.hasMore = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && points.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (points.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada riwayat poin',
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
      itemCount: points.length + (hasMore ? 1 : 0),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        if (index == points.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : TextButton(
                      onPressed: onLoadMore,
                      child: const Text('Muat lebih banyak'),
                    ),
            ),
          );
        }

        final point = points[index];
        return LoyaltyPointItem(point: point);
      },
    );
  }
}

class LoyaltyPointItem extends StatelessWidget {
  final LoyaltyPointModel point;

  const LoyaltyPointItem({
    super.key,
    required this.point,
  });

  @override
  Widget build(BuildContext context) {
    final isEarned = point.points > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isEarned
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isEarned ? Icons.add_circle_outline : Icons.remove_circle_outline,
              color: isEarned ? AppColors.success : AppColors.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.description ?? point.typeLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDateTime(point.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isEarned ? '+' : ''}${point.points}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isEarned ? AppColors.success : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Compact list for preview
class LoyaltyPointsPreview extends StatelessWidget {
  final List<LoyaltyPointModel> points;
  final int maxItems;
  final VoidCallback? onViewAll;

  const LoyaltyPointsPreview({
    super.key,
    required this.points,
    this.maxItems = 3,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final displayPoints = points.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Riwayat Poin Terbaru',
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
        const SizedBox(height: 8),
        if (displayPoints.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Belum ada riwayat',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
          )
        else
          ...displayPoints.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LoyaltyPointItem(point: point),
              )),
      ],
    );
  }
}
