part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

final class LoginEmailChanged extends LoginEvent {
  const LoginEmailChanged(this.email);
  final String email;

  @override
  List<Object?> get props => [email];
}

final class LoginPasswordChanged extends LoginEvent {
  const LoginPasswordChanged(this.password);
  final String password;

  @override
  List<Object?> get props => [password];
}

final class LoginWithEmailSubmitted extends LoginEvent {
  const LoginWithEmailSubmitted();
}

final class SignUpWithEmailSubmitted extends LoginEvent {
  const SignUpWithEmailSubmitted();
}

final class LoginWithGooglePressed extends LoginEvent {
  const LoginWithGooglePressed();
}

final class LoginWithApplePressed extends LoginEvent {
  const LoginWithApplePressed();
}

