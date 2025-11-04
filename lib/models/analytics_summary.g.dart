// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_summary.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnalyticsSummaryAdapter extends TypeAdapter<AnalyticsSummary> {
  @override
  final int typeId = 30;

  @override
  AnalyticsSummary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnalyticsSummary(
      total: fields[0] as int,
      positive: fields[1] as int,
      negative: fields[2] as int,
      neutral: fields[3] as int,
      topEmotions: (fields[4] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, AnalyticsSummary obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.total)
      ..writeByte(1)
      ..write(obj.positive)
      ..writeByte(2)
      ..write(obj.negative)
      ..writeByte(3)
      ..write(obj.neutral)
      ..writeByte(4)
      ..write(obj.topEmotions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsSummaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
