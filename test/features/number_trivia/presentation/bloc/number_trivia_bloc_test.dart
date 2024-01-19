import 'package:clean_app/core/error/failures.dart';
import 'package:clean_app/core/usecases/usecase.dart';
import 'package:clean_app/core/util/input_converter.dart';
import 'package:clean_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  setUpAll(() {
    registerFallbackValue(const Params(number: 1));
    registerFallbackValue(NoParams());
  });

  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
        concrete: mockGetConcreteNumberTrivia,
        random: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter);
  });

  test('initialState should be Empty', () {
    expect(bloc.state, Empty());
  });

  group('GetTriviaForConcreteNumber', () {
    const tNumberString = '1';
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

    void setUpMockInputConverterSuccess() =>
        when(() => mockInputConverter.stringToUnsignedInteger(any()))
            .thenReturn(const Right(tNumberParsed));

    test(
        'should call the InputConverter to validate and convert the string to an unsigned integer',
        () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((invocation) async => const Right(tNumberTrivia));
      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(
          () => mockInputConverter.stringToUnsignedInteger(any()));
      // assert
      verify(() => mockInputConverter.stringToUnsignedInteger(tNumberString));
    }); // test

    test('should emit [Error] when the input is invalid', () async {
      // arrange
      when(() => mockInputConverter.stringToUnsignedInteger(any()))
          .thenReturn(Left(InvalidInputFailure()));
      // assert
      const expected = Error(message: INVALID_INPUT_FAILURE_MESSAGE);
      expect(bloc.stream, emits(expected));
      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    }); // test

    test('should get data from the concrete use case', () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((invocation) async => const Right(tNumberTrivia));
      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(() => mockGetConcreteNumberTrivia(any()));
      // assert
      verify(() =>
          mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));
    }); // test

    test('should emit [Loading, Loaded] when data is gotten successfully',
        () async {
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((invocation) async => const Right(tNumberTrivia));
      // assert
      final expected = [Loading(), const Loaded(trivia: tNumberTrivia)];
      expect(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    }); // test

    test('should emit [Loading, Error] when getting data fails', () async {
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((invocation) async => Left(ServerFailure()));
      // assert
      final expected = [
        Loading(),
        const Error(message: SERVER_FAILURE_MESSAGE)
      ];
      expect(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    }); // test

    test(
        'should emit [Loading, Error] with proper message for the error when gatting data fails',
        () async {
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((invocation) async => Left(CacheFailure()));
      // assert
      final expected = [Loading(), const Error(message: CACHE_FAILURE_MESSAGE)];
      expect(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    }); // test
  }); // group
  group('GetTriviaForRandomNumber', () {
    const tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

    test('should get data from the random use case', () async {
      // arrange
      when(() => mockGetRandomNumberTrivia(any()))
          .thenAnswer((invocation) async => const Right(tNumberTrivia));
      // act
      bloc.add(GetTriviaForRandomNumber());
      await untilCalled(() => mockGetRandomNumberTrivia(any()));
      // assert
      verify(() => mockGetRandomNumberTrivia(NoParams()));
    }); // test

    test('should emit [Loading, Loaded] when data is gotten successfully',
        () async {
      when(() => mockGetRandomNumberTrivia(any()))
          .thenAnswer((invocation) async => const Right(tNumberTrivia));
      // assert
      final expected = [Loading(), const Loaded(trivia: tNumberTrivia)];
      expect(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(GetTriviaForRandomNumber());
    }); // test

    test('should emit [Loading, Error] when getting data fails', () async {
      when(() => mockGetRandomNumberTrivia(any()))
          .thenAnswer((invocation) async => Left(ServerFailure()));
      // assert
      final expected = [
        Loading(),
        const Error(message: SERVER_FAILURE_MESSAGE)
      ];
      expect(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(GetTriviaForRandomNumber());
    }); // test

    test(
        'should emit [Loading, Error] with proper message for the error when gatting data fails',
        () async {
      when(() => mockGetRandomNumberTrivia(any()))
          .thenAnswer((invocation) async => Left(CacheFailure()));
      // assert
      final expected = [Loading(), const Error(message: CACHE_FAILURE_MESSAGE)];
      expect(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(GetTriviaForRandomNumber());
    }); // test
  }); // group
}
