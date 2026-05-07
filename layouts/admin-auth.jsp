<%
    // ==========================================
    // KIỂM TRA QUYỀN TRUY CẬP ADMIN
    // ==========================================
    
    // 1. Kiểm tra session có tồn tại không
    String adminEmail = (String) session.getAttribute("admin");
    String adminRole = (String) session.getAttribute("role");

    // 2. Nếu chưa đăng nhập -> Chuyển hướng về trang đăng nhập
    if (adminEmail == null || adminRole == null) {
        response.sendRedirect("dangnhap.jsp");
        return;
    }
%>
