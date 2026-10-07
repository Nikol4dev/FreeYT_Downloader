import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'android_engine.dart';
import 'engine.dart';
import 'windows_engine.dart';

final engineProvider = Provider<DownloadEngine>((_) => Platform.isAndroid ? AndroidEngine() : WindowsEngine());

String friendlyError(Object? error) {
  final raw = error is PlatformException
      ? (error.message ?? '')
      : (error?.toString() ?? '').replaceFirst('Exception: ', '');
  final t = raw.toLowerCase();

  if (t.contains('not a bot')) return 'Bot check. Update engine, retry';
  if (t.contains('confirm your age') || t.contains('age-restricted')) return 'Age-restricted';
  if (t.contains('private video')) return 'Private video';
  if (t.contains('not available in your country') || t.contains('geo')) return 'Region blocked';
  if (t.contains('video unavailable') || t.contains('has been removed') || t.contains('no longer available')) {
    return 'Unavailable';
  }
  if (t.contains('unable to resolve host') ||
      t.contains('network is unreachable') ||
      t.contains('timed out') ||
      t.contains('timeoutexception')) {
    return 'No connection';
  }
  if (t.contains('no space left') || t.contains('enospc')) return 'No storage space';
  if (t.contains('http error 403') || t.contains('unable to extract') || t.contains('nsig')) {
    return 'Update engine, retry';
  }
  return raw.isEmpty ? 'Unknown error' : raw.split('\n').first;
}
