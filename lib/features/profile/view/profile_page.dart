import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/di/injection.dart';
import '../../../core/supabase/supabase_storage.dart';
import '../bloc/profile_bloc.dart';
import 'profile_view.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        authBloc: context.read<AuthBloc>(),
        authRepository: locate<AuthRepository>(),
        storageService: locate<StorageService>(),
      )..add(const ProfileLoadRequested()),
      child: const ProfileView(),
    );
  }
}
