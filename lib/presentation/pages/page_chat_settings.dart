import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:locationprojectflutter/core/constants/constants_colors.dart';
import 'package:locationprojectflutter/presentation/state_management/mobx/mobx_chat_settings.dart';
import 'package:locationprojectflutter/presentation/utils/responsive_screen.dart';
import 'package:locationprojectflutter/presentation/widgets/widget_app_bar_total.dart';

class PageChatSettings extends StatefulWidget {
  @override
  _PageChatSettingsState createState() => _PageChatSettingsState();
}

class _PageChatSettingsState extends State<PageChatSettings> {
  MobXChatSettingsStore _mobX = MobXChatSettingsStore();

  @override
  void initState() {
    super.initState();

    _mobX.initControllerTextEditing();
  }

  @override
  Widget build(BuildContext context) {
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
      children: <Widget>[
        _mainBody(),
        _loading(),
      ],
    );
  }

  Widget _mainBody() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _circleAvatar(),
          _textFieldsData(),
          _buttonUpdate(),
        ],
      ),
      padding: EdgeInsets.symmetric(
          horizontal: ResponsiveScreen().widthMediaQuery(context, 15)),
    );
  }

  Widget _circleAvatar() {
    return Container(
      child: Center(
        child: Stack(
          children: <Widget>[
            _mobX.avatarImageFileGet == null
                ? _mobX.photoUrlGet != null
                    ? Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: ResponsiveScreen()
                                  .widthMediaQuery(context, 2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  ConstantsColors.ORANGE),
                            ),
                            width:
                                ResponsiveScreen().widthMediaQuery(context, 90),
                            height: ResponsiveScreen()
                                .heightMediaQuery(context, 50),
                            padding: EdgeInsets.all(ResponsiveScreen()
                                .widthMediaQuery(context, 20)),
                          ),
                          imageUrl: _mobX.photoUrlGet != null
                              ? _mobX.photoUrlGet
                              : '',
                          width:
                              ResponsiveScreen().widthMediaQuery(context, 90),
                          height:
                              ResponsiveScreen().widthMediaQuery(context, 90),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(45.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Icon(
                        Icons.account_circle,
                        size: 90.0,
                        color: ConstantsColors.DARK_GRAY,
                      )
                : Material(
                    child: Image.file(
                      _mobX.avatarImageFileGet,
                      width: ResponsiveScreen().widthMediaQuery(context, 90),
                      height: ResponsiveScreen().widthMediaQuery(context, 90),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(45.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  ),
            IconButton(
              icon: Icon(
                Icons.camera_alt,
                color: ConstantsColors.DARK_BLUE.withOpacity(0.5),
              ),
              onPressed: () => _mobX.newTaskModalBottomSheet(context),
              padding: const EdgeInsets.all(30.0),
              splashColor: Colors.transparent,
              highlightColor: ConstantsColors.DARK_BLUE,
              iconSize: 30.0,
            ),
          ],
        ),
      ),
      width: double.infinity,
      margin: EdgeInsets.all(ResponsiveScreen().widthMediaQuery(context, 20)),
    );
  }

  Widget _textFieldsData() {
    return Column(
      children: <Widget>[
        Container(
          child: Text(
            'Nickname',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: ConstantsColors.DARK_BLUE,
            ),
          ),
          margin: EdgeInsets.only(
            left: ResponsiveScreen().widthMediaQuery(context, 10),
            bottom: ResponsiveScreen().heightMediaQuery(context, 5),
            top: ResponsiveScreen().heightMediaQuery(context, 10),
          ),
        ),
        Container(
          child: Theme(
            data: Theme.of(context).copyWith(
              primaryColor: ConstantsColors.DARK_BLUE,
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cool Man',
                contentPadding: EdgeInsets.all(
                    ResponsiveScreen().widthMediaQuery(context, 5)),
                hintStyle: TextStyle(color: ConstantsColors.DARK_GRAY),
              ),
              controller: _mobX.controllerNicknameGet,
              onChanged: (value) {
                _mobX.nickname(value);
              },
              focusNode: _mobX.focusNodeNicknameGet,
            ),
          ),
          margin: EdgeInsets.symmetric(
              horizontal: ResponsiveScreen().widthMediaQuery(context, 30)),
        ),
        Container(
          child: Text(
            'About Me',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: ConstantsColors.DARK_BLUE,
            ),
          ),
          margin: EdgeInsets.only(
            left: ResponsiveScreen().widthMediaQuery(context, 10),
            top: ResponsiveScreen().heightMediaQuery(context, 30),
            bottom: ResponsiveScreen().heightMediaQuery(context, 5),
          ),
        ),
        Container(
          child: Theme(
            data: Theme.of(context).copyWith(
              primaryColor: ConstantsColors.DARK_BLUE,
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Fun, like travel and play PES...',
                contentPadding: EdgeInsets.all(
                    ResponsiveScreen().widthMediaQuery(context, 5)),
                hintStyle: TextStyle(color: ConstantsColors.DARK_GRAY),
              ),
              controller: _mobX.controllerAboutMeGet,
              onChanged: (value) {
                _mobX.aboutMe(value);
              },
              focusNode: _mobX.focusNodeAboutMeGet,
            ),
          ),
          margin: EdgeInsets.symmetric(
              horizontal: ResponsiveScreen().widthMediaQuery(context, 30)),
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget _buttonUpdate() {
    return Container(
      child: FlatButton(
        onPressed: _mobX.handleUpdateData,
        child: const Text(
          'UPDATE',
          style: TextStyle(fontSize: 16.0),
        ),
        color: ConstantsColors.DARK_BLUE,
        highlightColor: ConstantsColors.GRAY2,
        splashColor: Colors.transparent,
        textColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveScreen().widthMediaQuery(context, 30),
          vertical: ResponsiveScreen().heightMediaQuery(context, 10),
        ),
      ),
      margin: EdgeInsets.symmetric(
          vertical: ResponsiveScreen().heightMediaQuery(context, 50)),
    );
  }

  Widget _loading() {
    return Positioned(
      child: _mobX.isLoadingGet
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(ConstantsColors.ORANGE),
                ),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
  }
}
