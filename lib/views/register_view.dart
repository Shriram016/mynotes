import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/constants/routes.dart';
import 'package:flutter_project/services/auth/auth_exceptions.dart';
import 'package:flutter_project/services/auth/auth_service.dart';
import 'package:flutter_project/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_project/services/auth/bloc/auth_event.dart';
import 'package:flutter_project/services/auth/bloc/auth_state.dart';
import 'package:flutter_project/utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, 'Weak Password');
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(context, 'Email Is Already In Use');
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, 'Invalid Email Address');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Failed To Register');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reigster Page'),
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
                onPressed: () async {
                  // Initialize Firebase App Before Calling it.

                  final email = _email.text;
                  final password = _password.text;
                  context
                      .read<AuthBloc>()
                      .add(AuthEventRegister(email, password));
                  // try {
                  //   await AuthService.firebase().createUser(
                  //     email: email,
                  //     password: password,
                  //   );
                  //   await AuthService.firebase().sendEmailVerification();
                  //   await Navigator.of(context).pushNamed(verifyEmailRoute);
                  // } on WeakPasswordAuthException {
                  //   await showErrorDialog(
                  //     context,
                  //     'Weak Password',
                  //   );
                  // } on EmailAlreadyInUseAuthException {
                  //   await showErrorDialog(
                  //     context,
                  //     'Email is already in USE',
                  //   );
                  // } on InvalidEmailAuthException {
                  //   await showErrorDialog(
                  //     context,
                  //     'This is an Invalid Email Address',
                  //   );
                  // } on GenericAuthException {
                  //   await showErrorDialog(
                  //     context,
                  //     "Error :Some ERROR OCCURRED",
                  //   );
                  // }
                },
                child: const Text('Register')),
            TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                  // Navigator.of(context) .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                },
                child: const Text('Already Registered? Login Here'))
          ],
        ),
      ),
    );
  }
}
