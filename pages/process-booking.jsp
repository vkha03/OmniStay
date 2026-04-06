<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String roomNumber = request.getParameter("roomId"); 
    String checkIn = request.getParameter("checkIn");
    String checkOut = request.getParameter("checkOut");
    String fullName = request.getParameter("fullName");
    String phone = request.getParameter("phone");
    String email = request.getParameter("email");
    String note = request.getParameter("note");

    if(roomNumber != null && fullName != null) {
        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/omnistay", "root", "");

            // ==========================================
            // BƯỚC 0: TỰ ĐỘNG TÌM ID VÀ GIÁ TIỀN TỪ SỐ PHÒNG
            // ==========================================
            int dbRoomId = 0;
            double roomPrice = 0;
            
            // JOIN bảng rooms và room_types để lôi giá ra
            String sql0 = "SELECT rs.id, rt.base_price FROM rooms rs JOIN room_types rt ON rs.room_type_id = rt.id WHERE rs.room_number = ?";
            PreparedStatement ps0 = conn.prepareStatement(sql0);
            ps0.setString(1, roomNumber);
            ResultSet rs0 = ps0.executeQuery();
            if(rs0.next()) {
                dbRoomId = rs0.getInt("id");         
                roomPrice = rs0.getDouble("base_price"); 
            }
            rs0.close(); ps0.close();

            // Nếu tìm thấy phòng thì mới chạy tiếp
            if(dbRoomId > 0) {
                
                // ==========================================
                // BƯỚC 1: THÊM KHÁCH HÀNG
                // ==========================================
                String sql1 = "INSERT INTO guests (full_name, phone_number, email) VALUES (?, ?, ?)";
                PreparedStatement ps1 = conn.prepareStatement(sql1, Statement.RETURN_GENERATED_KEYS);
                ps1.setString(1, fullName);
                ps1.setString(2, phone);
                ps1.setString(3, email);
                ps1.executeUpdate();

                // Lấy ID khách hàng vừa đẻ ra
                ResultSet rs1 = ps1.getGeneratedKeys();
                rs1.next();
                int guestId = rs1.getInt(1); 
                rs1.close(); ps1.close();

                // ==========================================
                // BƯỚC 2: THÊM HÓA ĐƠN (bookings)
                // ==========================================
                // Lấy chữ "BK-" ghép với Số điện thoại của khách luôn cho dễ nhớ!
				String bookingCode = "BK-" + phone;
                
                String sql2 = "INSERT INTO bookings (booking_code, guest_id, check_in_date, check_out_date, total_amount, notes, status) VALUES (?, ?, ?, ?, ?, ?, 'PENDING')";
             	// Ép nó trả về cái ID tự tăng vừa tạo ra (Statement.RETURN_GENERATED_KEYS)
                PreparedStatement ps2 = conn.prepareStatement(sql2, Statement.RETURN_GENERATED_KEYS);
                ps2.setString(1, bookingCode);
                ps2.setInt(2, guestId); 
                ps2.setString(3, checkIn);
                ps2.setString(4, checkOut);
                ps2.setDouble(5, roomPrice); 
                ps2.setString(6, note);
                ps2.executeUpdate();

                // Lấy ID hóa đơn vừa đẻ ra
                ResultSet rs2 = ps2.getGeneratedKeys();
                rs2.next();
                int bookingId = rs2.getInt(1);
                rs2.close(); ps2.close();

                // ==========================================
                // BƯỚC 3: THÊM CHI TIẾT PHÒNG (booking_rooms)
                // ==========================================
                String sql3 = "INSERT INTO booking_rooms (booking_id, room_id, historical_price) VALUES (?, ?, ?)";
                PreparedStatement ps3 = conn.prepareStatement(sql3);
                ps3.setInt(1, bookingId); 
                ps3.setInt(2, dbRoomId); 
                ps3.setDouble(3, roomPrice);
                ps3.executeUpdate();
                ps3.close();

                // ==========================================
                // BƯỚC 4: KHÓA PHÒNG LẠI (OCCUPIED)
                // ==========================================
                String sql4 = "UPDATE rooms SET status = 'OCCUPIED' WHERE id = ?";
                PreparedStatement ps4 = conn.prepareStatement(sql4);
                ps4.setInt(1, dbRoomId); 
                ps4.executeUpdate();
                ps4.close();

                // ==========================================
                // XONG! BÁO THÀNH CÔNG VÀ CHUYỂN TRANG
                // ==========================================
                session.setAttribute("thongBao", "Tuyệt vời! Đặt phòng " + roomNumber + " thành công. Mã hóa đơn: " + bookingCode);
                response.sendRedirect("rooms.jsp"); 
                
            } else {
                out.println("<h3>Lỗi: Không tìm thấy phòng này trong hệ thống!</h3>");
            }
            
            conn.close();

        } catch (Exception e) {
            out.println("<h3>Lỗi hệ thống: " + e.getMessage() + "</h3>");
        }
    } else {
        out.println("<h3>Vui lòng nhập đủ thông tin!</h3>");
    }
%>