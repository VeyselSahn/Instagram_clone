import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

class Undeletable extends StatefulWidget {
  final Future future;
  final dynamic builder;

  const Undeletable({Key key, this.future, this.builder}) : super(key: key);

  @override
  _UndeletableState createState() => _UndeletableState();
}

class _UndeletableState extends State<Undeletable> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
        future: widget.future,
        builder: widget.builder);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;


}
