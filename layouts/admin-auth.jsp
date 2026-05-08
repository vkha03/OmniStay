<%
    // ==========================================
    // KIỂM TRA QUYỀN TRUY CẬP ADMIN
    // ==========================================
    
    // 1. Kiểm tra session có tồn tại không
    String adminEmail = (String) session.getAttribute("admin");
    String adminRole = (String) session.getAttribute("role"); // ADMIN or RECEPTIONIST

    // 2. Nếu chưa đăng nhập -> Chuyển hướng về trang đăng nhập
    if (adminEmail == null || adminRole == null) {
        response.sendRedirect(request.getContextPath() + "/admin-pages/dangnhap.jsp");
        return;
    }
%>
