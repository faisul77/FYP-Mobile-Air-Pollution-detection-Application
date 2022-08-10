import 'package:flutter/cupertino.dart';

class PARAMETERS extends StatefulWidget {
  final String? parametervalue;
  final String parametername;
  final String parameterunit;
  const PARAMETERS({Key? key,required this.parametervalue,required this.parametername, required this.parameterunit}) : super(key: key);

  @override
  _ParameterState createState() => _ParameterState();
}

class _ParameterState extends State<PARAMETERS> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          widget.parametervalue.toString(),
          style: new TextStyle(
            fontSize: 20,
          ),
        ),
        Text(
          widget.parametername.toString(),
        ),
        Text(
          widget.parameterunit.toString(),
        )
      ],
    );
  }
}
