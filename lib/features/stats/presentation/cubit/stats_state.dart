import 'package:equatable/equatable.dart';

enum ExportStatus { idle, exporting, done, failed }

class StatsState extends Equatable {
  final ExportStatus status;
  final String? filePath;

  const StatsState({this.status = ExportStatus.idle, this.filePath});

  @override
  List<Object?> get props => [status, filePath];
}
