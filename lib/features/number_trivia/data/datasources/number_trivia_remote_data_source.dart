import 'dart:convert';

import 'package:clean_app/core/error/exceptions.dart';
import 'package:clean_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:http/http.dart' as http;

abstract class NumberTriviaRemoteDataSource {
  /// Calls the http://numbersapi.com/{number} endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number);

  /// Calls the http://numbersapi.com/random endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getRandomNumberTrivia();
}

class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  final http.Client client;

  NumberTriviaRemoteDataSourceImpl({required this.client});

  Future<NumberTriviaModel> _getTrivia(String endpoint) async {
    final expectedUri = Uri.parse('http://numbersapi.com/$endpoint');
    final expectedHeaders = {'Content-Type': 'application/json'};
    final response = await client.get(expectedUri, headers: expectedHeaders);

    if (response.statusCode == 200) {
      final triviaSample =
          NumberTriviaModel.fromJson(jsonDecode(response.body));
      return triviaSample;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) =>
      _getTrivia('$number');

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() => _getTrivia('random');
}
