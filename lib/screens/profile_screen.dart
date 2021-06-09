import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lunad/data/models/user.dart';
import 'package:lunad/widgets/filled_button.dart';
import 'package:lunad/widgets/filled_text_field.dart';
import 'package:lunad/screens/rider/bloc/rider_bloc.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({Key key, this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User _user;
  TextEditingController displayNameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  var profileFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    _user = widget.user;
    displayNameController.text = _user.displayName;
    firstNameController.text = _user.firstName;
    lastNameController.text = _user.lastName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.red.shade600,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: BlocProvider<RiderBloc>(
        create: (context) => RiderBloc(),
        child: BlocListener<RiderBloc, RiderState>(
          listener: (context, state) {
            if (state is UpdatedRiderProfile) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  'Updated your profile successfully!',
                  style: TextStyle(
                    color: Colors.green.shade900,
                  ),
                ),
                backgroundColor: Colors.white,
              ));
            }
          },
          child: BlocBuilder<RiderBloc, RiderState>(
            builder: (context, state) {
              return buildRiderProfile(context);
            },
          ),
        ),
      ),
    );
  }

  Padding buildRiderProfile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 15.0,
      ),
      child: Form(
        key: profileFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Edit your profile the way you like it',
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 25.0),
            FilledTextField(
              controller: displayNameController,
              labelText: 'Display Name',
              validator: (val) {
                if (val.isEmpty) {
                  return 'This field is required';
                }

                return null;
              },
            ),
            SizedBox(height: 15.0),
            FilledTextField(
              controller: firstNameController,
              labelText: 'First Name',
              validator: (val) {
                if (val.isEmpty) {
                  return 'This field is required';
                }

                return null;
              },
            ),
            SizedBox(height: 15.0),
            FilledTextField(
              controller: lastNameController,
              labelText: 'Last Name',
              validator: (val) {
                if (val.isEmpty) {
                  return 'This field is required';
                }

                return null;
              },
            ),
            SizedBox(height: 20.0),
            buildFilledButton(
              label: 'UPDATE',
              onPressed: () => _updateProfile(context),
            ),
          ],
        ),
      ),
    );
  }

  _updateProfile(BuildContext context) {
    if (!profileFormKey.currentState.validate()) return;

    final newDisplayName = displayNameController.text.trim();
    final newFirstName = firstNameController.text.trim();
    final newLastName = lastNameController.text.trim();

    if (newDisplayName == _user.displayName &&
        newFirstName == _user.firstName &&
        newLastName == _user.lastName) return;

    setState(() {
      _user = User(
        id: _user.id,
        displayName: newDisplayName,
        firstName: newFirstName,
        lastName: newLastName,
      );
    });

    final updatedRider = User(
      id: _user.id,
      displayName: newDisplayName,
      firstName: newFirstName,
      lastName: newLastName,
    );

    BlocProvider.of<RiderBloc>(context).add(UpdateRiderProfile(updatedRider));
  }
}
