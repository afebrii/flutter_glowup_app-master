import 'dart:convert';
import 'dart:developer' as dev;
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/variables.dart';
import '../models/requests/appointment_request_model.dart';
import '../models/responses/appointment_model.dart';
import '../models/responses/customer_model.dart';
import '../models/responses/service_model.dart';
import 'auth_local_datasource.dart';

class AppointmentRemoteDatasource {
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthLocalDatasource().getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Either<String, List<AppointmentModel>>> getAppointments({
    DateTime? date,
    String? status,
  }) async {
    try {
      var url = Variables.appointments;
      final params = <String>[];
      if (date != null) {
        final dateStr = date.toIso8601String().split('T').first;
        params.add('start_date=$dateStr');
        params.add('end_date=$dateStr');
      }
      if (status != null) {
        params.add('status=$status');
      }
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      dev.log('📡 GET $url', name: 'Appointments');

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      dev.log('📥 Status ${response.statusCode}', name: 'Appointments');
      dev.log('📥 Body: ${response.body}', name: 'Appointments');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data['data'] as List)
            .map((e) => AppointmentModel.fromJson(e))
            .toList();
        dev.log('✅ Found ${list.length} appointments', name: 'Appointments');
        return Right(list);
      } else {
        final error = jsonDecode(response.body);
        final message = error['message'] ?? 'Gagal memuat appointment';
        dev.log('❌ Error: $message', name: 'Appointments');
        return Left(message);
      }
    } catch (e, stackTrace) {
      dev.log('💥 Exception: $e', name: 'Appointments');
      dev.log('$stackTrace', name: 'Appointments');
      return Left('Gagal memuat appointment: $e');
    }
  }

  Future<Either<String, List<TimeSlot>>> getAvailableSlots({
    required DateTime date,
    required int serviceId,
    int? staffId,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T').first;
      var url =
          '${Variables.availableSlots}?date=$dateStr&service_id=$serviceId';
      if (staffId != null) {
        url += '&staff_id=$staffId';
      }

      dev.log('[AvailableSlots] 📡 GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      dev.log('[AvailableSlots] 📥 Status ${response.statusCode}');
      dev.log('[AvailableSlots] 📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final slotsData = data['data'];

        List slotsList;
        if (slotsData is Map) {
          slotsList = (slotsData['slots'] as List?) ?? [];
        } else if (slotsData is List) {
          slotsList = slotsData;
        } else {
          dev.log('[AvailableSlots] ⚠️ Unexpected data type: ${slotsData.runtimeType}');
          return const Right([]);
        }

        dev.log('[AvailableSlots] ✅ Found ${slotsList.length} slots');
        final list = slotsList.map((e) {
          // API may return simple strings like "09:00" or objects like {"time": "09:00", "available": true}
          if (e is String) {
            return TimeSlot(time: e, isAvailable: true);
          } else if (e is Map<String, dynamic>) {
            return TimeSlot.fromJson(e);
          }
          return TimeSlot(time: e.toString(), isAvailable: true);
        }).toList();
        return Right(list);
      } else {
        final error = jsonDecode(response.body);
        final message = error['message'] ?? 'Gagal memuat slot waktu';
        dev.log('[AvailableSlots] ❌ Error: $message');
        return Left(message);
      }
    } catch (e, stackTrace) {
      dev.log('[AvailableSlots] 💥 Exception: $e');
      dev.log('[AvailableSlots] $stackTrace');
      return Left('Gagal memuat slot waktu: $e');
    }
  }

  Future<Either<String, AppointmentModel>> createAppointment(
      AppointmentRequestModel request) async {
    try {
      final body = jsonEncode(request.toJson());
      dev.log('📡 POST ${Variables.appointments}', name: 'Appointments');
      dev.log('📦 Body: $body', name: 'Appointments');

      final response = await http.post(
        Uri.parse(Variables.appointments),
        headers: await _getHeaders(),
        body: body,
      );

      dev.log('📥 Status ${response.statusCode}', name: 'Appointments');
      dev.log('📥 Body: ${response.body}', name: 'Appointments');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Right(AppointmentModel.fromJson(data['data']));
      } else {
        final error = jsonDecode(response.body);
        final message = error['message'] ?? 'Gagal membuat appointment';
        dev.log('❌ Error: $message', name: 'Appointments');
        return Left(message);
      }
    } catch (e, stackTrace) {
      dev.log('💥 Exception: $e', name: 'Appointments');
      dev.log('$stackTrace', name: 'Appointments');
      return Left('Gagal membuat appointment: $e');
    }
  }

  Future<Either<String, AppointmentModel>> createAppointmentMock(
      AppointmentRequestModel request) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Calculate end time based on start time + 60 minutes default
    final startParts = request.startTime.split(':');
    final startHour = int.parse(startParts[0]);
    final startMinute = int.parse(startParts[1]);
    final totalMinutes = startHour * 60 + startMinute + 60;
    final endHour = (totalMinutes ~/ 60) % 24;
    final endMinute = totalMinutes % 60;
    final endTime = '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

    final newAppointment = AppointmentModel(
      id: DateTime.now().millisecondsSinceEpoch,
      customerId: request.customerId,
      serviceId: request.serviceId,
      staffId: request.staffId,
      appointmentDate: DateTime.parse(request.appointmentDate),
      startTime: request.startTime,
      endTime: endTime,
      status: AppointmentStatus.pending,
      source: AppointmentSource.fromString(request.source),
      notes: request.notes,
      createdAt: DateTime.now(),
    );

    return Right(newAppointment);
  }

  Future<Either<String, AppointmentModel>> updateStatus(
      int id, UpdateAppointmentStatusRequest request) async {
    try {
      final url = '${Variables.appointments}/$id/status';
      final body = jsonEncode(request.toJson());
      dev.log('📡 PATCH $url', name: 'Appointments');
      dev.log('📦 Body: $body', name: 'Appointments');

      final response = await http.patch(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: body,
      );

      dev.log('📥 Status ${response.statusCode}', name: 'Appointments');
      dev.log('📥 Body: ${response.body}', name: 'Appointments');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Right(AppointmentModel.fromJson(data['data']));
      } else {
        final error = jsonDecode(response.body);
        final message = error['message'] ?? 'Gagal mengupdate status';
        dev.log('❌ Error: $message', name: 'Appointments');
        return Left(message);
      }
    } catch (e, stackTrace) {
      dev.log('💥 Exception: $e', name: 'Appointments');
      dev.log('$stackTrace', name: 'Appointments');
      return Left('Gagal mengupdate status: $e');
    }
  }

  // Mock data for testing
  Future<Either<String, List<AppointmentModel>>> getAppointmentsMock({
    DateTime? date,
    String? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final appointments = [
      AppointmentModel(
        id: 1,
        customerId: 1,
        serviceId: 1,
        appointmentDate: today,
        startTime: '09:00',
        endTime: '10:00',
        status: AppointmentStatus.confirmed,
        source: AppointmentSource.whatsapp,
        customer: CustomerModel(
          id: 1,
          name: 'Rina Susanti',
          phone: '081234567890',
          createdAt: DateTime(2024, 1, 15),
        ),
        service: ServiceModel(
          id: 1,
          categoryId: 1,
          name: 'Basic Facial',
          durationMinutes: 60,
          price: 150000,
        ),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      AppointmentModel(
        id: 2,
        customerId: 2,
        serviceId: 2,
        appointmentDate: today,
        startTime: '10:30',
        endTime: '12:00',
        status: AppointmentStatus.pending,
        source: AppointmentSource.phone,
        customer: CustomerModel(
          id: 2,
          name: 'Maya Putri',
          phone: '081234567891',
          createdAt: DateTime(2024, 2, 10),
        ),
        service: ServiceModel(
          id: 2,
          categoryId: 1,
          name: 'Acne Facial',
          durationMinutes: 90,
          price: 250000,
        ),
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      AppointmentModel(
        id: 3,
        customerId: 3,
        serviceId: 3,
        appointmentDate: today,
        startTime: '13:00',
        endTime: '14:30',
        status: AppointmentStatus.inProgress,
        source: AppointmentSource.walkIn,
        customer: CustomerModel(
          id: 3,
          name: 'Dewi Anggraini',
          phone: '081234567892',
          createdAt: DateTime(2023, 11, 5),
        ),
        service: ServiceModel(
          id: 3,
          categoryId: 1,
          name: 'Whitening Facial',
          durationMinutes: 90,
          price: 300000,
        ),
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      AppointmentModel(
        id: 4,
        customerId: 4,
        serviceId: 6,
        appointmentDate: today,
        startTime: '14:00',
        endTime: '15:00',
        status: AppointmentStatus.confirmed,
        source: AppointmentSource.online,
        customer: CustomerModel(
          id: 4,
          name: 'Siti Nurhaliza',
          phone: '081234567893',
          createdAt: DateTime(2024, 3, 1),
        ),
        service: ServiceModel(
          id: 6,
          categoryId: 2,
          name: 'Body Scrub',
          durationMinutes: 60,
          price: 200000,
        ),
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      AppointmentModel(
        id: 5,
        customerId: 5,
        serviceId: 9,
        appointmentDate: today,
        startTime: '15:30',
        endTime: '16:30',
        status: AppointmentStatus.pending,
        source: AppointmentSource.whatsapp,
        customer: CustomerModel(
          id: 5,
          name: 'Amanda Wijaya',
          phone: '081234567894',
          createdAt: DateTime(2024, 4, 20),
        ),
        service: ServiceModel(
          id: 9,
          categoryId: 3,
          name: 'Hair Spa',
          durationMinutes: 60,
          price: 150000,
        ),
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      // Tomorrow appointments
      AppointmentModel(
        id: 6,
        customerId: 6,
        serviceId: 4,
        appointmentDate: today.add(const Duration(days: 1)),
        startTime: '09:00',
        endTime: '11:00',
        status: AppointmentStatus.confirmed,
        source: AppointmentSource.phone,
        customer: CustomerModel(
          id: 6,
          name: 'Ratna Sari',
          phone: '081234567895',
          createdAt: DateTime(2023, 6, 15),
        ),
        service: ServiceModel(
          id: 4,
          categoryId: 1,
          name: 'Anti Aging Facial',
          durationMinutes: 120,
          price: 450000,
        ),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      AppointmentModel(
        id: 7,
        customerId: 8,
        serviceId: 7,
        appointmentDate: today.add(const Duration(days: 1)),
        startTime: '11:00',
        endTime: '12:30',
        status: AppointmentStatus.pending,
        source: AppointmentSource.online,
        customer: CustomerModel(
          id: 8,
          name: 'Fitri Handayani',
          phone: '081234567897',
          createdAt: DateTime(2023, 12, 1),
        ),
        service: ServiceModel(
          id: 7,
          categoryId: 2,
          name: 'Body Massage',
          durationMinutes: 90,
          price: 300000,
        ),
        createdAt: now,
      ),
      // Yesterday (completed)
      AppointmentModel(
        id: 8,
        customerId: 9,
        serviceId: 12,
        appointmentDate: today.subtract(const Duration(days: 1)),
        startTime: '14:00',
        endTime: '14:45',
        status: AppointmentStatus.completed,
        source: AppointmentSource.walkIn,
        customer: CustomerModel(
          id: 9,
          name: 'Lisa Permata',
          phone: '081234567898',
          createdAt: DateTime(2024, 1, 10),
        ),
        service: ServiceModel(
          id: 12,
          categoryId: 4,
          name: 'Manicure',
          durationMinutes: 45,
          price: 100000,
        ),
        createdAt: today.subtract(const Duration(days: 3)),
      ),
    ];

    // Filter by date if provided
    var filtered = appointments;
    if (date != null) {
      final targetDate = DateTime(date.year, date.month, date.day);
      filtered = appointments.where((a) {
        final appointmentDateOnly = DateTime(
          a.appointmentDate.year,
          a.appointmentDate.month,
          a.appointmentDate.day,
        );
        return appointmentDateOnly.isAtSameMomentAs(targetDate);
      }).toList();
    }

    // Filter by status if provided
    if (status != null) {
      filtered = filtered
          .where((a) => a.status.toApiString() == status)
          .toList();
    }

    // Sort by start time
    filtered.sort((a, b) {
      final dateCompare = a.appointmentDate.compareTo(b.appointmentDate);
      if (dateCompare != 0) return dateCompare;
      return a.startTime.compareTo(b.startTime);
    });

    return Right(filtered);
  }

  Future<Either<String, List<TimeSlot>>> getAvailableSlotsMock({
    required DateTime date,
    required int serviceId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Generate time slots from 09:00 to 18:00
    final slots = <TimeSlot>[];
    final bookedSlots = ['09:00', '10:30', '13:00', '14:00', '15:30'];

    for (var hour = 9; hour < 18; hour++) {
      for (var minute = 0; minute < 60; minute += 30) {
        final time =
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        slots.add(TimeSlot(
          time: time,
          isAvailable: !bookedSlots.contains(time),
        ));
      }
    }

    return Right(slots);
  }
}
