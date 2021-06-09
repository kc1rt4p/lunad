import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lunad/data/models/delivery_information.dart';
import 'package:lunad/data/models/consumer_request.dart';
import 'package:lunad/repositories/request_repository.dart';
import 'package:lunad/screens/consumer/bloc/consumer_request_bloc.dart';
import 'package:lunad/screens/consumer/widgets/filled_dropdown_button.dart';
import 'package:lunad/screens/consumer/widgets/request_created.dart';
import 'package:lunad/screens/consumer/widgets/loading.dart';
import 'package:lunad/widgets/filled_button.dart';
import 'package:lunad/widgets/modal_text_field.dart';

class DeliveryInformationScreen extends StatefulWidget {
  final ConsumerRequest consumerRequest;

  const DeliveryInformationScreen({Key key, this.consumerRequest})
      : super(key: key);

  @override
  _DeliveryInformationScreenState createState() =>
      _DeliveryInformationScreenState();
}

class _DeliveryInformationScreenState extends State<DeliveryInformationScreen> {
  final TextEditingController _receiverNameController = TextEditingController();

  final TextEditingController _receiverPhoneNumberController =
      TextEditingController();

  final TextEditingController _itemDescriptionController =
      TextEditingController();

  final TextEditingController _itemDeclaredValueController =
      TextEditingController();

  final TextEditingController _deliveryRemarksController =
      TextEditingController();

  var formKey = GlobalKey<FormState>();
  String paymentFrom = 'sender';

  ConsumerRequest _consumerRequest;

  double totalDistance = 0;

  double deliveryFee = 0;

  double serviceFee = 59;

  @override
  void initState() {
    super.initState();
    _consumerRequest = widget.consumerRequest;
    _computeDistance();
    _computeDeliveryFee();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: true,
          title: Text('Padeliver Information'),
        ),
        body: BlocProvider<ConsumerRequestBloc>(
          create: (context) => ConsumerRequestBloc(),
          child: BlocListener<ConsumerRequestBloc, ConsumerRequestState>(
            listener: (context, state) {
              // listen here for state changes
            },
            child: BlocBuilder<ConsumerRequestBloc, ConsumerRequestState>(
              builder: (context, state) {
                if (state is CreatingRequest)
                  return buildLoading(context, screenHeight, screenWidth);

                if (state is CreatedRequest)
                  return buildRequestCreated(
                      context, screenHeight, screenWidth);

                return buildInitial(context);
              },
            ),
          ),
        ));
  }

  _computeDistance() {
    totalDistance = Geolocator.distanceBetween(
          _consumerRequest.pickUpLatLng[0],
          _consumerRequest.pickUpLatLng[1],
          _consumerRequest.dropOffLatLng[0],
          _consumerRequest.dropOffLatLng[1],
        ) /
        1000;
  }

  _computeDeliveryFee() {
    // deliveryFee += 50;

    // if (totalDistance > 1) {
    //   deliveryFee += (totalDistance - 1) * 5;
    // }

    deliveryFee += totalDistance * 15;
  }

  buildInitial(BuildContext context) {
    return Container(
      color: Colors.red.shade600,
      padding: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 20.0,
      ),
      child: Column(
        children: [
          Expanded(
            child: Form(
              key: formKey,
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    buildFilledDropDown(
                      labelText: 'Payment From',
                      value: paymentFrom,
                      items: [
                        DropdownMenuItem(
                          child: Text('Sender'),
                          value: 'sender',
                        ),
                        DropdownMenuItem(
                          child: Text('Receiver'),
                          value: 'receiver',
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          paymentFrom = val;
                        });
                      },
                    ),
                    SizedBox(height: 15.0),
                    buildModalTextField(
                      controller: _receiverNameController,
                      labelText: 'Receiver Name',
                      hintText: 'Enter receiver\'s name',
                      validator: (val) {
                        if (val.trim().isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15.0),
                    buildModalTextField(
                      controller: _receiverPhoneNumberController,
                      labelText: 'Receiver\'s Contact Number',
                      hintText: 'Enter receiver\'s phone number',
                      keyboardType: TextInputType.phone,
                      validator: (val) {
                        if (val.trim().isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15.0),
                    buildModalTextField(
                      controller: _itemDescriptionController,
                      labelText: 'Item Description',
                      hintText: 'Ex. food, documents, gadgets etc',
                      validator: (val) {
                        if (val.trim().isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15.0),
                    buildModalTextField(
                      controller: _itemDeclaredValueController,
                      labelText: 'Item Declared Value (₱)',
                      keyboardType: TextInputType.number,
                      hintText: 'Enter what you think your item\'s worth',
                      validator: (val) {
                        if (val.trim().isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15.0),
                    buildModalTextField(
                      controller: _deliveryRemarksController,
                      labelText: 'Remarks',
                      hintText: 'Additional instructions for rider',
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'Delivery Fee',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '₱ ${deliveryFee.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Service Fee',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '₱ ${serviceFee.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            children: [
                              Text(
                                'Total Amount',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '₱ ${(serviceFee + deliveryFee).toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    buildFilledButton(
                      labelColor: Colors.red.shade600,
                      label: 'Submit',
                      onPressed: () => _onSubmitTapped(context),
                    ),
                    buildFilledButton(
                      labelColor: Colors.black,
                      label: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _onSubmitTapped(BuildContext context) {
    final _consumerRequestBloc = BlocProvider.of<ConsumerRequestBloc>(context);

    if (!formKey.currentState.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Fill up the delivery information',
          style: TextStyle(
            color: Colors.red,
          ),
        ),
        backgroundColor: Colors.white,
      ));
      return;
    }

    final ConsumerRequest consumerRequest = widget.consumerRequest;

    final deliveryInformation = DeliveryInformation(
      receiverName: _receiverNameController.text.trim(),
      receiverPhoneNumber: _receiverPhoneNumberController.text.trim(),
      itemDescription: _itemDescriptionController.text.trim(),
      itemDeclaredValue: double.parse(_itemDeclaredValueController.text.trim()),
      deliveryRemarks: _deliveryRemarksController.text.trim(),
      paymentFrom: paymentFrom,
      deliveryFee: deliveryFee,
      serviceFee: serviceFee,
      totalAmount: deliveryFee + serviceFee,
    );

    _consumerRequestBloc.add(CreateDeliveryRequest(
      consumerRequest: consumerRequest,
      deliveryInformation: deliveryInformation,
    ));
  }
}
