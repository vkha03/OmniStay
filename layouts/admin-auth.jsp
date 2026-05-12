<%
    // ========================================================================
    // KIỂM TRA QUYỀN TRUY CẬP HỆ THỐNG QUẢN TRỊ (ADMIN / STAFF AUTHENTICATION)
    // File này được include ở đầu tất cả các trang trong thư mục admin-pages.
    // Đảm nhận vai trò như một Middleware xác thực (Authentication Filter),
    // ngăn chặn các truy cập trái phép trực tiếp qua URL khi chưa đăng nhập.
    // ========================================================================
    
    // 1. TRÍCH XUẤT THÔNG TIN PHIÊN LÀM VIỆC (READ SESSION ATTRIBUTES)
    // Lấy thông tin tài khoản đăng nhập từ đối tượng `session` (HttpSession).
    String adminEmail = (String) session.getAttribute("admin");
    // Lấy cấp độ phân quyền (Role) của người dùng để quyết định tính năng được phép hiển thị:
    // - 'ADMIN': Toàn quyền quản trị (Quản lý nhân sự, cấu hình hệ thống, xóa dữ liệu).
    // - 'RECEPTIONIST': Quyền lễ tân (Quản lý đặt phòng, check-in, dịch vụ).
    String adminRole = (String) session.getAttribute("role"); 

    // 2. KIỂM TRA TÍNH HỢP LỆ VÀ ĐIỀU HƯỚNG (VALIDATE AND REDIRECT)
    // Nếu thuộc tính `admin` hoặc `role` không tồn tại (nghĩa là phiên làm việc đã hết hạn
    // hoặc người dùng chưa từng đăng nhập hợp lệ), hệ thống sẽ từ chối truy cập.
    if (adminEmail == null || adminRole == null) {
        // Gửi mã phản hồi 302 Redirect, điều hướng trình duyệt về trang đăng nhập
        response.sendRedirect(request.getContextPath() + "/admin-pages/dangnhap.jsp");
        // Dừng ngay việc thực thi các đoạn mã nguồn ở trang chính (trang include file này),
        // tránh rò rỉ dữ liệu hoặc lỗi do thiếu thông tin tài khoản
        return;
    }
%>
