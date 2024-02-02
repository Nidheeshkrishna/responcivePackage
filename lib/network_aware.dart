import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:flutter/material.dart';

class NetworkAwareWidget extends InheritedWidget {
  @override
  final Widget child;
  final bool isConnected;

  const NetworkAwareWidget(
      {super.key, required this.child, required this.isConnected})
      : super(child: child);

  static NetworkAwareWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NetworkAwareWidget>();
  }

  @override
  bool updateShouldNotify(NetworkAwareWidget oldWidget) {
    return isConnected != oldWidget.isConnected;
  }
}

class NetworkProvider extends StatefulWidget {
  final Widget child;

  const NetworkProvider({super.key, required this.child});

  @override
  _NetworkProviderState createState() => _NetworkProviderState();
}

class _NetworkProviderState extends State<NetworkProvider> {
  bool _isConnected = false;
  final DataConnectionChecker _dataConnectionChecker = DataConnectionChecker();

  @override
  void initState() {
    super.initState();
    _initializeNetworkListener();
  }

  void _initializeNetworkListener() {
    _dataConnectionChecker.onStatusChange.listen((DataConnectionStatus status) {
      setState(() {
        _isConnected = status == DataConnectionStatus.connected;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return NetworkAwareWidget(
      isConnected: _isConnected,
      child: widget.child,
    );
  }
}
