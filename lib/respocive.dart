import 'dart:convert';

import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NetworkUtils {
  static Future<bool> isNetworkConnected() async {
    DataConnectionChecker dataConnectionChecker = DataConnectionChecker();
    DataConnectionStatus status = await dataConnectionChecker.connectionStatus;
    return status == DataConnectionStatus.connected;
  }
}

class ResponsiveData extends InheritedWidget {
  final double screenWidth;
  final double screenHeight;
  final double textFactor;
  final Orientation orientation;
  final String jwtToken;
  final BuildContext context;
  final bool isConnected;

  const ResponsiveData({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.textFactor,
    required this.orientation,
    required this.context,
    required this.jwtToken,
    required this.isConnected,
    required super.child,
  });

  bool isTablet() {
    return screenHeight >= 900 && screenWidth >= 600;
  }

  // void checkAndRefreshToken() async {
  //   await TokenManager.checkAndRefreshToken(context);
  // }

  @override
  bool updateShouldNotify(covariant ResponsiveData oldWidget) {
    // checkAndRefreshToken();

    double? screenWidthAdjusted = 0.0;
    double? screenHeightAdjusted = 0.0;
    double? textFactorcalculated = 0.0;
    double safeAreaHorizontal;
    double? safeAreaVertical = 0.0;
    bool? isNetworkConnected;

    if (orientation == Orientation.portrait) {
      screenWidthAdjusted =
          isTablet() ? screenWidth.clamp(3.5, 4.5) : screenWidth.clamp(3, 4);
      screenHeightAdjusted = screenHeight;
    } else {
      screenHeightAdjusted = screenWidth;
      screenWidthAdjusted =
          isTablet() ? screenHeight.clamp(3.5, 4.5) : screenHeight.clamp(3, 4);
    }
    if (isTablet()) {
      textFactorcalculated = 1.2;
    } else {
      textFactorcalculated = 1.0;
    }

    safeAreaHorizontal = MediaQuery.paddingOf(context).left +
        MediaQuery.paddingOf(context).right;
    safeAreaVertical = MediaQuery.paddingOf(context).top +
        MediaQuery.paddingOf(context).bottom;
    DataConnectionChecker dataConnectionChecker = DataConnectionChecker();
    dataConnectionChecker.onStatusChange.listen((DataConnectionStatus status) {
      isNetworkConnected = status == DataConnectionStatus.connected;
    });

    // Check if any of the properties that affect the layout have changed.
    return (screenWidthAdjusted - safeAreaHorizontal) / 100 !=
            oldWidget.screenWidth ||
        screenHeightAdjusted != oldWidget.screenHeight ||
        textFactorcalculated != oldWidget.textFactor ||
        orientation != oldWidget.orientation ||
        jwtToken != oldWidget.jwtToken ||
        isNetworkConnected != oldWidget.isConnected;
  }

  static ResponsiveData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ResponsiveData>()!;
  }
}

// class TokenManager {
//   static var _accessToken;

//   static getAccessToken(BuildContext context) async {
//     bool isTokenExpired = await FlutterSessionJwt.isTokenExpired();

//     if (isTokenExpired) {
//       if (context.mounted) {
//         await refreshToken(context);
//       }
//     }
//   }

//   static Future<void> refreshToken(BuildContext context) async {
//     try {
//       _accessToken = await IsarServices().getAccessTocken();
//       // Call your authentication API endpoint to obtain a new token
//       // Replace 'YOUR_AUTH_API_ENDPOINT' with your actual authentication API endpoint
//       final response = await http.post(
//         Uri.parse(Urls.tokenRefresh),
//         headers: <String, String>{
//           'Content-Type': 'application/x-www-form-urlencoded',
//           'Authorization': 'Bearer $_accessToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//         _accessToken = jsonResponse['access_token'];
//         await IsarServices().updateAccessToken(_accessToken);
//       } else {
//         if (kDebugMode) {
//           print('Error refreshing token: ${response.statusCode}');
//         }
//       }
//     } catch (error) {
//       // Handle exception
//     }
//   }

//   static Future<void> checkAndRefreshToken(BuildContext context) async {
//     bool isTokenExpired = await FlutterSessionJwt.isTokenExpired();

//     if (isTokenExpired) {
//       if (context.mounted) {
//         await refreshToken(context);
//       }
//     }
//   }
// }

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
