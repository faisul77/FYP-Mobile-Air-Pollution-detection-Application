import 'package:air_pollution_quality_monitor/read/parameters.dart';
import 'package:flutter/material.dart';

class PARAMETERSTREAMBUILDER extends StatefulWidget {
  final Stream<List<int>>? paramstream;
  final String paramname;
  final String paramunit;
  const PARAMETERSTREAMBUILDER({Key? key, required this.paramstream, required this.paramname, required this.paramunit}) : super(key: key);

  @override
  _PARAMETERSTREAMBUILDERState createState() => _PARAMETERSTREAMBUILDERState();
}

class _PARAMETERSTREAMBUILDERState extends State<PARAMETERSTREAMBUILDER> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:widget.paramstream,
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return CircularProgressIndicator();
        }
        return PARAMETERS(parametervalue: snapshot.data.toString(),parametername: widget.paramname, parameterunit: widget.paramunit,);
      },
    );
  }
}
