import 'dart:ui';

import 'package:firebase_task_manager/models/task_model.dart';

Color taskPriorityColor(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.low:
      return const Color(0xFF4BAA5B);
    case TaskPriority.medium:
      return const Color(0xFFE29B2F);
    case TaskPriority.high:
      return const Color(0xFFE85A5A);
  }
}

Color taskPriorityBg(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.low:
      return const Color(0xFFEAF8F0);
    case TaskPriority.medium:
      return const Color(0xFFFFF1DD);
    case TaskPriority.high:
      return const Color(0xFFFEEAEA);
  }
}
