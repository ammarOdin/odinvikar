import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class PdfApi {

  static Future<File> generateInvoice(String month, String shiftAmount, String shiftLength, String averageLength, String averagePay, String commission) async {
    final pdf = pw.Document();
    final image = (await rootBundle.load('assets/icon_iOS.png')).buffer.asUint8List();

    pdf.addPage(
        pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context){
        return pw.ListView(
          children: [
            pw.Header(
                child: pw.Text("Timer for " + month + " - Odinskolen", style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold))
            ),
            pw.Container(
                alignment: pw.Alignment.centerLeft,
                padding: pw.EdgeInsets.only(bottom: 10, top: 20),
                child:pw.Text("Antal vagter: " + shiftAmount, style: pw.TextStyle(fontSize: 18,))
            ),
            pw.Container(
                alignment: pw.Alignment.centerLeft,
                padding: pw.EdgeInsets.only(bottom: 10),
                child: pw.Text("Antal timer: " + shiftLength, style: pw.TextStyle(fontSize: 18,))
            ),
            pw.Container(
                alignment: pw.Alignment.centerLeft,
                padding: pw.EdgeInsets.only(bottom: 10),
                child: pw.Text("Gennemsnittelig antal timer pr. vagt: " + averageLength, style: pw.TextStyle(fontSize: 18,))
            ),
            pw.Container(
                alignment: pw.Alignment.centerLeft,
                padding: pw.EdgeInsets.only(bottom: 10),
                child: pw.Text("Gennemsnittelig løn pr. vagt: " + averagePay + ",-", style: pw.TextStyle(fontSize: 18,))
            ),
            pw.Container(
                alignment: pw.Alignment.centerLeft,
                padding: pw.EdgeInsets.only(bottom: 10, top: 30),
                child: pw.Text("2,5 % kommision for " + month + " måned: " + commission + ",-", style: pw.TextStyle(fontSize: 18,))
            ),
            pw.Spacer(),
            pw.Row(
        children: [
          pw.Container(
        alignment: pw.Alignment.centerLeft,
        //padding: pw.EdgeInsets.only(right: 50),
        child: pw.Text("Fil genereret: " + DateFormat('dd/MM/yyyy').add_Hm().format(DateTime.now()), style: pw.TextStyle(fontSize: 14,))),
          /*pw.Container(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text("Send til afregning", style: pw.TextStyle(fontSize: 14,))),*/
        pw.Spacer(),
        pw.SizedBox(
          height: 75,
          child: pw.Image(pw.MemoryImage(image)),),
              ]
            ),
          ]
        );
      },
    ));
    return saveDocument(name: 'faktura_vikarly.pdf', pdf: pdf);
  }

  static Future<File> saveDocument({required name, required pdf}) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');

    await file.writeAsBytes(bytes);
    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;
    await OpenFile.open(url);
  }
}