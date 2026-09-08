import 'package:equatable/equatable.dart';

class FeeHead extends Equatable {
  final String title;
  final double amount;
  final bool isPaid;

  const FeeHead({
    required this.title,
    required this.amount,
    this.isPaid = false,
  });

  @override
  List<Object?> get props => [title, amount, isPaid];
}

class FeeStatement extends Equatable {
  final String studentId;
  final String termTitle;
  final double totalAmount;
  final double paidAmount;
  final double outstandingBalance;
  final DateTime dueDate;
  final List<FeeHead> breakdown;

  const FeeStatement({
    required this.studentId,
    required this.termTitle,
    required this.totalAmount,
    required this.paidAmount,
    required this.outstandingBalance,
    required this.dueDate,
    required this.breakdown,
  });

  @override
  List<Object?> get props => [
        studentId,
        termTitle,
        totalAmount,
        paidAmount,
        outstandingBalance,
        dueDate,
        breakdown,
      ];
}
