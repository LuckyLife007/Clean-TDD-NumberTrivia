import 'package:clean_app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TriviaControls extends StatefulWidget {
  const TriviaControls({
    super.key,
  });

  @override
  State<TriviaControls> createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  final controller = TextEditingController();
  String inputString = '';

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextField(
          onSubmitted: (value) {
            dispatchConcrete();
          },
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), hintText: 'Input a number'),
          onChanged: (value) {
            inputString = value;
          }),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
            child: ElevatedButton(
                onPressed: dispatchConcrete, child: const Text('Search'))),
        const SizedBox(width: 10),
        Expanded(
            child: ElevatedButton(
                onPressed: dispatchRandom,
                child: const Text('Get Random Trivia')))
      ])
    ]);
  }

  void dispatchConcrete() {
    controller.clear();
    BlocProvider.of<NumberTriviaBloc>(context)
        .add(GetTriviaForConcreteNumber(inputString));
  }

  void dispatchRandom() {
    controller.clear();
    BlocProvider.of<NumberTriviaBloc>(context).add(GetTriviaForRandomNumber());
  }
}
