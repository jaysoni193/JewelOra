import 'dart:convert';

/// Represents a 1-on-1 Virtual Live Video Shopping Consultation booking with a jewellery stylist.
class VideoAppointmentModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final String categoryInterest;
  final String preferredLanguage;
  final DateTime appointmentDate;
  final String timeSlot;
  final String platform; // 'WhatsApp Video' or 'Google Meet'
  final String notes;
  final String status; // 'confirmed', 'completed', 'cancelled'
  final DateTime createdAt;

  const VideoAppointmentModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.categoryInterest,
    this.preferredLanguage = 'English',
    required this.appointmentDate,
    required this.timeSlot,
    this.platform = 'WhatsApp Video',
    this.notes = '',
    this.status = 'confirmed',
    required this.createdAt,
  });

  /// Preset categories of jewellery for virtual demonstration
  static const List<String> availableCategories = [
    'Bridal Polki & Kundan',
    'Solitaire & Diamond Rings',
    'Daily Wear Gold & Chains',
    'Antique Temple Jewellery',
    'Mangalsutras & Sets',
    'Silver Articles & Coins',
  ];

  /// Languages supported by Jewel Ora stylists
  static const List<String> availableLanguages = [
    'English',
    'Hindi (हिंदी)',
    'Gujarati (ગુજરાતી)',
  ];

  /// Standard video consultation time slots
  static const List<String> availableTimeSlots = [
    '11:00 AM - 11:45 AM',
    '02:00 PM - 02:45 PM',
    '04:00 PM - 04:45 PM',
    '06:00 PM - 06:45 PM',
  ];

  /// Video calling platforms
  static const List<String> availablePlatforms = [
    'WhatsApp Video',
    'Google Meet',
  ];

  /// Whether the appointment is upcoming
  bool get isUpcoming {
    if (status != 'confirmed') return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final apptDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
    return !apptDay.isBefore(today);
  }

  /// Number of days until this appointment from [today]
  int daysUntil([DateTime? today]) {
    final now = today ?? DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfAppt = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
    return startOfAppt.difference(startOfToday).inDays;
  }

  VideoAppointmentModel copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? categoryInterest,
    String? preferredLanguage,
    DateTime? appointmentDate,
    String? timeSlot,
    String? platform,
    String? notes,
    String? status,
    DateTime? createdAt,
  }) {
    return VideoAppointmentModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      categoryInterest: categoryInterest ?? this.categoryInterest,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      timeSlot: timeSlot ?? this.timeSlot,
      platform: platform ?? this.platform,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'categoryInterest': categoryInterest,
      'preferredLanguage': preferredLanguage,
      'appointmentDate': appointmentDate.toIso8601String(),
      'timeSlot': timeSlot,
      'platform': platform,
      'notes': notes,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory VideoAppointmentModel.fromMap(Map<String, dynamic> map) {
    return VideoAppointmentModel(
      id: map['id'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      customerPhone: map['customerPhone'] as String? ?? '',
      categoryInterest: map['categoryInterest'] as String? ?? availableCategories.first,
      preferredLanguage: map['preferredLanguage'] as String? ?? 'English',
      appointmentDate: map['appointmentDate'] != null
          ? DateTime.tryParse(map['appointmentDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      timeSlot: map['timeSlot'] as String? ?? availableTimeSlots.first,
      platform: map['platform'] as String? ?? 'WhatsApp Video',
      notes: map['notes'] as String? ?? '',
      status: map['status'] as String? ?? 'confirmed',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory VideoAppointmentModel.fromJson(String source) =>
      VideoAppointmentModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
