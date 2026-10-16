import 'dart:convert';

class OccasionReminderModel {
  final String id;
  final String title;
  final String recipient; // 'Spouse / Partner', 'Mother', 'Sister', 'Daughter', 'Friend', 'Self'
  final int month; // 1-12
  final int day; // 1-31
  final int? year; // Milestone year (e.g. 2019 for wedding year)
  final String? categoryHint; // 'Rings', 'Necklaces', 'Earrings', 'Bangles', 'Coins'
  final double? budget;
  final String? notes;

  const OccasionReminderModel({
    required this.id,
    required this.title,
    required this.recipient,
    required this.month,
    required this.day,
    this.year,
    this.categoryHint,
    this.budget,
    this.notes,
  });

  /// Calculates number of calendar days until next occurrence
  int daysUntilNext(DateTime today) {
    final normalizedToday = DateTime(today.year, today.month, today.day);
    var candidate = DateTime(today.year, month, day);

    if (candidate.isBefore(normalizedToday)) {
      // Milestone has passed this year, roll over to next year
      candidate = DateTime(today.year + 1, month, day);
    }

    return candidate.difference(normalizedToday).inDays;
  }

  /// Calculates milestone years completed (e.g. 5th Anniversary)
  int? yearsCompleted(DateTime today) {
    if (year == null) return null;
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final anniversaryThisYear = DateTime(today.year, month, day);
    final count = anniversaryThisYear.isAfter(normalizedToday)
        ? (today.year - year!)
        : (today.year - year! + 1);
    return count > 0 ? count : 1;
  }

  bool isUpcoming(DateTime today, {int thresholdDays = 14}) {
    final days = daysUntilNext(today);
    return days >= 0 && days <= thresholdDays;
  }

  String get formattedDate {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final mName = (month >= 1 && month <= 12) ? months[month - 1] : '';
    return '$day $mName (Annually)';
  }

  OccasionReminderModel copyWith({
    String? id,
    String? title,
    String? recipient,
    int? month,
    int? day,
    int? year,
    String? categoryHint,
    double? budget,
    String? notes,
  }) {
    return OccasionReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      recipient: recipient ?? this.recipient,
      month: month ?? this.month,
      day: day ?? this.day,
      year: year ?? this.year,
      categoryHint: categoryHint ?? this.categoryHint,
      budget: budget ?? this.budget,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'recipient': recipient,
      'month': month,
      'day': day,
      'year': year,
      'categoryHint': categoryHint,
      'budget': budget,
      'notes': notes,
    };
  }

  factory OccasionReminderModel.fromMap(Map<String, dynamic> map) {
    return OccasionReminderModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      recipient: map['recipient'] as String? ?? 'Spouse / Partner',
      month: map['month'] as int? ?? 1,
      day: map['day'] as int? ?? 1,
      year: map['year'] as int?,
      categoryHint: map['categoryHint'] as String?,
      budget: (map['budget'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory OccasionReminderModel.fromJson(String source) =>
      OccasionReminderModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
