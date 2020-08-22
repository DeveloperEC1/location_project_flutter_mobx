import 'package:flutter/material.dart';
import 'package:locationprojectflutter/presentation/utils/responsive_screen.dart';

class TFFFirebase extends StatelessWidget {
  final Icon icon;
  final String hint;
  final TextEditingController controller;
  final bool obSecure;
  final TextInputType textInputType;

  const TFFFirebase(
      {Key key,
        this.icon,
        this.hint,
        this.controller,
        this.obSecure,
        this.textInputType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: ResponsiveScreen().widthMediaQuery(context, 20),
        right: ResponsiveScreen().widthMediaQuery(context, 20),
      ),
      child: Center(
        child: TextFormField(
          key: key,
          controller: controller,
          obscureText: obSecure,
          keyboardType: textInputType,
          validator: (String value) {
            if (value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
          style: TextStyle(
            fontSize: 20,
            color: Colors.greenAccent,
          ),
          decoration: InputDecoration(
            hintStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            hintText: hint,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: Colors.green,
                width: 2,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: Colors.green,
                width: 3,
              ),
            ),
            prefixIcon: Padding(
              child: IconTheme(
                data: IconThemeData(
                  color: Colors.green,
                ),
                child: icon,
              ),
              padding: EdgeInsets.only(
                left: ResponsiveScreen().widthMediaQuery(context, 30),
                right: ResponsiveScreen().widthMediaQuery(context, 10),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
