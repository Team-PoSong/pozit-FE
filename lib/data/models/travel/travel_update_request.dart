class TravelUpdateRequest {
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final List<int> tagIds;

  const TravelUpdateRequest({
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.tagIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'destination': destination,
      'startDate': _formatDate(startDate),
      'endDate': _formatDate(endDate),
      'tagIds': tagIds,
    };
  }

  static String _formatDate(DateTime date) =>
      date.toIso8601String().substring(0, 10);
}
