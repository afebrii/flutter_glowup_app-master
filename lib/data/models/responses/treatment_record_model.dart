import 'appointment_model.dart';
import 'customer_model.dart';
import 'user_model.dart';

/// Treatment record model for documenting treatments
class TreatmentRecordModel {
  final int id;
  final int appointmentId;
  final int customerId;
  final int staffId;
  final String? notes;
  final List<String>? beforePhotos;
  final List<String>? beforePhotoUrls;
  final List<String>? afterPhotos;
  final List<String>? afterPhotoUrls;
  final String? recommendations;
  final DateTime? followUpDate;
  final AppointmentModel? appointment;
  final CustomerModel? customer;
  final UserModel? staff;
  final DateTime? createdAt;

  TreatmentRecordModel({
    required this.id,
    required this.appointmentId,
    required this.customerId,
    required this.staffId,
    this.notes,
    this.beforePhotos,
    this.beforePhotoUrls,
    this.afterPhotos,
    this.afterPhotoUrls,
    this.recommendations,
    this.followUpDate,
    this.appointment,
    this.customer,
    this.staff,
    this.createdAt,
  });

  factory TreatmentRecordModel.fromJson(Map<String, dynamic> json) {
    // API returns singular before_photo/after_photo (string), wrap in list
    List<String>? parsePhotos(dynamic plural, dynamic singular) {
      if (plural != null) return List<String>.from(plural);
      if (singular != null && singular is String) return [singular];
      return null;
    }

    return TreatmentRecordModel(
      id: json['id'],
      appointmentId: json['appointment_id'],
      customerId: json['customer_id'],
      staffId: json['staff_id'],
      notes: json['notes'],
      beforePhotos: parsePhotos(json['before_photos'], json['before_photo']),
      beforePhotoUrls:
          parsePhotos(json['before_photo_urls'], json['before_photo_url']),
      afterPhotos: parsePhotos(json['after_photos'], json['after_photo']),
      afterPhotoUrls:
          parsePhotos(json['after_photo_urls'], json['after_photo_url']),
      recommendations: json['recommendations'],
      followUpDate: json['follow_up_date'] != null
          ? DateTime.parse(json['follow_up_date'])
          : null,
      appointment: json['appointment'] != null
          ? AppointmentModel.fromJson(json['appointment'])
          : null,
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'])
          : null,
      staff: json['staff'] != null ? UserModel.fromJson(json['staff']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'appointment_id': appointmentId,
        'customer_id': customerId,
        'staff_id': staffId,
        'notes': notes,
        'before_photos': beforePhotos,
        'after_photos': afterPhotos,
        'recommendations': recommendations,
        'follow_up_date': followUpDate?.toIso8601String().split('T').first,
        'created_at': createdAt?.toIso8601String(),
      };

  /// Check if has before photos
  bool get hasBeforePhotos =>
      beforePhotoUrls != null && beforePhotoUrls!.isNotEmpty;

  /// Check if has after photos
  bool get hasAfterPhotos =>
      afterPhotoUrls != null && afterPhotoUrls!.isNotEmpty;

  /// Check if has any photos
  bool get hasPhotos => hasBeforePhotos || hasAfterPhotos;

  /// Get total photos count
  int get totalPhotosCount =>
      (beforePhotoUrls?.length ?? 0) + (afterPhotoUrls?.length ?? 0);

  /// Check if has follow up scheduled
  bool get hasFollowUp => followUpDate != null;

  /// Check if follow up is due
  bool get isFollowUpDue {
    if (followUpDate == null) return false;
    return DateTime.now().isAfter(followUpDate!) ||
        DateTime.now().day == followUpDate!.day;
  }

  /// Get days until follow up
  int? get daysUntilFollowUp {
    if (followUpDate == null) return null;
    return followUpDate!.difference(DateTime.now()).inDays;
  }
}
