# 🏨 OmniStay Cần Thơ - Toàn Tập Tài Liệu Kiến Trúc & Kỹ Thuật (Comprehensive System Documentation)

> **DÀNH CHO AI AGENTS & LẬP TRÌNH VIÊN:** 
> Đây là bản đặc tả kỹ thuật siêu chi tiết và toàn diện nhất về dự án OmniStay Cần Thơ. Tài liệu này được thiết kế đặc biệt để cung cấp toàn bộ Context (bối cảnh), Architecture (kiến trúc), Data Flow (luồng dữ liệu) và Features (tính năng) để bất kỳ AI nào (hoặc Developer) cũng có thể hiểu sâu sắc hệ thống, từ đó hỗ trợ viết báo cáo dài (ví dụ: báo cáo đồ án 40 trang), bảo trì hoặc phát triển thêm tính năng mới mà không phá vỡ cấu trúc hiện tại.

---

## 1. 🌟 Tổng Quan Dự Án (Project Overview)
**Tên dự án:** OmniStay Cần Thơ - Hệ thống Quản lý Khách sạn Toàn diện tích hợp AI & Thanh toán trực tuyến.
**Mục tiêu:** Xây dựng một nền tảng web cung cấp trải nghiệm đặt phòng mượt mà cho khách hàng và công cụ quản trị mạnh mẽ, trực quan cho Lễ tân/Quản lý khách sạn. Điểm nhấn là việc áp dụng AI (Google Gemini) để làm Lễ tân ảo, cùng cổng thanh toán VNPAY thực tế.
**Mô hình thiết kế:** Sử dụng mô hình Model 1 (JSP thuần kết hợp JDBC), ưu tiên tốc độ triển khai, xử lý trực tiếp nghiệp vụ trên server-side rendering, kết hợp AJAX cho các tác vụ bất đồng bộ (chatbot).

---

## 2. 🛠 Cấu Trúc Công Nghệ (Tech Stack)
- **Frontend (Giao diện người dùng & Admin):**
  - **HTML5/CSS3:** Xây dựng bố cục và tạo kiểu. Cấu trúc UI/UX theo xu hướng Glassmorphism, Bento Box Layout.
  - **JavaScript (Vanilla JS - ES6+):** Xử lý logic tại client (tính tiền động, validate form, Fetch API).
  - **Bootstrap 5.3.3:** Framework CSS chính đảm bảo Responsive, sử dụng các component có sẵn (Modals, Toasts, Cards).
  - **Chart.js:** Vẽ biểu đồ thống kê doanh thu trực quan trên Admin Dashboard.
- **Backend (Xử lý nghiệp vụ):**
  - **JavaServer Pages (JSP):** Xử lý server-side, render HTML động dựa trên dữ liệu từ CSDL.
  - **JDBC (Java Database Connectivity):** Giao tiếp trực tiếp với MySQL sử dụng `PreparedStatement` để bảo mật.
- **Cơ Sở Dữ Liệu (Database):**
  - **MySQL 8.0+:** Hệ quản trị CSDL quan hệ.
- **Web Server & Môi trường:**
  - **Apache Tomcat 10.1.x:** Chạy ứng dụng Java/JSP.
- **Tích hợp bên thứ ba (Third-party Integrations):**
  - **VNPAY Sandbox:** Cổng thanh toán điện tử chuẩn Việt Nam, hỗ trợ giao dịch qua thẻ ATM/QR Pay.
  - **Google Gemini API:** Xử lý ngôn ngữ tự nhiên, đóng vai trò Lễ tân ảo (AI Concierge) tư vấn khách hàng.

---

## 3. 📂 Cấu Trúc Thư Mục Chi Tiết (Detailed Directory Structure)

Dự án được deploy tại thư mục `[Tomcat_Path]/webapps/OmniStay/`.

```text
OmniStay/
├── index.jsp                 # Landing Page (Trang chủ chính) - Hiển thị banner, giới thiệu, phòng nổi bật
├── env-secrets.jsp           # [CORE SECURITY] Chứa cấu hình kết nối DB, API Keys (Tuyệt đối không push lên Git)
├── env-secrets-example.jsp   # File mẫu để setup môi trường mới
├── omnistay.sql              # File script khởi tạo CSDL, chứa các Table và dữ liệu mẫu (Seeding)
│
├── layouts/                  # Components UI dùng chung (Server-side Include)
│   ├── navbar.jsp            # Thanh điều hướng Header cho trang khách hàng
│   ├── footer.jsp            # Chân trang (Thông tin liên hệ, Links)
│   ├── chatbot.jsp           # Giao diện bong bóng chat AI (Fixed góc phải dưới màn hình)
│   ├── sidebar-admin.jsp     # Sidebar điều hướng của phân hệ Admin
│   └── admin-auth.jsp        # [BẢO MẬT] Script kiểm tra Session, chặn truy cập trái phép vào Admin
│
├── pages/                    # Phân hệ Khách hàng (Client Portal)
│   ├── rooms.jsp             # Trang danh sách tất cả các loại phòng, có bộ lọc
│   ├── room-detail.jsp       # Chi tiết 1 loại phòng (Hình ảnh, giá, mô tả, tiện ích)
│   ├── booking.jsp           # Giao diện Checkout, nhập thông tin đặt phòng, chọn dịch vụ
│   ├── process-booking.jsp   # [Logic] Xử lý lưu thông tin đặt phòng vào CSDL
│   ├── vnpay-config.jsp      # [Logic] Khởi tạo tham số và URL thanh toán gửi sang VNPAY
│   ├── vnpay-return.jsp      # Trang hiển thị kết quả trả về từ VNPAY (Thành công/Thất bại)
│   ├── invoice-lookup.jsp    # Trang nhập Mã Booking (VD: OM-1234) để tra cứu
│   └── invoice-detail.jsp    # Trang hiển thị Hóa đơn chi tiết (Trạng thái phòng, công nợ)
│
├── admin-pages/              # Phân hệ Quản trị / Lễ tân (Admin Portal)
│   ├── dangnhap.jsp          # Trang đăng nhập dành cho Nhân viên/Admin
│   ├── logout.jsp            # Logic đăng xuất, hủy Session
│   ├── index.jsp             # Dashboard chính: Thống kê KPI, Biểu đồ doanh thu Chart.js
│   ├── admin-bookings.jsp    # Quản lý Hóa đơn/Đơn đặt phòng (Duyệt, Check-in, Check-out, Hủy)
│   ├── admin-rooms.jsp       # Sơ đồ phòng thực tế, quản lý trạng thái vật lý (Available, Cleaning...)
│   ├── admin-guests.jsp      # Quản lý danh sách khách hàng (CRM cơ bản)
│   ├── admin-services.jsp    # Quản lý danh mục Dịch vụ (Thêm, sửa, xóa Spa, Đưa đón...)
│   └── admin-staff.jsp       # Quản lý nhân sự, phân quyền (Chỉ ROLE = ADMIN mới được truy cập)
│
└── api/                      # Thư mục chứa các API tự viết phục vụ AJAX
    └── chat-api.jsp          # Endpoint nhận tin nhắn từ chatbot.jsp, gọi Google Gemini API và trả về JSON
```

---

## 4. 🗄 Kiến Trúc Cơ Sở Dữ Liệu (Database Schema)

Database `omnistay` được thiết kế chuẩn hóa 3NF, xử lý chặt chẽ các ràng buộc toàn vẹn.

1. **`room_types` (Loại phòng):** Định nghĩa danh mục sản phẩm.
   - Bảng: `id` (PK), `type_name` (Standard, Deluxe, Premium), `base_price` (Giá niêm yết), `max_occupancy` (Sức chứa tối đa), `description`, `image_url`.

2. **`rooms` (Phòng vật lý):** Danh sách phòng thực tế trên sơ đồ khách sạn.
   - Bảng: `id` (PK), `room_number` (Số phòng VD: 101, 202), `room_type_id` (FK), `status` (ENUM: `AVAILABLE`, `OCCUPIED`, `CLEANING`, `MAINTENANCE`).

3. **`services` (Dịch vụ bổ sung):** Dịch vụ khách có thể gọi thêm.
   - Bảng: `id` (PK), `service_name`, `price`, `unit` (Đơn vị tính: Phần, Chuyến, Lần), `icon`.

4. **`staff` (Nhân viên):** Tài khoản đăng nhập hệ thống nội bộ.
   - Bảng: `id` (PK), `full_name`, `email`, `password`, `role` (ENUM: `ADMIN`, `RECEPTIONIST`), `status`.

5. **`guests` (Khách hàng):** Lưu trữ hồ sơ người dùng.
   - Bảng: `id` (PK), `full_name`, `phone` (Unique - Định danh chính), `email`, `id_card` (CCCD).
   - *Logic:* Khách đặt phòng dựa trên số điện thoại, hệ thống tự tái sử dụng hồ sơ cũ hoặc tạo mới.

6. **`bookings` (Đơn đặt phòng / Hóa đơn chính):** Trái tim của hệ thống lưu trữ giao dịch.
   - Bảng: `id` (PK), `booking_code` (Mã ngẫu nhiên 8 ký tự, VD: OM-X9F8, UNIQUE), `guest_id` (FK), `check_in_date`, `check_out_date`, `total_amount` (Tổng tiền), `paid_amount` (Tiền đã thanh toán), `status` (ENUM: `PENDING`, `CONFIRMED`, `CHECKED_IN`, `CHECKED_OUT`, `CANCELLED`), `payment_method` (Tiền mặt, VNPAY, Chuyển khoản), `created_at`.

7. **`booking_rooms` (Chi tiết Phòng của Đơn):** Quan hệ N-N giữa Đơn và Phòng.
   - Bảng: `id` (PK), `booking_id` (FK), `room_id` (FK), `price_at_booking` (Lưu lịch sử giá lúc đặt).

8. **`booking_services` (Chi tiết Dịch vụ của Đơn):** Quan hệ N-N giữa Đơn và Dịch vụ.
   - Bảng: `id` (PK), `booking_id` (FK), `service_id` (FK), `quantity`, `price_at_booking`.

---

## 5. ⚙️ Danh Sách Tính Năng Phân Hệ (Module Features)

### 5.1. Phân Hệ Khách Hàng (Client Portal)
- **Giao diện trang chủ (Landing Page):** Bố cục hiện đại, giới thiệu tiện ích, hiển thị các loại phòng nổi bật, lời chứng thực.
- **Danh mục phòng (Room Categories):** Liệt kê trực quan các loại phòng, hình ảnh chất lượng cao.
- **Quy trình Đặt phòng siêu tốc (Guest Checkout):**
  - Khách hàng không cần đăng ký tài khoản. Định danh hoàn toàn bằng Số Điện Thoại.
  - Chọn ngày Check-in, Check-out, số lượng khách.
  - Chọn loại phòng và có thể Tick chọn mua kèm các dịch vụ bổ sung (VD: Ăn sáng, Đưa đón sân bay).
  - Tự động tính toán tổng tiền bằng JavaScript ngay trên giao diện trước khi submit.
- **Thanh toán trực tuyến (VNPAY Integration):**
  - Khách chọn thanh toán qua VNPAY, hệ thống điều hướng đến cổng VNPAY.
  - Hỗ trợ thanh toán thẻ ATM, quét mã QR.
  - Xử lý callback tự động cập nhật trạng thái đơn hàng (`paid_amount`) và trạng thái hóa đơn.
- **Tra cứu hóa đơn thông minh (Invoice Lookup):** Khách nhập Mã Booking để xem tình trạng đơn hàng, in hóa đơn điện tử, xem chi tiết công nợ (Balance).
- **Trợ lý ảo OmniAI (Gemini Chatbot):** 
  - Chatbot tích hợp trực tiếp góc màn hình.
  - Được tiêm Prompt tri thức khổng lồ về giá phòng, giờ check-in, chính sách hoàn hủy.
  - Phản hồi cực kỳ thông minh, tự nhiên theo ngôn ngữ tiếng Việt, có khả năng tư vấn và thuyết phục khách hàng.

### 5.2. Phân Hệ Quản Trị Hệ Thống (Admin Dashboard)
- **Xác thực bảo mật:** Đăng nhập phân quyền. Nhân viên không thể vào trang nếu chưa có Session hợp lệ.
- **Bảng điều khiển Trung tâm (Dashboard Insights):**
  - Các khối Bento hiển thị KPI: Tổng doanh thu, Số phòng đang trống, Booking mới trong ngày.
  - Tích hợp Chart.js vẽ biểu đồ đường (Line Chart) thống kê doanh thu đa chiều.
- **Quản lý Đơn đặt phòng (Booking Management):**
  - Hiển thị danh sách Booking (Mã, Khách, Phòng, Tình trạng tài chính).
  - Nghiệp vụ Check-in: Chuyển trạng thái hóa đơn sang `CHECKED_IN`, đồng thời tự động cập nhật phòng vật lý sang `OCCUPIED`.
  - Nghiệp vụ Check-out: Thanh toán phần công nợ còn lại (nếu khách dùng thêm dịch vụ), đóng hóa đơn `CHECKED_OUT`, phòng chuyển sang trạng thái chờ dọn dẹp `CLEANING`.
- **Quản lý Sơ đồ Phòng (Room Management):**
  - Hiển thị trực quan theo dạng lưới (Grid) tình trạng của từng phòng (VD: Phòng 101 - Màu Xanh [Trống], Phòng 102 - Màu Đỏ [Đang có khách], Phòng 103 - Màu Vàng [Đang dọn]).
  - Lễ tân có thể click vào để cập nhật trạng thái vật lý (VD: Báo dọn xong -> Chuyển về Available).
- **Quản lý Khách hàng & Dịch vụ:** Bảng dữ liệu quản lý thông tin khách lưu trú và cài đặt danh mục dịch vụ bán kèm.

---

## 6. 🔄 Luồng Dữ Liệu Nghiệp Vụ Cốt Lõi (Core Data Flows)

### 6.1. Luồng Sinh Hóa Đơn (Order Processing Flow)
1. User điền form tại `booking.jsp`, bấm "Đặt phòng ngay".
2. Dữ liệu gửi sang `process-booking.jsp`.
3. Java tạo thuật toán sinh ngẫu nhiên `booking_code` (8 ký tự).
4. `INSERT INTO guests` (Nếu SĐT mới) hoặc lấy ID cũ.
5. Thực thi Transaction Insert đồng thời vào bảng `bookings`, `booking_rooms`, và `booking_services`.
6. Nếu thanh toán VNPAY, chuyển hướng sang `vnpay-config.jsp` để hash URL bằng Thuật toán SHA-512, gửi sang cổng thanh toán.

### 6.2. Luồng Xử Lý Công Nợ (Debt / Financial Logic)
- **Tổng tiền (Total Amount) =** (Giá phòng * Số đêm) + Tổng (Giá dịch vụ * Số lượng).
- **Công nợ (Balance) =** `total_amount` - `paid_amount`.
- Tại Admin, khi khách dùng thêm nước uống/giặt ủi, Lễ tân add dịch vụ vào Booking -> `total_amount` tăng -> Công nợ dương. Khi khách rời đi, lễ tân bấm thanh toán, cập nhật `paid_amount` bằng đúng `total_amount` -> Balance = 0.

### 6.3. Luồng AI Chatbot
1. Fetch API POST text từ Frontend lên `api/chat-api.jsp`.
2. Java đọc `GEMINI_API_KEY` từ file bí mật.
3. Ghép nối **System Instruction** (Chứa bối cảnh OmniStay Cần Thơ, giá, chính sách) + Lịch sử chat + Câu hỏi hiện tại.
4. Gửi HTTP Request tới `generativelanguage.googleapis.com`. Lọc JSON trả về văn bản hiển thị cho người dùng với hiệu ứng Typewriter.

---

## 7. 🔐 Tiêu Chuẩn Bảo Mật & Coding Convention

1. **Chống SQL Injection:** 100% các câu lệnh tương tác Database đều sử dụng `PreparedStatement` thay vì `Statement` nối chuỗi.
2. **Quản lý Môi trường (Environment Variables):** Sử dụng file `env-secrets.jsp` làm nơi tập trung duy nhất khai báo thông tin nhạy cảm.
3. **Phân quyền chặt chẽ:** Sử dụng `include` file `admin-auth.jsp` ở dòng đầu tiên của mọi file Admin để chặn đứng truy cập vòng (Direct URL Access).
4. **UI/UX đồng nhất:** Cấu trúc biến màu sắc CSS (`--primary-color`, `--secondary-color`) thống nhất tạo ra bộ nhận diện thương hiệu Premium. Bảng Admin sử dụng hiệu ứng bóng đổ (Box-shadow), bo góc (Border-radius) sang trọng.

---

## 8. 📝 Hướng Dẫn Sử Dụng Tài Liệu Này Cho AI Agents

Nếu bạn là một AI Agent được giao nhiệm vụ viết báo cáo đồ án (Report Generation):
- Dựa vào **Mục 1 & 2** để viết chương Tổng quan và Cơ sở lý thuyết.
- Dựa vào **Mục 4** để vẽ Sơ đồ thực thể liên kết (ERD) và viết đặc tả cơ sở dữ liệu.
- Dựa vào **Mục 5 & 6** để viết chương Phân tích thiết kế hệ thống, Sơ đồ Use-case, Biểu đồ tuần tự (Sequence Diagram) cho các chức năng Đặt phòng, Thanh toán, và Check-in/Check-out.
- Dựa vào luồng xử lý Gemini ở **Mục 6.3** để làm nổi bật "Tính năng sáng tạo / Công nghệ mới" trong báo cáo.

Tài liệu này bao quát 100% hệ sinh thái OmniStay. Mọi dữ kiện để viết báo cáo học thuật hoàn chỉnh đều đã có sẵn tại đây.
