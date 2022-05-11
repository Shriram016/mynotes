import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/constants/routes.dart';
import 'package:flutter_project/services/auth/auth_exceptions.dart';
import 'package:flutter_project/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_project/services/auth/bloc/auth_event.dart';
import 'package:flutter_project/services/auth/bloc/auth_state.dart';
import 'package:flutter_project/utilities/dialogs/error_dialog.dart';

import 'dart:developer' as logger show log;

import 'package:flutter_project/utilities/dialogs/loading_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(context, 'User Not Found');
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, 'Wrong Credentials');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication Error');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login Page'),
        ),
        body: Column(
          children: [
            TextField(
              controller: _email,
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.emailAddress,
              decoration:
                  const InputDecoration(hintText: 'Enter your mail Address'),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              decoration:
                  const InputDecoration(hintText: 'Enter your Password'),
            ),
            TextButton(
              child: const Text('Login'),
              onPressed: () async {
                // Initialize Firebase App Before Calling it.

                final email = _email.text;
                final password = _password.text;
                context.read<AuthBloc>().add(AuthEventLogIn(email, password));
                // try {

                // await AuthService.firebase().logIn(
                //   email: email,
                //   password: password,
                // );
                // final user = AuthService.firebase().currentUser;
                // // assert(user != null, 'USer is not Null');
                // if (user?.isEmailVerified ?? false) {
                //   await Navigator.of(context)
                //       .pushNamedAndRemoveUntil(notesRoute, (route) => false);
                // } else {
                //   await Navigator.pushNamedAndRemoveUntil(
                //       context, verifyEmailRoute, (route) => false);
                // }
                // } on UserNotFoundAuthException {
                //   await showErrorDialog(
                //     context,
                //     'User Not Found',
                //   );
                // } on WrongPasswordAuthException {
                //   await showErrorDialog(
                //     context,
                //     'Wrong Password',
                //   );
                // } on GenericAuthException catch (e) {
                // logger.log(e.toString());
                // await showErrorDialog(
                //   context,
                //   'Error : Some Error Occurred on Authentication',
                // );
                // }
              },
            ),
            TextButton(
                onPressed: () {
                  // Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
                  context.read<AuthBloc>().add(const AuthEventShouldRegister());
                },
                child: const Text('Click here to Register as New User'))
          ],
        ),
      ),
    );
  }
}
