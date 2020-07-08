import 'dart:ui';
import 'package:auto_animated/auto_animated.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:locationprojectflutter/core/constants/constants.dart';
import 'package:locationprojectflutter/data/models/model_stream_location/user_location.dart';
import 'package:locationprojectflutter/presentation/state_management/mobx/favorite_places_mobx.dart';
import 'package:locationprojectflutter/presentation/widgets/add_or_edit_favorites_places.dart';
import 'package:locationprojectflutter/presentation/widgets/drawer_total.dart';
import 'package:locationprojectflutter/presentation/utils/responsive_screen.dart';
import 'package:latlong/latlong.dart' as dis;
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'map_list.dart';

class FavoritePlaces extends StatefulWidget {
  const FavoritePlaces({Key key}) : super(key: key);

  @override
  _FavoritePlacesState createState() => _FavoritePlacesState();
}

class _FavoritePlacesState extends State<FavoritePlaces> {
  var _userLocation;
  String _API_KEY = Constants.API_KEY;
  FavoritePlacesMobXStore _mobX = FavoritePlacesMobXStore();

  @override
  void initState() {
    super.initState();

    _mobX.isCheckingBottomSheet(false);
    _mobX.getItems();
  }

  @override
  Widget build(BuildContext context) {
    _userLocation = Provider.of<UserLocation>(context);
    return Observer(
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(
              'Lovely Favorite Places',
              style: TextStyle(color: Color(0xFFE9FFFF)),
            ),
            iconTheme: IconThemeData(
              color: Color(0xFFE9FFFF),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.delete_forever),
                color: Color(0xFFE9FFFF),
                onPressed: () => _mobX.deleteData(),
              ),
            ],
          ),
          body: Container(
            child: Stack(
              children: [
                Column(
                  children: <Widget>[
                    _mobX.resultsSqflGet.length == 0
                        ? Align(
                            alignment: Alignment.center,
                            child: Text(
                              'No Favorite Places',
                              style: TextStyle(
                                color: Colors.deepPurpleAccent,
                                fontSize: 30,
                              ),
                            ),
                          )
                        : Expanded(
                            child: LiveList(
                              showItemInterval: Duration(milliseconds: 50),
                              showItemDuration: Duration(milliseconds: 50),
                              reAnimateOnVisibility: true,
                              scrollDirection: Axis.vertical,
                              itemCount: _mobX.resultsSqflGet.length,
                              itemBuilder: buildAnimatedItem,
                              separatorBuilder: (context, i) {
                                return SizedBox(
                                  height: ResponsiveScreen()
                                      .heightMediaQuery(context, 5),
                                  width: double.infinity,
                                  child: const DecoratedBox(
                                    decoration: const BoxDecoration(
                                        color: Colors.white),
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
                _mobX.checkingBottomSheetGet == true
                    ? Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 5,
                            sigmaY: 5,
                          ),
                          child: Container(
                            color: Colors.black.withOpacity(0),
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          drawer: DrawerTotal(),
        );
      },
    );
  }

  Widget buildAnimatedItem(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) =>
      FadeTransition(
        opacity: Tween<double>(
          begin: 0,
          end: 1,
        ).animate(animation),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, -0.1),
            end: Offset.zero,
          ).animate(animation),
          child: _childLiveList(index),
        ),
      );

  Widget _childLiveList(int index) {
    final dis.Distance _distance = dis.Distance();
    final double _meter = _distance(
      dis.LatLng(_userLocation.latitude, _userLocation.longitude),
      dis.LatLng(
          _mobX.resultsSqflGet[index].lat, _mobX.resultsSqflGet[index].lng),
    );
    return Slidable(
      key: UniqueKey(),
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.10,
      secondaryActions: <Widget>[
        IconSlideAction(
          color: Colors.orange,
          icon: Icons.edit,
          onTap: () => {
            _mobX.isCheckingBottomSheet(true),
            _newTaskModalBottomSheet(context, index),
          },
        ),
        IconSlideAction(
          color: Colors.greenAccent,
          icon: Icons.directions,
          onTap: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapList(
                  nameList: _mobX.resultsSqflGet[index].name,
                  vicinityList: _mobX.resultsSqflGet[index].vicinity,
                  latList: _mobX.resultsSqflGet[index].lat,
                  lngList: _mobX.resultsSqflGet[index].lng,
                ),
              ),
            ),
          },
        ),
        IconSlideAction(
          color: Colors.blueGrey,
          icon: Icons.share,
          onTap: () => {
            _shareContent(
                _mobX.resultsSqflGet[index].name,
                _mobX.resultsSqflGet[index].vicinity,
                _mobX.resultsSqflGet[index].lat,
                _mobX.resultsSqflGet[index].lng,
                _mobX.resultsSqflGet[index].photo)
          },
        ),
      ],
      actions: [
        IconSlideAction(
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => _mobX.deleteItem(_mobX.resultsSqflGet[index], index),
        ),
      ],
      dismissal: SlidableDismissal(
        child: SlidableDrawerDismissal(),
        dismissThresholds: <SlideActionType, double>{
          SlideActionType.secondary: 1.0
        },
        onDismissed: (actionType) {
          _mobX.deleteItem(_mobX.resultsSqflGet[index], index);
        },
      ),
      child: Container(
        color: Colors.grey,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                CachedNetworkImage(
                  fit: BoxFit.fill,
                  height: ResponsiveScreen().heightMediaQuery(context, 150),
                  width: double.infinity,
                  imageUrl: _mobX.resultsSqflGet[index].photo.isNotEmpty
                      ? "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=" +
                          _mobX.resultsSqflGet[index].photo +
                          "&key=$_API_KEY"
                      : "https://upload.wikimedia.org/wikipedia/commons/7/75/No_image_available.png",
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ],
            ),
            Container(
              height: ResponsiveScreen().heightMediaQuery(context, 150),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xAA000000),
                    const Color(0x00000000),
                    const Color(0x00000000),
                    const Color(0xAA000000),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _textList(_mobX.resultsSqflGet[index].name, 17.0, 0xffE9FFFF),
                  _textList(
                      _mobX.resultsSqflGet[index].vicinity, 15.0, 0xFFFFFFFF),
                  _textList(_calculateDistance(_meter), 15.0, 0xFFFFFFFF),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateDistance(double _meter) {
    String _myMeters;
    if (_meter < 1000.0) {
      _myMeters = 'Meters: ' + (_meter.round()).toString();
    } else {
      _myMeters =
          'KM: ' + (_meter.round() / 1000.0).toStringAsFixed(2).toString();
    }
    return _myMeters;
  }

  Widget _textList(String text, double fontSize, int color) {
    return Text(
      text,
      style: TextStyle(
        shadows: <Shadow>[
          Shadow(
            offset: Offset(1.0, 1.0),
            blurRadius: 1.0,
            color: Color(0xAA000000),
          ),
          Shadow(
            offset: Offset(1.0, 1.0),
            blurRadius: 1.0,
            color: Color(0xAA000000),
          ),
        ],
        fontSize: fontSize,
        color: Color(color),
      ),
    );
  }

  void _shareContent(
      String name, String vicinity, double lat, double lng, String photo) {
    final RenderBox box = context.findRenderObject();
    Share.share(
        'Name: $name' +
            '\n' +
            'Vicinity: $vicinity' +
            '\n' +
            'Latitude: $lat' +
            '\n' +
            'Longitude: $lng' +
            '\n' +
            'Photo: $photo',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  void _newTaskModalBottomSheet(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            _mobX.isCheckingBottomSheet(false);

            Navigator.pop(context, false);

            return Future.value(false);
          },
          child: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Container(
                child: ListView(
                  children: [
                    AddOrEditFavoritesPlaces(
                      id: _mobX.resultsSqflGet[index].id,
                      nameList: _mobX.resultsSqflGet[index].name,
                      addressList: _mobX.resultsSqflGet[index].vicinity,
                      latList: _mobX.resultsSqflGet[index].lat,
                      lngList: _mobX.resultsSqflGet[index].lng,
                      photoList: _mobX.resultsSqflGet[index].photo.isNotEmpty
                          ? _mobX.resultsSqflGet[index].photo
                          : "",
                      edit: true,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}