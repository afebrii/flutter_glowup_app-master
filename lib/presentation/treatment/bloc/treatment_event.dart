import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class TreatmentEvent extends Equatable {
  const TreatmentEvent();

  @override
  List<Object?> get props => [];
}

class FetchTreatments extends TreatmentEvent {
  final int? customerId;
  final int? appointmentId;
  final int page;

  const FetchTreatments({this.customerId, this.appointmentId, this.page = 1});

  @override
  List<Object?> get props => [customerId, appointmentId, page];
}

class FetchTreatmentById extends TreatmentEvent {
  final int treatmentId;

  const FetchTreatmentById(this.treatmentId);

  @override
  List<Object?> get props => [treatmentId];
}

class FetchCustomerTreatments extends TreatmentEvent {
  final int customerId;
  final int limit;

  const FetchCustomerTreatments(this.customerId, {this.limit = 10});

  @override
  List<Object?> get props => [customerId, limit];
}

class SelectTreatment extends TreatmentEvent {
  final int? treatmentId;

  const SelectTreatment(this.treatmentId);

  @override
  List<Object?> get props => [treatmentId];
}

class ClearTreatmentError extends TreatmentEvent {
  const ClearTreatmentError();
}

class ClearTreatmentSuccess extends TreatmentEvent {
  const ClearTreatmentSuccess();
}

class CreateTreatment extends TreatmentEvent {
  final int appointmentId;
  final int customerId;
  final String? notes;
  final String? recommendations;
  final DateTime? followUpDate;
  final List<File>? beforePhotos;
  final List<File>? afterPhotos;
  final List<String>? productsUsed;

  const CreateTreatment({
    required this.appointmentId,
    required this.customerId,
    this.notes,
    this.recommendations,
    this.followUpDate,
    this.beforePhotos,
    this.afterPhotos,
    this.productsUsed,
  });

  @override
  List<Object?> get props => [
        appointmentId,
        customerId,
        notes,
        recommendations,
        followUpDate,
        beforePhotos,
        afterPhotos,
        productsUsed,
      ];
}
