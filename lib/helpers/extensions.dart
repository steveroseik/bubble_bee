extension IntExtension on int {
  String addZeroIfLessThanTen() {
    return this < 10 ? '0$this' : toString();
  }
}
