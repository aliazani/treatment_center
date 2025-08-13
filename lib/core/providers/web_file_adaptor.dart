import 'dart:io' as web;

import 'package:treatment_center/core/providers/web_file.dart';

class WebFileAdapter implements WebFile {
  final web.File underlying;
  WebFileAdapter(this.underlying);
}
