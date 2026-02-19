import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/spaces.dart';
import '../../../core/widgets/responsive_widget.dart';
import '../../../data/datasources/referral_remote_datasource.dart';
import '../../../injection.dart';
import '../bloc/referral_bloc.dart';
import '../bloc/referral_event.dart';
import '../bloc/referral_state.dart';
import '../widgets/referral_info_card.dart';
import '../widgets/referral_history_list.dart';
import '../widgets/apply_referral_form.dart';

class ReferralPage extends StatelessWidget {
  final int customerId;

  const ReferralPage({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReferralBloc(
        referralDatasource: getIt<ReferralRemoteDatasource>(),
      )
        ..add(FetchReferralInfo(customerId))
        ..add(FetchReferralHistory(customerId))
        ..add(FetchReferredCustomers(customerId))
        ..add(const FetchProgramInfo()),
      child: ResponsiveWidget(
        phone: _ReferralPhoneLayout(customerId: customerId),
        tablet: _ReferralTabletLayout(customerId: customerId),
      ),
    );
  }
}

// Phone Layout
class _ReferralPhoneLayout extends StatelessWidget {
  final int customerId;

  const _ReferralPhoneLayout({required this.customerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Referral'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<ReferralBloc, ReferralState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<ReferralBloc>().add(const ClearReferralSuccess());
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: AppColors.error,
              ),
            );
            context.read<ReferralBloc>().add(const ClearReferralError());
          }
        },
        builder: (context, state) {
          if (state.isLoadingInfo && state.referralInfo == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Referral Info Card
                if (state.referralInfo != null)
                  ReferralInfoCard(
                    referralInfo: state.referralInfo!,
                    onShare: () {},
                    onViewHistory: () {},
                  ),
                const SpaceHeight.h16(),

                // Apply Referral Form
                ApplyReferralForm(
                  isLoading: state.isValidating || state.isApplying,
                  error: state.error,
                  onValidate: (code) {
                    context
                        .read<ReferralBloc>()
                        .add(ValidateReferralCode(code));
                  },
                  onApply: state.isCodeValid
                      ? () {
                          final code =
                              state.validationResult?['code'] as String? ?? '';
                          context.read<ReferralBloc>().add(
                                ApplyReferralCode(customerId, code),
                              );
                        }
                      : null,
                  onClear: () {
                    context
                        .read<ReferralBloc>()
                        .add(const ClearValidation());
                  },
                ),
                const SpaceHeight.h20(),

                // Referral History
                const Text(
                  'Riwayat Referral',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SpaceHeight.h12(),
                ReferralHistoryList(
                  referrals: state.history,
                  isLoading: state.isLoadingHistory,
                  hasMore: state.hasMoreHistory,
                  onLoadMore: () {
                    final nextPage =
                        (state.historyMeta?.currentPage ?? 0) + 1;
                    context.read<ReferralBloc>().add(
                          FetchReferralHistory(customerId, page: nextPage),
                        );
                  },
                ),
                const SpaceHeight.h20(),

                // Referred Customers
                const Text(
                  'Pelanggan Referral',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SpaceHeight.h12(),
                _ReferredCustomersList(state: state),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Tablet Layout
class _ReferralTabletLayout extends StatelessWidget {
  final int customerId;

  const _ReferralTabletLayout({required this.customerId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReferralBloc, ReferralState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
            ),
          );
          context.read<ReferralBloc>().add(const ClearReferralSuccess());
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
            ),
          );
          context.read<ReferralBloc>().add(const ClearReferralError());
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Panel (40%) - Info + Apply Form
              Expanded(
                flex: 40,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (state.referralInfo != null)
                        ReferralInfoCard(
                          referralInfo: state.referralInfo!,
                          onShare: () {},
                          onViewHistory: () {},
                        ),
                      if (state.isLoadingInfo && state.referralInfo == null)
                        const Center(child: CircularProgressIndicator()),
                      const SpaceHeight.h16(),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color:
                                  AppColors.border.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.link,
                                    color: AppColors.primary, size: 20),
                                SpaceWidth.w8(),
                                Text(
                                  'Terapkan Kode Referral',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SpaceHeight.h12(),
                            ApplyReferralForm(
                              isLoading:
                                  state.isValidating || state.isApplying,
                              error: state.error,
                              onValidate: (code) {
                                context.read<ReferralBloc>().add(
                                      ValidateReferralCode(code),
                                    );
                              },
                              onApply: state.isCodeValid
                                  ? () {
                                      final code =
                                          state.validationResult?['code']
                                                  as String? ??
                                              '';
                                      context.read<ReferralBloc>().add(
                                            ApplyReferralCode(
                                                customerId, code),
                                          );
                                    }
                                  : null,
                              onClear: () {
                                context.read<ReferralBloc>().add(
                                      const ClearValidation(),
                                    );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SpaceWidth.w20(),

              // Right Panel (60%) - History + Referred
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
                            Tab(text: 'Riwayat Referral'),
                            Tab(text: 'Pelanggan Referral'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              ReferralHistoryList(
                                referrals: state.history,
                                isLoading: state.isLoadingHistory,
                                hasMore: state.hasMoreHistory,
                                onLoadMore: () {
                                  final nextPage =
                                      (state.historyMeta?.currentPage ?? 0) +
                                          1;
                                  context.read<ReferralBloc>().add(
                                        FetchReferralHistory(customerId,
                                            page: nextPage),
                                      );
                                },
                              ),
                              _ReferredCustomersList(state: state),
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

class _ReferredCustomersList extends StatelessWidget {
  final ReferralState state;

  const _ReferredCustomersList({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingReferred) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.referredCustomers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline,
                  size: 48,
                  color: AppColors.textMuted.withValues(alpha: 0.5)),
              const SpaceHeight.h12(),
              const Text(
                'Belum ada pelanggan referral',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.referredCustomers.length,
      separatorBuilder: (_, __) => const SpaceHeight.h8(),
      itemBuilder: (context, index) {
        final referral = state.referredCustomers[index];
        final refereeName = referral.referee?.name ?? 'Pelanggan #${referral.refereeId}';
        final refereePhone = referral.referee?.phone ?? '';
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  refereeName.isNotEmpty ? refereeName[0] : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SpaceWidth.w12(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      refereeName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (refereePhone.isNotEmpty)
                      Text(
                        refereePhone,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    Text(
                      referral.statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: referral.isRewarded
                            ? AppColors.success
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
