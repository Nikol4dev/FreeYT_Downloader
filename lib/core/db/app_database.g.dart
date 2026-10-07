// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MediaFilesTable extends MediaFiles with TableInfo<$MediaFilesTable, MediaEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _youtubeIdMeta = const VerificationMeta('youtubeId');
  @override
  late final GeneratedColumn<String> youtubeId = GeneratedColumn<String>(
    'youtube_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _channelMeta = const VerificationMeta('channel');
  @override
  late final GeneratedColumn<String> channel = GeneratedColumn<String>(
    'channel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _contentUriMeta = const VerificationMeta('contentUri');
  @override
  late final GeneratedColumn<String> contentUri = GeneratedColumn<String>(
    'content_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeBytesMeta = const VerificationMeta('fileSizeBytes');
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
    'file_size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isAudioOnlyMeta = const VerificationMeta('isAudioOnly');
  @override
  late final GeneratedColumn<bool> isAudioOnly = GeneratedColumn<bool>(
    'is_audio_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_audio_only" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta('thumbnailUrl');
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastPositionMsMeta = const VerificationMeta('lastPositionMs');
  @override
  late final GeneratedColumn<int> lastPositionMs = GeneratedColumn<int>(
    'last_position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta('downloadedAt');
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    youtubeId,
    title,
    channel,
    contentUri,
    durationMs,
    fileSizeBytes,
    isAudioOnly,
    thumbnailUrl,
    isFavorite,
    lastPositionMs,
    downloadedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_files';
  @override
  VerificationContext validateIntegrity(Insertable<MediaEntity> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('youtube_id')) {
      context.handle(_youtubeIdMeta, youtubeId.isAcceptableOrUnknown(data['youtube_id']!, _youtubeIdMeta));
    } else if (isInserting) {
      context.missing(_youtubeIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('channel')) {
      context.handle(_channelMeta, channel.isAcceptableOrUnknown(data['channel']!, _channelMeta));
    }
    if (data.containsKey('content_uri')) {
      context.handle(_contentUriMeta, contentUri.isAcceptableOrUnknown(data['content_uri']!, _contentUriMeta));
    } else if (isInserting) {
      context.missing(_contentUriMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(_durationMsMeta, durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta));
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
        _fileSizeBytesMeta,
        fileSizeBytes.isAcceptableOrUnknown(data['file_size_bytes']!, _fileSizeBytesMeta),
      );
    }
    if (data.containsKey('is_audio_only')) {
      context.handle(_isAudioOnlyMeta, isAudioOnly.isAcceptableOrUnknown(data['is_audio_only']!, _isAudioOnlyMeta));
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(_thumbnailUrlMeta, thumbnailUrl.isAcceptableOrUnknown(data['thumbnail_url']!, _thumbnailUrlMeta));
    } else if (isInserting) {
      context.missing(_thumbnailUrlMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(_isFavoriteMeta, isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('last_position_ms')) {
      context.handle(
        _lastPositionMsMeta,
        lastPositionMs.isAcceptableOrUnknown(data['last_position_ms']!, _lastPositionMsMeta),
      );
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(_downloadedAtMeta, downloadedAt.isAcceptableOrUnknown(data['downloaded_at']!, _downloadedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaEntity(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      youtubeId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}youtube_id'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      channel: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}channel'])!,
      contentUri: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}content_uri'])!,
      durationMs: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}duration_ms'])!,
      fileSizeBytes: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}file_size_bytes'])!,
      isAudioOnly: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_audio_only'])!,
      thumbnailUrl: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}thumbnail_url'])!,
      isFavorite: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      lastPositionMs: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}last_position_ms'])!,
      downloadedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}downloaded_at'])!,
    );
  }

  @override
  $MediaFilesTable createAlias(String alias) {
    return $MediaFilesTable(attachedDatabase, alias);
  }
}

class MediaEntity extends DataClass implements Insertable<MediaEntity> {
  final int id;
  final String youtubeId;
  final String title;
  final String channel;
  final String contentUri;
  final int durationMs;
  final int fileSizeBytes;
  final bool isAudioOnly;
  final String thumbnailUrl;
  final bool isFavorite;
  final int lastPositionMs;
  final DateTime downloadedAt;
  const MediaEntity({
    required this.id,
    required this.youtubeId,
    required this.title,
    required this.channel,
    required this.contentUri,
    required this.durationMs,
    required this.fileSizeBytes,
    required this.isAudioOnly,
    required this.thumbnailUrl,
    required this.isFavorite,
    required this.lastPositionMs,
    required this.downloadedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['youtube_id'] = Variable<String>(youtubeId);
    map['title'] = Variable<String>(title);
    map['channel'] = Variable<String>(channel);
    map['content_uri'] = Variable<String>(contentUri);
    map['duration_ms'] = Variable<int>(durationMs);
    map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    map['is_audio_only'] = Variable<bool>(isAudioOnly);
    map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['last_position_ms'] = Variable<int>(lastPositionMs);
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    return map;
  }

  MediaFilesCompanion toCompanion(bool nullToAbsent) {
    return MediaFilesCompanion(
      id: Value(id),
      youtubeId: Value(youtubeId),
      title: Value(title),
      channel: Value(channel),
      contentUri: Value(contentUri),
      durationMs: Value(durationMs),
      fileSizeBytes: Value(fileSizeBytes),
      isAudioOnly: Value(isAudioOnly),
      thumbnailUrl: Value(thumbnailUrl),
      isFavorite: Value(isFavorite),
      lastPositionMs: Value(lastPositionMs),
      downloadedAt: Value(downloadedAt),
    );
  }

  factory MediaEntity.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaEntity(
      id: serializer.fromJson<int>(json['id']),
      youtubeId: serializer.fromJson<String>(json['youtubeId']),
      title: serializer.fromJson<String>(json['title']),
      channel: serializer.fromJson<String>(json['channel']),
      contentUri: serializer.fromJson<String>(json['contentUri']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      fileSizeBytes: serializer.fromJson<int>(json['fileSizeBytes']),
      isAudioOnly: serializer.fromJson<bool>(json['isAudioOnly']),
      thumbnailUrl: serializer.fromJson<String>(json['thumbnailUrl']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      lastPositionMs: serializer.fromJson<int>(json['lastPositionMs']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'youtubeId': serializer.toJson<String>(youtubeId),
      'title': serializer.toJson<String>(title),
      'channel': serializer.toJson<String>(channel),
      'contentUri': serializer.toJson<String>(contentUri),
      'durationMs': serializer.toJson<int>(durationMs),
      'fileSizeBytes': serializer.toJson<int>(fileSizeBytes),
      'isAudioOnly': serializer.toJson<bool>(isAudioOnly),
      'thumbnailUrl': serializer.toJson<String>(thumbnailUrl),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'lastPositionMs': serializer.toJson<int>(lastPositionMs),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
    };
  }

  MediaEntity copyWith({
    int? id,
    String? youtubeId,
    String? title,
    String? channel,
    String? contentUri,
    int? durationMs,
    int? fileSizeBytes,
    bool? isAudioOnly,
    String? thumbnailUrl,
    bool? isFavorite,
    int? lastPositionMs,
    DateTime? downloadedAt,
  }) => MediaEntity(
    id: id ?? this.id,
    youtubeId: youtubeId ?? this.youtubeId,
    title: title ?? this.title,
    channel: channel ?? this.channel,
    contentUri: contentUri ?? this.contentUri,
    durationMs: durationMs ?? this.durationMs,
    fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    isAudioOnly: isAudioOnly ?? this.isAudioOnly,
    thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    isFavorite: isFavorite ?? this.isFavorite,
    lastPositionMs: lastPositionMs ?? this.lastPositionMs,
    downloadedAt: downloadedAt ?? this.downloadedAt,
  );
  MediaEntity copyWithCompanion(MediaFilesCompanion data) {
    return MediaEntity(
      id: data.id.present ? data.id.value : this.id,
      youtubeId: data.youtubeId.present ? data.youtubeId.value : this.youtubeId,
      title: data.title.present ? data.title.value : this.title,
      channel: data.channel.present ? data.channel.value : this.channel,
      contentUri: data.contentUri.present ? data.contentUri.value : this.contentUri,
      durationMs: data.durationMs.present ? data.durationMs.value : this.durationMs,
      fileSizeBytes: data.fileSizeBytes.present ? data.fileSizeBytes.value : this.fileSizeBytes,
      isAudioOnly: data.isAudioOnly.present ? data.isAudioOnly.value : this.isAudioOnly,
      thumbnailUrl: data.thumbnailUrl.present ? data.thumbnailUrl.value : this.thumbnailUrl,
      isFavorite: data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      lastPositionMs: data.lastPositionMs.present ? data.lastPositionMs.value : this.lastPositionMs,
      downloadedAt: data.downloadedAt.present ? data.downloadedAt.value : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaEntity(')
          ..write('id: $id, ')
          ..write('youtubeId: $youtubeId, ')
          ..write('title: $title, ')
          ..write('channel: $channel, ')
          ..write('contentUri: $contentUri, ')
          ..write('durationMs: $durationMs, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('isAudioOnly: $isAudioOnly, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('lastPositionMs: $lastPositionMs, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    youtubeId,
    title,
    channel,
    contentUri,
    durationMs,
    fileSizeBytes,
    isAudioOnly,
    thumbnailUrl,
    isFavorite,
    lastPositionMs,
    downloadedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaEntity &&
          other.id == this.id &&
          other.youtubeId == this.youtubeId &&
          other.title == this.title &&
          other.channel == this.channel &&
          other.contentUri == this.contentUri &&
          other.durationMs == this.durationMs &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.isAudioOnly == this.isAudioOnly &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.isFavorite == this.isFavorite &&
          other.lastPositionMs == this.lastPositionMs &&
          other.downloadedAt == this.downloadedAt);
}

class MediaFilesCompanion extends UpdateCompanion<MediaEntity> {
  final Value<int> id;
  final Value<String> youtubeId;
  final Value<String> title;
  final Value<String> channel;
  final Value<String> contentUri;
  final Value<int> durationMs;
  final Value<int> fileSizeBytes;
  final Value<bool> isAudioOnly;
  final Value<String> thumbnailUrl;
  final Value<bool> isFavorite;
  final Value<int> lastPositionMs;
  final Value<DateTime> downloadedAt;
  const MediaFilesCompanion({
    this.id = const Value.absent(),
    this.youtubeId = const Value.absent(),
    this.title = const Value.absent(),
    this.channel = const Value.absent(),
    this.contentUri = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.isAudioOnly = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.lastPositionMs = const Value.absent(),
    this.downloadedAt = const Value.absent(),
  });
  MediaFilesCompanion.insert({
    this.id = const Value.absent(),
    required String youtubeId,
    required String title,
    this.channel = const Value.absent(),
    required String contentUri,
    required int durationMs,
    this.fileSizeBytes = const Value.absent(),
    this.isAudioOnly = const Value.absent(),
    required String thumbnailUrl,
    this.isFavorite = const Value.absent(),
    this.lastPositionMs = const Value.absent(),
    this.downloadedAt = const Value.absent(),
  }) : youtubeId = Value(youtubeId),
       title = Value(title),
       contentUri = Value(contentUri),
       durationMs = Value(durationMs),
       thumbnailUrl = Value(thumbnailUrl);
  static Insertable<MediaEntity> custom({
    Expression<int>? id,
    Expression<String>? youtubeId,
    Expression<String>? title,
    Expression<String>? channel,
    Expression<String>? contentUri,
    Expression<int>? durationMs,
    Expression<int>? fileSizeBytes,
    Expression<bool>? isAudioOnly,
    Expression<String>? thumbnailUrl,
    Expression<bool>? isFavorite,
    Expression<int>? lastPositionMs,
    Expression<DateTime>? downloadedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (youtubeId != null) 'youtube_id': youtubeId,
      if (title != null) 'title': title,
      if (channel != null) 'channel': channel,
      if (contentUri != null) 'content_uri': contentUri,
      if (durationMs != null) 'duration_ms': durationMs,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (isAudioOnly != null) 'is_audio_only': isAudioOnly,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (lastPositionMs != null) 'last_position_ms': lastPositionMs,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
    });
  }

  MediaFilesCompanion copyWith({
    Value<int>? id,
    Value<String>? youtubeId,
    Value<String>? title,
    Value<String>? channel,
    Value<String>? contentUri,
    Value<int>? durationMs,
    Value<int>? fileSizeBytes,
    Value<bool>? isAudioOnly,
    Value<String>? thumbnailUrl,
    Value<bool>? isFavorite,
    Value<int>? lastPositionMs,
    Value<DateTime>? downloadedAt,
  }) {
    return MediaFilesCompanion(
      id: id ?? this.id,
      youtubeId: youtubeId ?? this.youtubeId,
      title: title ?? this.title,
      channel: channel ?? this.channel,
      contentUri: contentUri ?? this.contentUri,
      durationMs: durationMs ?? this.durationMs,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      isAudioOnly: isAudioOnly ?? this.isAudioOnly,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      lastPositionMs: lastPositionMs ?? this.lastPositionMs,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (youtubeId.present) {
      map['youtube_id'] = Variable<String>(youtubeId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (channel.present) {
      map['channel'] = Variable<String>(channel.value);
    }
    if (contentUri.present) {
      map['content_uri'] = Variable<String>(contentUri.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (isAudioOnly.present) {
      map['is_audio_only'] = Variable<bool>(isAudioOnly.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (lastPositionMs.present) {
      map['last_position_ms'] = Variable<int>(lastPositionMs.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaFilesCompanion(')
          ..write('id: $id, ')
          ..write('youtubeId: $youtubeId, ')
          ..write('title: $title, ')
          ..write('channel: $channel, ')
          ..write('contentUri: $contentUri, ')
          ..write('durationMs: $durationMs, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('isAudioOnly: $isAudioOnly, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('lastPositionMs: $lastPositionMs, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }
}

class $DownloadTasksTable extends DownloadTasks with TableInfo<$DownloadTasksTable, DownloadTaskEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _channelMeta = const VerificationMeta('channel');
  @override
  late final GeneratedColumn<String> channel = GeneratedColumn<String>(
    'channel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta('thumbnailUrl');
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _presetMeta = const VerificationMeta('preset');
  @override
  late final GeneratedColumn<String> preset = GeneratedColumn<String>(
    'preset',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _progressMeta = const VerificationMeta('progress');
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _playlistMeta = const VerificationMeta('playlist');
  @override
  late final GeneratedColumn<String> playlist = GeneratedColumn<String>(
    'playlist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sectionMeta = const VerificationMeta('section');
  @override
  late final GeneratedColumn<String> section = GeneratedColumn<String>(
    'section',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exactCutMeta = const VerificationMeta('exactCut');
  @override
  late final GeneratedColumn<bool> exactCut = GeneratedColumn<bool>(
    'exact_cut',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("exact_cut" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    url,
    title,
    channel,
    thumbnailUrl,
    durationMs,
    preset,
    status,
    progress,
    playlist,
    section,
    exactCut,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_tasks';
  @override
  VerificationContext validateIntegrity(Insertable<DownloadTaskEntity> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('url')) {
      context.handle(_urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('channel')) {
      context.handle(_channelMeta, channel.isAcceptableOrUnknown(data['channel']!, _channelMeta));
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(_thumbnailUrlMeta, thumbnailUrl.isAcceptableOrUnknown(data['thumbnail_url']!, _thumbnailUrlMeta));
    }
    if (data.containsKey('duration_ms')) {
      context.handle(_durationMsMeta, durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta));
    }
    if (data.containsKey('preset')) {
      context.handle(_presetMeta, preset.isAcceptableOrUnknown(data['preset']!, _presetMeta));
    } else if (isInserting) {
      context.missing(_presetMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('progress')) {
      context.handle(_progressMeta, progress.isAcceptableOrUnknown(data['progress']!, _progressMeta));
    }
    if (data.containsKey('playlist')) {
      context.handle(_playlistMeta, playlist.isAcceptableOrUnknown(data['playlist']!, _playlistMeta));
    }
    if (data.containsKey('section')) {
      context.handle(_sectionMeta, section.isAcceptableOrUnknown(data['section']!, _sectionMeta));
    }
    if (data.containsKey('exact_cut')) {
      context.handle(_exactCutMeta, exactCut.isAcceptableOrUnknown(data['exact_cut']!, _exactCutMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadTaskEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadTaskEntity(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      url: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      channel: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}channel'])!,
      thumbnailUrl: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}thumbnail_url'])!,
      durationMs: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}duration_ms'])!,
      preset: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}preset'])!,
      status: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      progress: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}progress'])!,
      playlist: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}playlist']),
      section: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}section']),
      exactCut: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}exact_cut'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $DownloadTasksTable createAlias(String alias) {
    return $DownloadTasksTable(attachedDatabase, alias);
  }
}

class DownloadTaskEntity extends DataClass implements Insertable<DownloadTaskEntity> {
  final String id;
  final String url;
  final String title;
  final String channel;
  final String thumbnailUrl;
  final int durationMs;
  final String preset;
  final String status;
  final double progress;
  final String? playlist;
  final String? section;
  final bool exactCut;
  final DateTime createdAt;
  const DownloadTaskEntity({
    required this.id,
    required this.url,
    required this.title,
    required this.channel,
    required this.thumbnailUrl,
    required this.durationMs,
    required this.preset,
    required this.status,
    required this.progress,
    this.playlist,
    this.section,
    required this.exactCut,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['url'] = Variable<String>(url);
    map['title'] = Variable<String>(title);
    map['channel'] = Variable<String>(channel);
    map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    map['duration_ms'] = Variable<int>(durationMs);
    map['preset'] = Variable<String>(preset);
    map['status'] = Variable<String>(status);
    map['progress'] = Variable<double>(progress);
    if (!nullToAbsent || playlist != null) {
      map['playlist'] = Variable<String>(playlist);
    }
    if (!nullToAbsent || section != null) {
      map['section'] = Variable<String>(section);
    }
    map['exact_cut'] = Variable<bool>(exactCut);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DownloadTasksCompanion toCompanion(bool nullToAbsent) {
    return DownloadTasksCompanion(
      id: Value(id),
      url: Value(url),
      title: Value(title),
      channel: Value(channel),
      thumbnailUrl: Value(thumbnailUrl),
      durationMs: Value(durationMs),
      preset: Value(preset),
      status: Value(status),
      progress: Value(progress),
      playlist: playlist == null && nullToAbsent ? const Value.absent() : Value(playlist),
      section: section == null && nullToAbsent ? const Value.absent() : Value(section),
      exactCut: Value(exactCut),
      createdAt: Value(createdAt),
    );
  }

  factory DownloadTaskEntity.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadTaskEntity(
      id: serializer.fromJson<String>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String>(json['title']),
      channel: serializer.fromJson<String>(json['channel']),
      thumbnailUrl: serializer.fromJson<String>(json['thumbnailUrl']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      preset: serializer.fromJson<String>(json['preset']),
      status: serializer.fromJson<String>(json['status']),
      progress: serializer.fromJson<double>(json['progress']),
      playlist: serializer.fromJson<String?>(json['playlist']),
      section: serializer.fromJson<String?>(json['section']),
      exactCut: serializer.fromJson<bool>(json['exactCut']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String>(title),
      'channel': serializer.toJson<String>(channel),
      'thumbnailUrl': serializer.toJson<String>(thumbnailUrl),
      'durationMs': serializer.toJson<int>(durationMs),
      'preset': serializer.toJson<String>(preset),
      'status': serializer.toJson<String>(status),
      'progress': serializer.toJson<double>(progress),
      'playlist': serializer.toJson<String?>(playlist),
      'section': serializer.toJson<String?>(section),
      'exactCut': serializer.toJson<bool>(exactCut),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DownloadTaskEntity copyWith({
    String? id,
    String? url,
    String? title,
    String? channel,
    String? thumbnailUrl,
    int? durationMs,
    String? preset,
    String? status,
    double? progress,
    Value<String?> playlist = const Value.absent(),
    Value<String?> section = const Value.absent(),
    bool? exactCut,
    DateTime? createdAt,
  }) => DownloadTaskEntity(
    id: id ?? this.id,
    url: url ?? this.url,
    title: title ?? this.title,
    channel: channel ?? this.channel,
    thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    durationMs: durationMs ?? this.durationMs,
    preset: preset ?? this.preset,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    playlist: playlist.present ? playlist.value : this.playlist,
    section: section.present ? section.value : this.section,
    exactCut: exactCut ?? this.exactCut,
    createdAt: createdAt ?? this.createdAt,
  );
  DownloadTaskEntity copyWithCompanion(DownloadTasksCompanion data) {
    return DownloadTaskEntity(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      channel: data.channel.present ? data.channel.value : this.channel,
      thumbnailUrl: data.thumbnailUrl.present ? data.thumbnailUrl.value : this.thumbnailUrl,
      durationMs: data.durationMs.present ? data.durationMs.value : this.durationMs,
      preset: data.preset.present ? data.preset.value : this.preset,
      status: data.status.present ? data.status.value : this.status,
      progress: data.progress.present ? data.progress.value : this.progress,
      playlist: data.playlist.present ? data.playlist.value : this.playlist,
      section: data.section.present ? data.section.value : this.section,
      exactCut: data.exactCut.present ? data.exactCut.value : this.exactCut,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTaskEntity(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('channel: $channel, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('durationMs: $durationMs, ')
          ..write('preset: $preset, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('playlist: $playlist, ')
          ..write('section: $section, ')
          ..write('exactCut: $exactCut, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    url,
    title,
    channel,
    thumbnailUrl,
    durationMs,
    preset,
    status,
    progress,
    playlist,
    section,
    exactCut,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadTaskEntity &&
          other.id == this.id &&
          other.url == this.url &&
          other.title == this.title &&
          other.channel == this.channel &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.durationMs == this.durationMs &&
          other.preset == this.preset &&
          other.status == this.status &&
          other.progress == this.progress &&
          other.playlist == this.playlist &&
          other.section == this.section &&
          other.exactCut == this.exactCut &&
          other.createdAt == this.createdAt);
}

class DownloadTasksCompanion extends UpdateCompanion<DownloadTaskEntity> {
  final Value<String> id;
  final Value<String> url;
  final Value<String> title;
  final Value<String> channel;
  final Value<String> thumbnailUrl;
  final Value<int> durationMs;
  final Value<String> preset;
  final Value<String> status;
  final Value<double> progress;
  final Value<String?> playlist;
  final Value<String?> section;
  final Value<bool> exactCut;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DownloadTasksCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.channel = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.preset = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.playlist = const Value.absent(),
    this.section = const Value.absent(),
    this.exactCut = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadTasksCompanion.insert({
    required String id,
    required String url,
    required String title,
    this.channel = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.durationMs = const Value.absent(),
    required String preset,
    required String status,
    this.progress = const Value.absent(),
    this.playlist = const Value.absent(),
    this.section = const Value.absent(),
    this.exactCut = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       url = Value(url),
       title = Value(title),
       preset = Value(preset),
       status = Value(status);
  static Insertable<DownloadTaskEntity> custom({
    Expression<String>? id,
    Expression<String>? url,
    Expression<String>? title,
    Expression<String>? channel,
    Expression<String>? thumbnailUrl,
    Expression<int>? durationMs,
    Expression<String>? preset,
    Expression<String>? status,
    Expression<double>? progress,
    Expression<String>? playlist,
    Expression<String>? section,
    Expression<bool>? exactCut,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (channel != null) 'channel': channel,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (durationMs != null) 'duration_ms': durationMs,
      if (preset != null) 'preset': preset,
      if (status != null) 'status': status,
      if (progress != null) 'progress': progress,
      if (playlist != null) 'playlist': playlist,
      if (section != null) 'section': section,
      if (exactCut != null) 'exact_cut': exactCut,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadTasksCompanion copyWith({
    Value<String>? id,
    Value<String>? url,
    Value<String>? title,
    Value<String>? channel,
    Value<String>? thumbnailUrl,
    Value<int>? durationMs,
    Value<String>? preset,
    Value<String>? status,
    Value<double>? progress,
    Value<String?>? playlist,
    Value<String?>? section,
    Value<bool>? exactCut,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DownloadTasksCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      channel: channel ?? this.channel,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      durationMs: durationMs ?? this.durationMs,
      preset: preset ?? this.preset,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      playlist: playlist ?? this.playlist,
      section: section ?? this.section,
      exactCut: exactCut ?? this.exactCut,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (channel.present) {
      map['channel'] = Variable<String>(channel.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (preset.present) {
      map['preset'] = Variable<String>(preset.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (playlist.present) {
      map['playlist'] = Variable<String>(playlist.value);
    }
    if (section.present) {
      map['section'] = Variable<String>(section.value);
    }
    if (exactCut.present) {
      map['exact_cut'] = Variable<bool>(exactCut.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTasksCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('channel: $channel, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('durationMs: $durationMs, ')
          ..write('preset: $preset, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('playlist: $playlist, ')
          ..write('section: $section, ')
          ..write('exactCut: $exactCut, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTable extends Playlists with TableInfo<$PlaylistsTable, Playlist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(Insertable<Playlist> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Playlist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Playlist(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }
}

class Playlist extends DataClass implements Insertable<Playlist> {
  final int id;
  final String name;
  final DateTime createdAt;
  const Playlist({required this.id, required this.name, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(id: Value(id), name: Value(name), createdAt: Value(createdAt));
  }

  factory Playlist.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Playlist(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Playlist copyWith({int? id, String? name, DateTime? createdAt}) =>
      Playlist(id: id ?? this.id, name: name ?? this.name, createdAt: createdAt ?? this.createdAt);
  Playlist copyWithCompanion(PlaylistsCompanion data) {
    return Playlist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Playlist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Playlist && other.id == this.id && other.name == this.name && other.createdAt == this.createdAt);
}

class PlaylistsCompanion extends UpdateCompanion<Playlist> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  const PlaylistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Playlist> custom({Expression<int>? id, Expression<String>? name, Expression<DateTime>? createdAt}) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PlaylistsCompanion copyWith({Value<int>? id, Value<String>? name, Value<DateTime>? createdAt}) {
    return PlaylistsCompanion(id: id ?? this.id, name: name ?? this.name, createdAt: createdAt ?? this.createdAt);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PlaylistItemsTable extends PlaylistItems with TableInfo<$PlaylistItemsTable, PlaylistItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta('playlistId');
  @override
  late final GeneratedColumn<int> playlistId = GeneratedColumn<int>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaIdMeta = const VerificationMeta('mediaId');
  @override
  late final GeneratedColumn<int> mediaId = GeneratedColumn<int>(
    'media_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [playlistId, mediaId, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_items';
  @override
  VerificationContext validateIntegrity(Insertable<PlaylistItem> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(_playlistIdMeta, playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta));
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('media_id')) {
      context.handle(_mediaIdMeta, mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta));
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta, addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, mediaId};
  @override
  PlaylistItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistItem(
      playlistId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}playlist_id'])!,
      mediaId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}media_id'])!,
      addedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}added_at'])!,
    );
  }

  @override
  $PlaylistItemsTable createAlias(String alias) {
    return $PlaylistItemsTable(attachedDatabase, alias);
  }
}

class PlaylistItem extends DataClass implements Insertable<PlaylistItem> {
  final int playlistId;
  final int mediaId;
  final DateTime addedAt;
  const PlaylistItem({required this.playlistId, required this.mediaId, required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<int>(playlistId);
    map['media_id'] = Variable<int>(mediaId);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  PlaylistItemsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistItemsCompanion(playlistId: Value(playlistId), mediaId: Value(mediaId), addedAt: Value(addedAt));
  }

  factory PlaylistItem.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistItem(
      playlistId: serializer.fromJson<int>(json['playlistId']),
      mediaId: serializer.fromJson<int>(json['mediaId']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<int>(playlistId),
      'mediaId': serializer.toJson<int>(mediaId),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  PlaylistItem copyWith({int? playlistId, int? mediaId, DateTime? addedAt}) => PlaylistItem(
    playlistId: playlistId ?? this.playlistId,
    mediaId: mediaId ?? this.mediaId,
    addedAt: addedAt ?? this.addedAt,
  );
  PlaylistItem copyWithCompanion(PlaylistItemsCompanion data) {
    return PlaylistItem(
      playlistId: data.playlistId.present ? data.playlistId.value : this.playlistId,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistItem(')
          ..write('playlistId: $playlistId, ')
          ..write('mediaId: $mediaId, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, mediaId, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistItem &&
          other.playlistId == this.playlistId &&
          other.mediaId == this.mediaId &&
          other.addedAt == this.addedAt);
}

class PlaylistItemsCompanion extends UpdateCompanion<PlaylistItem> {
  final Value<int> playlistId;
  final Value<int> mediaId;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const PlaylistItemsCompanion({
    this.playlistId = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistItemsCompanion.insert({
    required int playlistId,
    required int mediaId,
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : playlistId = Value(playlistId),
       mediaId = Value(mediaId);
  static Insertable<PlaylistItem> custom({
    Expression<int>? playlistId,
    Expression<int>? mediaId,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (mediaId != null) 'media_id': mediaId,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistItemsCompanion copyWith({
    Value<int>? playlistId,
    Value<int>? mediaId,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return PlaylistItemsCompanion(
      playlistId: playlistId ?? this.playlistId,
      mediaId: mediaId ?? this.mediaId,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<int>(playlistId.value);
    }
    if (mediaId.present) {
      map['media_id'] = Variable<int>(mediaId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistItemsCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('mediaId: $mediaId, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MediaFilesTable mediaFiles = $MediaFilesTable(this);
  late final $DownloadTasksTable downloadTasks = $DownloadTasksTable(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $PlaylistItemsTable playlistItems = $PlaylistItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [mediaFiles, downloadTasks, playlists, playlistItems];
}

typedef $$MediaFilesTableCreateCompanionBuilder = MediaFilesCompanion Function({
  Value<int> id,
  required String youtubeId,
  required String title,
  Value<String> channel,
  required String contentUri,
  required int durationMs,
  Value<int> fileSizeBytes,
  Value<bool> isAudioOnly,
  required String thumbnailUrl,
  Value<bool> isFavorite,
  Value<int> lastPositionMs,
  Value<DateTime> downloadedAt,
});
typedef $$MediaFilesTableUpdateCompanionBuilder = MediaFilesCompanion Function({
  Value<int> id,
  Value<String> youtubeId,
  Value<String> title,
  Value<String> channel,
  Value<String> contentUri,
  Value<int> durationMs,
  Value<int> fileSizeBytes,
  Value<bool> isAudioOnly,
  Value<String> thumbnailUrl,
  Value<bool> isFavorite,
  Value<int> lastPositionMs,
  Value<DateTime> downloadedAt,
});

class $$MediaFilesTableFilterComposer extends Composer<_$AppDatabase, $MediaFilesTable> {
  $$MediaFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get youtubeId =>
      $composableBuilder(column: $table.youtubeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contentUri =>
      $composableBuilder(column: $table.contentUri, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs =>
      $composableBuilder(column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSizeBytes =>
      $composableBuilder(column: $table.fileSizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAudioOnly =>
      $composableBuilder(column: $table.isAudioOnly, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailUrl =>
      $composableBuilder(column: $table.thumbnailUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite =>
      $composableBuilder(column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastPositionMs =>
      $composableBuilder(column: $table.lastPositionMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get downloadedAt =>
      $composableBuilder(column: $table.downloadedAt, builder: (column) => ColumnFilters(column));
}

class $$MediaFilesTableOrderingComposer extends Composer<_$AppDatabase, $MediaFilesTable> {
  $$MediaFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get youtubeId =>
      $composableBuilder(column: $table.youtubeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contentUri =>
      $composableBuilder(column: $table.contentUri, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs =>
      $composableBuilder(column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSizeBytes =>
      $composableBuilder(column: $table.fileSizeBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAudioOnly =>
      $composableBuilder(column: $table.isAudioOnly, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailUrl =>
      $composableBuilder(column: $table.thumbnailUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite =>
      $composableBuilder(column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastPositionMs =>
      $composableBuilder(column: $table.lastPositionMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get downloadedAt =>
      $composableBuilder(column: $table.downloadedAt, builder: (column) => ColumnOrderings(column));
}

class $$MediaFilesTableAnnotationComposer extends Composer<_$AppDatabase, $MediaFilesTable> {
  $$MediaFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get youtubeId => $composableBuilder(column: $table.youtubeId, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get channel => $composableBuilder(column: $table.channel, builder: (column) => column);

  GeneratedColumn<String> get contentUri => $composableBuilder(column: $table.contentUri, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<int> get fileSizeBytes =>
      $composableBuilder(column: $table.fileSizeBytes, builder: (column) => column);

  GeneratedColumn<bool> get isAudioOnly => $composableBuilder(column: $table.isAudioOnly, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl =>
      $composableBuilder(column: $table.thumbnailUrl, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<int> get lastPositionMs =>
      $composableBuilder(column: $table.lastPositionMs, builder: (column) => column);

  GeneratedColumn<DateTime> get downloadedAt =>
      $composableBuilder(column: $table.downloadedAt, builder: (column) => column);
}

class $$MediaFilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaFilesTable,
          MediaEntity,
          $$MediaFilesTableFilterComposer,
          $$MediaFilesTableOrderingComposer,
          $$MediaFilesTableAnnotationComposer,
          $$MediaFilesTableCreateCompanionBuilder,
          $$MediaFilesTableUpdateCompanionBuilder,
          (MediaEntity, BaseReferences<_$AppDatabase, $MediaFilesTable, MediaEntity>),
          MediaEntity,
          PrefetchHooks Function()
        > {
  $$MediaFilesTableTableManager(_$AppDatabase db, $MediaFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MediaFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MediaFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$MediaFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> youtubeId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> channel = const Value.absent(),
                Value<String> contentUri = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> fileSizeBytes = const Value.absent(),
                Value<bool> isAudioOnly = const Value.absent(),
                Value<String> thumbnailUrl = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> lastPositionMs = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
              }) => MediaFilesCompanion(
                id: id,
                youtubeId: youtubeId,
                title: title,
                channel: channel,
                contentUri: contentUri,
                durationMs: durationMs,
                fileSizeBytes: fileSizeBytes,
                isAudioOnly: isAudioOnly,
                thumbnailUrl: thumbnailUrl,
                isFavorite: isFavorite,
                lastPositionMs: lastPositionMs,
                downloadedAt: downloadedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String youtubeId,
                required String title,
                Value<String> channel = const Value.absent(),
                required String contentUri,
                required int durationMs,
                Value<int> fileSizeBytes = const Value.absent(),
                Value<bool> isAudioOnly = const Value.absent(),
                required String thumbnailUrl,
                Value<bool> isFavorite = const Value.absent(),
                Value<int> lastPositionMs = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
              }) => MediaFilesCompanion.insert(
                id: id,
                youtubeId: youtubeId,
                title: title,
                channel: channel,
                contentUri: contentUri,
                durationMs: durationMs,
                fileSizeBytes: fileSizeBytes,
                isAudioOnly: isAudioOnly,
                thumbnailUrl: thumbnailUrl,
                isFavorite: isFavorite,
                lastPositionMs: lastPositionMs,
                downloadedAt: downloadedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MediaFilesTable, MediaEntity>(table),
                  BaseReferences<_$AppDatabase, $MediaFilesTable, MediaEntity>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaFilesTable,
      MediaEntity,
      $$MediaFilesTableFilterComposer,
      $$MediaFilesTableOrderingComposer,
      $$MediaFilesTableAnnotationComposer,
      $$MediaFilesTableCreateCompanionBuilder,
      $$MediaFilesTableUpdateCompanionBuilder,
      (MediaEntity, BaseReferences<_$AppDatabase, $MediaFilesTable, MediaEntity>),
      MediaEntity,
      PrefetchHooks Function()
    >;
typedef $$DownloadTasksTableCreateCompanionBuilder = DownloadTasksCompanion Function({
  required String id,
  required String url,
  required String title,
  Value<String> channel,
  Value<String> thumbnailUrl,
  Value<int> durationMs,
  required String preset,
  required String status,
  Value<double> progress,
  Value<String?> playlist,
  Value<String?> section,
  Value<bool> exactCut,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$DownloadTasksTableUpdateCompanionBuilder = DownloadTasksCompanion Function({
  Value<String> id,
  Value<String> url,
  Value<String> title,
  Value<String> channel,
  Value<String> thumbnailUrl,
  Value<int> durationMs,
  Value<String> preset,
  Value<String> status,
  Value<double> progress,
  Value<String?> playlist,
  Value<String?> section,
  Value<bool> exactCut,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$DownloadTasksTableFilterComposer extends Composer<_$AppDatabase, $DownloadTasksTable> {
  $$DownloadTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailUrl =>
      $composableBuilder(column: $table.thumbnailUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs =>
      $composableBuilder(column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preset =>
      $composableBuilder(column: $table.preset, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get playlist =>
      $composableBuilder(column: $table.playlist, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get section =>
      $composableBuilder(column: $table.section, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get exactCut =>
      $composableBuilder(column: $table.exactCut, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$DownloadTasksTableOrderingComposer extends Composer<_$AppDatabase, $DownloadTasksTable> {
  $$DownloadTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailUrl =>
      $composableBuilder(column: $table.thumbnailUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs =>
      $composableBuilder(column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preset =>
      $composableBuilder(column: $table.preset, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get playlist =>
      $composableBuilder(column: $table.playlist, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get section =>
      $composableBuilder(column: $table.section, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get exactCut =>
      $composableBuilder(column: $table.exactCut, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$DownloadTasksTableAnnotationComposer extends Composer<_$AppDatabase, $DownloadTasksTable> {
  $$DownloadTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url => $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get channel => $composableBuilder(column: $table.channel, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl =>
      $composableBuilder(column: $table.thumbnailUrl, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<String> get preset => $composableBuilder(column: $table.preset, builder: (column) => column);

  GeneratedColumn<String> get status => $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get progress => $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<String> get playlist => $composableBuilder(column: $table.playlist, builder: (column) => column);

  GeneratedColumn<String> get section => $composableBuilder(column: $table.section, builder: (column) => column);

  GeneratedColumn<bool> get exactCut => $composableBuilder(column: $table.exactCut, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DownloadTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadTasksTable,
          DownloadTaskEntity,
          $$DownloadTasksTableFilterComposer,
          $$DownloadTasksTableOrderingComposer,
          $$DownloadTasksTableAnnotationComposer,
          $$DownloadTasksTableCreateCompanionBuilder,
          $$DownloadTasksTableUpdateCompanionBuilder,
          (DownloadTaskEntity, BaseReferences<_$AppDatabase, $DownloadTasksTable, DownloadTaskEntity>),
          DownloadTaskEntity,
          PrefetchHooks Function()
        > {
  $$DownloadTasksTableTableManager(_$AppDatabase db, $DownloadTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$DownloadTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$DownloadTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$DownloadTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> channel = const Value.absent(),
                Value<String> thumbnailUrl = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String> preset = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<String?> playlist = const Value.absent(),
                Value<String?> section = const Value.absent(),
                Value<bool> exactCut = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadTasksCompanion(
                id: id,
                url: url,
                title: title,
                channel: channel,
                thumbnailUrl: thumbnailUrl,
                durationMs: durationMs,
                preset: preset,
                status: status,
                progress: progress,
                playlist: playlist,
                section: section,
                exactCut: exactCut,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String url,
                required String title,
                Value<String> channel = const Value.absent(),
                Value<String> thumbnailUrl = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                required String preset,
                required String status,
                Value<double> progress = const Value.absent(),
                Value<String?> playlist = const Value.absent(),
                Value<String?> section = const Value.absent(),
                Value<bool> exactCut = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadTasksCompanion.insert(
                id: id,
                url: url,
                title: title,
                channel: channel,
                thumbnailUrl: thumbnailUrl,
                durationMs: durationMs,
                preset: preset,
                status: status,
                progress: progress,
                playlist: playlist,
                section: section,
                exactCut: exactCut,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DownloadTasksTable, DownloadTaskEntity>(table),
                  BaseReferences<_$AppDatabase, $DownloadTasksTable, DownloadTaskEntity>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadTasksTable,
      DownloadTaskEntity,
      $$DownloadTasksTableFilterComposer,
      $$DownloadTasksTableOrderingComposer,
      $$DownloadTasksTableAnnotationComposer,
      $$DownloadTasksTableCreateCompanionBuilder,
      $$DownloadTasksTableUpdateCompanionBuilder,
      (DownloadTaskEntity, BaseReferences<_$AppDatabase, $DownloadTasksTable, DownloadTaskEntity>),
      DownloadTaskEntity,
      PrefetchHooks Function()
    >;
typedef $$PlaylistsTableCreateCompanionBuilder = PlaylistsCompanion Function({
  Value<int> id,
  required String name,
  Value<DateTime> createdAt,
});
typedef $$PlaylistsTableUpdateCompanionBuilder = PlaylistsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<DateTime> createdAt,
});

class $$PlaylistsTableFilterComposer extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PlaylistsTableOrderingComposer extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PlaylistsTableAnnotationComposer extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PlaylistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistsTable,
          Playlist,
          $$PlaylistsTableFilterComposer,
          $$PlaylistsTableOrderingComposer,
          $$PlaylistsTableAnnotationComposer,
          $$PlaylistsTableCreateCompanionBuilder,
          $$PlaylistsTableUpdateCompanionBuilder,
          (Playlist, BaseReferences<_$AppDatabase, $PlaylistsTable, Playlist>),
          Playlist,
          PrefetchHooks Function()
        > {
  $$PlaylistsTableTableManager(_$AppDatabase db, $PlaylistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$PlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) => PlaylistsCompanion(id: id, name: name, createdAt: createdAt),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<DateTime> createdAt = const Value.absent(),
          }) => PlaylistsCompanion.insert(id: id, name: name, createdAt: createdAt),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaylistsTable, Playlist>(table),
                  BaseReferences<_$AppDatabase, $PlaylistsTable, Playlist>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaylistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistsTable,
      Playlist,
      $$PlaylistsTableFilterComposer,
      $$PlaylistsTableOrderingComposer,
      $$PlaylistsTableAnnotationComposer,
      $$PlaylistsTableCreateCompanionBuilder,
      $$PlaylistsTableUpdateCompanionBuilder,
      (Playlist, BaseReferences<_$AppDatabase, $PlaylistsTable, Playlist>),
      Playlist,
      PrefetchHooks Function()
    >;
typedef $$PlaylistItemsTableCreateCompanionBuilder = PlaylistItemsCompanion Function({
  required int playlistId,
  required int mediaId,
  Value<DateTime> addedAt,
  Value<int> rowid,
});
typedef $$PlaylistItemsTableUpdateCompanionBuilder = PlaylistItemsCompanion Function({
  Value<int> playlistId,
  Value<int> mediaId,
  Value<DateTime> addedAt,
  Value<int> rowid,
});

class $$PlaylistItemsTableFilterComposer extends Composer<_$AppDatabase, $PlaylistItemsTable> {
  $$PlaylistItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get playlistId =>
      $composableBuilder(column: $table.playlistId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => ColumnFilters(column));
}

class $$PlaylistItemsTableOrderingComposer extends Composer<_$AppDatabase, $PlaylistItemsTable> {
  $$PlaylistItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get playlistId =>
      $composableBuilder(column: $table.playlistId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => ColumnOrderings(column));
}

class $$PlaylistItemsTableAnnotationComposer extends Composer<_$AppDatabase, $PlaylistItemsTable> {
  $$PlaylistItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get playlistId => $composableBuilder(column: $table.playlistId, builder: (column) => column);

  GeneratedColumn<int> get mediaId => $composableBuilder(column: $table.mediaId, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt => $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$PlaylistItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistItemsTable,
          PlaylistItem,
          $$PlaylistItemsTableFilterComposer,
          $$PlaylistItemsTableOrderingComposer,
          $$PlaylistItemsTableAnnotationComposer,
          $$PlaylistItemsTableCreateCompanionBuilder,
          $$PlaylistItemsTableUpdateCompanionBuilder,
          (PlaylistItem, BaseReferences<_$AppDatabase, $PlaylistItemsTable, PlaylistItem>),
          PlaylistItem,
          PrefetchHooks Function()
        > {
  $$PlaylistItemsTableTableManager(_$AppDatabase db, $PlaylistItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PlaylistItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PlaylistItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$PlaylistItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> playlistId = const Value.absent(),
            Value<int> mediaId = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => PlaylistItemsCompanion(playlistId: playlistId, mediaId: mediaId, addedAt: addedAt, rowid: rowid),
          createCompanionCallback: ({
            required int playlistId,
            required int mediaId,
            Value<DateTime> addedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => PlaylistItemsCompanion.insert(playlistId: playlistId, mediaId: mediaId, addedAt: addedAt, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaylistItemsTable, PlaylistItem>(table),
                  BaseReferences<_$AppDatabase, $PlaylistItemsTable, PlaylistItem>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaylistItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistItemsTable,
      PlaylistItem,
      $$PlaylistItemsTableFilterComposer,
      $$PlaylistItemsTableOrderingComposer,
      $$PlaylistItemsTableAnnotationComposer,
      $$PlaylistItemsTableCreateCompanionBuilder,
      $$PlaylistItemsTableUpdateCompanionBuilder,
      (PlaylistItem, BaseReferences<_$AppDatabase, $PlaylistItemsTable, PlaylistItem>),
      PlaylistItem,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MediaFilesTableTableManager get mediaFiles => $$MediaFilesTableTableManager(_db, _db.mediaFiles);
  $$DownloadTasksTableTableManager get downloadTasks => $$DownloadTasksTableTableManager(_db, _db.downloadTasks);
  $$PlaylistsTableTableManager get playlists => $$PlaylistsTableTableManager(_db, _db.playlists);
  $$PlaylistItemsTableTableManager get playlistItems => $$PlaylistItemsTableTableManager(_db, _db.playlistItems);
}
