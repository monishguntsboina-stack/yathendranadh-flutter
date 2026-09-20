class TableModel {
  final String id;
  final String tableNumber;
  final int capacity;
  final String status; // 'available' or 'occupied'

  TableModel({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    this.status = 'available',
  });

  bool get isAvailable => status == 'available';

  factory TableModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return TableModel(
      id: documentId ?? (map['id'] as String? ?? ''),
      tableNumber: map['tableNumber']?.toString() ?? '',
      capacity: (map['capacity'] as num?)?.toInt() ?? 4,
      status: map['status'] as String? ?? 'available',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tableNumber': tableNumber,
      'capacity': capacity,
      'status': status,
    };
  }

  TableModel copyWith({
    String? id,
    String? tableNumber,
    int? capacity,
    String? status,
  }) {
    return TableModel(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
    );
  }
}
