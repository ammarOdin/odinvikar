import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<HomeScreen> {


  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 0),
      children: [
        Container(
          color: Colors.blue,
          margin: const EdgeInsets.only(bottom: 10),
          height: MediaQuery.of(context).size.height / 3,
          child: ListView(
            children: [
              Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 30),
                  child: const Center(
                      child: Text(
                        "Næste mulige vagt",
                        style: TextStyle(color: Colors.white),
                      ))),
              Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 40),
                child: const Center(
                    child: Text(
                      "DATO",
                      style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                    )),
              ),
            ],
          ),
        ),
        Container(padding: const EdgeInsets.only(top: 20, bottom: 20, left: 20), child: const Text("Denne Uge", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),),

        CardFb2(text: "Vikar - DATO", imageUrl: "https://katrinebjergskolen.aarhus.dk/media/23192/aula-logo.jpg?anchor=center&mode=crop&width=1200&height=630&rnd=132022572610000000", subtitle: "Se mere", onPressed: showJobInfo),
      ],
    );
  }
  Future showJobInfo () => showSlidingBottomSheet(
    context,
    builder: (context) => SlidingSheetDialog(
      duration: const Duration(milliseconds: 450),
      snapSpec: const SnapSpec(
          snappings: [0.4, 0.7, 1], initialSnap: 0.4
      ),
      builder: showJob,
      /////headerBuilder: buildHeader,
      avoidStatusBar: true,
      cornerRadius: 15,
    ),
  );

  Widget buildHeader(BuildContext context, SheetState state) => Material(child: Stack(children: <Widget>[Container(height: MediaQuery.of(context).size.height / 3 , color: Colors.blue,),Positioned(bottom: 20, child: SizedBox(width: MediaQuery.of(context).size.width, height: 40, child: Image.network("https://katrinebjergskolen.aarhus.dk/media/23192/aula-logo.jpg?anchor=center&mode=crop&width=1200&height=630&rnd=132022572610000000", height: 59, fit: BoxFit.contain)))],),);

  Widget showJob(context, state) => Material(
    child: ListView(
      shrinkWrap: true,
      primary: false,
      children: [
        Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.only(bottom: 30), child: const Center(child: Text("Vagt Detaljer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),),),
        Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.only(bottom: 10, left: 10), child: const Align(alignment: Alignment.centerLeft, child: Text("Mulige vagt: DATO"),) ,),
        Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.only(bottom: 10, left: 10), child: const Align(alignment: Alignment.centerLeft, child: Text("Du vil blive kontaktet på dagen hvis du får vagten. Ellers kontakter du IKKE vagt-telefonen."),) ,),
        //Container(margin: const EdgeInsets.all(3), decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.8), borderRadius: const BorderRadius.all(Radius.circular(10))), child: ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.transparent, shadowColor: Colors.transparent, ), onPressed: () {  }, child: Align(alignment: Alignment.centerLeft, child: Row(children: const [Align(alignment: Alignment.centerLeft, child: Text("Rediger", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)), Spacer(), Align(alignment: Alignment.centerRight, child: Icon(Icons.edit, color: Colors.black,))]),)) ,),
        Container(margin: const EdgeInsets.only(top: 3, left: 3, right: 3, bottom: 15), decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.8), borderRadius: const BorderRadius.all(Radius.circular(10))), child: ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.transparent, shadowColor: Colors.transparent, ), onPressed: () {  }, child: Align(alignment: Alignment.centerLeft, child: Row(children: const [Align(alignment: Alignment.centerLeft, child: Text("Slet", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),)), Spacer(), Align(alignment: Alignment.centerRight, child: Icon(Icons.delete, color: Colors.red,))]),)) ,),
      ],
    ),
  );

}

class CardFb2 extends StatelessWidget {
  final String text;
  final String imageUrl;
  final String subtitle;
  final Function() onPressed;

  const CardFb2(
      {required this.text,
        required this.imageUrl,
        required this.subtitle,
        required this.onPressed,
        Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 75,
        padding: const EdgeInsets.all(15.0),
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.5),
          boxShadow: [
            BoxShadow(
                offset: const Offset(10, 20),
                blurRadius: 10,
                spreadRadius: 0,
                color: Colors.grey.withOpacity(.05)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(width: 60, height: 40, child: Image.network(imageUrl, height: 59, fit: BoxFit.cover))),
            const SizedBox(
              width: 15,
            ),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )),
            const Spacer(),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                  fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
