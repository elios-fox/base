import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/auth/auth_repository.dart';
import '../../../core/di/injection.dart';
import '../bloc/login_bloc.dart';
import 'sign_up_view.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(authRepository: locate<AuthRepository>()),
      child: const SignUpView(),
    );
  }
}
