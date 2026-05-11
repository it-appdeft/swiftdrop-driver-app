class TransactionModel {
  final String id;
  final String orderId;
  final double amount;
  final String type;   // 'delivery' | 'bonus' | 'deduction' | 'adjustment'
  final bool isCredit; // true = money added, false = deducted
  final DateTime createdAt;
  final String? note;

  const TransactionModel({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.type,
    required this.isCredit,
    required this.createdAt,
    this.note,
  });

  bool get isBonus     => type == 'bonus';
  bool get isDelivery  => type == 'delivery';
  bool get isDeduction => type == 'deduction';

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id:       json['id'] as String? ?? '',
        orderId:  json['order_id'] as String? ?? '',
        amount:   (json['amount'] as num?)?.toDouble() ?? 0.0,
        type:     json['type'] as String? ?? 'delivery',
        isCredit: json['is_credit'] as bool? ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        note: json['note'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'amount': amount,
        'type': type,
        'is_credit': isCredit,
        'created_at': createdAt.toIso8601String(),
        if (note != null) 'note': note,
      };
}
