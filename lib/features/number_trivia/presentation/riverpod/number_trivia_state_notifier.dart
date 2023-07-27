import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';

const String serverFailureMessage = 'Server Failure';
const String cacheFailureMessage = 'Cache Failure';
const String invalidInputFailureMessage =
    'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaState extends Equatable {
  const NumberTriviaState();

  @override
  List<Object?> get props => [];
}

class Empty extends NumberTriviaState {}

class Loading extends NumberTriviaState {}

class Loaded extends NumberTriviaState {
  final NumberTrivia trivia;

  const Loaded({required this.trivia});

  @override
  List<Object?> get props => [trivia];
}

class Error extends NumberTriviaState {
  final String message;

  const Error({required this.message});

  @override
  List<Object?> get props => [message];
}

class NumberTriviaStateNotifier extends StateNotifier<NumberTriviaState> {
  NumberTriviaStateNotifier() : super(Empty());

  void setLoading() {
    state = Loading();
  }

  void setLoaded(NumberTrivia trivia) {
    state = Loaded(trivia: trivia);
  }

  void setError(String message) {
    state = Error(message: message);
  }
}
