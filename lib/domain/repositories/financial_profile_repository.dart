import '../entities/financial_profile.dart';

abstract class FinancialProfileRepository {
  Stream<FinancialProfile?> getProfile();
  Future<void> updateProfile(FinancialProfile profile);
  Future<void> deleteProfile();
}
