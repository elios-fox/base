part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, failure }

final class HomeState extends Equatable {
  const HomeState({this.status = HomeStatus.initial, this.greeting = ''});

  final HomeStatus status;
  final String greeting;

  HomeState copyWith({HomeStatus? status, String? greeting}) {
    return HomeState(
      status: status ?? this.status,
      greeting: greeting ?? this.greeting,
    );
  }

  @override
  List<Object?> get props => [status, greeting];
}
