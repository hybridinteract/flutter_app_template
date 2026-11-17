import 'package:app_template/features/auth/controllers/auth_bloc.dart';
import 'package:app_template/features/auth/controllers/auth_event.dart';
import 'package:app_template/features/auth/controllers/auth_state.dart';
import 'package:app_template/features/auth/models/user_model.dart';
import 'package:app_template/features/auth/views/widgets/permission_guard.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget createWidgetUnderTest(String permission) {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: Scaffold(
          body: PermissionGuard(
            permission: permission,
            fallback: const Text('Access Denied'),
            child: const Text('Admin Panel Content'),
          ),
        ),
      ),
    );
  }

  testWidgets('renders child when user has required permission', (
    tester,
  ) async {
    const user = UserModel(
      id: '1',
      name: 'Admin',
      email: 'admin@example.com',
      roles: ['admin'],
      permissions: ['reports:read_all'],
    );

    when(() => mockAuthBloc.state).thenReturn(const AuthSuccess(user: user));

    await tester.pumpWidget(createWidgetUnderTest('reports:read_all'));

    expect(find.text('Admin Panel Content'), findsOneWidget);
    expect(find.text('Access Denied'), findsNothing);
  });

  testWidgets('renders fallback when user lacks required permission', (
    tester,
  ) async {
    const user = UserModel(
      id: '2',
      name: 'Member',
      email: 'member@example.com',
      roles: ['member'],
      permissions: ['reports:read_own'],
    );

    when(() => mockAuthBloc.state).thenReturn(const AuthSuccess(user: user));

    await tester.pumpWidget(createWidgetUnderTest('reports:read_all'));

    expect(find.text('Admin Panel Content'), findsNothing);
    expect(find.text('Access Denied'), findsOneWidget);
  });

  testWidgets(
    'renders child when user is developer_admin regardless of permissions',
    (tester) async {
      const devAdmin = UserModel(
        id: '3',
        name: 'Dev Admin',
        email: 'dev@example.com',
        roles: ['developer_admin'],
        permissions: [],
      );

      when(() => mockAuthBloc.state)
          .thenReturn(const AuthSuccess(user: devAdmin));

      await tester.pumpWidget(createWidgetUnderTest('any:permission:string'));

      expect(find.text('Admin Panel Content'), findsOneWidget);
      expect(find.text('Access Denied'), findsNothing);
    },
  );
}
