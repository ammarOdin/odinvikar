import 'dart:html';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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

    await file.writeAsBytes(bytes);

    return file;

  }

  static Future openFile(File file) async {
    final url = file.relativePath;

    await OpenFile.open(url);
  }
}
