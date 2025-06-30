// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkWrapper extends StatefulWidget {
  final Widget child;
  const NetworkWrapper({required this.child, super.key});

  @override
  State<NetworkWrapper> createState() => _NetworkWrapperState();
}

class _NetworkWrapperState extends State<NetworkWrapper> {
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((status) {
      setState(() => isOffline = (status == ConnectivityResult.none));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (isOffline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.red,
              padding: const EdgeInsets.all(12),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, color: Colors.white),
                  SizedBox(width: 8),
                  Text("No Internet Connection", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
