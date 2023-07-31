import 'package:data_connection_checker_nulls/data_connection_checker_nulls.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:number_trivia/core/util/input_converter.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/number_trivia_local_data_source.dart';
import '../../data/datasources/number_trivia_remote_data_source.dart';
import '../../data/repositories/number_trivia_repository_impl.dart';
import '../../domain/repositories/number_trivia_repository.dart';

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

final getConcreteNumberTriviaProvider =
    Provider<GetConcreteNumberTrivia>((ref) {
  final repository = ref.watch(numberTriviaRepositoryProvider);
  return GetConcreteNumberTrivia(repository);
});

final getRandomNumberTriviaProvider = Provider<GetRandomNumberTrivia>((ref) {
  final repository = ref.watch(numberTriviaRepositoryProvider);
  return GetRandomNumberTrivia(repository);
});

final inputConverterProvider =
    Provider<InputConverter>((ref) => InputConverter());

final numberTriviaStateNotifierProvider =
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

final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

final dataConnectionCheckerProvider =
    Provider<DataConnectionChecker>((ref) => DataConnectionChecker());

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  final dataConnectionChecker = ref.watch(dataConnectionCheckerProvider);
  return NetworkInfoImpl(dataConnectionChecker);
});

final numberTriviaRemoteDataSourceProvider =
    Provider<NumberTriviaRemoteDataSource>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return NumberTriviaRemoteDataSourceImpl(client: httpClient);
});

final numberTriviaLocalDataSourceProvider =
    Provider<NumberTriviaLocalDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return sharedPreferences.when(
    data: (value) {
      return NumberTriviaLocalDataSourceImpl(sharedPreferences: value);
    },
    loading: () {
      throw Exception("Shared Preferences is still loading");
    },
    error: (error, stackTrace) {
      throw Exception("Error fetching Shared Preferences: $error");
    },
  );
});

final numberTriviaRepositoryProvider = Provider<NumberTriviaRepository>((ref) {
  final remoteDataSource = ref.watch(numberTriviaRemoteDataSourceProvider);
  final localDataSource = ref.watch(numberTriviaLocalDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return NumberTriviaRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
  );
});
