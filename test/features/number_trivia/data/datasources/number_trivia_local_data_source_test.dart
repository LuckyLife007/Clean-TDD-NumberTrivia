import 'dart:convert';

import 'package:clean_app/core/error/exceptions.dart';
import 'package:clean_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late NumberTriviaLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(
        sharedPreferences: mockSharedPreferences);
  }); // setUp

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture('trivia_cached.json')));

    test(
        'should return NumberTrivia from SharedPreferences when there is one in the cache',
        () async {
      // arrange
      when(() => mockSharedPreferences.getString(any()))
          .thenReturn(fixture('trivia_cached.json'));
      // act
      final result = await dataSource.getLastNumberTrivia();
      // assert
      verify(() => mockSharedPreferences.getString(cachedNumberTrivia));
      expect(result, tNumberTriviaModel);
    }); // test: should return NumberTrivia from SharedPreferences when there is one in the cache

    test('should throw a CacheException when there is not a cached value',
        () async {
      // arrange
      when(() => mockSharedPreferences.getString(any())).thenReturn(null);
      // act
      final call = dataSource.getLastNumberTrivia;
      // assert
      expect(() => call(), throwsA(isA<CacheException>()));
    }); // test: should throw a CacheException when there is not a cached value
  }); // group: getLastNumberTrivia

  group('cacheNumberTrivia', () {
    const tNumberTriviaModel =
        NumberTriviaModel(text: 'test trivia', number: 1);

    test('should call SharedPreferences to cache the data', () {
      // arrange
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((invocation) async => true);
      // act
      dataSource.cacheNumberTrivia(tNumberTriviaModel);
      // assert
      final jsonString = jsonEncode(tNumberTriviaModel);
      verify(() =>
          mockSharedPreferences.setString(cachedNumberTrivia, jsonString));
    }); // test: should call SharedPreferences to cache the data
  }); // group: cacheNumberTrivia
} // main
