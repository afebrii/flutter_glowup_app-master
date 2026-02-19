import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/responses/loyalty_reward_model.dart';

class RedeemRewardDialog extends StatelessWidget {
  final LoyaltyRewardModel reward;
  final int currentPoints;
  final bool isLoading;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const RedeemRewardDialog({
    super.key,
    required this.reward,
    required this.currentPoints,
    this.isLoading = false,
    required this.onConfirm,
    required this.onCancel,
  });

  bool get canRedeem => currentPoints >= reward.pointsRequired;
  int get remainingPoints => currentPoints - reward.pointsRequired;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              reward.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (reward.description != null) ...[
              const SizedBox(height: 8),
              Text(
                reward.description!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            // Points info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Poin Anda',
                    value: currentPoints.toString(),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'Poin Dibutuhkan',
                    value: '-${reward.pointsRequired}',
                    valueColor: AppColors.error,
                  ),
                  const Divider(height: 16),
                  _InfoRow(
                    label: 'Sisa Poin',
                    value: remainingPoints.toString(),
                    valueColor:
                        canRedeem ? AppColors.success : AppColors.error,
                    isBold: true,
                  ),
                ],
              ),
            ),
            if (!canRedeem) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Poin Anda tidak cukup. Butuh ${reward.pointsRequired - currentPoints} poin lagi.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: canRedeem && !isLoading ? onConfirm : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Tukar Sekarang'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Helper function to show redeem dialog
Future<bool?> showRedeemRewardDialog(
  BuildContext context, {
  required LoyaltyRewardModel reward,
  required int currentPoints,
  required Future<bool> Function() onConfirm,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (context) => _RedeemDialogWrapper(
      reward: reward,
      currentPoints: currentPoints,
      onConfirm: onConfirm,
    ),
  );
}

class _RedeemDialogWrapper extends StatefulWidget {
  final LoyaltyRewardModel reward;
  final int currentPoints;
  final Future<bool> Function() onConfirm;

  const _RedeemDialogWrapper({
    required this.reward,
    required this.currentPoints,
    required this.onConfirm,
  });

  @override
  State<_RedeemDialogWrapper> createState() => _RedeemDialogWrapperState();
}

class _RedeemDialogWrapperState extends State<_RedeemDialogWrapper> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return RedeemRewardDialog(
      reward: widget.reward,
      currentPoints: widget.currentPoints,
      isLoading: _isLoading,
      onConfirm: () async {
        setState(() => _isLoading = true);
        final success = await widget.onConfirm();
        if (mounted) {
          Navigator.of(context).pop(success);
        }
      },
      onCancel: () => Navigator.of(context).pop(false),
    );
  }
}
