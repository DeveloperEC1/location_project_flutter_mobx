import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:locationprojectflutter/presentation/state_management/mobx/mobx_custom_map_list.dart';
import 'package:locationprojectflutter/presentation/utils/responsive_screen.dart';
import 'package:locationprojectflutter/presentation/widgets/widget_app_bar_total.dart';

class PageCustomMapList extends StatefulWidget {
  @override
  _PageCustomMapListState createState() => _PageCustomMapListState();
}

class _PageCustomMapListState extends State<PageCustomMapList> {
  MobXCustomMapListStore _mobX = MobXCustomMapListStore();

  @override
  void initState() {
    super.initState();

    _mobX.isCheckingBottomSheet(false);
    _mobX.clearMarkers();
  }

  @override
  Widget build(BuildContext context) {
    _mobX.userLocation(context);
    _mobX.currentLocation();
    return Observer(
      builder: (context) {
        return Scaffold(
          appBar: WidgetAppBarTotal(),
          body: _body(),
        );
      },
    );
  }

  Widget _body() {
    return Stack(
      children: [
        _googleMap(),
        _blur(),
      ],
    );
  }

  Widget _googleMap() {
    return GoogleMap(
      onMapCreated: _mobX.onMapCreatedGet,
      initialCameraPosition: CameraPosition(
        target: _mobX.currentLocationGet,
        zoom: 10.0,
      ),
      markers: Set<Marker>.of(_mobX.markersGet),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomGesturesEnabled: true,
      mapType: MapType.normal,
      onTap: (latLong) {
        _mobX.addMarker(latLong, context);
      },
    );
  }

  Widget _blur() {
    return _mobX.isCheckingBottomSheetGet == true
        ? Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: ResponsiveScreen().widthMediaQuery(context, 5),
                sigmaY: ResponsiveScreen().widthMediaQuery(context, 5),
              ),
              child: Container(color: Colors.black.withOpacity(0)),
            ),
          )
        : Container();
  }
}
