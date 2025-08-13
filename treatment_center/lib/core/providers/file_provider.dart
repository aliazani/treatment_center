export 'file_provider_stub.dart'
    if (dart.library.ffi) 'file_provider_io.dart'
    if (dart.library.js_interop) 'file_provider_web.dart';
