import 'package:equatable/equatable.dart';

abstract class PackageEvent extends Equatable {
  const PackageEvent();

  @override
  List<Object?> get props => [];
}

class FetchPackages extends PackageEvent {
  final int? serviceId;
  final bool activeOnly;

  const FetchPackages({this.serviceId, this.activeOnly = true});

  @override
  List<Object?> get props => [serviceId, activeOnly];
}

class FetchPackageById extends PackageEvent {
  final int packageId;

  const FetchPackageById(this.packageId);

  @override
  List<Object?> get props => [packageId];
}

class FetchCustomerPackages extends PackageEvent {
  final int? customerId;
  final String? status;
  final bool usableOnly;
  final int page;

  const FetchCustomerPackages({
    this.customerId,
    this.status,
    this.usableOnly = false,
    this.page = 1,
  });

  @override
  List<Object?> get props => [customerId, status, usableOnly, page];
}

class SellPackage extends PackageEvent {
  final int customerId;
  final int packageId;
  final double? pricePaid;
  final String? notes;

  const SellPackage({
    required this.customerId,
    required this.packageId,
    this.pricePaid,
    this.notes,
  });

  @override
  List<Object?> get props => [customerId, packageId, pricePaid, notes];
}

class UsePackageSession extends PackageEvent {
  final int customerPackageId;
  final int? appointmentId;
  final String? notes;

  const UsePackageSession(
    this.customerPackageId, {
    this.appointmentId,
    this.notes,
  });

  @override
  List<Object?> get props => [customerPackageId, appointmentId, notes];
}

class FetchUsablePackages extends PackageEvent {
  final int customerId;
  final int serviceId;

  const FetchUsablePackages({
    required this.customerId,
    required this.serviceId,
  });

  @override
  List<Object?> get props => [customerId, serviceId];
}

class SelectCustomerPackage extends PackageEvent {
  final int? customerPackageId;

  const SelectCustomerPackage(this.customerPackageId);

  @override
  List<Object?> get props => [customerPackageId];
}

class ClearPackageError extends PackageEvent {
  const ClearPackageError();
}

class ClearPackageSuccess extends PackageEvent {
  const ClearPackageSuccess();
}
