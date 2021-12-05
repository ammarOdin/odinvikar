import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddDayScreen  extends StatefulWidget {
  const AddDayScreen ({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<AddDayScreen>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: buildBody(),
    );
  }

  buildBody() {
    return ListView(
      children: [
        const Center(child: Text("Tilføj dage", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),), ),
        Container(),
        Container(),
      ],
    );
  }
}
