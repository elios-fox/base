import 'package:base/features/home/bloc/home_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeBloc', () {
    test('initial state is correct', () {
      final bloc = HomeBloc();
      expect(bloc.state, const HomeState());
      bloc.close();
    });

    blocTest<HomeBloc, HomeState>(
      'emits [loading, success] when HomeStarted is added',
      build: HomeBloc.new,
      act: (bloc) => bloc.add(const HomeStarted()),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        const HomeState(
          status: HomeStatus.success,
          greeting: 'Welcome to Base!',
        ),
      ],
    );
  });
}
