import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;

import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  Future<String> createPdf(String title, String fullTranscript, String summary) async {
    final pdf = pw.Document();

    // ✅ 1. NotoSansKR 폰트 로드
    final fontData = await rootBundle.load('assets/fonts/NotoSansKR-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    // ✅ 2. PDF 페이지 구성
    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: ttf),
        build: (context) => [
          pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          pw.Text('요약', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text(summary, style: pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 20),
          pw.Text('전체 회의록', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text(fullTranscript, style: pw.TextStyle(fontSize: 14)),
        ],
      ),
    );

    // ✅ 3. 파일 저장
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/meeting_summary.pdf');
    await file.writeAsBytes(await pdf.save());

    return file.path; // 경로 반환
  }
}
