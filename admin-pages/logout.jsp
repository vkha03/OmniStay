<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- ==========================================================================
     ĐIỀU KHIỂN ĐĂNG XUẤT HỆ THỐNG (ADMIN LOGOUT ACTION)
     Đóng vai trò là điểm cuối (endpoint) chấm dứt phiên làm việc an toàn:
     Hủy bỏ vĩnh viễn toàn bộ thuộc tính được lưu trữ trong đối tượng Session,
     sau đó lập tức chuyển hướng người dùng trở về màn hình xác thực đăng nhập.
     ========================================================================== --%>
<%
    // Xóa sạch bộ nhớ phiên hiện tại nhằm phòng ngừa chiếm đoạt phiên (Session Hijacking)
    session.invalidate();
    
    // Điều hướng trở lại giao diện cổng đăng nhập trung tâm
    response.sendRedirect("dangnhap.jsp");
%>
