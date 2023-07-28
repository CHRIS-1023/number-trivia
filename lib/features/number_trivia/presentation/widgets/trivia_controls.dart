import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../riverpod.dart';


class TriviaControls extends ConsumerWidget {
  const TriviaControls({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    late String inputStr;

    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Input a number',
          ),
          onChanged: (value) {
            inputStr = value;
          },
          onSubmitted: (_) {
            addConcrete(ref, inputStr);
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => addConcrete(ref, inputStr),
                child: const Text('Search'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade500,
                ),
                onPressed: () => addRandom(ref),
                child: const Text('Get random trivia'),
              ),
            ),
          ],
        )
      ],
    );
  }

  void addConcrete(WidgetRef ref, String inputStr) {
    ref
        .read(numberTriviaProvider.notifier)
        .getTriviaForConcreteNumber(inputStr);
  }

  void addRandom(WidgetRef ref) {
    ref.read(numberTriviaProvider.notifier).getTriviaForRandomNumber();
  }
}
