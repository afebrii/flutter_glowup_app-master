import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/responses/referral_model.dart';

class ReferralHistoryList extends StatelessWidget {
  final List<ReferralLogModel> referrals;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final bool hasMore;

  const ReferralHistoryList({
    super.key,
    required this.referrals,
    this.isLoading = false,
    this.onLoadMore,
    this.hasMore = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && referrals.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (referrals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada referral',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bagikan kode referral Anda\nuntuk mendapatkan bonus!',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: referrals.length + (hasMore ? 1 : 0),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        if (index == referrals.length) {
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

        final referral = referrals[index];
        return ReferralHistoryItem(referral: referral);
      },
    );
  }
}

class ReferralHistoryItem extends StatelessWidget {
  final ReferralLogModel referral;

  const ReferralHistoryItem({
    super.key,
    required this.referral,
  });

  String get _refereeName => referral.referee?.name ?? 'Unknown';

  @override
  Widget build(BuildContext context) {
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
          CircleAvatar(
            radius: 20,
            backgroundColor: _getStatusColor(referral.status).withValues(alpha: 0.1),
            child: Text(
              _refereeName.isNotEmpty
                  ? _refereeName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(referral.status),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _refereeName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _StatusBadge(status: referral.status),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(referral.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (referral.referrerPoints > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${referral.referrerPoints}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'expired':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: statusInfo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        statusInfo.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: statusInfo.color,
        ),
      ),
    );
  }

  ({String label, Color color}) _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return (label: 'Selesai', color: AppColors.success);
      case 'pending':
        return (label: 'Menunggu', color: AppColors.warning);
      case 'expired':
        return (label: 'Kadaluarsa', color: AppColors.error);
      default:
        return (label: status, color: AppColors.textMuted);
    }
  }
}

/// Preview for dashboard or summary
class ReferralHistoryPreview extends StatelessWidget {
  final List<ReferralLogModel> referrals;
  final int maxItems;
  final VoidCallback? onViewAll;

  const ReferralHistoryPreview({
    super.key,
    required this.referrals,
    this.maxItems = 3,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final displayReferrals = referrals.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Referral Terbaru',
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
        if (displayReferrals.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Belum ada referral',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
          )
        else
          ...displayReferrals.map((referral) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ReferralHistoryItem(referral: referral),
              )),
      ],
    );
  }
}
