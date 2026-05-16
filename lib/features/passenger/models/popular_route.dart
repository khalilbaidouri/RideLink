class PopularRoute {
  final String fromId;
  final String toId;
  final String fromName;
  final String toName;
  final int count;

  const PopularRoute({
    required this.fromId,
    required this.toId,
    required this.fromName,
    required this.toName,
    required this.count,
  });

  factory PopularRoute.fromJson({
    required Map<String, dynamic> departure,
    required Map<String, dynamic> destination,
    required int count,
  }) {
    final fromId = departure['id'].toString();
    final toId = destination['id'].toString();

    return PopularRoute(
      fromId: fromId,
      toId: toId,
      fromName: departure['name']?.toString() ?? 'Unknown',
      toName: destination['name']?.toString() ?? 'Unknown',
      count: count,
    );
  }

  String get label => '$fromName -> $toName';
}
