import '../utils/http.dart';
import 'api_service.dart';

class ScheduleApi {
  static const String basePath = '/schedules';
  
  // 生成计划
  Future<DioResponse> generatePlan(List<Map<String, dynamic>> schedules) async {
    return await ApiService.request(
      'POST',
      '$basePath/generate-plan',
      data: {'schedules': schedules},
    );
  }
}
