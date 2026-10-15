# ☕ Ứng Dụng Đặt Đồ Ăn & Thức Uống (Coffee & Food Ordering App)

> **Hệ thống Full-Stack hoàn chỉnh:** Mobile App (**Flutter**) + Backend Web API (**.NET 9 C# / SQL Server**)

Dự án được xây dựng theo chuẩn chuyên nghiệp, hỗ trợ đầy đủ luồng đặt hàng, giỏ hàng, thanh toán tiền mặt (COD), chuyển khoản VietQR động, định vị chi nhánh TP.HCM trên Google Maps và theo dõi trạng thái đơn hàng thời gian thực.

---

## ⚠️ LƯU Ý TỬ HUYỆT (BẮT BUỘC ĐỌC TRƯỚC TIÊN!)

> [!CAUTION]
> **BẮT BUỘC** phải clone hoặc giải nén thư mục dự án vào đường dẫn tuyệt đối **KHÔNG CÓ DẤU TIẾNG VIỆT** và **KHÔNG CÓ KHOẢNG TRẮNG ĐẶC BIỆT**.
>
> ✅ **ĐƯỜNG DẪN HỢP LỆ (KHUYÊN DÙNG):**
> - `C:\CoffeeShopApp`
> - `D:\Projects\CoffeeShopApp`
>
> ❌ **TUYỆT ĐỐI TRÁNH:**
> - `C:\Users\Nguyễn Văn A\Desktop\Đồ Án\...` *(Dính dấu tiếng Việt)*
> - `D:\Mon Hoc\Do An Coffee Shop\...` *(Dính khoảng trắng và ký tự lạ)*
>
> 👉 **Lý do:** Công cụ biên dịch Gradle của Android Studio và SDK C++ sẽ **BỊ LỖI BUILD FAILED NGAY LẬP TỨC** nếu phát hiện ký tự UTF-8 có dấu trong đường dẫn file!

---

## 🛠️ Yêu Cầu Môi Trường (Prerequisites)

Trước khi chạy, hãy đảm bảo máy tính của bạn đã cài đặt các công cụ sau:

| Công cụ | Phiên bản khuyến nghị | Mục đích |
| :--- | :---: | :--- |
| **.NET SDK** | `9.0` (hoặc `>= 8.0`) | Biên dịch và chạy Backend RESTful API |
| **Flutter SDK** | `>= 3.24.x` (kênh stable) | Phát triển & chạy ứng dụng Mobile |
| **Microsoft SQL Server** | Express / Developer / LocalDB | Cơ sở dữ liệu quan hệ lưu trữ đơn hàng & món ăn |
| **Android Studio** | Phiên bản mới nhất (2024+) | Chạy máy ảo Android Emulator & Android SDK build tools |
| **Google Chrome** | Bản mới nhất | Dùng để chạy thử bản Web siêu nhanh (nếu máy yếu) |

---

## 🚀 Bước 1: Khởi Chạy Backend .NET C#

Backend chịu trách nhiệm cung cấp RESTful API, xác thực JWT và quản lý dữ liệu SQL Server.

1. **Mở Terminal (PowerShell / Command Prompt)** tại **thư mục gốc** của dự án:
   ```bash
   cd C:\CoffeeShopApp
   ```

2. **Khôi phục các gói thư viện NuGet:**
   ```bash
   dotnet restore
   ```

3. **Khởi chạy máy chủ Backend:**
   ```bash
   dotnet run
   ```

4. **Cơ chế tự động nạp dữ liệu (Auto Database Seeding):**
   - Ngay khi khởi động, Backend sẽ tự động kết nối SQL Server, dọn dẹp và khởi tạo mới tinh 100% database `CoffeeShopDb`.
   - Hệ thống tự động **seed sẵn toàn bộ 24 món ăn chuẩn xu hướng** (kèm hình ảnh Unsplash sắc nét, sống 100%), **4 danh mục chính**, **5 chi nhánh sầm uất tại TP.HCM**, cùng các tài khoản mẫu.
   - Tài liệu API tương tác trực quan **Swagger UI** sẽ tự động sẵn sàng tại:  
     👉 **`http://localhost:5108`** (hoặc cổng hiển thị trên cửa sổ Terminal).

---

## 📱 Bước 2: Khởi Chạy Mobile App (Flutter)

Giữ nguyên cửa sổ Terminal Backend đang chạy ở Bước 1, mở một **cửa sổ Terminal mới** để chạy ứng dụng Flutter.

1. **Chuyển hướng vào thư mục ứng dụng:**
   ```bash
   cd C:\CoffeeShopApp\mobile_app
   ```

2. **Tải toàn bộ các thư viện Flutter:**
   ```bash
   flutter pub get
   ```

3. **Khởi chạy ứng dụng:**

   - **Cách 1: Chạy trên Máy ảo Android (Android Emulator) hoặc Thiết bị thật (Khuyên dùng):**
     ```bash
     flutter run --no-enable-impeller
     ```
     > [!TIP]
     > Cờ `--no-enable-impeller` giúp máy ảo Android render mượt mà bằng engine đồ họa Skia ổn định, **không bị hiện tượng văng màn hình hay tràn bộ nhớ RAM** trên các máy tính cấu hình vừa phải.

   - **Cách 2: Chạy trực tiếp trên Trình duyệt Web Google Chrome (Siêu nhẹ & Nhanh):**
     ```bash
     flutter run -d chrome
     ```
     > [!NOTE]
     > Rất thích hợp khi cần xem nhanh giao diện, demo sản phẩm hoặc khi máy tính không đủ tài nguyên để bật máy ảo Android nặng.

---

## ⚙️ Cấu Hình Chuỗi Kết Nối SQL Server (Nếu Khác Máy)

Nếu máy tính của bạn sử dụng tên SQL Server Instance khác với mặc định, hãy mở file [appsettings.json](file:///c:/CoffeShopApp/appsettings.json) tại thư mục gốc và chỉnh sửa mục `ConnectionStrings:DefaultConnection`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=CoffeeShopDb;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true;"
  }
}
```

### Các trường hợp phổ biến:
- **Dùng SQL Server cục bộ mặc định (Windows Authentication):**
  ```text
  Server=localhost;Database=CoffeeShopDb;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true;
  ```
- **Dùng bản SQL Server Express:**
  ```text
  Server=localhost\SQLEXPRESS;Database=CoffeeShopDb;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true;
  ```
- **Dùng Visual Studio LocalDB:**
  ```text
  Server=(localdb)\mssqllocaldb;Database=CoffeeShopDb;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true;
  ```
- **Dùng tài khoản `sa` có mật khẩu:**
  ```text
  Server=localhost,1433;Database=CoffeeShopDb;User Id=sa;Password=MatKhauCuaBan123!;TrustServerCertificate=True;MultipleActiveResultSets=true;
  ```

---

## 🔑 Tài Khoản Mẫu Để Đăng Nhập & Chấm Đồ Án

Hệ thống đã chuẩn bị sẵn 2 tài khoản demo với đầy đủ quyền hạn:

| Vai trò | Số điện thoại | Mật khẩu | Quyền hạn & Chức năng |
| :--- | :---: | :---: | :--- |
| 👑 **Quản Trị Viên (Admin)** | `0909000001` | `Admin@123` | Quản lý toàn bộ hệ thống, kiểm duyệt đơn hàng, xem báo cáo, thêm chi nhánh |
| ☕ **Khách Hàng (Customer)** | `0909123456` | `123456` | Xem thực đơn, thêm giỏ hàng, áp mã Voucher, đặt hàng (COD / QR), theo dõi đơn realtime |

---

## 🌟 Các Tính Năng Nổi Bật Của Ứng Dụng

- 🛍️ **Trang chủ & Menu đa dạng:** Phân loại 4 danh mục chuẩn (*Cà Phê Việt, Trà Trái Cây & Trà Sữa, Đá Xay & Matcha, Bánh Ngọt & Ăn Vặt*), tích hợp tìm kiếm tức thì và hình ảnh sắc nét.
- 🛒 **Giỏ hàng thông minh:** Tùy chỉnh kích cỡ (Size S/M/L), độ ngọt, đá, topping; tự động tính tổng tiền và phí giao hàng.
- 💳 **Thanh toán linh hoạt:**
  - **Tiền mặt (COD):** Xác nhận trực tiếp với luồng xử lý an toàn (Safe Delay Modification), không lỗi văng.
  - **Chuyển khoản VietQR động:** Tạo mã QR kèm số tiền và nội dung chuyển khoản tự động, đồng hồ đếm ngược 10 phút.
- 📍 **Hệ thống Chi nhánh TP.HCM:** 5 chi nhánh trung tâm (*Quận 1 Nguyễn Huệ, Quận 3 Hồ Con Rùa, Bình Thạnh Landmark 81, TP. Thủ Đức, Quận 7 Phú Mỹ Hưng*) kèm tính toán khoảng cách GPS.
- 🛵 **Theo dõi đơn hàng thời gian thực:** Giả lập tiến trình 4 giai đoạn (*Đã nhận đơn ➔ Quán đang làm ➔ Tài xế đang giao ➔ Giao thành công*) với timeline trực quan.
- 🎁 **Kho Voucher:** Hỗ trợ nhập mã giảm giá (`FREESHIP`, `COFFEE10`, `VIP20`).

---

Chúc cả nhóm chạy đồ án thành công tốt đẹp và đạt điểm số cao nhất! 🎉
