import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lunad/data/bloc/auth/auth_bloc.dart';
import 'package:lunad/data/models/user.dart';
import 'package:lunad/screens/consumer/create_booking_screen.dart';
import 'package:lunad/widgets/lunad_logo.dart';
import 'package:lunad/widgets/styled_icon_button.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:lunad/screens/profile_screen.dart';

class ConsumerHomeScreen extends StatefulWidget {
  final User user;

  const ConsumerHomeScreen({Key key, this.user}) : super(key: key);

  @override
  _ConsumerHomeScreenState createState() => _ConsumerHomeScreenState();
}

class _ConsumerHomeScreenState extends State<ConsumerHomeScreen> {
  User _user;

  @override
  void initState() {
    _user = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      height: screenHeight,
      width: screenWidth,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Container(
                color: Colors.red.shade600,
                height: screenHeight * 0.30,
                width: screenWidth,
                padding: EdgeInsets.fromLTRB(10.0, statusBarHeight, 10.0, 10.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: screenWidth * .6,
                        child: Image.asset(
                          'assets/images/logo_white.png',
                          color: Colors.black.withOpacity(0.09),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: screenWidth * .5,
                        child: LunadLogo(),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      left: 10,
                      child: buildIconButton(
                        onTap: () => _handleLogOut(context),
                        icon: FontAwesomeIcons.signOutAlt,
                        tooltip: 'Menu',
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 10,
                      child: buildIconButton(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                              user: _user,
                            ),
                          ),
                        ),
                        icon: FontAwesomeIcons.user,
                        tooltip: 'Profile',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.0),
              Expanded(
                child: Container(
                  color: Colors.red.shade600,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Hello, ${_user.firstName} ${_user.lastName}',
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
                                'How can we help you today?',
                                textScaleFactor: 1.6,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          padding: EdgeInsets.only(top: 20.0),
                          children: [
                            buildServiceItem(
                              title: 'Padeliver',
                              subTitle:
                                  'Get your parcels picked up and delivered to your desired location',
                              icon: FaIcon(
                                FontAwesomeIcons.shippingFast,
                                color: Colors.white,
                                size: 30.0,
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CreateBookingScreen(
                                      requestType: 'delivery',
                                      user: _user,
                                    ),
                                  ),
                                );
                              },
                            ),
                            buildServiceItem(
                                title: 'Pasabuy',
                                subTitle:
                                    'We will run your errands for you: shopping, groceries, food delivery and etc.',
                                icon: FaIcon(
                                  FontAwesomeIcons.shoppingBasket,
                                  color: Colors.white,
                                  size: 30.0,
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => CreateBookingScreen(
                                        requestType: 'errand',
                                        user: _user,
                                      ),
                                    ),
                                  );
                                }),
                            // buildServiceItem(
                            //     title: 'Transport Service',
                            //     subTitle:
                            //         'We will give you a ride to get you where you want to go',
                            //     icon: FaIcon(
                            //       FontAwesomeIcons.taxi,
                            //       color: Colors.white,
                            //       size: 30.0,
                            //     ),
                            //     onTap: () {
                            //       Navigator.of(context).push(
                            //         MaterialPageRoute(
                            //           builder: (context) =>
                            //               CreateBookingScreen(
                            //             requestType: 'transport',
                            //           ),
                            //         ),
                            //       );
                            //     }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

_handleLogOut(BuildContext context) {
  Alert(
    context: context,
    type: AlertType.warning,
    desc: 'Are you sure you want to logout?',
    title: 'Confirm Logout',
    style: AlertStyle(
      isCloseButton: false,
      backgroundColor: Colors.red.shade600,
      titleStyle: TextStyle(
        color: Colors.white,
      ),
      descStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.normal,
        fontSize: 14.0,
      ),
    ),
    buttons: [
      DialogButton(
        child: Text(
          'Yes',
        ),
        onPressed: () {
          BlocProvider.of<AuthBloc>(context).add(SignOutUser());
          Navigator.of(context).pop();
        },
      ),
      DialogButton(
        child: Text(
          'No',
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  ).show();
}

GestureDetector buildServiceItem({
  String title,
  String subTitle,
  Widget icon,
  Function onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white30,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60.0,
            padding: const EdgeInsets.only(left: 5.0, right: 10.0),
            child: icon,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    fontSize: 20.0,
                  ),
                ),
                Text(
                  subTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 50.0,
            padding: EdgeInsets.only(left: 10.0),
            child: FaIcon(
              FontAwesomeIcons.arrowRight,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}
