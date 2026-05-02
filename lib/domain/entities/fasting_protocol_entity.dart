class FastingProtocol {
  final String name;
  final String description;
  final int fastingHours;
  final int eatingHours;

  const FastingProtocol({
    required this.name,
    required this.description,
    required this.fastingHours,
    required this.eatingHours,
  });

  Duration get fastingDuration => Duration(hours: fastingHours);

  static const protocols = [
    FastingProtocol(
      name: '12:12',
      description: '12h jejum, 12h alimentação',
      fastingHours: 12,
      eatingHours: 12,
    ),
    FastingProtocol(
      name: '16:8',
      description: '16h jejum, 8h alimentação',
      fastingHours: 16,
      eatingHours: 8,
    ),
    FastingProtocol(
      name: '18:6',
      description: '18h jejum, 6h alimentação',
      fastingHours: 18,
      eatingHours: 6,
    ),
    FastingProtocol(
      name: '20:4',
      description: '20h jejum, 4h alimentação',
      fastingHours: 20,
      eatingHours: 4,
    ),
    FastingProtocol(
      name: '24h',
      description: '24h jejum completo',
      fastingHours: 24,
      eatingHours: 0,
    ),
    FastingProtocol(
      name: 'OMAD',
      description: 'One Meal A Day (23h jejum)',
      fastingHours: 23,
      eatingHours: 1,
    ),
  ];

  static FastingProtocol get defaultProtocol => protocols[1]; // 16:8
}
