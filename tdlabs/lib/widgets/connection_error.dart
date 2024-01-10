import 'package:flutter/cupertino.dart';

typedef StringCallback = Function(String value);

class ConnectionError extends StatefulWidget {
  final VoidCallback onRefresh;

  const ConnectionError({Key? key, required this.onRefresh}) : super(key: key);

  @override
  _ConnectionErrorState createState() => _ConnectionErrorState();
}

class _ConnectionErrorState extends State<ConnectionError> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('No internet connection.'),
        CupertinoButton(
          child: const Text('Retry'),
          onPressed: widget.onRefresh,
        ),
      ],
    );
  }
}
