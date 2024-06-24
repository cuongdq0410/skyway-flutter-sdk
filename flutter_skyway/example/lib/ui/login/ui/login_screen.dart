import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skyway_example/ui/base/base_screen.dart';
import 'package:flutter_skyway_example/ui/login/cubit/login_cubit.dart';
import 'package:flutter_skyway_example/ui/widget/common_button.dart';
import 'package:flutter_skyway_example/ui/widget/route_define.dart';
import 'package:form_field_validator/form_field_validator.dart';

class LoginScreen extends BaseScreen {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends BaseState<LoginScreen, LoginCubit> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  @override
  Widget buildContent(BuildContext context) {
    return BlocListener(
      bloc: cubit,
      listener: (context, state) {
        if (state is LoginSuccessState) {
          pushScreen(RouteDefine.homeScreen.name);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 60),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Text(
                  'VOICE CHAT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.blue,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Form(
                  key: _formkey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextFormField(
                          controller: _emailController,
                          validator: MultiValidator(
                            [
                              RequiredValidator(
                                errorText: 'Enter email address',
                              ),
                              EmailValidator(
                                  errorText: 'Please correct email filled'),
                            ],
                          ).call,
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            errorStyle: TextStyle(fontSize: 18),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.all(
                                Radius.circular(9),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextFormField(
                          controller: _passController,
                          validator: MultiValidator(
                            [
                              RequiredValidator(
                                  errorText: 'Please enter Password'),
                              MinLengthValidator(8,
                                  errorText: 'Password must be atlist 8 digit'),
                            ],
                          ).call,
                          decoration: const InputDecoration(
                            hintText: 'Password',
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.key),
                            errorStyle: TextStyle(fontSize: 18),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.all(
                                Radius.circular(9),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      CommonButton(
                        onTap: () {
                          final isValid =
                              _formkey.currentState?.validate() ?? false;
                          if (!isValid) return;
                          cubit.login(
                            _emailController.text,
                            _passController.text,
                          );
                        },
                        text: 'LOGIN',
                        backgroundColor: Colors.blue,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  afterBuild() {}
}
