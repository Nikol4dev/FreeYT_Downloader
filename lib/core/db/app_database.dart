import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('MediaEntity')
class MediaFiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get youtubeId => text().unique()();
  TextColumn get title => text()();
  TextColumn get channel => text().withDefault(const Constant(''))();

  TextColumn get contentUri => text()();
  IntColumn get durationMs => integer()();
  IntColumn get fileSizeBytes => integer().withDefault(const Constant(0))();
  BoolColumn get isAudioOnly => boolean().withDefault(const Constant(false))();
  TextColumn get thumbnailUrl => text()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get lastPositionMs => integer().withDefault(const Constant(0))();
  DateTimeColumn get downloadedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('DownloadTaskEntity')
class DownloadTasks extends Table {
  TextColumn get id => text()();
  TextColumn get url => text()();
  TextColumn get title => text()();
  TextColumn get channel => text().withDefault(const Constant(''))();
  TextColumn get thumbnailUrl => text().withDefault(const Constant(''))();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  TextColumn get preset => text()();
  TextColumn get status => text()();
  RealColumn get progress => real().withDefault(const Constant(0.0))();
  TextColumn get playlist => text().nullable()();
  TextColumn get section => text().nullable()();
  BoolColumn get exactCut => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Playlists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class PlaylistItems extends Table {
  IntColumn get playlistId => integer()();
  IntColumn get mediaId => integer()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {playlistId, mediaId};
}

enum LibrarySort { recent, title, channel, size }

class PlaylistRow {
  const PlaylistRow(this.id, this.name, this.count);
  final int id;
  final String name;
  final int count;
}

@DriftDatabase(tables: [MediaFiles, DownloadTasks, Playlists, PlaylistItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.renameColumn(mediaFiles, 'absolute_file_path', mediaFiles.contentUri);
        await m.addColumn(mediaFiles, mediaFiles.channel);
        await m.addColumn(mediaFiles, mediaFiles.fileSizeBytes);
        await m.addColumn(mediaFiles, mediaFiles.isFavorite);
        await m.addColumn(mediaFiles, mediaFiles.lastPositionMs);
        await m.deleteTable('download_tasks');
        await m.createTable(downloadTasks);
      }
      if (from < 3) {
        await m.createTable(playlists);
        await m.createTable(playlistItems);
        await m.addColumn(downloadTasks, downloadTasks.playlist);
      }
      if (from < 4) {
        await m.addColumn(downloadTasks, downloadTasks.section);
        await m.addColumn(downloadTasks, downloadTasks.exactCut);
      }
    },
  );

  Stream<List<MediaEntity>> watchLibrary({
    String query = '',
    LibrarySort sort = LibrarySort.recent,
    bool favoritesOnly = false,
  }) {
    final q = select(mediaFiles)
      ..orderBy([
        (t) => switch (sort) {
          LibrarySort.recent => OrderingTerm.desc(t.downloadedAt),
          LibrarySort.title => OrderingTerm.asc(t.title),
          LibrarySort.channel => OrderingTerm.asc(t.channel),
          LibrarySort.size => OrderingTerm.desc(t.fileSizeBytes),
        },
      ]);
    final text = query.trim();
    if (text.isNotEmpty) {
      final like = '%$text%';
      q.where((t) => t.title.like(like) | t.channel.like(like));
    }
    if (favoritesOnly) q.where((t) => t.isFavorite.equals(true));
    return q.watch();
  }

  Future<MediaEntity?> findMediaByYoutubeId(String youtubeId) =>
      (select(mediaFiles)..where((t) => t.youtubeId.equals(youtubeId))).getSingleOrNull();

  Future<void> upsertMedia(MediaFilesCompanion entry) =>
      into(mediaFiles).insert(entry, onConflict: DoUpdate((_) => entry, target: [mediaFiles.youtubeId]));

  Future<int> deleteMedia(int id) async {
    await (delete(playlistItems)..where((t) => t.mediaId.equals(id))).go();
    return (delete(mediaFiles)..where((t) => t.id.equals(id))).go();
  }

  Future<void> savePosition(int id, int positionMs) =>
      (update(mediaFiles)..where((t) => t.id.equals(id))).write(MediaFilesCompanion(lastPositionMs: Value(positionMs)));

  Future<MediaEntity?> mediaById(int id) => (select(mediaFiles)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> updateDetails(int id, String title, String channel) => (update(
    mediaFiles,
  )..where((t) => t.id.equals(id))).write(MediaFilesCompanion(title: Value(title), channel: Value(channel)));

  Future<void> setFavorite(int id, bool value) =>
      (update(mediaFiles)..where((t) => t.id.equals(id))).write(MediaFilesCompanion(isFavorite: Value(value)));

  Future<List<DownloadTaskEntity>> unfinishedTasks() =>
      (select(downloadTasks)
            ..where((t) => t.status.isIn(['pending', 'downloading', 'paused']))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Future<void> upsertTask(DownloadTasksCompanion entry) => into(downloadTasks).insertOnConflictUpdate(entry);

  Future<void> deleteTask(String id) => (delete(downloadTasks)..where((t) => t.id.equals(id))).go();

  Stream<List<PlaylistRow>> watchPlaylistRows() =>
      customSelect(
        'SELECT p.id AS id, p.name AS name, COUNT(i.media_id) AS n FROM playlists p '
        'LEFT JOIN playlist_items i ON i.playlist_id = p.id GROUP BY p.id ORDER BY p.name COLLATE NOCASE',
        readsFrom: {playlists, playlistItems},
      ).watch().map(
        (rows) => [for (final r in rows) PlaylistRow(r.read<int>('id'), r.read<String>('name'), r.read<int>('n'))],
      );

  Future<int> createPlaylist(String name) => into(playlists).insert(PlaylistsCompanion.insert(name: name));

  Future<int> findOrCreatePlaylist(String name) async {
    final rows = await (select(playlists)..where((t) => t.name.equals(name))).get();
    if (rows.isNotEmpty) return rows.first.id;
    return createPlaylist(name);
  }

  Future<void> renamePlaylist(int id, String name) =>
      (update(playlists)..where((t) => t.id.equals(id))).write(PlaylistsCompanion(name: Value(name)));

  Future<void> deletePlaylist(int id) async {
    await (delete(playlistItems)..where((t) => t.playlistId.equals(id))).go();
    await (delete(playlists)..where((t) => t.id.equals(id))).go();
  }

  Future<void> addToPlaylist(int playlistId, int mediaId) => into(playlistItems).insert(
    PlaylistItemsCompanion.insert(playlistId: playlistId, mediaId: mediaId),
    mode: InsertMode.insertOrIgnore,
  );

  Future<void> removeFromPlaylist(int playlistId, int mediaId) =>
      (delete(playlistItems)..where((t) => t.playlistId.equals(playlistId) & t.mediaId.equals(mediaId))).go();

  Stream<List<MediaEntity>> watchPlaylistMedia(int playlistId) {
    final q = select(mediaFiles).join([innerJoin(playlistItems, playlistItems.mediaId.equalsExp(mediaFiles.id))])
      ..where(playlistItems.playlistId.equals(playlistId))
      ..orderBy([OrderingTerm.asc(playlistItems.addedAt), OrderingTerm.asc(mediaFiles.id)]);
    return q.watch().map((rows) => [for (final r in rows) r.readTable(mediaFiles)]);
  }
}

LazyDatabase _openConnection() => LazyDatabase(() async {
  final dir = await getApplicationDocumentsDirectory();
  return NativeDatabase.createInBackground(File(p.join(dir.path, 'premium_db_v1.sqlite')));
});
