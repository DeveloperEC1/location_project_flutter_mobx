import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:chips_choice/chips_choice.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_stories/flutter_stories.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong/latlong.dart' as dis;
import 'package:locationprojectflutter/core/constants/constants_colors.dart';
import 'package:locationprojectflutter/core/constants/constants_images.dart';
import 'package:locationprojectflutter/presentation/state_management/mobx/mobx_list_map.dart';
import 'package:locationprojectflutter/presentation/utils/utils_app.dart';
import 'package:locationprojectflutter/presentation/widgets/widget_drawer_total.dart';
import 'package:locationprojectflutter/presentation/utils/responsive_screen.dart';

class PageListMap extends StatefulWidget {
  @override
  _PageListMapState createState() => _PageListMapState();
}

class _PageListMapState extends State<PageListMap> {
  MobXListMapStore _mobX = MobXListMapStore();

  @override
  void initState() {
    super.initState();

    _mobX.initGetSharedPrefs();
    _mobX.isCheckingBottomSheet(false);
    _mobX.isSearching(true);
    _mobX.isSearchAfter(false);
    _mobX.isActiveSearch(false);
    _mobX.isActiveNav(false);
    _mobX.isDisplayGrid(false);
    _mobX.finalTagsChips('');
    _mobX.tagsChips([]);
  }

  @override
  Widget build(BuildContext context) {
    _mobX.userLocation(context);
    _mobX.searchNearbyTotal(true, _mobX.isSearchingGet, false, "", "");
    return Observer(
      builder: (context) {
        return Scaffold(
          appBar: _appBar(),
          body: _body(),
          drawer: WidgetDrawerTotal(),
        );
      },
    );
  }

  PreferredSizeWidget _appBar() {
    if (_mobX.isActiveSearchGet) {
      return AppBar(
        iconTheme: IconThemeData(color: ConstantsColors.LIGHT_BLUE),
        backgroundColor: ConstantsColors.BLACK2,
        title: Form(
          key: _mobX.formKeySearchGet,
          child: Row(
            children: <Widget>[
              Flexible(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Search a place...',
                    hintStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: ResponsiveScreen().widthMediaQuery(context, 1),
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                  controller: _mobX.controllerSearchGet,
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                color: ConstantsColors.LIGHT_BLUE,
                onPressed: () {
                  if (_mobX.formKeySearchGet.currentState.validate()) {
                    _mobX.tagsChips([]);
                    _mobX.isSearchAfter(true);
                    _mobX.searchNearbyTotal(
                        false,
                        true,
                        _mobX.isSearchingAfterGet,
                        "",
                        _mobX.controllerSearchGet.text);
                  }
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.close),
            color: ConstantsColors.LIGHT_BLUE,
            onPressed: () => {
              _mobX.controllerSearchGet.clear(),
              _mobX.isActiveSearch(false),
            },
          )
        ],
      );
    } else {
      return AppBar(
        iconTheme: IconThemeData(color: ConstantsColors.LIGHT_BLUE),
        backgroundColor: Colors.indigoAccent,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            color: ConstantsColors.LIGHT_BLUE,
            onPressed: () => _mobX.isActiveSearch(true),
          ),
          IconButton(
            icon: const Icon(Icons.navigation),
            color: ConstantsColors.LIGHT_BLUE,
            onPressed: () => {
              _mobX.tagsChips([]),
              _mobX.isSearchAfter(true),
              _mobX.searchNearbyTotal(
                  false, true, _mobX.isSearchingAfterGet, "", ""),
            },
          ),
        ],
      );
    }
  }

  Widget _body() {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: ResponsiveScreen().heightMediaQuery(context, 140),
            automaticallyImplyLeading: false,
            floating: true,
            pinned: true,
            backgroundColor: Colors.transparent,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(
                  ResponsiveScreen().widthMediaQuery(context, 0)),
              child: Container(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _stories(),
                    _dividerGrey(),
                    _chipsType(),
                    _dividerGrey(),
                  ],
                ),
              ),
            ),
          ),
        ];
      },
      body: Stack(
        children: [
          _mainBody(),
          if (_mobX.isActiveNavGet) _loading(),
          _blur(),
        ],
      ),
    );
  }

  Widget _mainBody() {
    return Column(
      children: <Widget>[
        _imagesListGrid(),
        _dividerGrey(),
        _listGridData(),
      ],
    );
  }

  Widget _dividerGrey() {
    return SizedBox(
      height: ResponsiveScreen().heightMediaQuery(context, 1),
      width: double.infinity,
      child: const DecoratedBox(
        decoration: BoxDecoration(color: Colors.grey),
      ),
    );
  }

  Widget _stories() {
    return StreamBuilder(
      stream: _mobX.firestoreGet
          .collection('places')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ConstantsColors.ORANGE),
            ),
          );
        } else {
          _mobX.listMessage(snapshot.data.documents);
          final images = List.generate(
            _mobX.listMessageGet.length,
            (index) => Image.network(_mobX.listMessageGet[index]
                    .data()['photo']
                    .isNotEmpty
                ? "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=" +
                    _mobX.listMessageGet[index].data()['photo'] +
                    "&key=${_mobX.API_KEYGet}"
                : "https://upload.wikimedia.org/wikipedia/commons/7/75/No_image_available.png"),
          );
          return CupertinoPageScaffold(
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: CupertinoColors.activeOrange,
                    width: ResponsiveScreen().widthMediaQuery(context, 2),
                    style: BorderStyle.solid,
                  ),
                ),
                width: ResponsiveScreen().widthMediaQuery(context, 50),
                height: ResponsiveScreen().widthMediaQuery(context, 50),
                padding: const EdgeInsets.all(2.0),
                child: GestureDetector(
                  onTap: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) {
                        return CupertinoPageScaffold(
                          backgroundColor: Colors.black,
                          child: Stack(
                            children: [
                              Story(
                                onFlashForward: Navigator.of(context).pop,
                                onFlashBack: Navigator.of(context).pop,
                                momentCount: _mobX.listMessageGet.length,
                                momentDurationGetter: (idx) =>
                                    const Duration(seconds: 5),
                                momentBuilder: (context, idx) => images[idx],
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: EdgeInsets.all(ResponsiveScreen()
                                      .widthMediaQuery(context, 20)),
                                  child: ClipOval(
                                    child: Material(
                                      child: InkWell(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: Colors.blueGrey,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 28.0,
                                          ),
                                        ),
                                        onTap: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        imageUrl: _mobX.listMessageGet[0]
                                .data()['photo']
                                .isNotEmpty
                            ? "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=" +
                                _mobX.listMessageGet[0].data()['photo'] +
                                "&key=${_mobX.API_KEYGet}"
                            : "https://upload.wikimedia.org/wikipedia/commons/7/75/No_image_available.png",
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _imagesListGrid() {
    return Container(
      height: ResponsiveScreen().heightMediaQuery(context, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ConstantsColors.GRAY,
            ConstantsColors.TRANSPARENT,
            ConstantsColors.TRANSPARENT,
            ConstantsColors.GRAY,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _displayListGrid(
              ConstantsImages.LIST_LIGHT, ConstantsImages.LIST_DARK, false),
          _displayListGrid(
              ConstantsImages.GRID_DARK, ConstantsImages.GRID_LIGHT, true),
        ],
      ),
    );
  }

  Widget _displayListGrid(
      String showTrue, String showFalse, bool isDisplayGrid) {
    return Container(
      width: ResponsiveScreen().widthMediaQuery(context, 40),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          child: Container(
            child: IconButton(
              icon: !kIsWeb
                  ? SvgPicture.asset(
                      _mobX.isDisplayGridGet ? showTrue : showFalse)
                  : Container(),
              onPressed: () {
                _mobX.isDisplayGrid(isDisplayGrid);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _listGridData() {
    return _mobX.isSearchingGet || _mobX.isSearchingAfterGet
        ? Padding(
            padding: EdgeInsets.only(
                top: ResponsiveScreen().heightMediaQuery(context, 8)),
            child: const CircularProgressIndicator(),
          )
        : _mobX.placesGet.length == 0
            ? const Text(
                'No Places',
                style: TextStyle(
                  color: Colors.deepPurpleAccent,
                  fontSize: 30,
                ),
              )
            : Expanded(
                child: _mobX.isDisplayGridGet
                    ? Padding(
                        padding: EdgeInsets.all(
                            ResponsiveScreen().widthMediaQuery(context, 8)),
                        child: LiveGrid(
                          showItemInterval: const Duration(milliseconds: 50),
                          showItemDuration: const Duration(milliseconds: 50),
                          reAnimateOnVisibility: true,
                          scrollDirection: Axis.vertical,
                          itemCount: _mobX.placesGet.length,
                          itemBuilder: _buildAnimatedItem,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing:
                                ResponsiveScreen().widthMediaQuery(context, 8),
                            mainAxisSpacing:
                                ResponsiveScreen().widthMediaQuery(context, 8),
                          ),
                        ),
                      )
                    : LiveList(
                        showItemInterval: const Duration(milliseconds: 50),
                        showItemDuration: const Duration(milliseconds: 50),
                        reAnimateOnVisibility: true,
                        scrollDirection: Axis.vertical,
                        itemCount: _mobX.placesGet.length,
                        itemBuilder: _buildAnimatedItem,
                        separatorBuilder: (context, i) {
                          return SizedBox(
                            height:
                                ResponsiveScreen().heightMediaQuery(context, 5),
                            width: double.infinity,
                            child: const DecoratedBox(
                              decoration: BoxDecoration(color: Colors.white),
                            ),
                          );
                        },
                      ),
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
              child: Container(
                color: Colors.black.withOpacity(0),
              ),
            ),
          )
        : Container();
  }

  Widget _buildAnimatedItem(
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
            begin: const Offset(0, -0.1),
            end: Offset.zero,
          ).animate(animation),
          child: _childLiveListGrid(index),
        ),
      );

  Widget _childLiveListGrid(int index) {
    final dis.Distance _distance = dis.Distance();
    final double _meter = _distance(
      dis.LatLng(
          _mobX.userLocationGet.latitude, _mobX.userLocationGet.longitude),
      dis.LatLng(_mobX.placesGet[index].geometry.location.lat,
          _mobX.placesGet[index].geometry.location.lng),
    );
    return Slidable(
      key: UniqueKey(),
      actionPane: const SlidableDrawerActionPane(),
      actionExtentRatio: _mobX.isDisplayGridGet ? 0.15 : 0.1,
      secondaryActions: <Widget>[
        IconSlideAction(
          color: Colors.green,
          icon: Icons.add,
          onTap: () => {
            _mobX.isCheckingBottomSheet(true),
            _mobX.newTaskModalBottomSheet(context, index),
          },
        ),
        IconSlideAction(
          color: Colors.greenAccent,
          icon: Icons.directions,
          onTap: () => {
            _mobX.createNavPlace(index, context),
          },
        ),
        IconSlideAction(
          color: Colors.blueGrey,
          icon: Icons.share,
          onTap: () => {
            _mobX.shareContent(
              _mobX.placesGet[index].name,
              _mobX.placesGet[index].vicinity,
              _mobX.placesGet[index].geometry.location.lat,
              _mobX.placesGet[index].geometry.location.lng,
              _mobX.placesGet[index].photos[0].photo_reference,
              context,
            )
          },
        ),
      ],
      child: _listGridItem(index, _meter),
    );
  }

  Widget _listGridItem(int index, double _meter) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        child: Stack(
          children: <Widget>[
            CachedNetworkImage(
              fit: BoxFit.fill,
              height: _mobX.isDisplayGridGet
                  ? double.infinity
                  : ResponsiveScreen().heightMediaQuery(context, 150),
              width: double.infinity,
              imageUrl: _mobX.placesGet[index].photos.isNotEmpty
                  ? "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=" +
                      _mobX.placesGet[index].photos[0].photo_reference +
                      "&key=${_mobX.API_KEYGet}"
                  : "https://upload.wikimedia.org/wikipedia/commons/7/75/No_image_available.png",
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            Container(
              height: _mobX.isDisplayGridGet
                  ? double.infinity
                  : ResponsiveScreen().heightMediaQuery(context, 150),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ConstantsColors.GRAY,
                    ConstantsColors.TRANSPARENT,
                    ConstantsColors.TRANSPARENT,
                    ConstantsColors.GRAY,
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(
                  ResponsiveScreen().widthMediaQuery(context, 4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _textListView(_mobX.placesGet[index].name, 17.0,
                      ConstantsColors.LIGHT_BLUE),
                  _textListView(
                      _mobX.placesGet[index].vicinity, 15.0, Colors.white),
                  Row(
                    children: [
                      _textListView(
                          _mobX.calculateDistance(_meter), 15.0, Colors.white),
                      UtilsApp.dividerWidth(context, 20),
                      _textListView(
                        _mobX.placesGet[index].opening_hours != null
                            ? _mobX.placesGet[index].opening_hours.open_now
                                ? 'Open'
                                : !_mobX.placesGet[index].opening_hours.open_now
                                    ? 'Close'
                                    : 'No info'
                            : "No info",
                        15.0,
                        ConstantsColors.YELLOW,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipsType() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ConstantsColors.GRAY,
            ConstantsColors.TRANSPARENT,
            ConstantsColors.TRANSPARENT,
            ConstantsColors.TRANSPARENT,
            ConstantsColors.TRANSPARENT,
            ConstantsColors.GRAY,
          ],
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            ChipsChoice<String>.multiple(
              value: _mobX.tagsChipsGet,
              options: ChipsChoiceOption.listFrom<String, String>(
                source: _mobX.optionsChipsGet,
                value: (i, v) => v,
                label: (i, v) => v,
              ),
              itemConfig: ChipsChoiceItemConfig(
                  labelStyle: TextStyle(fontSize: 20),
                  selectedBrightness: Brightness.dark,
                  selectedColor: ConstantsColors.LIGHT_PURPLE,
                  shapeBuilder: (selected) {
                    return RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(
                        color: selected
                            ? Colors.deepPurpleAccent
                            : Colors.blueGrey.withOpacity(.5),
                      ),
                    );
                  }),
              onChanged: (val) => {
                _mobX.tagsChips(val),
                _mobX.finalTagsChips(_mobX.tagsChipsGet.toString()),
                _mobX.isSearchAfter(true),
                _mobX.searchNearbyTotal(
                    false,
                    true,
                    _mobX.isSearchingAfterGet,
                    _mobX.finalTagsChipsGet
                        .substring(_mobX.finalTagsChipsGet.length == 0 ? 0 : 1),
                    "")
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _textListView(String text, double fontSize, Color color) {
    return Text(
      text,
      style: TextStyle(
        shadows: <Shadow>[
          Shadow(
            offset: Offset(ResponsiveScreen().widthMediaQuery(context, 1),
                ResponsiveScreen().widthMediaQuery(context, 1)),
            blurRadius: ResponsiveScreen().widthMediaQuery(context, 1),
            color: ConstantsColors.GRAY,
          ),
        ],
        fontSize: fontSize,
        color: color,
      ),
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
}
