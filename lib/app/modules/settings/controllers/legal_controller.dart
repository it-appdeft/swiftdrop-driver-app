import 'package:get/get.dart';
import '../../../../data/models/legal_content_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../base/base_controller.dart';

class LegalController extends BaseController {
  final AuthRepository _authRepo;
  LegalController(this._authRepo);

  final legalContent = Rxn<LegalContentModel>();
  final title = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final mode = Get.arguments?['mode'] as String? ?? 'terms';
    if (mode == 'privacy') {
      title.value = 'Privacy Policy';
      fetchPrivacyPolicy();
    } else {
      title.value = 'Terms & Conditions';
      fetchTermsAndConditions();
    }
  }

  Future<void> fetchTermsAndConditions() async {
    await runAsync(() async {
      try {
        final res = await _authRepo.getTermsAndConditions();
        if (res.success && res.data != null) {
          legalContent.value = res.data;
        }
      } catch (_) {}
    });
  }

  Future<void> fetchPrivacyPolicy() async {
    await runAsync(() async {
      try {
        final res = await _authRepo.getPrivacyPolicy();
        if (res.success && res.data != null) {
          legalContent.value = res.data;
        }
      } catch (_) {}
    });
  }
}
