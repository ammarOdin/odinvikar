import 'dart:html';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';

class PdfApi {

  double calculateShiftsHoursAverage(){
    double averageHours = 0;

    return averageHours;
  }

  double calculateCommission(){
    double commission = 0;

    return commission;
  }


  static Future<File> generateInvoice() async{
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context){
        return pw.Center(
          child: pw.Text("Invoice")
        );
      }
    ));

    return saveDocument(name: 'Faktura - Vikarly', pdf: pdf);
  }

  static Future<File> saveDocument({required name, required pdf}) async  {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');

  }
}
