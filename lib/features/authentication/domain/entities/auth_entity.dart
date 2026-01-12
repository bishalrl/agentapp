class AuthEntity {
  final String token;
  final CounterEntity counter;
  final bool mustChangePassword;

  const AuthEntity({
    required this.token,
    required this.counter,
    this.mustChangePassword = false,
  });
}

class CounterEntity {
  final String id;
  final String agencyName;
  final String email;
  final String phoneNumber;
  final double walletBalance;

  const CounterEntity({
    required this.id,
    required this.agencyName,
    required this.email,
    required this.phoneNumber,
    required this.walletBalance,
  });
}

