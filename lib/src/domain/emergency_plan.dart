import 'dart:convert';

class EmergencyContact {
  const EmergencyContact({required this.name, required this.phone});

  final String name;
  final String phone;

  Map<String, Object?> toJson() => {'name': name, 'phone': phone};

  factory EmergencyContact.fromJson(Map<String, Object?> json) =>
      EmergencyContact(
        name: (json['name'] as String?) ?? '',
        phone: (json['phone'] as String?) ?? '',
      );

  @override
  bool operator ==(Object other) =>
      other is EmergencyContact && other.name == name && other.phone == phone;

  @override
  int get hashCode => Object.hash(name, phone);
}

/// The family's own seizure action plan, shown on the timer screen when a
/// seizure goes on too long.
class EmergencyPlan {
  const EmergencyPlan({
    this.alertAfter = const Duration(minutes: 5),
    this.rescueMedication = '',
    this.rescueDose = '',
    this.callAfterRescue = const Duration(minutes: 10),
    this.minHoursBetweenRescueDoses,
    this.emergencyNumber = '911',
    this.contacts = const [],
    this.instructions = '',
  });

  /// When the timer turns to a warning. Five minutes is the threshold most
  /// seizure action plans use for rescue medication and calling for help.
  final Duration alertAfter;
  final String rescueMedication;
  final String rescueDose;

  /// If the seizure continues this long after the rescue dose, call for
  /// emergency help.
  final Duration callAfterRescue;

  /// Optional minimum gap between rescue doses, shown on the home screen.
  final int? minHoursBetweenRescueDoses;
  final String emergencyNumber;
  final List<EmergencyContact> contacts;

  /// Free-text steps from the family's neurologist.
  final String instructions;

  bool get hasRescueMedication => rescueMedication.trim().isNotEmpty;

  bool get isConfigured =>
      hasRescueMedication || contacts.isNotEmpty || instructions.isNotEmpty;

  EmergencyPlan copyWith({
    Duration? alertAfter,
    String? rescueMedication,
    String? rescueDose,
    Duration? callAfterRescue,
    int? Function()? minHoursBetweenRescueDoses,
    String? emergencyNumber,
    List<EmergencyContact>? contacts,
    String? instructions,
  }) {
    return EmergencyPlan(
      alertAfter: alertAfter ?? this.alertAfter,
      rescueMedication: rescueMedication ?? this.rescueMedication,
      rescueDose: rescueDose ?? this.rescueDose,
      callAfterRescue: callAfterRescue ?? this.callAfterRescue,
      minHoursBetweenRescueDoses: minHoursBetweenRescueDoses != null
          ? minHoursBetweenRescueDoses()
          : this.minHoursBetweenRescueDoses,
      emergencyNumber: emergencyNumber ?? this.emergencyNumber,
      contacts: contacts ?? this.contacts,
      instructions: instructions ?? this.instructions,
    );
  }

  Map<String, Object?> toJson() => {
    'alertAfterSeconds': alertAfter.inSeconds,
    'rescueMedication': rescueMedication,
    'rescueDose': rescueDose,
    'callAfterRescueSeconds': callAfterRescue.inSeconds,
    'minHoursBetweenRescueDoses': minHoursBetweenRescueDoses,
    'emergencyNumber': emergencyNumber,
    'contacts': [for (final c in contacts) c.toJson()],
    'instructions': instructions,
  };

  factory EmergencyPlan.fromJson(Map<String, Object?> json) {
    const defaults = EmergencyPlan();
    return EmergencyPlan(
      alertAfter: Duration(
        seconds:
            (json['alertAfterSeconds'] as num?)?.toInt() ??
            defaults.alertAfter.inSeconds,
      ),
      rescueMedication: (json['rescueMedication'] as String?) ?? '',
      rescueDose: (json['rescueDose'] as String?) ?? '',
      callAfterRescue: Duration(
        seconds:
            (json['callAfterRescueSeconds'] as num?)?.toInt() ??
            defaults.callAfterRescue.inSeconds,
      ),
      minHoursBetweenRescueDoses: (json['minHoursBetweenRescueDoses'] as num?)
          ?.toInt(),
      emergencyNumber:
          (json['emergencyNumber'] as String?) ?? defaults.emergencyNumber,
      contacts: [
        for (final c in (json['contacts'] as List?) ?? const [])
          EmergencyContact.fromJson((c as Map).cast<String, Object?>()),
      ],
      instructions: (json['instructions'] as String?) ?? '',
    );
  }

  String encode() => jsonEncode(toJson());

  static EmergencyPlan decode(String? source, {EmergencyPlan? fallback}) {
    if (source == null || source.isEmpty) {
      return fallback ?? const EmergencyPlan();
    }
    try {
      return EmergencyPlan.fromJson(
        (jsonDecode(source) as Map).cast<String, Object?>(),
      );
    } on FormatException {
      return fallback ?? const EmergencyPlan();
    }
  }

  /// A sensible emergency number for the phone's region. Always editable.
  static String defaultEmergencyNumber(String? countryCode) {
    switch (countryCode?.toUpperCase()) {
      case 'US':
      case 'CA':
      case 'MX':
      case 'PR':
        return '911';
      case 'AU':
        return '000';
      case 'NZ':
        return '111';
      case 'GB':
        return '999';
      default:
        return '112';
    }
  }
}

/// Standard seizure first aid ("Stay, Safe, Side"), shown while timing.
const firstAidSteps = <String>[
  'Stay with them and keep timing.',
  'Keep them safe: move hard or sharp things away and cushion the head.',
  'Turn them gently onto their side if they are not awake and aware.',
  'Nothing in the mouth. Do not hold them down.',
];
