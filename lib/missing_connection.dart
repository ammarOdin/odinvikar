import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class MissingConnectionPage extends StatefulWidget {
  const MissingConnectionPage({Key? key}) : super(key: key);

  @override
  State<MissingConnectionPage> createState() => _MissingConnectionPageState();
}

class _MissingConnectionPageState extends State<MissingConnectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        toolbarHeight: kToolbarHeight + 2,
        //iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 40),
            child: Center(
              child: Text("Internetforbindelse", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 15, top: 10),
            child: Text("Du har ikke forbindelse til internettet. For at app'en kan fungere, skal du være koblet til et netværk.",
              style: TextStyle(fontSize: 14, color: Colors.grey),),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 40),
            child: ElevatedButton.icon(onPressed: () async {
/*
              bool result = await InternetConnectionChecker().hasConnection;
              if (result == true) {
                Navigator.pop(context);
              } else {
                showTopSnackBar(context, CustomSnackBar.error(message: "Ingen forbindelse. Prøv igen",),);
              }
            */}, icon: const Icon(Icons.wifi), label: const Align(alignment: Alignment.centerLeft, child: Text("Test forbindelse")), style: ButtonStyle(shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: const BorderSide(color: Colors.blue)
                )
            )),),
          ),
        ],
      ),
    );
  }
}
