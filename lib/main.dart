import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/auth_service.dart';

// Estado global
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final userState = ValueNotifier<Map<String, dynamic>>({});

// Función global para actualizar usuario
Future<void> updateUserData() async {
  try {
    final authService = AuthService();
    final userData = await authService.getUserProfile();
    userState.value = {...userState.value, ...userData};
    
    // Forzar rebuild de la UI actual
    if (navigatorKey.currentContext != null) {
      Future.microtask(() {
        if (navigatorKey.currentContext != null) {
          (navigatorKey.currentContext! as Element).markNeedsBuild();
        }
      });
    }
  } catch (e) {
    debugPrint('Error actualizando datos del usuario: $e');
  }
}

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint(details.toString());
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,  // Añadimos la key del navigator
      debugShowCheckedModeBanner: false,
      title: 'Soowe',
      locale: const Locale('es', ''),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('es', ''),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90E2),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        // Envolvemos todas las rutas con el estado global
        Widget page;
        switch (settings.name) {
          case '/login':
            page = const LoginScreen();
            break;
          case '/home':
            page = const HomeScreen();
            break;
          default:
            page = const LoginScreen();
        }

        // Envolvemos la página con el estado
        return MaterialPageRoute(
          builder: (context) => _StateWrapper(child: page),
          settings: settings,
        );
      },
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}

// Wrapper que proporciona el estado a todas las pantallas
class _StateWrapper extends StatelessWidget {
  final Widget child;

  const _StateWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, dynamic>>(
      valueListenable: userState,
      builder: (context, userData, _) => child,
    );
  }
}

// Extensión para acceder a los datos del usuario desde cualquier lugar
extension GlobalUserData on BuildContext {
  Map<String, dynamic> get userData => userState.value;
  
  String get userName => '${userData['nombre'] ?? ''} ${userData['apellido'] ?? ''}'.trim();
  
  String get userPhone {
    final phone = userData['telefono'] ?? '';
    if (phone.isEmpty) return '';
    
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length != 10) return phone;
    
    return '(${cleaned.substring(0, 3)}) - ${cleaned.substring(3, 6)} - ${cleaned.substring(6, 10)}';
  }
}