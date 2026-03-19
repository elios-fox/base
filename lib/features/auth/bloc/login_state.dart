part of 'login_bloc.dart';

enum LoginStatus {
  initial,
  submitting,
  success,
  failure,
  emailConfirmationSent,
}

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

  /// Use [clearError] to explicitly clear the error message.
  LoginState copyWith({
    String? email,
    String? password,
    String? name,
    LoginStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [email, password, name, status, errorMessage];
}
