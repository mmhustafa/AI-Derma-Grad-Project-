// lib/core/models/auth_model.dart

/// Models for authentication requests and responses.

// ─── Request ────────────────────────────────────────────────────────────────

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class RegisterRequest {
  final String userName;
  final String email;
  final String password;
  final int age;
  final String gender;

  RegisterRequest({
    required this.userName,
    required this.email,
    required this.password,
    required this.age,
    required this.gender,
  });

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'email': email,
        'password': password,
        'age': age,
        'gender': gender,
      };
}

// ─── Response ────────────────────────────────────────────────────────────────

class LoginResponse {
  final String token;
  final DateTime expiration;

  LoginResponse({required this.token, required this.expiration});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      expiration: DateTime.parse(json['expiration'] as String),
    );
  }
}
