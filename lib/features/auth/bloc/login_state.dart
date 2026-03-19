part of 'login_bloc.dart';

enum LoginStatus { initial, submitting, success, failure }

final class LoginState extends Equatable {
  const LoginState({
    this.email = '',
    this.password = '',
    this.name = '',
    this.status = LoginStatus.initial,
    this.errorMessage,
  });

  final String email;
  final String password;
  final String name;
  final LoginStatus status;
  final String? errorMessage;

  LoginState copyWith({
    String? email,
    String? password,
    String? name,
    LoginStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [email, password, name, status, errorMessage];
}
