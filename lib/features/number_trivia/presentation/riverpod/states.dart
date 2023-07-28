import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:number_trivia/core/util/input_converter.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../injection_container.dart';

final numberTriviaStateNotifierProvider =
    StateNotifierProvider<NumberTriviaStateNotifier, NumberTriviaState>((ref) {
  final getConcreteNumberTrivia = ref.read(getConcreteNumberTriviaProvider);
  final getRandomNumberTrivia = ref.read(getRandomNumberTriviaProvider);
  final inputConverter = ref.read(inputConverterProvider);

  return NumberTriviaStateNotifier(
    getConcreteNumberTrivia: getConcreteNumberTrivia,
    getRandomNumberTrivia: getRandomNumberTrivia,
    inputConverter: inputConverter,
  );
});

class NumberTriviaStateNotifier extends StateNotifier<NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaStateNotifier({
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
      failureOrTrivia?.fold(
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
    switch (failure.runtimeType) {
      case ServerFailure:
        return serverFailureMessage;
      case CacheFailure:
        return cacheFailureMessage;
      default:
        return 'Unexpected error';
    }
  }
}
