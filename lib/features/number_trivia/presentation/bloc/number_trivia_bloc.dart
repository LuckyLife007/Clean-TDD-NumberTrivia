// ignore_for_file: constant_identifier_names

import 'package:bloc/bloc.dart';
import 'package:clean_app/core/error/failures.dart';
import 'package:clean_app/core/usecases/usecase.dart';
import 'package:clean_app/core/util/input_converter.dart';
import 'package:clean_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc(
      {required GetConcreteNumberTrivia concrete,
      required GetRandomNumberTrivia random,
      required this.inputConverter})
      : getConcreteNumberTrivia = concrete,
        getRandomNumberTrivia = random,
        super(Empty()) {
    on<NumberTriviaEvent>((event, emit) async {
      if (event is GetTriviaForConcreteNumber) {
        String string = event.numberString;
        final inputEither = inputConverter.stringToUnsignedInteger(string);

        await inputEither.fold((failure) {
          emit(const Error(message: INVALID_INPUT_FAILURE_MESSAGE));
        }, (integer) async {
          emit(Loading());
          final failureOrEither =
              await getConcreteNumberTrivia(Params(number: integer));
          _eitherLoadedOrErrorState(failureOrEither, emit);
        });
      } else if (event is GetTriviaForRandomNumber) {
        emit(Loading());
        final failureOrEither = await getRandomNumberTrivia(NoParams());
        _eitherLoadedOrErrorState(failureOrEither, emit);
      }
    });
  }

  void _eitherLoadedOrErrorState(Either<Failure, NumberTrivia> failureOrEither,
      Emitter<NumberTriviaState> emit) {
    failureOrEither.fold(
        (failure) => emit(Error(message: _mapFailureToMessage(failure))),
        (trivia) => emit(Loaded(trivia: trivia)));
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (ServerFailure):
        return SERVER_FAILURE_MESSAGE;
      case const (CacheFailure):
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected error';
    }
  }
}
