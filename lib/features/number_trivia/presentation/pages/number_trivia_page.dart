import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:number_trivia/features/number_trivia/presentation/widgets/trivia_controls.dart';

import '../riverpod/number_trivia_state_notifier.dart';
import '../riverpod/number_trivia_state_provider.dart';
import '../widgets/loading_widget.dart';
import '../widgets/message_display.dart';
import '../widgets/trivia_display.dart';

class NumberTriviaPage extends ConsumerWidget {
  const NumberTriviaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Trivia'),
      ),
      body: SingleChildScrollView(
        child: buildBody(context, ref),
      ),
    );
  }

  Consumer buildBody(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, watch, child) {
        final state = ref.watch(numberTriviaStateProvider);

        if (state is Empty) {
          return const MessageDisplay(message: 'Start searching');
        } else if (state is Loading) {
          return const LoadingWidget();
        } else if (state is Loaded) {
          return TriviaDisplay(numberTrivia: state.trivia);
        } else if (state is Error) {
          return MessageDisplay(message: state.message);
        }
        
        return Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              child: const Placeholder(),
            ),
            const SizedBox(
              height: 20,
            ),
            const TriviaControls(),
          ],
        );
      },
    );
  }
}
