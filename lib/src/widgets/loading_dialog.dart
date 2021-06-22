import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({Key? key}) : super(key: key);

  Widget _buildAlertDialog() {
    return AlertDialog(
      content: Row(
        children: const <Widget>[
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Text('Loading...'),
        ],
      ),
    );
  }

  void showLoadingDialog(BuildContext context) {
    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext ctx) => _buildAlertDialog(),
    );
  }

  @override
  Widget build(BuildContext context) => _buildAlertDialog();
}
