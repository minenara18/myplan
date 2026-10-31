import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Adapter Dio palsu untuk pengujian RemoteRepository tanpa jaringan.
class FakeDioAdapter implements HttpClientAdapter {
  FakeDioAdapter(this.onFetch);

  /// Handler per permintaan: balikkan ResponseBody sesuai skenario.
  final Future<ResponseBody> Function(RequestOptions options) onFetch;

  final List<RequestOptions> capturedRequests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    capturedRequests.add(options);
    return onFetch(options);
  }

  @override
  void close({bool force = false}) {}
}

/// Buat ResponseBody JSON dengan header application/json.
ResponseBody fakeJsonResponse(int statusCode, Map<String, dynamic> body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: const ['application/json'],
    },
  );
}
