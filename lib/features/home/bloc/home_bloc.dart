import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    // Simulate loading; replace with real data fetching.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    emit(
      state.copyWith(
        status: HomeStatus.success,
        greeting: 'Welcome to Base!',
      ),
    );
  }
}
