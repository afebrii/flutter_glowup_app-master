import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/spaces.dart';
import '../../../core/extensions/date_time_ext.dart';
import '../../../core/widgets/responsive_widget.dart';
import '../../../data/datasources/loyalty_remote_datasource.dart';
import '../../../injection.dart';
import '../bloc/loyalty_bloc.dart';
import '../bloc/loyalty_event.dart';
import '../bloc/loyalty_state.dart';
import '../widgets/loyalty_summary_card.dart';
import '../widgets/loyalty_points_history.dart';
import '../widgets/loyalty_rewards_grid.dart';
import '../widgets/redeem_reward_dialog.dart';

class LoyaltyPage extends StatelessWidget {
  final int customerId;

  const LoyaltyPage({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoyaltyBloc(
        loyaltyDatasource: getIt<LoyaltyRemoteDatasource>(),
      )
        ..add(FetchLoyaltySummary(customerId))
        ..add(const FetchRewards())
        ..add(FetchPointsHistory(customerId))
        ..add(FetchRedemptions(customerId)),
      child: ResponsiveWidget(
        phone: _LoyaltyPhoneLayout(customerId: customerId),
        tablet: _LoyaltyTabletLayout(customerId: customerId),
      ),
    );
  }
}

// Phone Layout
class _LoyaltyPhoneLayout extends StatelessWidget {
  final int customerId;

  const _LoyaltyPhoneLayout({required this.customerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Loyalty'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<LoyaltyBloc, LoyaltyState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<LoyaltyBloc>().add(const ClearLoyaltySuccess());
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: AppColors.error,
              ),
            );
            context.read<LoyaltyBloc>().add(const ClearLoyaltyError());
          }
        },
        builder: (context, state) {
          return DefaultTabController(
            length: 4,
            child: Column(
              children: [
                // Summary Card
                if (state.summary != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: LoyaltySummaryCard(
                      summary: state.summary!,
                      onViewHistory: () {},
                      onRedeemReward: () {},
                    ),
                  ),
                if (state.isLoadingSummary)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),

                // Tabs
                Container(
                  color: Colors.white,
                  child: const TabBar(
                    isScrollable: true,
                    tabs: [
                      Tab(text: 'Riwayat Poin'),
                      Tab(text: 'Rewards'),
                      Tab(text: 'Penukaran'),
                      Tab(text: 'Gunakan Kode'),
                    ],
                  ),
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    children: [
                      // Points History
                      LoyaltyPointsHistory(
                        points: state.pointsHistory,
                        isLoading: state.isLoadingPoints,
                        hasMore: state.hasMorePoints,
                        onLoadMore: () {
                          final nextPage =
                              (state.pointsMeta?.currentPage ?? 0) + 1;
                          context.read<LoyaltyBloc>().add(
                                FetchPointsHistory(customerId, page: nextPage),
                              );
                        },
                      ),

                      // Rewards Grid
                      LoyaltyRewardsGrid(
                        rewards: state.rewards,
                        currentPoints: state.summary?.currentPoints ?? 0,
                        isLoading: state.isLoadingRewards,
                        onRewardTap: (reward) {
                          showDialog(
                            context: context,
                            builder: (_) => BlocProvider.value(
                              value: context.read<LoyaltyBloc>(),
                              child: RedeemRewardDialog(
                                reward: reward,
                                currentPoints:
                                    state.summary?.currentPoints ?? 0,
                                isLoading: state.isRedeeming,
                                onConfirm: () {
                                  context.read<LoyaltyBloc>().add(
                                        RedeemReward(customerId, reward.id),
                                      );
                                  Navigator.pop(context);
                                },
                                onCancel: () => Navigator.pop(context),
                              ),
                            ),
                          );
                        },
                      ),

                      // Redemptions
                      _RedemptionsList(state: state),

                      // Check Code Form
                      _CheckCodeForm(state: state),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Tablet Layout
class _LoyaltyTabletLayout extends StatelessWidget {
  final int customerId;

  const _LoyaltyTabletLayout({required this.customerId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoyaltyBloc, LoyaltyState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
            ),
          );
          context.read<LoyaltyBloc>().add(const ClearLoyaltySuccess());
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
            ),
          );
          context.read<LoyaltyBloc>().add(const ClearLoyaltyError());
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Panel (40%) - Summary + Rewards + Check Code
              Expanded(
                flex: 40,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (state.summary != null)
                        LoyaltySummaryCard(
                          summary: state.summary!,
                          onViewHistory: () {},
                          onRedeemReward: () {},
                        ),
                      if (state.isLoadingSummary)
                        const Center(child: CircularProgressIndicator()),
                      const SpaceHeight.h16(),
                      // Rewards
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.card_giftcard,
                                    color: AppColors.primary, size: 20),
                                SpaceWidth.w8(),
                                Text(
                                  'Rewards',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SpaceHeight.h12(),
                            LoyaltyRewardsGrid(
                              rewards: state.rewards,
                              currentPoints:
                                  state.summary?.currentPoints ?? 0,
                              isLoading: state.isLoadingRewards,
                              onRewardTap: (reward) {
                                showDialog(
                                  context: context,
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<LoyaltyBloc>(),
                                    child: RedeemRewardDialog(
                                      reward: reward,
                                      currentPoints:
                                          state.summary?.currentPoints ?? 0,
                                      isLoading: state.isRedeeming,
                                      onConfirm: () {
                                        context.read<LoyaltyBloc>().add(
                                              RedeemReward(
                                                  customerId, reward.id),
                                            );
                                        Navigator.pop(context);
                                      },
                                      onCancel: () => Navigator.pop(context),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SpaceHeight.h16(),
                      // Check Code Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.qr_code_scanner,
                                    color: AppColors.primary, size: 20),
                                SpaceWidth.w8(),
                                Text(
                                  'Gunakan Kode',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SpaceHeight.h12(),
                            _CheckCodeForm(state: state),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SpaceWidth.w20(),

              // Right Panel (60%) - Points History + Redemptions
              Expanded(
                flex: 60,
                child: DefaultTabController(
                  length: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(text: 'Riwayat Poin'),
                            Tab(text: 'Penukaran'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              LoyaltyPointsHistory(
                                points: state.pointsHistory,
                                isLoading: state.isLoadingPoints,
                                hasMore: state.hasMorePoints,
                                onLoadMore: () {
                                  final nextPage =
                                      (state.pointsMeta?.currentPage ?? 0) + 1;
                                  context.read<LoyaltyBloc>().add(
                                        FetchPointsHistory(customerId,
                                            page: nextPage),
                                      );
                                },
                              ),
                              _RedemptionsList(state: state),
                            ],
                          ),
                        ),
                      ],
                    ),
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

// Check Code Form Widget
class _CheckCodeForm extends StatefulWidget {
  final LoyaltyState state;

  const _CheckCodeForm({required this.state});

  @override
  State<_CheckCodeForm> createState() => _CheckCodeFormState();
}

class _CheckCodeFormState extends State<_CheckCodeForm> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final checked = state.checkedRedemption;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Code Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Masukkan kode redemption',
                    prefixIcon: const Icon(Icons.confirmation_number_outlined,
                        size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SpaceWidth.w12(),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: state.isCheckingCode
                      ? null
                      : () {
                          final code = _codeController.text.trim();
                          if (code.isNotEmpty) {
                            context
                                .read<LoyaltyBloc>()
                                .add(CheckRedemptionCode(code));
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state.isCheckingCode
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Cek Kode'),
                ),
              ),
            ],
          ),
          const SpaceHeight.h16(),

          // Result Card
          if (checked != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: checked.isValid
                    ? AppColors.success.withValues(alpha: 0.05)
                    : AppColors.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: checked.isValid
                      ? AppColors.success.withValues(alpha: 0.3)
                      : AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Row(
                    children: [
                      Icon(
                        checked.isValid
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: checked.isValid
                            ? AppColors.success
                            : AppColors.error,
                        size: 20,
                      ),
                      const SpaceWidth.w8(),
                      Text(
                        checked.isValid ? 'Kode Valid' : 'Kode Tidak Valid',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: checked.isValid
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SpaceHeight.h12(),

                  // Reward Info
                  Text(
                    checked.reward?.name ?? 'Reward',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SpaceHeight.h8(),

                  // Details
                  _DetailRow(
                    label: 'Kode',
                    value: checked.code,
                  ),
                  _DetailRow(
                    label: 'Poin Digunakan',
                    value: '${checked.pointsUsed} pts',
                  ),
                  _DetailRow(
                    label: 'Status',
                    value: checked.statusLabel,
                  ),
                  if (checked.validUntil != null)
                    _DetailRow(
                      label: 'Berlaku Hingga',
                      value: checked.validUntil!.toFormattedDate,
                    ),
                  const SpaceHeight.h16(),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            context
                                .read<LoyaltyBloc>()
                                .add(const ClearCheckedRedemption());
                            _codeController.clear();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Batal'),
                        ),
                      ),
                      if (checked.canUse) ...[
                        const SpaceWidth.w12(),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: state.isUsingCode
                                ? null
                                : () {
                                    context.read<LoyaltyBloc>().add(
                                          UseRedemptionCode(checked.code),
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: state.isUsingCode
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Gunakan Kode'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Redemptions List with Cancel Button
class _RedemptionsList extends StatelessWidget {
  final LoyaltyState state;

  const _RedemptionsList({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingRedemptions) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.redemptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.redeem,
                size: 48, color: AppColors.textMuted.withValues(alpha: 0.5)),
            const SpaceHeight.h12(),
            const Text(
              'Belum ada penukaran',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.redemptions.length,
      separatorBuilder: (_, __) => const SpaceHeight.h8(),
      itemBuilder: (context, index) {
        final redemption = state.redemptions[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.redeem,
                    color: AppColors.primary, size: 20),
              ),
              const SpaceWidth.w12(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      redemption.reward?.name ?? 'Reward',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kode: ${redemption.code}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(redemption.status)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  redemption.statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(redemption.status),
                  ),
                ),
              ),
              // Cancel button for active/pending redemptions
              if (redemption.canUse) ...[
                const SpaceWidth.w8(),
                SizedBox(
                  height: 32,
                  child: IconButton(
                    onPressed: state.isCancelling
                        ? null
                        : () => _showCancelDialog(context, redemption.id),
                    icon: const Icon(Icons.close, size: 18),
                    color: AppColors.error,
                    tooltip: 'Batalkan',
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context, int redemptionId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batalkan Penukaran?'),
        content: const Text(
          'Poin yang digunakan akan dikembalikan. Apakah Anda yakin ingin membatalkan penukaran ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              context.read<LoyaltyBloc>().add(CancelRedemption(redemptionId));
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.success;
      case 'used':
        return AppColors.info;
      case 'expired':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }
}
