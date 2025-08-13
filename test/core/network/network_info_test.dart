import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:treatment_center/core/network/network_info.dart';

@GenerateMocks([InternetConnectionChecker])
import 'network_info_test.mocks.dart';

void main() {
  late NetworkInfoImpl networkInfo;
  late MockInternetConnectionChecker mockChecker;

  setUp(() {
    mockChecker = MockInternetConnectionChecker();
    networkInfo = NetworkInfoImpl(connectionChecker: mockChecker);
  });

  group('NetworkInfoImpl', () {
    test('implements NetworkInfo interface', () {
      expect(networkInfo, isA<NetworkInfo>());
    });

    test('injects dependency correctly', () {
      expect(networkInfo.connectionChecker, mockChecker);
    });
  });

  group('isConnected', () {
    test('returns true when connected', () async {
      // Arrange
      when(mockChecker.hasConnection).thenAnswer((_) async => true);

      // Act
      final result = await networkInfo.isConnected;

      // Assert
      expect(result, isTrue);
      verify(mockChecker.hasConnection).called(1);
    });

    test('returns false when disconnected', () async {
      // Arrange
      when(mockChecker.hasConnection).thenAnswer((_) async => false);

      // Act
      final result = await networkInfo.isConnected;

      // Assert
      expect(result, isFalse);
      verify(mockChecker.hasConnection).called(1);
    });

    test('calls checker exactly once per invocation', () async {
      // Arrange
      when(mockChecker.hasConnection).thenAnswer((_) async => true);

      // Act
      await networkInfo.isConnected;

      // Assert
      verify(mockChecker.hasConnection).called(1);
      verifyNoMoreInteractions(mockChecker);
    });

    test('handles consecutive calls with different results', () async {
      // Arrange
      var callCount = 0;
      when(mockChecker.hasConnection).thenAnswer((_) async {
        final responses = [true, false, true];
        return responses[callCount++];
      });

      // Act
      final results = [
        await networkInfo.isConnected,
        await networkInfo.isConnected,
        await networkInfo.isConnected,
      ];

      // Assert
      expect(results, [true, false, true]);
      verify(mockChecker.hasConnection).called(3);
    });
  });

  group('Exception Handling', () {
    test('propagates generic exceptions', () {
      // Arrange
      when(
        mockChecker.hasConnection,
      ).thenThrow(Exception('Network check failed'));

      // Act & Assert
      expect(() => networkInfo.isConnected, throwsA(isA<Exception>()));
    });

    test('propagates timeout exceptions', () {
      // Arrange
      when(mockChecker.hasConnection).thenThrow(
        TimeoutException('Connection timeout', Duration(seconds: 10)),
      );

      // Act & Assert
      expect(() => networkInfo.isConnected, throwsA(isA<TimeoutException>()));
    });

    test('propagates socket exceptions', () {
      // Arrange
      when(
        mockChecker.hasConnection,
      ).thenThrow(SocketException('Host lookup failed'));

      // Act & Assert
      expect(() => networkInfo.isConnected, throwsA(isA<SocketException>()));
    });
  });

  group('Concurrent Access', () {
    test('handles multiple simultaneous calls', () async {
      // Arrange
      when(mockChecker.hasConnection).thenAnswer((_) async => true);

      // Act
      final futures = List.generate(5, (_) => networkInfo.isConnected);
      final results = await Future.wait(futures);

      // Assert
      expect(results, everyElement(isTrue));
      verify(mockChecker.hasConnection).called(5);
    });

    test('handles delayed responses', () async {
      // Arrange
      when(mockChecker.hasConnection).thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 100));
        return true;
      });

      // Act
      final stopwatch = Stopwatch()..start();
      final result = await networkInfo.isConnected;
      stopwatch.stop();

      // Assert
      expect(result, isTrue);
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(90));
    });
  });

  group('Real-world Scenarios', () {
    test('simulates network state changes', () async {
      // Arrange
      var callCount = 0;
      when(mockChecker.hasConnection).thenAnswer((_) async {
        final responses = [true, false, true];
        return responses[callCount++];
      });

      // Act & Assert
      expect(await networkInfo.isConnected, isTrue);
      expect(await networkInfo.isConnected, isFalse);
      expect(await networkInfo.isConnected, isTrue);
    });

    test('handles unstable connection', () async {
      // Arrange
      var callCount = 0;
      when(mockChecker.hasConnection).thenAnswer((_) async {
        final responses = [true, false, true, false];
        return responses[callCount++];
      });

      // Act
      final states = <bool>[];
      for (int i = 0; i < 4; i++) {
        states.add(await networkInfo.isConnected);
      }

      // Assert
      expect(states, [true, false, true, false]);
    });
  });

  group('Error Recovery', () {
    test('recovers from transient errors', () async {
      // Arrange
      var callCount = 0;
      when(mockChecker.hasConnection).thenAnswer((_) async {
        if (callCount++ == 0) {
          throw Exception('Temporary failure');
        }
        return true;
      });

      // Act & Assert
      expect(() => networkInfo.isConnected, throwsException);
      expect(await networkInfo.isConnected, isTrue);
    });

    test('fails consistently for persistent errors', () async {
      // Arrange
      when(
        mockChecker.hasConnection,
      ).thenThrow(Exception('Persistent failure'));

      // Act & Assert
      for (int i = 0; i < 3; i++) {
        expect(() => networkInfo.isConnected, throwsException);
      }
    });
  });

  group('Constructor', () {
    test('creates instance with required dependency', () {
      // Arrange
      final checker = MockInternetConnectionChecker();

      // Act
      final instance = NetworkInfoImpl(connectionChecker: checker);

      // Assert
      expect(instance, isA<NetworkInfo>());
      expect(instance.connectionChecker, checker);
    });

    test('requires connectionChecker parameter', () {
      expect(
        () => NetworkInfoImpl(connectionChecker: mockChecker),
        returnsNormally,
      );
    });
  });
}
