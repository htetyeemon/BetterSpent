class ExpenseModel {
  final String id;
  final String name;
  final String category;
  final double amount;
  final DateTime date;
  final String? note;

  ExpenseModel({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.date,
    this.note,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  ExpenseModel copyWith({
    String? id,
    String? name,
    String? category,
    double? amount,
    DateTime? date,
    String? note,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
