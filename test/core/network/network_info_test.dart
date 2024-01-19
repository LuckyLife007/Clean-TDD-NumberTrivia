import 'package:clean_app/core/network/network_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class MockInternetConnection extends Mock implements InternetConnection {}

void main() {
  late NetworkInfoImpl networkInfo;
  late MockInternetConnection mockInternetConnection;

  setUp(() {
    mockInternetConnection = MockInternetConnection();
    networkInfo = NetworkInfoImpl(mockInternetConnection);
  });

  test('should make the call to InternetConnection.hasInternetAccess',
      () async {
    // arrange
    when(() => mockInternetConnection.hasInternetAccess)
        .thenAnswer((invocation) async => true);
    // act
    final result = await networkInfo.isConnected;
    // assert
    verify(() => mockInternetConnection.hasInternetAccess);
    expect(result, true);
  });
}
