import 'package:data_connection_checker_nulls/data_connection_checker_nulls.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/network_info.dart';
import 'core/util/input_converter.dart';
import 'features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'features/number_trivia/presentation/riverpod.dart';

// service locator
final sl = GetIt.instance;

final getConcreteNumberTriviaProvider =
    Provider<GetConcreteNumberTrivia>((ref) => GetConcreteNumberTrivia(sl()));
final getRandomNumberTriviaProvider =
    Provider<GetRandomNumberTrivia>((ref) => GetRandomNumberTrivia(sl()));
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

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  final client = http.Client();
  final dataConnectionChecker = DataConnectionChecker();

  // Register Riverpod providers
  sl.registerLazySingleton<InputConverter>(() => InputConverter());
  sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(dataConnectionChecker));
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<http.Client>(() => client);
  sl.registerLazySingleton<DataConnectionChecker>(() => dataConnectionChecker);

  // Use cases
  sl.registerLazySingleton(() => GetConcreteNumberTrivia(sl()));
  sl.registerLazySingleton(() => GetRandomNumberTrivia(sl()));

  // Repository
  sl.registerLazySingleton<NumberTriviaRepository>(
      () => NumberTriviaRepositoryImpl(
            remoteDataSource: sl(),
            localDataSource: sl(),
            networkInfo: sl(),
          ));

  // Data sources
  sl.registerLazySingleton<NumberTriviaRemoteDataSource>(
      () => NumberTriviaRemoteDataSourceImpl(client: sl()));
  sl.registerLazySingleton<NumberTriviaLocalDataSource>(
      () => NumberTriviaLocalDataSourceImpl(sharedPreferences: sl()));
}
