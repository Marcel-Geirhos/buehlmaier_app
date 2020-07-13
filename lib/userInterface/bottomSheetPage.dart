import 'package:flutter/material.dart';

class BottomSheetPage {
  TextEditingController _consumerName = TextEditingController();
  mainBottomSheet(BuildContext context) {
    showModalBottomSheet(context: context, builder: (BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text('Kundenname:'),
              TextFormField(
                controller: _consumerName,
                decoration: InputDecoration(
                  labelText: 'Kundenname',
                  prefixIcon: Icon(Icons.person, size: 22.0),
                  contentPadding: const EdgeInsets.all(0),
                  isDense: true,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}