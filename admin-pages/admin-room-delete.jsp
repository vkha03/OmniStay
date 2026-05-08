<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../layouts/admin-auth.jsp" %>
<%
    if (!"ADMIN".equals(adminRole)) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<%@ page import="java.sql.*" %>
<%
    // 1. Hứng ID của phòng cần xóa từ URL
    String roomId = request.getParameter("id");

    if (roomId != null && !roomId.isEmpty()) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            // 2. Kết nối Database
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/omnistay", "root", "");

            // 3. Viết lệnh Xóa
            String sql = "DELETE FROM rooms WHERE id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(roomId));
            
            // 4. Thực thi lệnh
            int rowsAffected = ps.executeUpdate();

            // 5. Nếu xóa thành công thì tạo thông báo màu xanh gửi về
            if (rowsAffected > 0) {
                session.setAttribute("thongBao", "Đã xóa phòng thành công khỏi hệ thống!");
            }

        } catch (Exception e) {
            // Nếu lỗi (ví dụ phòng đang dính khóa ngoại với bảng booking) thì báo lỗi
            session.setAttribute("thongBao", "Lỗi không thể xóa: " + e.getMessage());
        } finally {
            // Đóng kết nối cho an toàn
            if (ps != null) try { ps.close(); } catch (Exception ignore) {}
            if (conn != null) try { conn.close(); } catch (Exception ignore) {}
        }
    }

    // 6. Xóa xong (hoặc lỗi) thì lập tức đá văng về trang danh sách phòng
    response.sendRedirect("admin-rooms.jsp");
%>