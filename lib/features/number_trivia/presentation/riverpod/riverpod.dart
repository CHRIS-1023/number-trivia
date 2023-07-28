import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:number_trivia/core/util/input_converter.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/widgets/loading_widget.dart';
import 'package:number_trivia/features/number_trivia/presentation/widgets/message_display.dart';
import 'package:number_trivia/features/number_trivia/presentation/widgets/trivia_display.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../../injection_container.dart';

const String serverFailureMessage = 'Server Failure';
const String cacheFailureMessage = 'Cache Failure';
const String invalidInputFailureMessage =
    'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaState extends Equatable {
  const NumberTriviaState();

  @override
  List<Object?> get props => [];

  when(
      {required MessageDisplay Function() empty,
      required LoadingWidget Function() loading,
      required TriviaDisplay Function(dynamic triviaState) loaded,
      required MessageDisplay Function(dynamic error) error}) {}
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

class NumberTriviaNotifier extends StateNotifier<NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaNotifier({
    required this.getConcreteNumberTrivia,
    required this.getRandomNumberTrivia,
    required this.inputConverter,
  }) : super(Empty());

  Future<void> getTriviaForConcreteNumber(String numberString) async {
    final inputEither = inputConverter.stringToUnsignedInteger(numberString);

    inputEither?.fold((failure) {
      state = const Error(message: invalidInputFailureMessage);
    }, (integer) async {
      state = Loading();
      final failureOrTrivia =
          await getConcreteNumberTrivia(Params(number: integer));
      failureOrTrivia!.fold(
        (failure) => state = Error(message: _mapFailureToMessage(failure)),
        (trivia) => state = Loaded(trivia: trivia),
      );
    });
  }

  Future<void> getTriviaForRandomNumber() async {
    state = Loading();
    final failureOrTrivia = await getRandomNumberTrivia(NoParams());
    failureOrTrivia?.fold(
      (failure) => state = Error(message: _mapFailureToMessage(failure)),
      (trivia) => state = Loaded(trivia: trivia),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return serverFailureMessage;
    } else if (failure is CacheFailure) {
      return cacheFailureMessage;
    } else {
      return 'Unexpected error';
    }
  }
}

final numberTriviaProvider =
    StateNotifierProvider<NumberTriviaNotifier, NumberTriviaState>((ref) {
  final getConcreteNumberTrivia = ref.watch(getConcreteNumberTriviaProvider);
  final getRandomNumberTrivia = ref.watch(getRandomNumberTriviaProvider);
  final inputConverter = ref.watch(inputConverterProvider);

  return NumberTriviaNotifier(
    getConcreteNumberTrivia: getConcreteNumberTrivia,
    getRandomNumberTrivia: getRandomNumberTrivia,
    inputConverter: inputConverter,
  );
});
