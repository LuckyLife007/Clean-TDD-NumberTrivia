import 'package:clean_app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:clean_app/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clean_app/features/number_trivia/presentation/widgets/widgets.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Number Trivia App')),
        body: SingleChildScrollView(child: buildBody(context)));
  }

  BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
    return BlocProvider(
        create: (context) => sl<NumberTriviaBloc>(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            const SizedBox(height: 10),
            BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
              builder: (context, state) {
                if (state is Empty) {
                  return const MessageDisplay(message: 'Start Searching!');
                } else if (state is Loading) {
                  return const LoadingWidget();
                } else if (state is Loaded) {
                  return TriviaDisplay(numberTrivia: state.trivia);
                } else if (state is Error) {
                  return MessageDisplay(
                    message: state.message,
                  );
                } else {
                  return const Text('Something went wrong!');
                }
              },
            ),
            const SizedBox(height: 20),
            const TriviaControls()
          ]),
        ));
  }
}
