<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../env-secrets.jsp" %>
<%-- ==========================================================================
     BỘ ĐIỀU KHIỂN XỬ LÝ LƯU TRỮ ĐÁNH GIÁ (FEEDBACK SUBMISSION CONTROLLER)
     Hứng dữ liệu đánh giá từ trang chi tiết hóa đơn (invoice-detail.jsp)
     khi khách hàng thực hiện gửi nhận xét về phòng đã lưu trú.
     Tự động gán trạng thái được duyệt (status = 1) do được xác thực qua đơn hàng.
     ========================================================================== --%>
<%
    // 1. CHUẨN HÓA BẢNG MÃ VÀ TIẾP NHẬN THAM SỐ (PARAMETER EXTRACTION)
    request.setCharacterEncoding("UTF-8");
    String bookingId = request.getParameter("booking_id");
    String guestId = request.getParameter("guest_id");
    String roomId = request.getParameter("room_id");
    String rating = request.getParameter("rating");
    String comment = request.getParameter("comment");
    // Mã đặt phòng và SĐT để duy trì phiên tra cứu chi tiết hóa đơn sau khi chuyển hướng
    String code = request.getParameter("code");
    String phone = request.getParameter("phone");

    // Xác thực cơ bản: Phải có ID đơn đặt phòng và Điểm đánh giá (Rating)
    if (bookingId != null && rating != null) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            // 2. KHỞI TẠO KẾT NỐI VÀ LƯU VÀO CSDL (PERSIST REVIEW RECORD)
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(SECRET_DB_URL, SECRET_DB_USER, SECRET_DB_PASS);
            
            // Chèn bản ghi mới vào bảng reviews. Đặt status = 1 (Hiển thị ngay lập tức)
            String sql = "INSERT INTO reviews (guest_id, booking_id, room_id, rating, comment, status) VALUES (?, ?, ?, ?, ?, 1)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(guestId));
            pstmt.setInt(2, Integer.parseInt(bookingId));
            pstmt.setInt(3, Integer.parseInt(roomId));
            pstmt.setInt(4, Integer.parseInt(rating));
            pstmt.setString(5, comment);
            
            pstmt.executeUpdate();
            
            // 3. CHUYỂN HƯỚNG VỀ GIAO DIỆN HÓA ĐƠN KÈM THÔNG BÁO (REDIRECT WITH SUCCESS FLAG)
            // Trả khách hàng về giao diện cũ kèm theo tham số feedback=success để kích hoạt thông báo thành công
            response.sendRedirect("invoice-detail.jsp?code=" + code + "&phone=" + phone + "&feedback=success");
            
        } catch (Exception e) {
            out.println("Lỗi khi gửi đánh giá: " + e.getMessage());
            e.printStackTrace();
        } finally {
            // 4. THU HỒI TÀI NGUYÊN (CLEANUP RESOURCES)
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    } else {
        // Trường hợp truy cập trực tiếp trái phép, đẩy về trang tra cứu hóa đơn gốc
        response.sendRedirect("invoice-lookup.jsp");
    }
%>
