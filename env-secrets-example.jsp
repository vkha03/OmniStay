<%! 
    // ========================================================================
    // OMNISTAY - CẤU HÌNH CÁC THAM SỐ HỆ THỐNG & BẢO MẬT (MẪU)
    // HƯỚNG DẪN: Hãy Copy file này thành env-secrets.jsp và điền thông tin thật.
    // Các biến này được định nghĩa ở cấp độ class (Declaration block)
    // nhằm mục đích tái sử dụng và chia sẻ trạng thái an toàn giữa các trang.
    // ========================================================================

    // 1. CẤU HÌNH CƠ SỞ DỮ LIỆU (DATABASE CONFIGURATION)
    // Đường dẫn kết nối JDBC chuẩn, tắt xác thực SSL và sử dụng chuẩn thời gian quốc tế UTC
    public static final String SECRET_DB_URL = "jdbc:mysql://localhost:3306/omnistay?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    // Tên tài khoản quản trị CSDL của bạn
    public static final String SECRET_DB_USER = "YOUR_DB_USER"; 
    // Mật khẩu truy cập CSDL tương ứng
    public static final String SECRET_DB_PASS = "YOUR_DB_PASSWORD"; 

    // 2. TÍCH HỢP CỔNG THANH TOÁN VNPAY (VNPAY PAYMENT GATEWAY)
    // Mã đối tác (Terminal ID) do hệ thống VNPAY cung cấp khi đăng ký môi trường Sandbox/Live
    public static final String SECRET_VNP_TMN = "YOUR_VNP_TMN_HERE"; 
    // Chuỗi mã hóa bí mật dùng để xác thực tính hợp lệ của gói tin yêu cầu/phản hồi
    public static final String SECRET_VNP_HASH = "YOUR_VNP_HASH_HERE"; 

    // 3. THÔNG BÁO QUẢN LÝ QUA ZALO BOT (ZALO BOT NOTIFICATION)
    // Khóa truy cập API của ứng dụng Zalo Official Account
    public static final String SECRET_ZALO_TOKEN = "YOUR_ZALO_TOKEN_HERE";
    // ID của người dùng hoặc nhóm Zalo nhận tin nhắn tự động từ hệ thống
    public static final String SECRET_ZALO_CHATID = "YOUR_ZALO_CHATID_HERE"; 

    // 4. DỊCH VỤ SMTP GỬI EMAIL (EMAIL SMTP SERVICE)
    // Địa chỉ server SMTP mặc định (Sử dụng Gmail của Google)
    public static final String SECRET_MAIL_HOST = "smtp.gmail.com"; 
    // Cổng giao tiếp SMTP hỗ trợ giao thức bảo mật TLS
    public static final String SECRET_MAIL_PORT = "587"; 
    // Tài khoản email dùng làm hệ thống gửi thư tự động
    public static final String SECRET_MAIL_USER = "YOUR_EMAIL_HERE"; 
    // Mật khẩu ứng dụng (App Password) được tạo từ phần bảo mật tài khoản Google
    public static final String SECRET_MAIL_PASS = "YOUR_GMAIL_APP_PASSWORD_HERE"; 

    // 5. TÍCH HỢP TRỢ LÝ TRÍ TUỆ NHÂN TẠO (GOOGLE GEMINI AI CONFIGURATION)
    // Khóa API xác thực yêu cầu truy vấn đến dịch vụ AI của Google DeepMind
    public static final String SECRET_GEMINI_KEY = "YOUR_GEMINI_API_KEY_HERE"; 
    // Tên phiên bản mô hình ngôn ngữ lớn được tối ưu hóa cho tác vụ khách sạn
    public static final String SECRET_GEMINI_MODEL = "gemini-2.0-flash"; 
%>
