class OnboardingData {
  final String firstName;
  final String lastName;
  final String sex;
  final String birthDate; // ISO 8601 string: yyyy-MM-dd
  final String? phoneNumber;
  final String email;
  final String username;
  final String password;
  final String country;
  final String state;
  final String city;

  OnboardingData({
    required this.firstName,
    required this.lastName,
    required this.sex,
    required this.birthDate,
    this.phoneNumber,
    required this.email,
    required this.username,
    required this.password,
    required this.country,
    required this.state,
    required this.city
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'sex': sex,
    'birthDate': birthDate,
    'phoneNumber': phoneNumber,
    'email': email,
    'username': username,
    'password': password,
    'country': country,
    'state': state,
    'city': city,
  };
}
