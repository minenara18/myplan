import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Mata kuliah — model nilai immutable dengan kesetaraan dan copyWith.
class Course extends Equatable {
  const Course({
    required this.id,
    required this.nama,
    required this.warnaIndex,
    required this.ikon,
  });

  final String id;
  final String nama;
  final int warnaIndex;
  final IconData ikon;

  Course copyWith({
    String? id,
    String? nama,
    int? warnaIndex,
    IconData? ikon,
  }) {
    return Course(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      warnaIndex: warnaIndex ?? this.warnaIndex,
      ikon: ikon ?? this.ikon,
    );
  }

  @override
  List<Object?> get props => [id, nama, warnaIndex, ikon];
}
