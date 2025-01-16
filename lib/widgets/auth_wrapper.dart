import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/leaders/leader_dashboard.dart';
import '../screens/login/login_screen.dart';
import '../screens/members/member_dashboard.dart';
import '../screens/parents/parent_dashboard.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        switch (authProvider.status) {
          case AuthStatus.initial:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );

          case AuthStatus.authenticated:
            switch (authProvider.userRole) {
              case 'LEADER':
                return const LeaderDashboard();
              case 'MEMBER':
                return const MemberDashboard();
              case 'GUARDIAN':
                return const ParentDashboard();
              default:
                return const LoginScreen();
            }

          case AuthStatus.unauthenticated:
            return const LoginScreen();
        }
      },
    );
  }
}