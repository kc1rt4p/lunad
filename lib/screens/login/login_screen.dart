import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:lunad/data/bloc/auth/auth_bloc.dart' as authBloc;
import 'package:lunad/data/models/user.dart';
import 'package:lunad/repositories/firebase_auth_repository.dart';
import 'package:lunad/widgets/filled_button.dart';
import 'package:lunad/widgets/filled_text_field.dart';
import 'package:lunad/widgets/lunad_logo.dart';
import 'package:lunad/dialogs/privacy_dialog.dart';

import 'bloc/login_bloc.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController phoneNumController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  TextEditingController displayNameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  DateTime lastCodeRequest;

  String loginAs = 'consumer';

  bool canVerify = false;
  bool validPhoneNumber = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final _authRepo = RepositoryProvider.of<FirebaseAuthRepo>(context);
    return Scaffold(
      body: Container(
        height: screenHeight,
        width: screenWidth,
        child: Column(
          children: [
            buildHeader(screenHeight, screenWidth),
            SizedBox(height: 3.0),
            Expanded(
              child: Container(
                color: Colors.red.shade600,
                width: double.infinity,
                child: Center(
                  child: BlocProvider<LoginBloc>(
                    create: (context) => LoginBloc(_authRepo),
                    child: BlocListener<LoginBloc, LoginState>(
                      listener: (context, state) {
                        if (state is CodeSentState) {
                          setState(() {
                            lastCodeRequest = DateTime.now();
                          });
                        }

                        if (state is AuthenticatedState) {
                          final _authBloc =
                              BlocProvider.of<authBloc.AuthBloc>(context);
                          _authBloc.add(authBloc.AuthenticateUser(state.user));
                        }

                        if (state is AccountNotFound) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              elevation: 10,
                              content: Text(
                                'Account not found - ${loginAs.toUpperCase()}',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                              backgroundColor: Colors.white,
                            ),
                          );
                        }

                        if (state is VerifyingError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              elevation: 10,
                              content: Text(
                                'Error Verifying - Invalid Code',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                              backgroundColor: Colors.white,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(18.0),
                        child: Center(
                          child: BlocBuilder<LoginBloc, LoginState>(
                            builder: (context, state) {
                              if (state is LoginInitial ||
                                  state is AccountNotFound) {
                                return getUserPhone(
                                    context, screenHeight, screenWidth);
                              }

                              if (state is CodeSentState ||
                                  state is VerifyingError) {
                                return getSmsCode(
                                    context, screenHeight, screenWidth);
                              }

                              if (state is PhoneVerified) {
                                return buildGetUserInfo(context, state.user,
                                    screenHeight, screenWidth);
                              }

                              if (state is LoginLoading) {
                                return buildLoginLoading(screenWidth);
                              }

                              return buildLoginLoading(screenWidth);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Padding buildFooter(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 50.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            color: Colors.white,
          ),
          children: [
            TextSpan(
              text: 'By creating an account, you agree to our ',
            ),
            TextSpan(
              text: 'Terms & Conditions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return PrivacyPopUpDialog(
                          mdFileName: 'terms_and_conditions.md',
                        );
                      });
                },
            ),
            TextSpan(
              text: ' and ',
              style: TextStyle(),
            ),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return PrivacyPopUpDialog(
                          mdFileName: 'privacy_policy.md',
                        );
                      });
                },
            ),
          ],
        ),
      ),
    );
  }

  buildLoginLoading(double screenWidth) {
    return SizedBox(
      height: screenWidth * .2,
      width: screenWidth * .2,
      child: CircularProgressIndicator(strokeWidth: 8.0),
    );
  }

  ListView buildGetUserInfo(BuildContext context, User user,
      double screenHeight, double screenWidth) {
    return ListView(
      shrinkWrap: true,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Introduce Yourself',
            textScaleFactor: 1,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'What should we call you?',
            textScaleFactor: 1.5,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 35.0),
        FilledTextField(
          controller: displayNameController,
          hintText: 'Nickname',
          textInputType: TextInputType.text,
          maxLines: 1,
        ),
        SizedBox(height: 10.0),
        FilledTextField(
          controller: firstNameController,
          hintText: 'First Name',
          textInputType: TextInputType.text,
          maxLines: 1,
        ),
        SizedBox(height: 10.0),
        FilledTextField(
          controller: lastNameController,
          hintText: 'Last Name',
          textInputType: TextInputType.text,
          maxLines: 1,
        ),
        SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              child: MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 10.0,
                color: Colors.white,
                textColor: Colors.black,
                child: Text(
                  'CANCEL',
                  textScaleFactor: 1.2,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                  ),
                ),
                onPressed: () => onCancelTap(context),
              ),
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: buildFilledButton(
                label: 'CREATE',
                onPressed: () => _onNextTap(context, user),
              ),
            ),
          ],
        ),
        SizedBox(height: 30.0),
        buildFooter(screenWidth, screenHeight),
      ],
    );
  }

  ListView getSmsCode(
      BuildContext context, double screenHeight, double screenWidth) {
    return ListView(
      shrinkWrap: true,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Phone Verification',
            textScaleFactor: 1,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Enter the verification code below',
            textScaleFactor: 1.5,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 35.0),
        Row(
          children: [
            Expanded(
              child: FilledTextField(
                controller: codeController,
                hintText: 'Enter the verification code',
                textInputType: TextInputType.number,
                maxLines: 1,
                onChanged: (val) {
                  setState(() {
                    canVerify = val.length == 6;
                  });
                },
              ),
            ),
            SizedBox(width: 8.0),
            Material(
              elevation: 10.0,
              borderRadius: BorderRadius.circular(10),
              child: IconButton(
                icon: FaIcon(FontAwesomeIcons.chevronRight),
                onPressed: canVerify ? () => _sendCode(context) : null,
              ),
            ),
          ],
        ),
        SizedBox(height: 25.0),
        Row(
          children: [
            Expanded(
              child: buildFilledButton(
                label: 'BACK',
                onPressed: () => _cancelVerify(context),
              ),
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: buildFilledButton(
                label: 'RESEND',
                onPressed: () => _resendCode(context),
              ),
            ),
          ],
        ),
        SizedBox(height: 30.0),
        buildFooter(screenWidth, screenHeight),
      ],
    );
  }

  ListView getUserPhone(
      BuildContext context, double screenHeight, double screenWidth) {
    return ListView(
      shrinkWrap: true,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Hello, nice to meet you!',
            textScaleFactor: 1.1,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Get moving with Lunad',
            textScaleFactor: 1.9,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 35.0),
        Row(
          children: [
            Expanded(
              child: FilledTextField(
                controller: phoneNumController,
                isPhone: true,
                hintText: 'Enter your mobile number',
                textInputType: TextInputType.phone,
                maxLines: 1,
                onChanged: (val) {
                  setState(() {
                    validPhoneNumber = val.length == 10;
                  });
                },
              ),
            ),
            SizedBox(width: 8.0),
            Material(
              elevation: 10.0,
              borderRadius: BorderRadius.circular(10),
              child: IconButton(
                icon: FaIcon(FontAwesomeIcons.chevronRight),
                onPressed: validPhoneNumber ? () => _onLoginTap(context) : null,
              ),
            ),
          ],
        ),
        SizedBox(height: 30.0),
        buildFooter(screenWidth, screenHeight),
      ],
    );
  }

  Row buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          borderRadius: BorderRadius.circular(50.0),
          color: Colors.blue,
          child: IconButton(
            icon: FaIcon(
              FontAwesomeIcons.facebookF,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ),
        SizedBox(width: 30.0),
        Material(
          borderRadius: BorderRadius.circular(50.0),
          color: Colors.white,
          child: IconButton(
            icon: FaIcon(
              FontAwesomeIcons.google,
              color: Colors.red.shade600,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  onCancelTap(BuildContext context) {
    final _loginBloc = BlocProvider.of<LoginBloc>(context);
    _loginBloc.add(LoginReset());
  }

  _onLoginTap(BuildContext context) async {
    final userType = await showMaterialModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
          color: Colors.red.shade600,
          height: 200.0,
          width: double.infinity,
          child: Column(
            children: [
              Text(
                'Which one are you?',
                textScaleFactor: 1.6,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.userAlt,
                          color: Colors.white,
                        ),
                        TextButton(
                          child: Text(
                            'CONSUMER',
                            textScaleFactor: 1.5,
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context, 'consumer'),
                        ),
                      ],
                    ),
                    Divider(color: Colors.white54),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.motorcycle,
                          color: Colors.white,
                        ),
                        TextButton(
                          child: Text(
                            'RIDER',
                            textScaleFactor: 1.5,
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context, 'rider'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    if (userType == null) return;

    setState(() {
      loginAs = userType;
    });

    final _loginBloc = BlocProvider.of<LoginBloc>(context);
    final String username = phoneNumController.text.trim();

    _loginBloc.add(SendCode(username));
  }

  _cancelVerify(BuildContext context) {
    codeController.clear();
    final _loginBloc = BlocProvider.of<LoginBloc>(context);
    _loginBloc.add(LoginReset());
  }

  _sendCode(BuildContext context) async {
    final _loginBloc = BlocProvider.of<LoginBloc>(context);
    final String smsCode = codeController.text.trim();
    _loginBloc.add(VerifyPhoneNumber(smsCode,
        loginAs)); // this event will either send back Authenticated or UnAuthenticated
  }

  _resendCode(BuildContext context) async {
    final now = DateTime.now();
    final differenceInSeconds = now.difference(lastCodeRequest).inSeconds;
    print('seconds: $differenceInSeconds');
    if (differenceInSeconds < 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 10,
          content: Text(
            'Try again after ${60 - differenceInSeconds} seconds',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          backgroundColor: Colors.black,
        ),
      );
      return;
    }

    final _loginBloc = BlocProvider.of<LoginBloc>(context);
    final String phoneNum = phoneNumController.text.trim();
    _loginBloc.add(
      ResendCode(phoneNum),
    ); // this event will either send back Authenticated or UnAuthenticated
  }

  _onNextTap(BuildContext context, User user) {
    final _loginBloc = BlocProvider.of<LoginBloc>(context);
    final newUser = User(
      displayName: displayNameController.text.trim(),
      id: user.id,
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      phoneNum: user.phoneNum,
      type: loginAs,
    );

    _loginBloc.add(CreateUser(newUser));
  }

  Container buildHeader(double screenHeight, double screenWidth) {
    return Container(
      color: Colors.red.shade600,
      width: double.infinity,
      height: screenHeight * .40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: screenWidth * .7,
              child: Image.asset(
                'assets/images/logo_white.png',
                color: Colors.black.withOpacity(0.09),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: screenWidth * .6,
              child: LunadLogo(),
            ),
          ),
        ],
      ),
    );
  }
}
