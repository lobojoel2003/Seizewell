/// Seizure types, based on the ILAE 2017 operational classification and
/// described in plain language so a caregiver can pick one calmly.
enum SeizureType {
  focalAware(
    label: 'Focal aware',
    short: 'Focal aware',
    description:
        'Awake and aware throughout. May have twitching, tingling, a rising '
        'feeling, déjà vu, or an odd taste or smell.',
  ),
  focalImpaired(
    label: 'Focal impaired awareness',
    short: 'Focal impaired',
    description:
        'Confused or not responding. May stare, fiddle, chew or wander, and '
        'not remember it afterwards.',
  ),
  focalToBilateral(
    label: 'Focal to bilateral tonic-clonic',
    short: 'Focal → bilateral',
    description:
        'Starts on one side or in one area, then spreads into stiffening and '
        'jerking of the whole body.',
  ),
  tonicClonic(
    label: 'Generalized tonic-clonic',
    short: 'Tonic-clonic',
    description:
        'Loss of consciousness, stiffening, then rhythmic jerking of the whole '
        'body. Often followed by deep sleep or confusion.',
  ),
  absence(
    label: 'Absence',
    short: 'Absence',
    description:
        'A brief blank stare, usually under 20 seconds. May blink or flutter '
        'the eyelids, then carry on as if nothing happened.',
  ),
  myoclonic(
    label: 'Myoclonic',
    short: 'Myoclonic',
    description:
        'Sudden, very brief jerks of a muscle or group of muscles, like being '
        'startled. Often in the morning.',
  ),
  atonic(
    label: 'Atonic (drop)',
    short: 'Atonic',
    description:
        'Sudden loss of muscle tone. The head may drop, or the person may '
        'slump or fall.',
  ),
  tonic(
    label: 'Tonic',
    short: 'Tonic',
    description:
        'Sudden stiffening of the muscles of the body, arms or legs, often '
        'during sleep.',
  ),
  clonic(
    label: 'Clonic',
    short: 'Clonic',
    description: 'Rhythmic jerking of the muscles without a stiffening phase.',
  ),
  spasms(
    label: 'Epileptic spasms',
    short: 'Spasms',
    description:
        'Sudden bending forward or stiffening, often in clusters. Most common '
        'in babies and young children.',
  ),
  unknown(
    label: 'Not sure / other',
    short: 'Not sure',
    description:
        'Pick this if you are not sure. Describe what you saw in the notes — '
        'that helps the neurologist most.',
  );

  const SeizureType({
    required this.label,
    required this.short,
    required this.description,
  });

  final String label;
  final String short;
  final String description;

  /// Stable, kebab-case code used in exports (CSV, FHIR).
  String get code =>
      name.replaceAllMapped(RegExp('[A-Z]'), (m) => '-${m[0]!.toLowerCase()}');

  static SeizureType fromCode(String code) => SeizureType.values.firstWhere(
    (t) => t.code == code || t.name == code,
    orElse: () => SeizureType.unknown,
  );
}

/// Who wrote the entry.
enum Reporter {
  patient('Patient'),
  caregiver('Caregiver');

  const Reporter(this.label);
  final String label;
}

enum MedicationKind {
  maintenance('Daily medication'),
  rescue('Rescue medication');

  const MedicationKind(this.label);
  final String label;
}

enum MedicationChangeKind {
  started('Started'),
  doseChanged('Dose changed'),
  stopped('Stopped');

  const MedicationChangeKind(this.label);
  final String label;
}
