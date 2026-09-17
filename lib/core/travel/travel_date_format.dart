/// 당일치기는 단일 날짜로, 여러 날 여행은 기존 구분자로 표시합니다.
String formatTravelDateRange(
  DateTime start,
  DateTime end, {
  String separator = ' ~ ',
}) {
  if (start.year == end.year &&
      start.month == end.month &&
      start.day == end.day) {
    return '${start.month}/${start.day}';
  }
  return '${start.month}/${start.day}$separator${end.month}/${end.day}';
}
