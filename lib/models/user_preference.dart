class UserPreference {
  final int? id;
  final int userId;
  final String preferenceKey;
  final String value;

  UserPreference({
    this.id,
    required this.userId,
    required this.preferenceKey,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'preference_key': preferenceKey,
      'value': value,
    };
  }

  factory UserPreference.fromMap(Map<String, dynamic> map) {
    return UserPreference(
      id: map['id'],
      userId: map['user_id'],
      preferenceKey: map['preference_key'],
      value: map['value'],
    );
  }
}
