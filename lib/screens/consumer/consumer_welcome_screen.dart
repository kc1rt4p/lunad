import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lunad/data/models/consumer_request.dart';
import 'package:lunad/data/models/user.dart';
import 'package:lunad/screens/consumer/bloc/booking_info_bloc.dart';
import 'package:lunad/screens/consumer/bloc/consumer_request_bloc.dart';
import 'package:lunad/screens/consumer/consumer_bookings_screen.dart';
import 'package:lunad/screens/consumer/consumer_history_screen.dart';
import 'package:lunad/screens/consumer/consumer_home_screen.dart';

class ConsumerWelcomeScreen extends StatefulWidget {
  final User user;

  const ConsumerWelcomeScreen({this.user});

  @override
  _ConsumerWelcomeScreenState createState() => _ConsumerWelcomeScreenState();
}

class _ConsumerWelcomeScreenState extends State<ConsumerWelcomeScreen> {
  int _selectedPageIndex = 0;
  PageController _pageController = PageController();
  User _user;

  @override
  void initState() {
    _user = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pageViewItems = [
      ConsumerHomeScreen(
        user: _user,
      ),
      ConsumerBookingsScreen(
        user: _user,
      ),
      ConsumerHistoryScreen(),
    ];

    return Scaffold(
      body: BlocProvider<ConsumerRequestBloc>(
        create: (context) => ConsumerRequestBloc(),
        child: BlocListener<ConsumerRequestBloc, ConsumerRequestState>(
          listener: (context, state) {
            //
          },
          child: PageView(
            controller: _pageController,
            children: pageViewItems,
            onPageChanged: _onPageChanged,
            physics: NeverScrollableScrollPhysics(),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.listAlt),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }

  _onPageChanged(int index) {
    setState(() {
      this._selectedPageIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }
}
