<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../env-secrets.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    String bookingId = request.getParameter("booking_id");
    String guestId = request.getParameter("guest_id");
    String roomId = request.getParameter("room_id");
    String rating = request.getParameter("rating");
    String comment = request.getParameter("comment");
    String code = request.getParameter("code");
    String phone = request.getParameter("phone");

    if (bookingId != null && rating != null) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(SECRET_DB_URL, SECRET_DB_USER, SECRET_DB_PASS);
            
            String sql = "INSERT INTO reviews (guest_id, booking_id, room_id, rating, comment, status) VALUES (?, ?, ?, ?, ?, 1)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(guestId));
            pstmt.setInt(2, Integer.parseInt(bookingId));
            pstmt.setInt(3, Integer.parseInt(roomId));
            pstmt.setInt(4, Integer.parseInt(rating));
            pstmt.setString(5, comment);
            
            pstmt.executeUpdate();
            
            // Redirect back with success message
            response.sendRedirect("invoice-detail.jsp?code=" + code + "&phone=" + phone + "&feedback=success");
            
        } catch (Exception e) {
            out.println("Lỗi khi gửi đánh giá: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    } else {
        response.sendRedirect("invoice-lookup.jsp");
    }
%>
