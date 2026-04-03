# 🏨 OmniStay Cần Thơ - Trang Web Khách Sạn 5 Sao (Modern Luxury)

Chào mừng bạn đến với tài liệu hướng dẫn dự án **OmniStay Cần Thơ**. Tài liệu này được cập nhật theo đúng cấu trúc hiện tại của dự án nhằm giúp mọi người hiểu, vận hành và phát triển dự án hiệu quả.

---

## 🌟 1. Tầm Nhìn Dự Án (Concept)

OmniStay không chỉ là một trang web khách sạn thông thường. Nó được thiết kế theo phong cách **"Mekong Heritage"** (Di sản sông nước) kết hợp **Modern Luxury** dành riêng cho Cần Thơ.

- **Màu sắc chủ đạo**: Xanh cổ điển (`#1a6b5a`) và Vàng kim (`#d4a847`).
- **Trải nghiệm**: Tối giản, đẳng cấp, sang trọng.
- **Đối tượng**: Khách hàng thượng lưu, doanh nhân và khách du lịch cao cấp.

---

## 🛠 2. Công Nghệ Sử Dụng (Tech Stack)

Hệ thống được phát triển nhanh gọn với công nghệ Web Java (JSP):

1. **Frontend (View)**: HTML5, CSS3, JavaScript (ES6+), Bootstrap 5.3.3.
2. **Backend & Xử lý (Logic)**: Java Server Pages (JSP) kết hợp Scriptlet (`<% %>`) - Chạy trên server **Apache Tomcat 10**.
3. **Database**: MySQL 8.0+.
4. **Thư viện kết nối**: Database connections được thiết lập trực tiếp thông qua `mysql-connector-java`.

> ⚠️ **Lưu ý Kiến trúc**: Dự án hiện tải đang dùng cấu trúc **JSP + JDBC trực tiếp** để xử lý nhanh diện mạo trực quan và truy xuất trực tiếp hệ thống CSDL vào mã HTML, chứ chưa tách biệt theo mô hình hệ thống MVC (Servlet/Controller, DAO, Model riêng).

---

## 🗄️ 3. Cơ Sở Dữ Liệu (Database Structure)

Dự án sử dụng cơ sở dữ liệu `omnistay` (bạn có thể tải cấu trúc và dữ liệu cần thiết thông qua file `omnistay.sql` đính kèm). Các khái niệm xử lý cơ bản gồm:

- **room_types**: Danh mục loại phòng (Vd: Standard, Deluxe, Presidential Suite).
- Bổ trợ kèm chức năng phân phòng, quản lý tiện ích như `rooms` cùng các hoạt động `bookings`.

*(Chi tiết về kịch bản các Field hãy tham khảo trực tiếp file `omnistay.sql`)*

---

## 🏗️ 4. Cấu Trúc Thư Mục (Folder Structure)

Thư mục dự án theo cấu trúc được deploy trực tiếp tại Tomcat `webapps`:

```text
OmniStay/
├── index.jsp           # Trang chủ công cộng (Cấu hình gọi trực tiếp DB bảng room_types)
├── omnistay.sql        # File script phục hồi cơ sở dữ liệu dự phòng
├── README.md           # Tài liệu hướng dẫn (File bạn đang đọc)
├── admin-pages/        # Nơi chứa các trang quản trị (Chưa có dữ liệu hiện tại)
├── images/             # Thư mục hình ảnh động của dự án (Chưa có tư liệu hiện tại)
├── layouts/            # Các thành phần giao diện dùng chung (Includes)
│   ├── navbar.jsp          # Thanh điều hướng trên cùng
│   ├── footer.jsp          # Chân trang web
│   ├── chatbot.jsp         # Tích hợp widget Chatbot
│   └── sidebar-admin.jsp   # Menu bên phục vụ nội dung người dùng Admin
└── pages/              # Các trang chức năng nội bộ (dành cho Khách & Admin)
    ├── rooms.jsp           # Trang liệt kê hệ thống phòng đầy đủ
    ├── contact.jsp         # Trang liên hệ
    ├── dashboard.jsp       # Trang tổng quan
    ├── manager.jsp         # Trang quản lý hệ thống
    └── admin-room-edit.jsp # Trang chỉnh sửa cập nhật phòng dành cho Admin
```

---

## 🚀 5. Hướng Dẫn Cài Đặt (Setup Guide)

Để dự án hoạt động trơn tru trên môi trường cá nhân (Localhost), hãy thực hiện:

**Bước 1: Khởi tạo Database**
1. Mở MySQL Workbench, XAMPP hoặc công cụ MySQL của bạn.
2. Tạo database mới: `CREATE DATABASE omnistay CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`
3. Import file `omnistay.sql` có trong thư mục gốc của dự án vào database vừa tạo.

**Bước 2: Cài Đặt Server**
1. Cài đặt **Apache Tomcat 10**.
2. Tải Driver `mysql-connector-j-8.x.x.jar` tha vào thư mục `lib` của Tomcat (Nếu server của bạn chưa có).
3. Clone/Copy toàn bộ thư mục `OmniStay` thả trực tiếp vào thư mục `webapps/` của Tomcat.

**Bước 3: Chạy ứng dụng & Khởi Nghiệm**
1. Mở máy chủ Tomcat (Start Tomcat).
2. Khi deploy thành công, truy cập trình duyệt bằng nhánh: `http://localhost:8080/OmniStay/index.jsp`

> **Cấu hình DB trong code**: Kiểm tra và chỉnh sửa Scriptlets ở các file `.jsp` (ví dụ `index.jsp` từ dòng 8-9) để đảm bảo password (mặc định trống `""`) và username (`root`) khớp với hạ tầng máy cá nhân của bạn.

---

Hoàn thiện bởi **Đội ngũ OmniStay**. Chúc bạn thao tác thuận lợi!
