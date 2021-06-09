import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lunad/widgets/filled_button.dart';

class PrivacyPopUpDialog extends StatelessWidget {
  final double radius;
  final String mdFileName;

  PrivacyPopUpDialog({
    Key key,
    this.radius = 8,
    @required this.mdFileName,
  })  : assert(mdFileName.contains('.md'),
            'The file must contain the .md extension'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: Future.delayed(Duration(milliseconds: 150)).then((value) {
                return rootBundle.loadString('assets/mds/$mdFileName');
              }),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Markdown(
                    data: snapshot.data,
                  );
                }

                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.red.shade400,
                  ),
                );
              },
            ),
          ),
          buildFilledButton(
            label: 'OK',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
