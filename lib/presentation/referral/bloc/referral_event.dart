import 'package:equatable/equatable.dart';

abstract class ReferralEvent extends Equatable {
  const ReferralEvent();

  @override
  List<Object?> get props => [];
}

class FetchReferralInfo extends ReferralEvent {
  final int customerId;

  const FetchReferralInfo(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class FetchReferralHistory extends ReferralEvent {
  final int customerId;
  final int page;

  const FetchReferralHistory(this.customerId, {this.page = 1});

  @override
  List<Object?> get props => [customerId, page];
}

class FetchReferredCustomers extends ReferralEvent {
  final int customerId;
  final int page;

  const FetchReferredCustomers(this.customerId, {this.page = 1});

  @override
  List<Object?> get props => [customerId, page];
}

class ValidateReferralCode extends ReferralEvent {
  final String code;

  const ValidateReferralCode(this.code);

  @override
  List<Object?> get props => [code];
}

class ApplyReferralCode extends ReferralEvent {
  final int customerId;
  final String code;

  const ApplyReferralCode(this.customerId, this.code);

  @override
  List<Object?> get props => [customerId, code];
}

class FetchProgramInfo extends ReferralEvent {
  const FetchProgramInfo();
}

class ClearReferralError extends ReferralEvent {
  const ClearReferralError();
}

class ClearReferralSuccess extends ReferralEvent {
  const ClearReferralSuccess();
}

class ClearValidation extends ReferralEvent {
  const ClearValidation();
}
