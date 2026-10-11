import 'package:firebase_task_manager/app.dart';
import 'package:firebase_task_manager/models/task_model.dart';
import 'package:firebase_task_manager/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sign up screen validates email and password', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.ensureVisible(find.text('Sign Up'));
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsNWidgets(2));
    expect(find.byType(TextFormField), findsNWidgets(2));

    final createAccountButton = find.widgetWithText(
      ElevatedButton,
      'Create Account',
    );
    await tester.ensureVisible(createAccountButton);
    await tester.tap(createAccountButton);
    await tester.pump();
    expect(find.text('Enter your email address'), findsOneWidget);
    expect(find.text('Enter a password'), findsOneWidget);
  });

  testWidgets('shows the splash screen and navigates to the login screen', (
    tester,
  ) async {
    await tester.pumpWidget(const FirebaseTaskManager());
    expect(find.text('Firebase Task Manager'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to your Firebase Task Manager'), findsOneWidget);
  });

  testWidgets('tapping sign in navigates to the task list screen', (
    tester,
  ) async {
    await tester.pumpWidget(const FirebaseTaskManager());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('4 TOTAL'), findsOneWidget);
  });

  testWidgets('completed task title is struck through and marked done', (
    tester,
  ) async {
    await tester.pumpWidget(const FirebaseTaskManager());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpAndSettle();

    final title = tester.widget<Text>(find.text('Practice Firestore CRUD'));
    expect(title.style?.decoration, TextDecoration.lineThrough);
    expect(find.text('Done'), findsNWidgets(4));
  });

  testWidgets('tapping new task opens the form and adds a task', (
    tester,
  ) async {
    await tester.pumpWidget(const FirebaseTaskManager());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New Task'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Deploy app');
    await tester.ensureVisible(find.text('Save Task'));
    await tester.tap(find.text('Save Task'));
    await tester.pumpAndSettle();

    expect(find.text('Deploy app'), findsOneWidget);
  });

  test('generated task ids stay unique across rapid creation', () {
    final tasks = List.generate(
      25,
      (index) => TaskModel(
        title: 'Task $index',
        notes: 'Notes $index',
        dueDate: DateTime(2026, 10, index + 1),
        priority: TaskPriority.medium,
      ),
    );

    expect(tasks.map((task) => task.id).toSet().length, 25);
  });
}
