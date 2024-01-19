import 'dart:convert';

import 'package:clean_app/core/error/exceptions.dart';
import 'package:clean_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri());
  });

  late NumberTriviaRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  void setUpSuccessfulHttpCall() {
    when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpUnsuccessfulHttpCall() {
    when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture('trivia.json')));
    final expectedUri = Uri.parse('http://numbersapi.com/$tNumber');
    final expectedHeaders = {'Content-Type': 'application/json'};

    test('''should perform a GET request on a URL with 
    number being the endpoint and with application/json header''', () async {
      // arrange
      setUpSuccessfulHttpCall();
      // act
      dataSource.getConcreteNumberTrivia(tNumber);
      // assert
      verify(() => mockHttpClient.get(expectedUri, headers: expectedHeaders));
    }); // test: should perform a GET request on a URL with number and application/json

    test('should return NumberTrivia when the response code is 200 (success)',
        () async {
      // arrange
      setUpSuccessfulHttpCall();
      // act
      final result = await dataSource.getConcreteNumberTrivia(tNumber);
      // assert
      expect(result, tNumberTriviaModel);
    }); // test: should return NumberTrivia when the response code is 200 (success)

    test(
        'should throw a Server Exception when the response code is 404 or other',
        () async {
      // arrange
      setUpUnsuccessfulHttpCall();
      // act
      final call = dataSource.getConcreteNumberTrivia;
      // assert
      expect(() => call(tNumber), throwsA(isA<ServerException>()));
    }); // test: should throw a Server Exception when the response code is 404 or other
  }); // group: getConcreteNumberTrivia

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture('trivia.json')));
    final expectedUri = Uri.parse('http://numbersapi.com/random');
    final expectedHeaders = {'Content-Type': 'application/json'};

    test('''should perform a GET request on a URL with 
    random being the endpoint and with application/json header''', () async {
      // arrange
      setUpSuccessfulHttpCall();
      // act
      dataSource.getRandomNumberTrivia();
      // assert
      verify(() => mockHttpClient.get(expectedUri, headers: expectedHeaders));
    }); // test: should perform a GET request on a URL with random and application/json

    test('should return NumberTrivia when the response code is 200 (success)',
        () async {
      // arrange
      setUpSuccessfulHttpCall();
      // act
      final result = await dataSource.getRandomNumberTrivia();
      // assert
      expect(result, tNumberTriviaModel);
    }); // test: should return NumberTrivia when the response code is 200 (success)

    test(
        'should throw a Server Exception when the response code is 404 or other',
        () async {
      // arrange
      setUpUnsuccessfulHttpCall();
      // act
      final call = dataSource.getRandomNumberTrivia;
      // assert
      expect(() => call(), throwsA(isA<ServerException>()));
    }); // test: should throw a Server Exception when the response code is 404 or other
  }); // group: getRandomNumberTrivia
}
