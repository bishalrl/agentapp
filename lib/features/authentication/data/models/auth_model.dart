import '../../domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  const AuthModel({
    required super.token,
    required super.counter,
    super.mustChangePassword = false,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    // Handle different response formats
    // Format 1: { token, agent, mustChangePassword } - from login-bus-agent
    // Format 2: { token, counter } - from other endpoints
    print('🔍 AuthModel.fromJson: Parsing JSON');
    print('   JSON keys: ${json.keys}');
    print('   Token: ${json['token']}');
    print('   Agent: ${json['agent']}');
    print('   Counter: ${json['counter']}');
    
    final token = json['token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Token is missing or empty in response');
    }
    
    final counterData = json['agent'] ?? json['counter'];
    if (counterData == null) {
      throw Exception('Agent or counter data is missing in response');
    }
    
    return AuthModel(
      token: token,
      counter: CounterModel.fromJson(counterData as Map<String, dynamic>),
      mustChangePassword: json['mustChangePassword'] as bool? ?? false,
    );
  }
}

class CounterModel extends CounterEntity {
  const CounterModel({
    required super.id,
    required super.agencyName,
    required super.email,
    required super.phoneNumber,
    required super.walletBalance,
  });

  factory CounterModel.fromJson(Map<String, dynamic> json) {
    print('🔍 CounterModel.fromJson: Parsing JSON');
    print('   JSON keys: ${json.keys}');
    print('   ID: ${json['id'] ?? json['_id']}');
    print('   AgencyName: ${json['agencyName']}');
    print('   Email: ${json['email']}');
    
    final id = json['id'] as String? ?? json['_id'] as String?;
    if (id == null || id.isEmpty) {
      throw Exception('Counter ID is missing in response');
    }
    
    final agencyName = json['agencyName'] as String?;
    if (agencyName == null || agencyName.isEmpty) {
      throw Exception('Agency name is missing in response');
    }
    
    final email = json['email'] as String?;
    if (email == null || email.isEmpty) {
      throw Exception('Email is missing in response');
    }
    
    return CounterModel(
      id: id,
      agencyName: agencyName,
      email: email,
      phoneNumber: json['phoneNumber'] as String? ?? json['primaryContact'] as String? ?? '',
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

