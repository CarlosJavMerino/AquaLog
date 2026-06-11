import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aqualog/dives/bloc/logbook_bloc.dart';
import 'package:aqualog/dives/bloc/logbook_event.dart';
import 'package:aqualog/dives/bloc/logbook_state.dart';
import 'package:aqualog/dives/repository/dive_repository.dart';
import 'package:aqualog/dives/models/dive_model.dart';

// Mocks
class MockDiveRepository extends Mock implements DiveRepository {}
class FakeDive extends Fake implements Dive {} // Un objeto genérico

void main() {
  group('LogbookBloc Tests', () {
    late MockDiveRepository diveRepository;
    late LogbookBloc logbookBloc;

    // Una lista de inmersiones falsa para probar
    final mockDives = [
      Dive(
        id: '1',
        userId: 'user1',
        place: 'Cabo de Palos',
        depth: 20,
        time: 45,
        date: DateTime(2023),
      ),
    ];

    setUpAll(() {
      // Registrar fallbacks para mocktail
      registerFallbackValue(FakeDive());
    });

    setUp(() {
      diveRepository = MockDiveRepository();
      logbookBloc = LogbookBloc(diveRepository: diveRepository);
    });

    tearDown(() {
      logbookBloc.close();
    });

    test('El estado inicial es status.initial', () {
      expect(logbookBloc.state.status, LogbookStatus.initial);
      expect(logbookBloc.state.dives, isEmpty);
    });

    blocTest<LogbookBloc, LogbookState>(
      'Emite [loading, success] cuando se suscribe y recibe datos',
      build: () {
        // Simulamos que Firestore nos devuelve nuestra lista falsa
        when(() => diveRepository.getDives()).thenAnswer((_) => Stream.value(mockDives));
        return logbookBloc;
      },
      act: (bloc) => bloc.add(const LogbookSubscriptionRequested()),
      expect: () => [
        const LogbookState(status: LogbookStatus.loading),
        LogbookState(status: LogbookStatus.success, dives: mockDives),
      ],
    );

    blocTest<LogbookBloc, LogbookState>(
      'Llama al repositorio para borrar cuando se envía LogbookDiveDeleted',
      build: () {
        // Simulamos que el borrado fue exitoso
        when(() => diveRepository.deleteDive(any())).thenAnswer((_) async {});
        return logbookBloc;
      },
      act: (bloc) => bloc.add(const LogbookDiveDeleted('1')),
      verify: (_) {
        // Verificamos que se ordenó borrar el ID '1'
        verify(() => diveRepository.deleteDive('1')).called(1);
      },
    );
  });
}