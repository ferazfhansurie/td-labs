import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressBar extends StatefulWidget {
  const ProgressBar({
    Key? key,
  }) : super(key: key);

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: IntrinsicHeight(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 54, vertical: 66),
          decoration: BoxDecoration(
            color: CupertinoTheme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 10),
                child: const Text('Compressing Video',
                    style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w300)),
              ),
              const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(CupertinoColors.white),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 10),
                child: const Text('Please wait for 30 - 60 seconds',
                    style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w300)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
