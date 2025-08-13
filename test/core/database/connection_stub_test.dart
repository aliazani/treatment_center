@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/core/database/connection_stub.dart' as stub;

void main() {
  test('stub throws UnsupportedError', () {
    expect(() => stub.openConnection(), throwsUnsupportedError);
  });
}
