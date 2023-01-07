import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:locationprojectflutter/core/constants/constants_colors.dart';
import 'package:locationprojectflutter/presentation/state_management/mobx/mobx_live_chat.dart';
import 'package:locationprojectflutter/presentation/utils/responsive_screen.dart';
import 'package:locationprojectflutter/presentation/widgets/widget_app_bar_total.dart';

class PageLiveChat extends StatefulWidget {
  @override
  _PageLiveChatState createState() => _PageLiveChatState();
}

class _PageLiveChatState extends State<PageLiveChat> {
  MobXLiveChatStore _mobX = MobXLiveChatStore();

  @override
  void initState() {
    super.initState();

    _mobX.initGetSharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.blueGrey,
          appBar: WidgetAppBarTotal(),
          body: _body(),
        );
      },
    );
  }

  Widget _body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _listViewData(),
        _sendMessage(),
      ],
    );
  }

  Widget _listViewData() {
    return StreamBuilder(
      stream: _mobX.firestoreGet
          .collection('liveMessages')
          .orderBy('date', descending: true)
          .limit(50)
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
          return Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _mobX.listMessageGet.length,
              itemBuilder: (BuildContext ctx, int index) {
                return _message(
                  _mobX.listMessageGet[index].data()['from'],
                  _mobX.listMessageGet[index].data()['text'],
                  _mobX.valueUserEmailGet ==
                      _mobX.listMessageGet[index].data()['from'],
                );
              },
            ),
          );
        }
      },
    );
  }

  Widget _sendMessage() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: ResponsiveScreen().heightMediaQuery(context, 5)),
      child: Container(
        child: Row(
          children: <Widget>[
            _buildInput(),
            _sendButton("Send", _mobX.callback),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
        ),
        child: TextFormField(
          style: const TextStyle(color: Colors.blueGrey),
          onSaved: (value) => _mobX.callback(),
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            hintText: 'Type your message...',
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: Colors.green,
                width: ResponsiveScreen().widthMediaQuery(context, 2),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: Colors.green,
                width: ResponsiveScreen().widthMediaQuery(context, 3),
              ),
            ),
          ),
          controller: _mobX.messageControllerGet,
        ),
      ),
    );
  }

  Widget _sendButton(String text, VoidCallback callback) {
    return FlatButton(
      color: Colors.greenAccent,
      textColor: Colors.blueGrey,
      onPressed: callback,
      child: Text(text),
    );
  }

  Widget _message(String from, String text, bool me) {
    return Container(
      child: Column(
        crossAxisAlignment:
            me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            from,
            style: TextStyle(color: me ? Colors.lightGreen : Colors.lightBlue),
          ),
          Material(
            color: me ? Colors.lightGreenAccent : Colors.lightBlueAccent,
            borderRadius: BorderRadius.circular(10.0),
            elevation: ResponsiveScreen().widthMediaQuery(context, 6),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveScreen().heightMediaQuery(context, 10),
                horizontal: ResponsiveScreen().widthMediaQuery(context, 15),
              ),
              child: Text(
                text,
                style: const TextStyle(color: Colors.blueGrey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
