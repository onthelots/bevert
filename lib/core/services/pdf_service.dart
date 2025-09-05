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
  Future<String> createPdf(String title, {String? summary, String? fullTranscript}) async {
    final pdf = pw.Document();

    // ✅ 1. NotoSansKR 폰트 로드 (Regular, Bold)
    final fontData = await rootBundle.load('assets/fonts/NotoSansKR-Regular.ttf');
    final boldFontData = await rootBundle.load('assets/fonts/NotoSansKR-Bold.ttf');
    final ttf = pw.Font.ttf(fontData);
    final boldTtf = pw.Font.ttf(boldFontData);

    // ✅ 2. PDF 페이지 구성
    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(
          base: ttf,
          bold: boldTtf,
        ),
        build: (context) {
          final List<pw.Widget> content = [];

          // 제목 추가
          content.add(pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)));
          content.add(pw.SizedBox(height: 20));

          // 요약 추가 (존재하는 경우)
          if (summary != null && summary.isNotEmpty) {
            content.add(pw.Text('요약', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)));
            content.add(pw.SizedBox(height: 10));
            content.add(pw.Text(summary, style: pw.TextStyle(fontSize: 14)));
            content.add(pw.SizedBox(height: 20));
          }

          // 전체 회의록 추가 (존재하는 경우)
          if (fullTranscript != null && fullTranscript.isNotEmpty) {
            content.add(pw.Text('전체 회의록', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)));
            content.add(pw.SizedBox(height: 10));
            content.add(pw.Text(fullTranscript, style: pw.TextStyle(fontSize: 14)));
          }

          return content;
        },
      ),
    );

    // ✅ 3. 파일 저장
    final output = await getTemporaryDirectory();
    // 파일 이름으로 사용할 수 없는 문자를 언더스코어(_)로 대체
    final sanitizedTitle = title.replaceAll(RegExp(r'[\/:*?"<>|]'), '_');
    final file = File('${output.path}/$sanitizedTitle.pdf');
    await file.writeAsBytes(await pdf.save());

    return file.path; // 경로 반환
  }
}
