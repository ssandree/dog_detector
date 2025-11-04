// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_bundle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnalyticsBundleAdapter extends TypeAdapter<AnalyticsBundle> {
  @override
  final int typeId = 29;

  @override
  AnalyticsBundle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnalyticsBundle(
      summary: fields[0] as AnalyticsSummary,
      trend: (fields[1] as List).cast<TrendPoint>(),
      camera: (fields[2] as List).cast<CameraStat>(),
    );
  }

  @override
  void write(BinaryWriter writer, AnalyticsBundle obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.summary)
      ..writeByte(1)
      ..write(obj.trend)
      ..writeByte(2)
      ..write(obj.camera);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsBundleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TrendPointAdapter extends TypeAdapter<TrendPoint> {
  @override
  final int typeId = 32;

  @override
  TrendPoint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrendPoint(
      date: fields[0] as DateTime,
      positive: fields[1] as double,
      negative: fields[2] as double,
      neutral: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TrendPoint obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.positive)
      ..writeByte(2)
      ..write(obj.negative)
      ..writeByte(3)
      ..write(obj.neutral);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrendPointAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CameraStatAdapter extends TypeAdapter<CameraStat> {
  @override
  final int typeId = 33;

  @override
  CameraStat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CameraStat(
      cameraId: fields[0] as int,
      avgScore: fields[1] as double,
      count: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CameraStat obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.cameraId)
      ..writeByte(1)
      ..write(obj.avgScore)
      ..writeByte(2)
      ..write(obj.count);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CameraStatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
