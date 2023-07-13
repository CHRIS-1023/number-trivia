import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class NumberTriviaLocalDataSource {
  /// Gets the cached [NumberTriviaModel] which was gotten the last time
  /// the user had an internet connection.
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<NumberTriviaModel>? getLastNumberTrivia();

  Future<void>? cacheNumberTrivia(NumberTriviaModel triviaToCache);
}

class NumberTriviaLocalDataSourceImpl implements NumberTriviaLocalDataSource {
  final SharedPreferences sharedPreferences;

  NumberTriviaLocalDataSourceImpl({required this.sharedPreferences});
  @override
  Future<NumberTriviaModel>? getLastNumberTrivia() {
    throw UnimplementedError();
  }

  @override
  Future<void>? cacheNumberTrivia(NumberTriviaModel triviaToCache) {
    throw UnimplementedError();
  }
}
