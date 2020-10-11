import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart' as rec;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:locationprojectflutter/core/constants/constants_colors.dart';
import 'package:locationprojectflutter/core/constants/constants_images.dart';
import 'package:locationprojectflutter/presentation/state_management/mobx/mobx_chat_screen.dart';
import 'package:locationprojectflutter/presentation/utils/responsive_screen.dart';
import 'package:locationprojectflutter/presentation/utils/shower_pages.dart';
import 'package:locationprojectflutter/presentation/widgets/widget_audio.dart';
import 'package:locationprojectflutter/presentation/widgets/widget_video.dart';

class PageChatScreen extends StatefulWidget {
  final String peerId, peerAvatar;

  const PageChatScreen({Key key, this.peerId, this.peerAvatar})
      : super(key: key);

  @override
  _PageChatScreenState createState() => _PageChatScreenState();
}

class _PageChatScreenState extends State<PageChatScreen> {
  MobXChatScreenStore _mobX = MobXChatScreenStore();

  @override
  void initState() {
    super.initState();

    _mobX.initGetSharedPrefs(widget.peerId);
    _mobX.isShowSticker(false);
    _mobX.recordingStatus(rec.RecordingStatus.Initialized);
    _mobX.focusNodeGet.addListener(_mobX.onFocusChange);
    _mobX.initRecord(context);
  }

  @override
  Widget build(BuildContext context) {
    _mobX.handleCameraAndMic();
    return Observer(
      builder: (context) {
        return Scaffold(
          appBar: _appBar(),
          body: Stack(
            children: <Widget>[
              _mainBody(),
              _loading(),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Colors.indigoAccent,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.video_call),
          color: ConstantsColors.LIGHT_BLUE,
          onPressed: () => {
            _mobX.onSendMessage(
              _mobX.idVideo(widget.peerId),
              5,
              widget.peerId,
            ),
            ShowerPages.pushPageVideoCall(
              context,
              _mobX.idVideo(widget.peerId),
              ClientRole.Broadcaster,
            ),
          },
        ),
      ],
      leading: IconButton(
        icon: Icon(
          Icons.navigate_before,
          color: ConstantsColors.LIGHT_BLUE,
          size: 40,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _mainBody() {
    return Column(
      children: <Widget>[
        _buildMessagesList(),
        _mobX.isShowStickerGet ? _buildStickers() : Container(),
        _buildInput(),
      ],
    );
  }

  Widget _buildMessagesList() {
    return Flexible(
      child: _mobX.groupChatIdGet == ''
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  ConstantsColors.ORANGE,
                ),
              ),
            )
          : StreamBuilder(
              stream: _mobX.firestoreGet
                  .collection('messages')
                  .document(_mobX.groupChatIdGet)
                  .collection(_mobX.groupChatIdGet)
                  .orderBy('timestamp', descending: true)
                  .limit(30)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ConstantsColors.ORANGE,
                      ),
                    ),
                  );
                } else {
                  _mobX.listMessage(snapshot.data.documents);
                  return ListView.builder(
                    padding: EdgeInsets.all(
                        ResponsiveScreen().widthMediaQuery(context, 10)),
                    itemBuilder: (context, index) =>
                        _buildItem(index, _mobX.listMessageGet[index]),
                    itemCount: _mobX.listMessageGet.length,
                    reverse: true,
                    controller: _mobX.listScrollControllerGet,
                  );
                }
              },
            ),
    );
  }

  Widget _buildStickers() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              _stickers('mimi1', ConstantsImages.MIMI1),
              _stickers('mimi2', ConstantsImages.MIMI2),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              _stickers('mimi3', ConstantsImages.MIMI3),
              _stickers('mimi4', ConstantsImages.MIMI4),
              _stickers('mimi5', ConstantsImages.MIMI5),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: ConstantsColors.LIGHT_GRAY,
            width: ResponsiveScreen().widthMediaQuery(context, 0.5),
          ),
        ),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(ResponsiveScreen().widthMediaQuery(context, 5)),
      height: ResponsiveScreen().heightMediaQuery(context, 180),
    );
  }

  Widget _stickers(String name, String asset) {
    return FlatButton(
      onPressed: () => _mobX.onSendMessage(name, 2, widget.peerId),
      child: Image.asset(
        asset,
        width: ResponsiveScreen().widthMediaQuery(context, 50),
        height: ResponsiveScreen().heightMediaQuery(context, 50),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          _iconInput(
            const Icon(Icons.camera_alt),
            () => _mobX.newTaskModalBottomSheet(context, 1, widget.peerId),
          ),
          _iconInput(
            const Icon(Icons.video_library),
            () => _mobX.newTaskModalBottomSheet(context, 3, widget.peerId),
          ),
          _iconInput(
            const Icon(Icons.face),
            () => _mobX.getSticker(),
          ),
          _iconInput(
            _mobX.isCurrentStatusGet == rec.RecordingStatus.Initialized
                ? const Icon(Icons.mic_none)
                : const Icon(
                    Icons.mic,
                    color: Colors.red,
                  ),
            () => _mobX.isCurrentStatusGet == rec.RecordingStatus.Initialized
                ? _mobX.startRecord()
                : _mobX.stopRecord(context, widget.peerId),
          ),
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(
                  color: ConstantsColors.DARK_BLUE,
                  fontSize: 15.0,
                ),
                controller: _mobX.textEditingControllerGet,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: ConstantsColors.DARK_GRAY),
                ),
                focusNode: _mobX.focusNodeGet,
              ),
            ),
          ),
          _iconInput(
            const Icon(Icons.send),
            () => _mobX.onSendMessage(
              _mobX.textEditingControllerGet.text,
              0,
              widget.peerId,
            ),
          ),
        ],
      ),
      width: double.infinity,
      height: ResponsiveScreen().heightMediaQuery(context, 50),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: ConstantsColors.LIGHT_GRAY,
            width: ResponsiveScreen().widthMediaQuery(context, 0.5),
          ),
        ),
        color: Colors.white,
      ),
    );
  }

  Widget _iconInput(Widget icon, VoidCallback onTap) {
    return Material(
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: ResponsiveScreen().widthMediaQuery(context, 1)),
        child: IconButton(
          icon: icon,
          onPressed: onTap,
          color: ConstantsColors.DARK_BLUE,
        ),
      ),
      color: Colors.white,
    );
  }

  Widget _buildItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == _mobX.idGet) {
      return Row(
        children: <Widget>[
          document['type'] == 0
              ? Container(
                  child: Text(
                    document['content'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveScreen().heightMediaQuery(context, 10),
                    horizontal: ResponsiveScreen().widthMediaQuery(context, 15),
                  ),
                  width: ResponsiveScreen().widthMediaQuery(context, 200),
                  decoration: BoxDecoration(
                    color: ConstantsColors.DARK_BLUE,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  margin: EdgeInsets.only(
                    bottom: _mobX.isLastMessageRight(index)
                        ? ResponsiveScreen().heightMediaQuery(context, 20)
                        : ResponsiveScreen().heightMediaQuery(context, 10),
                    right: ResponsiveScreen().widthMediaQuery(context, 10),
                  ),
                )
              : document['type'] == 1
                  ? Container(
                      child: FlatButton(
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ConstantsColors.ORANGE,
                                ),
                              ),
                              width: ResponsiveScreen()
                                  .widthMediaQuery(context, 200),
                              height: ResponsiveScreen()
                                  .widthMediaQuery(context, 200),
                              padding: EdgeInsets.all(ResponsiveScreen()
                                  .widthMediaQuery(context, 70)),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Image.asset(
                                ConstantsImages.IMG_NOT_AVAILABLE,
                                width: ResponsiveScreen()
                                    .widthMediaQuery(context, 200),
                                height: ResponsiveScreen()
                                    .widthMediaQuery(context, 200),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: document['content'],
                            width: ResponsiveScreen()
                                .widthMediaQuery(context, 200),
                            height: ResponsiveScreen()
                                .widthMediaQuery(context, 200),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          clipBehavior: Clip.hardEdge,
                        ),
                        onPressed: () {
                          ShowerPages.pushPageFullPhoto(
                            context,
                            document['content'],
                          );
                        },
                        padding: EdgeInsets.all(0),
                      ),
                      margin: EdgeInsets.only(
                        bottom: _mobX.isLastMessageRight(index)
                            ? ResponsiveScreen().heightMediaQuery(context, 20)
                            : ResponsiveScreen().heightMediaQuery(context, 10),
                        right: ResponsiveScreen().widthMediaQuery(context, 10),
                      ),
                    )
                  : document['type'] == 2
                      ? Container(
                          child: Image.asset(
                            'assets/${document['content']}.gif',
                            width: ResponsiveScreen()
                                .widthMediaQuery(context, 100),
                            height: ResponsiveScreen()
                                .widthMediaQuery(context, 100),
                            fit: BoxFit.cover,
                          ),
                          margin: EdgeInsets.only(
                            bottom: _mobX.isLastMessageRight(index)
                                ? ResponsiveScreen()
                                    .heightMediaQuery(context, 20)
                                : ResponsiveScreen()
                                    .heightMediaQuery(context, 10),
                            right:
                                ResponsiveScreen().widthMediaQuery(context, 10),
                          ),
                        )
                      : document['type'] == 3
                          ? Container(
                              child: WidgetVideo(
                                url: document['content'],
                              ),
                              margin: EdgeInsets.only(
                                bottom: _mobX.isLastMessageRight(index)
                                    ? ResponsiveScreen()
                                        .heightMediaQuery(context, 20)
                                    : ResponsiveScreen()
                                        .heightMediaQuery(context, 10),
                                right: ResponsiveScreen()
                                    .widthMediaQuery(context, 10),
                              ),
                            )
                          : document['type'] == 4
                              ? Container(
                                  width: ResponsiveScreen()
                                      .widthMediaQuery(context, 300),
                                  height: ResponsiveScreen()
                                      .heightMediaQuery(context, 120),
                                  child: WidgetAudio(
                                    url: document['content'],
                                  ),
                                )
                              : document['type'] == 5
                                  ? GestureDetector(
                                      onTap: () => _mobX.videoSendMessage(
                                        widget.peerId,
                                        context,
                                      ),
                                      child: Container(
                                        child: Text(
                                          'Join video call',
                                          style: TextStyle(
                                              color: Colors.lightBlue),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: ResponsiveScreen()
                                              .heightMediaQuery(context, 10),
                                          horizontal: ResponsiveScreen()
                                              .widthMediaQuery(context, 15),
                                        ),
                                        width: ResponsiveScreen()
                                            .widthMediaQuery(context, 200),
                                        decoration: BoxDecoration(
                                          color: ConstantsColors.DARK_BLUE,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        margin: EdgeInsets.only(
                                          bottom: _mobX
                                                  .isLastMessageRight(index)
                                              ? ResponsiveScreen()
                                                  .heightMediaQuery(context, 20)
                                              : ResponsiveScreen()
                                                  .heightMediaQuery(
                                                      context, 10),
                                          right: ResponsiveScreen()
                                              .widthMediaQuery(context, 10),
                                        ),
                                      ),
                                    )
                                  : Container(),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                _mobX.isLastMessageLeft(index)
                    ? Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: ResponsiveScreen()
                                  .widthMediaQuery(context, 1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ConstantsColors.ORANGE,
                              ),
                            ),
                            width:
                                ResponsiveScreen().widthMediaQuery(context, 35),
                            height:
                                ResponsiveScreen().widthMediaQuery(context, 35),
                            padding: EdgeInsets.all(ResponsiveScreen()
                                .widthMediaQuery(context, 10)),
                          ),
                          imageUrl: widget.peerAvatar != null
                              ? widget.peerAvatar
                              : '',
                          width:
                              ResponsiveScreen().widthMediaQuery(context, 35),
                          height:
                              ResponsiveScreen().widthMediaQuery(context, 35),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(18.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(
                        width: ResponsiveScreen().widthMediaQuery(context, 35),
                      ),
                document['type'] == 0
                    ? Container(
                        child: Text(
                          document['content'],
                          style: TextStyle(color: ConstantsColors.DARK_BLUE),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical:
                              ResponsiveScreen().heightMediaQuery(context, 10),
                          horizontal:
                              ResponsiveScreen().widthMediaQuery(context, 15),
                        ),
                        width: ResponsiveScreen().widthMediaQuery(context, 200),
                        decoration: BoxDecoration(
                          color: ConstantsColors.LIGHT_GRAY,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        margin: EdgeInsets.only(
                            left: ResponsiveScreen()
                                .widthMediaQuery(context, 10)),
                      )
                    : document['type'] == 1
                        ? Container(
                            child: FlatButton(
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        ConstantsColors.ORANGE,
                                      ),
                                    ),
                                    width: ResponsiveScreen()
                                        .widthMediaQuery(context, 200),
                                    height: ResponsiveScreen()
                                        .widthMediaQuery(context, 200),
                                    padding: EdgeInsets.all(ResponsiveScreen()
                                        .widthMediaQuery(context, 70)),
                                    decoration: BoxDecoration(
                                      color: ConstantsColors.LIGHT_GRAY,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    child: Image.asset(
                                      ConstantsImages.IMG_NOT_AVAILABLE,
                                      width: ResponsiveScreen()
                                          .widthMediaQuery(context, 200),
                                      height: ResponsiveScreen()
                                          .widthMediaQuery(context, 200),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl: document['content'] != null
                                      ? document['content']
                                      : '',
                                  width: ResponsiveScreen()
                                      .widthMediaQuery(context, 200),
                                  height: ResponsiveScreen()
                                      .widthMediaQuery(context, 200),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                clipBehavior: Clip.hardEdge,
                              ),
                              onPressed: () {
                                ShowerPages.pushPageFullPhoto(
                                  context,
                                  document['content'],
                                );
                              },
                              padding: EdgeInsets.all(0),
                            ),
                            margin: EdgeInsets.only(
                                left: ResponsiveScreen()
                                    .widthMediaQuery(context, 10)),
                            decoration: BoxDecoration(
                              color: ConstantsColors.LIGHT_GRAY,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          )
                        : document['type'] == 2
                            ? Container(
                                child: Image.asset(
                                  'assets/${document['content']}.gif',
                                  width: ResponsiveScreen()
                                      .widthMediaQuery(context, 100),
                                  height: ResponsiveScreen()
                                      .widthMediaQuery(context, 100),
                                  fit: BoxFit.cover,
                                ),
                                margin: EdgeInsets.only(
                                    left: ResponsiveScreen()
                                        .widthMediaQuery(context, 10)),
                              )
                            : document['type'] == 3
                                ? Container(
                                    width: ResponsiveScreen()
                                        .widthMediaQuery(context, 200),
                                    height: ResponsiveScreen()
                                        .widthMediaQuery(context, 200),
                                    key: PageStorageKey(
                                      "keydata$index",
                                    ),
                                    child: WidgetVideo(
                                      url: document['content'],
                                    ),
                                    decoration: BoxDecoration(
                                      color: ConstantsColors.LIGHT_GRAY,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  )
                                : document['type'] == 4
                                    ? Container(
                                        width: ResponsiveScreen()
                                            .widthMediaQuery(context, 300),
                                        height: ResponsiveScreen()
                                            .heightMediaQuery(context, 105),
                                        child: WidgetAudio(
                                          url: document['content'],
                                        ),
                                        decoration: BoxDecoration(
                                          color: ConstantsColors.LIGHT_GRAY,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      )
                                    : document['type'] == 5
                                        ? GestureDetector(
                                            onTap: () => _mobX.videoSendMessage(
                                                widget.peerId, context),
                                            child: Container(
                                              child: const Text(
                                                'Join video call',
                                                style: TextStyle(
                                                    color: Colors.lightBlue),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                vertical: ResponsiveScreen()
                                                    .heightMediaQuery(
                                                        context, 10),
                                                horizontal: ResponsiveScreen()
                                                    .widthMediaQuery(
                                                        context, 15),
                                              ),
                                              width: ResponsiveScreen()
                                                  .widthMediaQuery(
                                                      context, 200),
                                              decoration: BoxDecoration(
                                                color:
                                                    ConstantsColors.LIGHT_GRAY,
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              margin: EdgeInsets.only(
                                                  left: ResponsiveScreen()
                                                      .widthMediaQuery(
                                                          context, 10)),
                                            ),
                                          )
                                        : Container(),
              ],
            ),
            _mobX.isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(
                          int.parse(
                            document['timestamp'],
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: ConstantsColors.DARK_GRAY,
                        fontSize: 12.0,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    margin: EdgeInsets.only(
                      left: ResponsiveScreen().widthMediaQuery(context, 50),
                      top: ResponsiveScreen().heightMediaQuery(context, 5),
                      bottom: ResponsiveScreen().widthMediaQuery(context, 5),
                    ),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(
            bottom: ResponsiveScreen().heightMediaQuery(context, 10)),
      );
    }
  }

  Widget _loading() {
    return _mobX.isLoadingGet
        ? Center(
            child: Container(
              decoration: BoxDecoration(
                color: ConstantsColors.DARK_GRAY2,
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : Container();
  }
}
