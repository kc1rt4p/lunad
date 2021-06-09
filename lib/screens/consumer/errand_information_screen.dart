import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lunad/data/models/errand_information.dart';
import 'package:lunad/data/models/consumer_request.dart';
import 'package:lunad/repositories/request_repository.dart';
import 'package:lunad/screens/consumer/bloc/consumer_request_bloc.dart';
import 'package:lunad/screens/consumer/widgets/request_created.dart';
import 'package:lunad/screens/consumer/widgets/loading.dart';
import 'package:lunad/widgets/filled_button.dart';
import 'package:lunad/widgets/modal_text_field.dart';

class ErrandInformationScreen extends StatefulWidget {
  final ConsumerRequest consumerRequest;

  const ErrandInformationScreen({Key key, this.consumerRequest})
      : super(key: key);

  @override
  _ErrandInformationScreenState createState() =>
      _ErrandInformationScreenState();
}

class _ErrandInformationScreenState extends State<ErrandInformationScreen> {
  var formKey = GlobalKey<FormState>();
  ConsumerRequest _consumerRequest;

  final storeNameController = TextEditingController();
  final itemDescriptionController = TextEditingController();
  List<ErrandItem> itemsToPurchase = [];
  final estimatedPriceController = TextEditingController();
  final remarksController = TextEditingController();
  final receiverNameController = TextEditingController();
  final receiverPhoneNumberController = TextEditingController();
  final itemNameController = TextEditingController();
  final itemQtyController = TextEditingController();
  String _itemDescription;

  double serviceFee = 0;
  double errandFee = 0;
  double estimatedPrice = 0;

  @override
  void initState() {
    _consumerRequest = widget.consumerRequest;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final requestRepository = RequestRepository();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text('Pasabuy Information'),
      ),
      body: BlocProvider<ConsumerRequestBloc>(
        create: (context) => ConsumerRequestBloc(),
        child: BlocListener<ConsumerRequestBloc, ConsumerRequestState>(
          listener: (context, state) {
            //
          },
          child: BlocBuilder<ConsumerRequestBloc, ConsumerRequestState>(
            builder: (context, state) {
              if (state is CreatingRequest)
                return buildLoading(context, screenHeight, screenWidth);

              if (state is CreatedRequest)
                return buildRequestCreated(context, screenHeight, screenWidth);

              return buildInitial(context);
            },
          ),
        ),
      ),
    );
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
                    buildModalTextField(
                      controller: receiverNameController,
                      labelText: 'Receiver Name',
                      hintText: 'Enter the name of receiver',
                      validator: (val) {
                        if (val.trim().isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15.0),
                    buildModalTextField(
                      controller: receiverPhoneNumberController,
                      keyboardType: TextInputType.phone,
                      labelText: 'Receiver\'s Phone Number',
                      hintText: 'Enter the receiver\'s phone number',
                      validator: (val) {
                        if (val.trim().isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15.0),
                    buildModalTextField(
                      controller: storeNameController,
                      labelText: 'Store Name',
                      hintText: 'ex. SM Naga, South Star Drug, Market etc.',
                      validator: (val) {
                        if (val.trim().isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15.0),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0, bottom: 5.0),
                      child: Text(
                        'Item Description',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    DropdownButtonFormField(
                      value: _itemDescription,
                      validator: (String val) {
                        if (val.isEmpty) {
                          return 'This field is required';
                        }

                        return null;
                      },
                      onChanged: (String val) {
                        if (val != 'food') {
                          serviceFee += 100;
                          final distance = Geolocator.distanceBetween(
                                _consumerRequest.pickUpLatLng[0],
                                _consumerRequest.pickUpLatLng[1],
                                _consumerRequest.dropOffLatLng[0],
                                _consumerRequest.dropOffLatLng[1],
                              ) /
                              1000;
                          errandFee += distance * 15;
                        } else {
                          errandFee += 30;
                          serviceFee += 20;
                        }
                        setState(() {
                          _itemDescription = val;
                        });
                      },
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      iconEnabledColor: Colors.white,
                      dropdownColor: Colors.red.shade600,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.white),
                        fillColor: Colors.red.shade400,
                        filled: true,
                        isDense: true,
                        contentPadding: EdgeInsets.all(10.0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red.shade400),
                        ),
                      ),
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(
                          child: Text('Food'),
                          value: 'food',
                        ),
                        DropdownMenuItem(
                          child: Text('Grocery'),
                          value: 'grocery',
                        ),
                        DropdownMenuItem(
                          child: Text('Hardware'),
                          value: 'hardware',
                        ),
                        DropdownMenuItem(
                          child: Text('Gadgets'),
                          value: 'gadget',
                        ),
                        DropdownMenuItem(
                          child: Text('Documents'),
                          value: 'document',
                        ),
                        DropdownMenuItem(
                          child: Text('Others'),
                          value: 'others',
                        ),
                      ],
                    ),
                    SizedBox(height: 15.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              Text(
                                'Items (${itemsToPurchase.length})',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () => _onShowAddItemTapped(context),
                                child: Text(
                                  'ADD AN ITEM',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Container(
                          height: itemsToPurchase.length > 1 ? 100.0 : 40,
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListView(
                              children: itemsToPurchase.map((item) {
                                return Container(
                                  margin: EdgeInsets.only(bottom: 5.0),
                                  padding: EdgeInsets.only(bottom: 3.0),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.black12,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        item.qty,
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 10.0),
                                      GestureDetector(
                                        onTap: () => _onRemoveItemTapped(
                                            itemsToPurchase.indexOf(item)),
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.0),
                    buildModalTextField(
                      controller: estimatedPriceController,
                      labelText: 'Estimated Price',
                      keyboardType: TextInputType.number,
                      hintText: 'Enter the estimated price',
                      onChanged: (val) {
                        if (val.isEmpty) return;
                        final price = double.parse(val);
                        setState(() {
                          estimatedPrice = price;
                        });
                      },
                      validator: (val) {
                        if (val.trim().isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15.0),
                    buildModalTextField(
                      controller: remarksController,
                      labelText: 'Remarks',
                      hintText: 'Enter additional instructions to rider',
                      maxLines: 2,
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
                                'Errand Fee',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '₱ ${errandFee.toStringAsFixed(2)}',
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
                          Row(
                            children: [
                              Text(
                                'Estimated Price',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '₱ ${estimatedPrice.toStringAsFixed(2)}',
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
                                '₱ ${(serviceFee + errandFee + estimatedPrice).toStringAsFixed(2)}',
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

    if (itemsToPurchase.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Add item/s to purchase',
          style: TextStyle(
            color: Colors.red,
          ),
        ),
        backgroundColor: Colors.white,
      ));
      return;
    }

    final errandInformation = ErrandInformation(
      receiverName: receiverNameController.text.trim(),
      receriverPhoneNumber: receiverPhoneNumberController.text.trim(),
      storeName: storeNameController.text.trim(),
      itemDescription: _itemDescription,
      estimatedPrice: estimatedPrice,
      totalFee: serviceFee + errandFee,
      serviceFee: serviceFee,
      errandFee: errandFee,
      remarks: remarksController.text.trim(),
    );

    _consumerRequestBloc.add(CreateErrandRequest(
      consumerRequest: _consumerRequest,
      errandInformation: errandInformation,
      itemsToPurchase: itemsToPurchase,
    ));
  }

  _onRemoveItemTapped(int index) {
    itemsToPurchase.removeAt(index);
    setState(() {});
  }

  _onShowAddItemTapped(BuildContext parentContext) async {
    final errandItem = await showModalBottomSheet<ErrandItem>(
      isDismissible: false,
      backgroundColor: Colors.red.shade600,
      context: parentContext,
      builder: (context) {
        return Container(
          height: 250.0,
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: ListView(
              children: [
                buildModalTextField(
                    controller: itemNameController,
                    labelText: 'Item Name',
                    hintText: 'ex. Rice, Milk etc.'),
                SizedBox(height: 15.0),
                buildModalTextField(
                    controller: itemQtyController,
                    labelText: 'Qty',
                    hintText: 'ex. 1kg'),
                SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: buildFilledButton(
                        label: 'CANCEL',
                        labelColor: Colors.red.shade600,
                        onPressed: () => Navigator.pop(context, null),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Expanded(
                      child: buildFilledButton(
                        label: 'ADD ITEM',
                        onPressed: () {
                          final newItem = ErrandItem(
                            name: itemNameController.text.trim(),
                            qty: itemQtyController.text.trim(),
                          );
                          Navigator.pop(context, newItem);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (errandItem == null) return;

    itemNameController.clear();
    itemQtyController.clear();

    setState(() {
      itemsToPurchase.add(errandItem);
    });
  }
}
