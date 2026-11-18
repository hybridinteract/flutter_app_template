import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// An in-memory asset bundle: maps asset paths to their text content, so
/// tests need no real files under assets/. Provide it to widgets with
/// `DefaultAssetBundle(bundle: FakeAssetBundle({...}), child: ...)`, or pass
/// it to code that takes an `AssetBundle`.
class FakeAssetBundle extends CachingAssetBundle {
  FakeAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final content = assets[key];
    if (content == null) throw FlutterError('Unable to load asset: "$key".');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(content)));
  }
}
