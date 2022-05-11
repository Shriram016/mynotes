import 'package:bloc/bloc.dart';
import 'package:flutter_project/services/auth/auth_provider.dart';
import 'package:flutter_project/services/auth/bloc/auth_event.dart';
import 'package:flutter_project/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialized()) {
    // Send Email Verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state); //Remains in the Same Screen
    });
    // Register User
    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(email: email, password: password);
        await provider.sendEmailVerification();
        emit(const AuthStateNeedsVerification());
      } on Exception catch (e) {
        emit(AuthStateRegistering(e));
      }
    });
    // Initialize Event
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } else if (user.isEmailVerified == false) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });
    // Login Event
    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthStateLoggedOut(exception: null, isLoading: true));
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(email: email, password: password);
        if (!user.isEmailVerified) {
          emit(const AuthStateLoggedOut(
              exception: null, isLoading: false)); //disables Loading Screen
          emit(const AuthStateNeedsVerification());
        } else {
          emit(const AuthStateLoggedOut(
              exception: null, isLoading: false)); //disables Loading Screen
          emit(AuthStateLoggedIn(user));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
    // LogOut Event
    on<AuthEventLogOut>((event, emit) async {
      try {
        // emit(const AuthStateLoading());
        await provider.logOut();
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
  }
}
