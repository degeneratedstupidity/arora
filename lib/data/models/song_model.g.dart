// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SongModelAdapter extends TypeAdapter<SongModel> {
  @override
  final typeId = 0;

  @override
  SongModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SongModel()
      ..id = fields[0] as String
      ..title = fields[1] as String
      ..artistName = fields[2] as String
      ..albumName = fields[3] as String?
      ..thumbnailUrl = fields[4] as String?
      ..durationMs = (fields[5] as num?)?.toInt()
      ..hasVideo = fields[6] as bool
      ..videoId = fields[7] as String?
      ..localFilePath = fields[8] as String
      ..releaseDate = fields[9] as String?
      ..downloadedAt = fields[10] as String;
  }

  @override
  void write(BinaryWriter writer, SongModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artistName)
      ..writeByte(3)
      ..write(obj.albumName)
      ..writeByte(4)
      ..write(obj.thumbnailUrl)
      ..writeByte(5)
      ..write(obj.durationMs)
      ..writeByte(6)
      ..write(obj.hasVideo)
      ..writeByte(7)
      ..write(obj.videoId)
      ..writeByte(8)
      ..write(obj.localFilePath)
      ..writeByte(9)
      ..write(obj.releaseDate)
      ..writeByte(10)
      ..write(obj.downloadedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
