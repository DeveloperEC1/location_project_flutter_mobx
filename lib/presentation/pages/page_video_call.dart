import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:locationprojectflutter/presentation/state_management/mobx/mobx_video_call.dart';
import 'package:locationprojectflutter/presentation/utils/responsive_screen.dart';
import 'package:locationprojectflutter/presentation/widgets/widget_app_bar_total.dart';

class PageVideoCall extends StatefulWidget {
  final String channelName;
  final ClientRole role;

  const PageVideoCall({Key key, this.channelName, @required this.role})
      : super(key: key);

  @override
  _PageVideoCallState createState() => _PageVideoCallState();
}

class _PageVideoCallState extends State<PageVideoCall> {
  MobXVideoCallStore _mobX = MobXVideoCallStore();

  @override
  void initState() {
    super.initState();

    _mobX.isMuted(false);
    _mobX.infoStringsClear();
    _mobX.usersClear();
    _mobX.initialize(widget.channelName, widget.role);
  }

  @override
  void dispose() {
    super.dispose();

    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: WidgetAppBarTotal(),
          body: _body(),
        );
      },
    );
  }

  Widget _body() {
    return Stack(
      children: <Widget>[
        _viewRows(),
        // _panel(),
        _toolbar(),
      ],
    );
  }

  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
          child: Column(
            children: <Widget>[_videoView(views[0])],
          ),
        );
      case 2:
        return Container(
          child: Column(
            children: <Widget>[
              _expandedVideoRow([views[0]]),
              _expandedVideoRow([views[1]])
            ],
          ),
        );
      case 3:
        return Container(
          child: Column(
            children: <Widget>[
              _expandedVideoRow(views.sublist(0, 2)),
              _expandedVideoRow(views.sublist(2, 3))
            ],
          ),
        );
      case 4:
        return Container(
          child: Column(
            children: <Widget>[
              _expandedVideoRow(views.sublist(0, 2)),
              _expandedVideoRow(views.sublist(2, 4))
            ],
          ),
        );
      default:
    }
    return Container();
  }

  List<Widget> _getRenderViews() {
    final List<AgoraRenderWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(AgoraRenderWidget(0, local: true, preview: true));
    }
    _mobX.isUsersGet.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
    return list;
  }

  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(children: wrappedViews),
    );
  }

  Widget _toolbar() {
    if (widget.role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.symmetric(
          vertical: ResponsiveScreen().heightMediaQuery(context, 48)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _mobX.onToggleMute,
            child: Icon(
              _mobX.isMutedGet ? Icons.mic_off : Icons.mic,
              color: _mobX.isMutedGet ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: const CircleBorder(),
            elevation: ResponsiveScreen().widthMediaQuery(context, 2),
            fillColor: _mobX.isMutedGet ? Colors.blueAccent : Colors.white,
            padding:
                EdgeInsets.all(ResponsiveScreen().widthMediaQuery(context, 12)),
          ),
          RawMaterialButton(
            onPressed: () => _mobX.onCallEnd(context),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: const CircleBorder(),
            elevation: ResponsiveScreen().widthMediaQuery(context, 2),
            fillColor: Colors.redAccent,
            padding:
                EdgeInsets.all(ResponsiveScreen().widthMediaQuery(context, 15)),
          ),
          RawMaterialButton(
            onPressed: _mobX.onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: const CircleBorder(),
            elevation: ResponsiveScreen().widthMediaQuery(context, 2),
            fillColor: Colors.white,
            padding:
                EdgeInsets.all(ResponsiveScreen().widthMediaQuery(context, 12)),
          )
        ],
      ),
    );
  }

// Widget _panel() {
//   return Container(
//     padding: EdgeInsets.symmetric(
//         vertical: ResponsiveScreen().heightMediaQuery(context, 48)),
//     alignment: Alignment.bottomCenter,
//     child: FractionallySizedBox(
//       heightFactor: 0.5,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 48),
//         child: ListView.builder(
//           reverse: true,
//           itemCount: _provider.isInfoStringsGet.length,
//           itemBuilder: (BuildContext context, int index) {
//             if (_provider.isInfoStringsGet.isEmpty) {
//               return null;
//             }
//             return Padding(
//               padding: EdgeInsets.symmetric(
//                 vertical: ResponsiveScreen().heightMediaQuery(context, 3),
//                 horizontal: ResponsiveScreen().widthMediaQuery(context, 10),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Flexible(
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         vertical:
//                             ResponsiveScreen().heightMediaQuery(context, 2),
//                         horizontal:
//                             ResponsiveScreen().widthMediaQuery(context, 5),
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.yellowAccent,
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                       child: Text(
//                         _provider.isInfoStringsGet[index],
//                         style: const TextStyle(color: Colors.blueGrey),
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     ),
//   );
// }
}
