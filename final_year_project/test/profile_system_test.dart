import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:final_year_project/main.dart';
import 'package:final_year_project/screens/profile_screen.dart';
import 'package:final_year_project/screens/order_history_screen.dart';
import 'package:final_year_project/screens/edit_profile_screen.dart';
import 'package:final_year_project/screens/notifications_screen.dart';
import 'package:final_year_project/screens/settings_screen.dart';
import 'package:final_year_project/screens/help_support_screen.dart';
import 'package:final_year_project/services/auth_service.dart';
import 'package:final_year_project/services/django_auth_service.dart';
import 'package:final_year_project/services/profile_service.dart';
import 'package:final_year_project/models/user_profile.dart';

void main() {
  group('Profile System Integration Tests', () {
    late AuthService authService;
    late DjangoAuthService djangoAuthService;
    late ProfileService profileService;

    setUp(() {
      authService = AuthService();
      djangoAuthService = DjangoAuthService();
      profileService = ProfileService();
    });

    testWidgets('Profile screen shows guest state when not authenticated', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: authService),
            ChangeNotifierProvider<DjangoAuthService>.value(value: djangoAuthService),
            ChangeNotifierProvider<ProfileService>.value(value: profileService),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );

      // Verify guest profile is shown
      expect(find.text('Welcome!'), findsOneWidget);
      expect(find.text('Sign up or log in to access your profile'), findsOneWidget);
    });

    testWidgets('Profile screen shows authenticated content when logged in', (WidgetTester tester) async {
      // Mock authenticated state
      await authService.signInWithEmailAndPassword('test@example.com', 'password');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: authService),
            ChangeNotifierProvider<DjangoAuthService>.value(value: djangoAuthService),
            ChangeNotifierProvider<ProfileService>.value(value: profileService),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Verify authenticated profile elements are shown
      expect(find.text('Account Management'), findsOneWidget);
      expect(find.text('Order History'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
    });

    testWidgets('Navigation to Order History screen works', (WidgetTester tester) async {
      await authService.signInWithEmailAndPassword('test@example.com', 'password');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: authService),
            ChangeNotifierProvider<DjangoAuthService>.value(value: djangoAuthService),
            ChangeNotifierProvider<ProfileService>.value(value: profileService),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Order History
      await tester.tap(find.text('Order History'));
      await tester.pumpAndSettle();

      // Verify navigation to Order History screen
      expect(find.byType(OrderHistoryScreen), findsOneWidget);
      expect(find.text('Order History'), findsAtLeastNWidgets(1));
    });

    testWidgets('Navigation to Edit Profile screen works', (WidgetTester tester) async {
      await authService.signInWithEmailAndPassword('test@example.com', 'password');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: authService),
            ChangeNotifierProvider<DjangoAuthService>.value(value: djangoAuthService),
            ChangeNotifierProvider<ProfileService>.value(value: profileService),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Edit Profile
      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      // Verify navigation to Edit Profile screen
      expect(find.byType(EditProfileScreen), findsOneWidget);
      expect(find.text('Edit Profile'), findsAtLeastNWidgets(1));
    });

    testWidgets('Navigation to Settings screen works', (WidgetTester tester) async {
      await authService.signInWithEmailAndPassword('test@example.com', 'password');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: authService),
            ChangeNotifierProvider<DjangoAuthService>.value(value: djangoAuthService),
            ChangeNotifierProvider<ProfileService>.value(value: profileService),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Verify navigation to Settings screen
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('Settings'), findsAtLeastNWidgets(1));
    });

    testWidgets('Navigation to Help & Support screen works', (WidgetTester tester) async {
      await authService.signInWithEmailAndPassword('test@example.com', 'password');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: authService),
            ChangeNotifierProvider<DjangoAuthService>.value(value: djangoAuthService),
            ChangeNotifierProvider<ProfileService>.value(value: profileService),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Help & Support
      await tester.tap(find.text('Help & Support'));
      await tester.pumpAndSettle();

      // Verify navigation to Help & Support screen
      expect(find.byType(HelpSupportScreen), findsOneWidget);
      expect(find.text('Help & Support'), findsAtLeastNWidgets(1));
    });

    testWidgets('Profile statistics display correctly', (WidgetTester tester) async {
      await authService.signInWithEmailAndPassword('test@example.com', 'password');

      // Mock profile with statistics
      final mockProfile = UserProfile(
        id: '1',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        phone: '+1234567890',
        profilePicture: null,
        dateJoined: DateTime.now(),
        addresses: [],
        paymentMethods: [],
        settings: UserSettings(),
        stats: UserStats(
          totalOrders: 5,
          totalAddresses: 2,
          totalPaymentMethods: 3,
          totalWishlistItems: 10,
        ),
        recentOrders: [],
      );

      profileService.setProfile(mockProfile);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: authService),
            ChangeNotifierProvider<DjangoAuthService>.value(value: djangoAuthService),
            ChangeNotifierProvider<ProfileService>.value(value: profileService),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Verify statistics are displayed
      expect(find.text('5'), findsOneWidget); // Total orders
      expect(find.text('2'), findsOneWidget); // Total addresses  
      expect(find.text('3'), findsOneWidget); // Total payment methods
      expect(find.text('10'), findsOneWidget); // Total wishlist items
    });

    testWidgets('Edit Profile screen form validation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProfileService>.value(value: profileService),
          ],
          child: const MaterialApp(home: EditProfileScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Try to save with empty fields
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter your first name'), findsOneWidget);
    });

    testWidgets('Settings screen toggles work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProfileService>.value(value: profileService),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap dark mode toggle
      final darkModeSwitch = find.byType(Switch).first;
      await tester.tap(darkModeSwitch);
      await tester.pumpAndSettle();

      // Verify Save button appears after changes
      expect(find.text('Save Settings'), findsOneWidget);
    });

    testWidgets('Notifications screen displays all notification types', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProfileService>.value(value: profileService),
          ],
          child: const MaterialApp(home: NotificationsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all notification categories are present
      expect(find.text('Order Updates'), findsOneWidget);
      expect(find.text('Promotional'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('App Updates'), findsOneWidget);
    });

    testWidgets('Help & Support screen shows contact options', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HelpSupportScreen()),
      );

      await tester.pumpAndSettle();

      // Verify contact options are displayed
      expect(find.text('Quick Contact'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('Live Chat'), findsOneWidget);
      expect(find.text('Frequently Asked Questions'), findsOneWidget);
    });

    group('ProfileService Tests', () {
      test('Profile service initializes correctly', () {
        final service = ProfileService();
        expect(service.userProfile, isNull);
        expect(service.isLoading, isFalse);
        expect(service.errorMessage, isNull);
      });

      test('Profile service handles mock data correctly', () {
        final service = ProfileService();
        
        final mockProfile = UserProfile(
          id: '1',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          phone: '+1234567890',
          profilePicture: null,
          dateJoined: DateTime.now(),
          addresses: [],
          paymentMethods: [],
          settings: UserSettings(),
          stats: UserStats(),
          recentOrders: [],
        );

        service.setProfile(mockProfile);
        expect(service.userProfile, equals(mockProfile));
        expect(service.userProfile!.fullName, equals('John Doe'));
      });
    });

    group('UserProfile Model Tests', () {
      test('UserProfile model serialization works correctly', () {
        final profile = UserProfile(
          id: '1',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          phone: '+1234567890',
          profilePicture: null,
          dateJoined: DateTime.now(),
          addresses: [],
          paymentMethods: [],
          settings: UserSettings(),
          stats: UserStats(),
          recentOrders: [],
        );

        final json = profile.toJson();
        final deserializedProfile = UserProfile.fromJson(json);

        expect(deserializedProfile.id, equals(profile.id));
        expect(deserializedProfile.email, equals(profile.email));
        expect(deserializedProfile.firstName, equals(profile.firstName));
        expect(deserializedProfile.lastName, equals(profile.lastName));
        expect(deserializedProfile.fullName, equals('John Doe'));
      });

      test('UserProfile initials are calculated correctly', () {
        final profile = UserProfile(
          id: '1',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          phone: '+1234567890',
          profilePicture: null,
          dateJoined: DateTime.now(),
          addresses: [],
          paymentMethods: [],
          settings: UserSettings(),
          stats: UserStats(),
          recentOrders: [],
        );

        expect(profile.initials, equals('JD'));
      });
    });
  });
}