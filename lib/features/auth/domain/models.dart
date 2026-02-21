class LoginRequest {
  final String staffId;
  final String password;

  LoginRequest({
    required this.staffId,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'staff_id': staffId,
      'password': password,
    };
  }
}

class LoginResponse {
  final String token;
  final User user;

  LoginResponse({
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}

class User {
  final int id;
  final String name;
  final String staffId;
  final String? phone;

  User({
    required this.id,
    required this.name,
    required this.staffId,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      staffId: json['staff_id'] ?? '',
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'staff_id': staffId,
      'phone': phone,
    };
  }
}
