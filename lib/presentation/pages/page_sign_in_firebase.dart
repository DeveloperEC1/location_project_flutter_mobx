import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:locationprojectflutter/core/constants/constants_images.dart';
import 'package:locationprojectflutter/presentation/state_management/mobx/mobx_sign_in_firebase.dart';
import 'package:locationprojectflutter/presentation/utils/shower_pages.dart';
import 'package:locationprojectflutter/presentation/utils/utils_app.dart';
import 'package:locationprojectflutter/presentation/utils/responsive_screen.dart';
import 'package:locationprojectflutter/presentation/widgets/widget_btn_firebase.dart';
import 'package:locationprojectflutter/presentation/widgets/widget_tff_firebase.dart';

class PageSignInFirebase extends StatefulWidget {
  @override
  _PageSignInFirebaseState createState() => _PageSignInFirebaseState();
}

class _PageSignInFirebaseState extends State<PageSignInFirebase> {
  MobXSignInFirebaseStore _mobX = MobXSignInFirebaseStore();

  @override
  void initState() {
    super.initState();

    _mobX.checkUserLogin(context);
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
          body: _body(context),
        );
      },
    );
  }

  Widget _body(BuildContext context) {
    return Form(
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
                _buttonLogin(),
                UtilsApp.dividerHeight(context, 5),
                _showErrors(),
                _buttonToRegister(),
                UtilsApp.dividerHeight(context, 20),
                _loginFacebookGmailSms(),
                UtilsApp.dividerHeight(context, 20),
                _loading(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _title() {
    return const Text(
      'Login',
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
            key: const Key('emailLogin'),
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
            key: const Key('passwordLogin'),
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

  Widget _buttonLogin() {
    return Padding(
      padding: EdgeInsets.only(
          left: ResponsiveScreen().widthMediaQuery(context, 20),
          right: ResponsiveScreen().widthMediaQuery(context, 20),
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: WidgetBtnFirebase(
        text: 'Login',
        onTap: () => _mobX.checkClickBtnLogin(context),
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

  Widget _buttonToRegister() {
    return GestureDetector(
      onTap: () {
        ShowerPages.pushPageRegisterEmailFirebase(context);
      },
      child: const Text(
        'Don' + "'" + 't Have an account? click here to register',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _loginFacebookGmailSms() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: ResponsiveScreen().widthMediaQuery(context, 60),
          height: ResponsiveScreen().widthMediaQuery(context, 60),
          child: MaterialButton(
            shape: const CircleBorder(),
            child: Image.asset(ConstantsImages.FACEBOOK_ICON),
            color: Colors.white,
            onPressed: () {
              _mobX.facebookLogin(context);
              _mobX.isLoading(true);
              _mobX.textError('');
            },
          ),
        ),
        UtilsApp.dividerWidth(context, 20),
        Container(
          width: ResponsiveScreen().widthMediaQuery(context, 60),
          height: ResponsiveScreen().widthMediaQuery(context, 60),
          child: MaterialButton(
            shape: const CircleBorder(),
            child: Image.asset(ConstantsImages.GOOGLE_ICON),
            color: Colors.white,
            onPressed: () {
              _mobX.signInWithGoogle(context);
              _mobX.isLoading(true);
              _mobX.textError('');
            },
          ),
        ),
        UtilsApp.dividerWidth(context, 20),
        Container(
          width: ResponsiveScreen().widthMediaQuery(context, 60),
          height: ResponsiveScreen().widthMediaQuery(context, 60),
          child: MaterialButton(
            shape: const CircleBorder(),
            child: Image.asset(ConstantsImages.PHONE_ICON),
            color: Colors.white,
            onPressed: () {
              ShowerPages.pushPagePhoneSmsAuth(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _loading() {
    return _mobX.isLoadingGet == true
        ? const CircularProgressIndicator()
        : Container();
  }
}
