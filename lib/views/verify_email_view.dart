import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/constants/routes.dart';
import 'package:flutter_project/services/auth/auth_service.dart';
import 'package:flutter_project/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_project/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email Page')),
      body: Column(children: [
        const Text(
            "we've sent you an email Verification. Please open that link to Verify your account"),
        const SizedBox(
          height: 20,
        ),
        const Text(
            "If you haven't received any mails yet, please click that button below"),
        TextButton(
            onPressed: () async {
              context
                  .read<AuthBloc>()
                  .add(const AuthEventSendEmailVerification());
              // await AuthService.firebase().sendEmailVerification();
            },
            child: const Text('Send Email Verification')),
        TextButton(
          onPressed: () async {
            context.read<AuthBloc>().add(const AuthEventLogOut());
            // await AuthService.firebase().logOut();
            // Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
          },
          child: const Text('Restart'),
        )
      ]),
    );
  }
}
