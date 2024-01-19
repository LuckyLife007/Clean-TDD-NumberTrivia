import 'package:clean_app/core/error/exceptions.dart';
import 'package:clean_app/core/error/failures.dart';
import 'package:clean_app/core/network/network_info.dart';
import 'package:clean_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_app/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:dartz/dartz.dart';

typedef _Chooser = Future<NumberTriviaModel> Function();

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final NumberTriviaRemoteDataSource remoteDataSource;
  final NumberTriviaLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  NumberTriviaRepositoryImpl(
      {required this.remoteDataSource,
      required this.localDataSource,
      required this.networkInfo});

  Future<Either<Failure, NumberTrivia>> _getTrivia(
      _Chooser getRemoteTrivia) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTrivia = await getRemoteTrivia();
        localDataSource.cacheNumberTrivia(remoteTrivia);
        return Right(remoteTrivia);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localTrivia = await localDataSource.getLastNumberTrivia();
        return Right(localTrivia);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(
      int number) async {
    return await _getTrivia(
        () => remoteDataSource.getConcreteNumberTrivia(number));
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async {
    return await _getTrivia(() => remoteDataSource.getRandomNumberTrivia());
  }
}
