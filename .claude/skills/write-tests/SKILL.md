---
name: write-tests
description: Write the minimum tests for a logic change (BLoC main event, and repository/model/form/core only where they hold logic) under test/, mirroring lib/, with bloc_test and mocktail.
---
# Workflow: Write Tests

What to test, the budget, and how to run cheaply: `.claude/rules/testing.md`. Write only what it lists; if the change holds no logic, write nothing.

## BLoC
- `class MockXRepository extends Mock implements XRepository {}` (mock the contract).
- Main event only: `[Loading, Success]`, and with the repository throwing a `Failure`, `[Loading, Failure(message)]`. Use `seed:` to start from a given state.
- Mocking `AuthRepository`? Stub `sessionExpired` in `setUp` (`thenAnswer((_) => const Stream.empty())`), because `AuthBloc` subscribes in its constructor.
```dart
blocTest<ProductBloc, ProductState>(
  'emits [ProductLoading, ProductFailure] when loading fails',
  build: () {
    // Throw a Failure (what the repository contract promises), never a raw exception.
    when(() => repository.getProducts()).thenThrow(const ServerFailure(message: 'Server error'));
    return ProductBloc(repository);
  },
  act: (bloc) => bloc.add(const ProductsRequested()),
  expect: () => [const ProductLoading(), const ProductFailure('Server error')],
);
```

## Repository (only status → Failure mapping or storage writes)
Mock the service and storage; assert the specific `Failure` (`throwsA(isA<XFailure>())`) or the write (`verify(...).called(1)`).

## Form
Wrap in `BlocProvider<XBloc>.value(value: mockBloc)` with `class MockXBloc extends MockBloc<XEvent, XState> implements XBloc {}`. Submit empty → error shown, `verifyNever(() => bloc.add(any()))`; submit valid → `verify(() => bloc.add(const XRequested(...))).called(1)`.

## Verify
`flutter test <touched files> -r failures-only 2>&1 | tail -5`. The full suite runs once in code-quality-check.
