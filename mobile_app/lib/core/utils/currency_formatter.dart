/// Tiện ích định dạng tiền tệ Việt Nam Đồng (VNĐ) dùng chung toàn ứng dụng.
///
/// Toàn bộ phép tính tiền trong app được thực hiện trên kiểu `int` (đơn vị: đồng)
/// để tránh sai số dấu phẩy động của `double`.
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Định dạng số tiền: `29000` -> `29.000 đ`, `-15000` -> `-15.000 đ`
  static String vnd(num amount) {
    final value = amount.round();
    final isNegative = value < 0;
    final digits = value.abs().toString();

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }

    return '${isNegative ? '-' : ''}${buffer.toString()} đ';
  }
}
