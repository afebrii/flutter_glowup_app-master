import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/responses/referral_model.dart';

class ApplyReferralForm extends StatefulWidget {
  final bool isLoading;
  final ReferralProgramInfo? validatedInfo;
  final String? error;
  final Function(String) onValidate;
  final VoidCallback? onApply;
  final VoidCallback? onClear;

  const ApplyReferralForm({
    super.key,
    this.isLoading = false,
    this.validatedInfo,
    this.error,
    required this.onValidate,
    this.onApply,
    this.onClear,
  });

  @override
  State<ApplyReferralForm> createState() => _ApplyReferralFormState();
}

class _ApplyReferralFormState extends State<ApplyReferralForm> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.card_giftcard_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Punya Kode Referral?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Masukkan kode referral',
                    hintStyle: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _controller.clear();
                              widget.onClear?.call();
                              setState(() {});
                            },
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {});
                    if (value.isEmpty) {
                      widget.onClear?.call();
                    }
                  },
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      widget.onValidate(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: widget.isLoading || _controller.text.isEmpty
                    ? null
                    : () => widget.onValidate(_controller.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Cek'),
              ),
            ],
          ),
          // Error message
          if (widget.error != null) ...[
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
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.error!,
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
          // Validated info
          if (widget.validatedInfo != null) ...[
            const SizedBox(height: 12),
            _ValidatedReferralCard(
              info: widget.validatedInfo!,
              onApply: widget.onApply,
              isLoading: widget.isLoading,
            ),
          ],
        ],
      ),
    );
  }
}

class _ValidatedReferralCard extends StatelessWidget {
  final ReferralProgramInfo info;
  final VoidCallback? onApply;
  final bool isLoading;

  const _ValidatedReferralCard({
    required this.info,
    this.onApply,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kode Referral Valid!',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Bonus untuk Anda: ${info.refereePoints} poin',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Gunakan Kode Ini'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet version for checkout flow
class ApplyReferralBottomSheet extends StatefulWidget {
  final Function(String) onValidate;
  final Future<bool> Function(String) onApply;

  const ApplyReferralBottomSheet({
    super.key,
    required this.onValidate,
    required this.onApply,
  });

  @override
  State<ApplyReferralBottomSheet> createState() =>
      _ApplyReferralBottomSheetState();
}

class _ApplyReferralBottomSheetState extends State<ApplyReferralBottomSheet> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  bool _isApplying = false;
  ReferralProgramInfo? _validatedInfo;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _validate() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _validatedInfo = null;
    });

    try {
      widget.onValidate(_controller.text);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _apply() async {
    if (_controller.text.isEmpty) return;

    setState(() => _isApplying = true);

    final success = await widget.onApply(_controller.text);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => _isApplying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Masukkan Kode Referral',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ApplyReferralForm(
            isLoading: _isLoading || _isApplying,
            validatedInfo: _validatedInfo,
            error: _error,
            onValidate: (code) => _validate(),
            onApply: _apply,
            onClear: () {
              setState(() {
                _validatedInfo = null;
                _error = null;
              });
            },
          ),
        ],
      ),
    );
  }
}
