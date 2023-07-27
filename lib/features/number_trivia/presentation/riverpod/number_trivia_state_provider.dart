import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'number_trivia_state_notifier.dart';

final numberTriviaStateProvider =
    StateNotifierProvider<NumberTriviaStateNotifier, NumberTriviaState>(
        (ref) => NumberTriviaStateNotifier());
