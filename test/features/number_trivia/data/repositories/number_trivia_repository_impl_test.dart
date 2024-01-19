import 'package:clean_app/core/error/exceptions.dart';
import 'package:clean_app/core/error/failures.dart';
import 'package:clean_app/core/network/network_info.dart';
import 'package:clean_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_app/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:clean_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;
  const tNumber = 1;
  const tNumberTriviaModel =
      NumberTriviaModel(text: 'test trivia', number: tNumber);
  const NumberTrivia tNumberTrivia = tNumberTriviaModel;

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );

    when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
        .thenAnswer((_) async => tNumberTriviaModel);
    when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
        .thenAnswer((_) async {});
    when(() => mockRemoteDataSource.getRandomNumberTrivia())
        .thenAnswer((_) async => tNumberTriviaModel);
  });

  group('getConcreteNumberTrivia', () {
    getTrivia() => repository.getConcreteNumberTrivia(tNumber);

    runTestsOnline(() {
      test('should check if the device is online', () async {
        // act
        await getTrivia();
        // assert
        verify(() => mockNetworkInfo.isConnected);
      }); // test: should check if the device is online

      test(
          'should return remote data when the call to remote data source is successful',
          () async {
        // act
        final result = await getTrivia();
        // assert
        verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        expect(result, const Right(tNumberTrivia));
      }); // test: should return remote data when the call to remote data source is successful

      test(
          'should cache the data locally when the call to remote data source is successful',
          () async {
        // act
        await getTrivia();
        // assert
        verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verify(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      }); // test: should cache the data locally when the call to remote data source is successful

      test(
          'should return server failure when the call to remote data source is unsuccessful',
          () async {
        // arrange
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
            .thenThrow(ServerException());
        // act
        final result = await getTrivia();
        // assert
        verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, Left(ServerFailure()));
      });
    }); // group: device is online

    runTestsOffline(() {
      test(
          'should return last locally cached data when the cached data is present',
          () async {
        // arrange
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        final result = await getTrivia();
        // assert
        verify(() => mockLocalDataSource.getLastNumberTrivia());
        expect(result, const Right(tNumberTriviaModel));
      }); // test: should return last locally cached data when the cached data is present

      test('should return CacheFailure when there is no cached data present',
          () async {
        // arrange
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());
        // act
        final result = await getTrivia();
        // assert
        verify(() => mockLocalDataSource.getLastNumberTrivia());
        expect(result, Left(CacheFailure()));
      }); // test: should return CacheFailure when there is no cached data present
    }); // group: device is offline
  }); // group: getConcreteNumberTrivia

  group('getRandomNumberTrivia', () {
    getTrivia() => repository.getRandomNumberTrivia();

    runTestsOnline(() {
      test('should check if the device is online', () async {
        // act
        await getTrivia();
        // assert
        verify(() => mockNetworkInfo.isConnected);
      }); // test: should check if the device is online

      test(
          'should return remote data when the call to remote data source is successful',
          () async {
        // act
        final result = await getTrivia();
        // assert
        verify(() => mockRemoteDataSource.getRandomNumberTrivia());
        expect(result, const Right(tNumberTrivia));
      }); // test: should return remote data when the call to remote data source is successful

      test(
          'should cache the data locally when the call to remote data source is successful',
          () async {
        // act
        await getTrivia();
        // assert
        verify(() => mockRemoteDataSource.getRandomNumberTrivia());
        verify(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      }); // test: should cache the data locally when the call to remote data source is successful

      test(
          'should return server failure when the call to remote data source is unsuccessful',
          () async {
        // arrange
        when(() => mockRemoteDataSource.getRandomNumberTrivia())
            .thenThrow(ServerException());
        // act
        final result = await getTrivia();
        // assert
        verify(() => mockRemoteDataSource.getRandomNumberTrivia());
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, Left(ServerFailure()));
      }); // test: should return server failure when the call to remote data source is unsuccessful
    }); // group: device is online

    runTestsOffline(() {
      test(
          'should return last locally cached data when the cached data is present',
          () async {
        // arrange
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        final result = await getTrivia();
        // assert
        verify(() => mockLocalDataSource.getLastNumberTrivia());
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, const Right(tNumberTrivia));
      }); // test: should return last locally cached data when the cached data is present

      test('should return CacheFailure when there is no cached data present',
          () async {
        // arrange
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());
        // act
        final result = await getTrivia();
        // assert
        expect(result, Left(CacheFailure()));
        verify(() => mockLocalDataSource.getLastNumberTrivia());
        verifyZeroInteractions(mockRemoteDataSource);
      }); // test: should return CacheFailure when there is no cached data present
    }); // group: device is offline
  }); // group: getRandomNumberTrivia
}
