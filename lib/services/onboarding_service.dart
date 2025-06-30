import 'package:celebrating/services/api_service.dart';
import '../models/onboarding_data.dart';

class OnboardingService {
  static Future<void> submitOnboarding(OnboardingData data) async {
    await ApiService.post('onboarding', data.toJson(), (json) => null);
  }
}
