import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../riverpod/riverpod.dart';
import '../widgets/widgets.dart';

class NumberTriviaPage extends ConsumerWidget {
  const NumberTriviaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Trivia'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Consumer(
                  builder: (context, watch, _) {
                    final state = ref.watch(numberTriviaProvider);

                    if (state is Empty) {
                      return const MessageDisplay(message: 'Start searching');
                    } else if (state is Loading) {
                      return const LoadingWidget();
                    } else if (state is Loaded) {
                      return TriviaDisplay(numberTrivia: state.trivia);
                    } else if (state is Error) {
                      return MessageDisplay(message: state.message);
                    }

                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 3,
                      child: const Placeholder(),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const TriviaControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
