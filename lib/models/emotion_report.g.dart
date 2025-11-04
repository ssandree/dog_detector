// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emotion_report.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmotionReportAdapter extends TypeAdapter<EmotionReport> {
  @override
  final int typeId = 31;

  @override
  EmotionReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmotionReport(
      emotion: fields[0] as String,
      confidence: fields[1] as double,
      date: fields[2] as DateTime,
      videoUrl: fields[3] as String,
      cameraId: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, EmotionReport obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.emotion)
      ..writeByte(1)
      ..write(obj.confidence)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.videoUrl)
      ..writeByte(4)
      ..write(obj.cameraId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmotionReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
