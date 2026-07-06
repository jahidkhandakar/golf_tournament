import 'package:equatable/equatable.dart';

/// One completed round in the golfer's personal history.
class Round extends Equatable {
  const Round({
    required this.id,
    required this.courseName,
    required this.date,
    required this.format,
    required this.score,
    required this.toPar,
  });

  final String id;
  final String courseName;
  final DateTime date;
  final String format;
  final int score;
  final int toPar;

  @override
  List<Object?> get props => [id, courseName, date, format, score, toPar];
}
