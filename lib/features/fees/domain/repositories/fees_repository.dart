import '../entities/fee_statement.dart';

abstract class FeesRepository {
  /// Fetch fee statement and breakdown for a student (Parent Portal)
  Future<FeeStatement> getStudentFeeStatement(String studentId);

  /// Initiate UPI or card payment transaction
  Future<String> initiateDigitalPayment({
    required String studentId,
    required double amount,
    required String paymentMode, // UPI, NET_BANKING, CARD
  });

  /// Generate tax-compliant PDF receipt bytes for instant download
  Future<List<int>> generatePaymentReceiptPdf(String transactionId);

  /// Admin defaulter aging list (30, 60, 90 days overdue)
  Future<List<Map<String, dynamic>>> getDefaulterAgingAnalytics();

  /// Record counter payment (Cash, Cheque, Bank Draft)
  Future<void> recordOfflinePayment({
    required String studentId,
    required double amount,
    required String paymentMethod,
    required String referenceNumber,
  });
}
