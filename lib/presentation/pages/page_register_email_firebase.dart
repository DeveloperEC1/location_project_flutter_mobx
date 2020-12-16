import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:locationprojectflutter/presentation/state_management/mobx/mobx_register_email_firebase.dart';
import 'package:locationprojectflutter/presentation/utils/utils_app.dart';
import 'package:locationprojectflutter/presentation/utils/responsive_screen.dart';
import 'package:locationprojectflutter/presentation/widgets/widget_btn_firebase.dart';
import 'package:locationprojectflutter/presentation/widgets/widget_tff_firebase.dart';

class PageRegisterEmailFirebase extends StatefulWidget {
  @override
  _PageRegisterEmailFirebaseState createState() =>
      _PageRegisterEmailFirebaseState();
}

class _PageRegisterEmailFirebaseState extends State<PageRegisterEmailFirebase> {
  MobXRegisterEmailFirebaseStore _mobX = MobXRegisterEmailFirebaseStore();

  @override
  void initState() {
    super.initState();

    _mobX.initGetSharedPrefs();
    _mobX.isSuccess(null);
    _mobX.isLoading(false);
    _mobX.textError('');
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.blueGrey,
          body: Form(
            key: _mobX.formKeyGet,
            child: Container(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _title(),
                      UtilsApp.dividerHeight(context, 70),
                      _textFieldsData(),
                      UtilsApp.dividerHeight(context, 20),
                      _buttonRegister(),
                      UtilsApp.dividerHeight(context, 5),
                      _showErrors(),
                      _buttonToLogin(),
                      UtilsApp.dividerHeight(context, 20),
                      _loading(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _title() {
    return const Text(
      'Register',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.greenAccent,
        fontSize: 40,
      ),
    );
  }

  Widget _textFieldsData() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: ResponsiveScreen().heightMediaQuery(context, 20),
          ),
          child: WidgetTFFFirebase(
            icon: const Icon(Icons.email),
            hint: "Email",
            controller: _mobX.emailControllerGet,
            textInputType: TextInputType.emailAddress,
            obSecure: false,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: ResponsiveScreen().heightMediaQuery(context, 20),
          ),
          child: WidgetTFFFirebase(
            icon: const Icon(Icons.lock),
            hint: "Password",
            controller: _mobX.passwordControllerGet,
            textInputType: TextInputType.text,
            obSecure: true,
          ),
        ),
      ],
    );
  }

  Widget _buttonRegister() {
    return Padding(
      padding: EdgeInsets.only(
          left: ResponsiveScreen().widthMediaQuery(context, 20),
          right: ResponsiveScreen().widthMediaQuery(context, 20),
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: WidgetBtnFirebase(
        text: 'Register',
        onTap: () => _mobX.checkClickBtnRegister(context),
      ),
    );
  }

  Widget _showErrors() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        _mobX.isSuccessGet == null
            ? ''
            : _mobX.isSuccessGet
                ? ''
                : _mobX.textErrorGet,
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 15,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buttonToLogin() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: const Text(
        'Have an account? click here to login',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _loading() {
    return _mobX.isLoadingGet == true
        ? const CircularProgressIndicator()
        : Container();
  }
}
