class EmergencyContact {
  final String name;
  final String number;
  final String icon; // emoji or icon name
  final String description;

  EmergencyContact({
    required this.name,
    required this.number,
    required this.icon,
    required this.description,
  });
}

class EmergencyNumbersService {
  // India Emergency Numbers
  static final List<EmergencyContact> emergencyNumbers = [
    EmergencyContact(
      name: 'Police',
      number: '100',
      icon: '🚨',
      description: 'Police Emergency',
    ),
    EmergencyContact(
      name: 'Ambulance',
      number: '102',
      icon: '🚑',
      description: 'Medical Emergency',
    ),
    EmergencyContact(
      name: 'Fire',
      number: '101',
      icon: '🚒',
      description: 'Fire Emergency',
    ),
    EmergencyContact(
      name: 'General',
      number: '112',
      icon: '📞',
      description: 'All Emergency',
    ),
    EmergencyContact(
      name: 'Women Helpline',
      number: '1091',
      icon: '👩',
      description: 'Women Safety',
    ),
    EmergencyContact(
      name: 'Disaster Management',
      number: '1070',
      icon: '⚠️',
      description: 'Disaster Relief',
    ),
  ];

  /// Get all emergency numbers
  static List<EmergencyContact> getEmergencyNumbers() {
    return emergencyNumbers;
  }

  /// Get emergency number by name
  static EmergencyContact? getByName(String name) {
    try {
      return emergencyNumbers.firstWhere((e) => e.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Get emergency number by phone number
  static EmergencyContact? getByNumber(String number) {
    try {
      return emergencyNumbers.firstWhere((e) => e.number == number);
    } catch (e) {
      return null;
    }
  }
}
