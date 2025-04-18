import 'class_api.dart';
import 'teacher_api.dart';
import 'student_api.dart';
import 'assignment_api.dart';
import 'submission_api.dart';
import 'chat_api.dart';
import 'file_api.dart';
import 'quiz_api.dart';
import 'schedule_api.dart';

class API {
  static final ClassApi classes = ClassApi();
  static final TeacherApi teachers = TeacherApi();
  static final StudentApi students = StudentApi();
  static final AssignmentApi assignments = AssignmentApi();
  static final SubmissionApi submissions = SubmissionApi();
  static final ChatApi chat = ChatApi();
  static final FileApi files = FileApi();
  static final QuizApi quiz = QuizApi();
  static final ScheduleApi schedules = ScheduleApi();
} 