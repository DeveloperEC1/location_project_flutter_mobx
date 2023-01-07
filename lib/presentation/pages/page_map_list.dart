import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:locationprojectflutter/core/constants/constants_colors.dart';
import 'package:locationprojectflutter/presentation/state_management/mobx/mobx_map_list.dart';
import 'package:locationprojectflutter/presentation/widgets/widget_app_bar_total.dart';

class PageMapList extends StatefulWidget {
  final double latList, lngList;
  final String nameList, vicinityList;

  const PageMapList(
      {Key key,
      @required this.nameList,
      @required this.vicinityList,
      @required this.latList,
      @required this.lngList})
      : super(key: key);

  @override
  _PageMapListState createState() => _PageMapListState();
}

class _PageMapListState extends State<PageMapList> {
  MobXMapListStore _mobX = MobXMapListStore();

  @override
  void initState() {
    super.initState();

    _mobX.initGetSharedPrefs();
    _mobX.initMarker(widget.nameList, widget.vicinityList, widget.latList,
        widget.lngList, context);
    _mobX.initGeofence(widget.latList, widget.lngList, widget.nameList);
    _mobX.initPlatformState(widget.nameList);
    _mobX.initNotifications();
    _mobX.isSearching(false);
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
          floatingActionButton: _floatingActionButton(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _body() {
    return Stack(
      children: [
        _googleMap(_mobX.currentLocationGet),
        if (_mobX.isSearchingGet) _loading(),
      ],
    );
  }

  Widget _googleMap(LatLng _currentLocation) {
    return GoogleMap(
      onMapCreated: _mobX.onMapCreatedGet,
      initialCameraPosition: CameraPosition(
        target: _currentLocation,
        zoom: 10.0,
      ),
      markers: Set<Marker>.of(_mobX.markersGet),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomGesturesEnabled: true,
      circles: Set.from([
        Circle(
          circleId: CircleId(
            _currentLocation.toString(),
          ),
          center: _currentLocation,
          fillColor: ConstantsColors.LIGHT_PURPLE,
          strokeColor: ConstantsColors.LIGHT_PURPLE,
          radius: _mobX.valueRadiusGet,
        ),
      ]),
      mapType: MapType.normal,
    );
  }

  Widget _loading() {
    return Container(
      decoration: BoxDecoration(
        color: ConstantsColors.DARK_GRAY2,
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  FloatingActionButton _floatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        _mobX.searchNearbyList(context);
      },
      label: const Text('Show Nearby Places'),
      icon: const Icon(Icons.place),
    );
  }
}
