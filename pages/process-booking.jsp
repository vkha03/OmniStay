<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<%
    // 1. CHỐNG LỖI FONT TIẾNG VIỆT
    request.setCharacterEncoding("UTF-8");

    // 2. HỨNG DỮ LIỆU TỪ FORM
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
            // 3. KẾT NỐI DATABASE
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/omnistay", "root", "");

            // ==========================================
            // BƯỚC 0: TÌM ID PHÒNG VÀ GIÁ TIỀN THẬT
            // ==========================================
            int dbRoomId = 0;
            double roomPrice = 0;
            String sql0 = "SELECT rs.id, rt.base_price FROM rooms rs JOIN room_types rt ON rs.room_type_id = rt.id WHERE rs.room_number = ?";
            PreparedStatement ps0 = conn.prepareStatement(sql0);
            ps0.setString(1, roomNumber);
            ResultSet rs0 = ps0.executeQuery();
            if(rs0.next()) {
                dbRoomId = rs0.getInt("id");          
                roomPrice = rs0.getDouble("base_price"); 
            }
            rs0.close(); ps0.close();

            if(dbRoomId > 0) {
                // ==========================================
                // BƯỚC 1: TÍNH SỐ ĐÊM VÀ TỔNG TIỀN (CÁCH CƠ BẢN)
                // ==========================================
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                java.util.Date d1 = sdf.parse(checkIn);
                java.util.Date d2 = sdf.parse(checkOut);
                
                // Tính số đêm = (Thời gian ra - Thời gian vào) / mili-giây của 1 ngày
                long diff = d2.getTime() - d1.getTime();
                long soDem = diff / (24 * 60 * 60 * 1000);
                
                if (soDem <= 0) { soDem = 1; } // Nếu khách ở đi trong ngày tính 1 đêm
                double tongTien = roomPrice * soDem;

                // ==========================================
                // BƯỚC 2: THÊM KHÁCH HÀNG (LẤY ID GUEST)
                // ==========================================
                String sql1 = "INSERT INTO guests (full_name, phone_number, email) VALUES (?, ?, ?)";
                PreparedStatement ps1 = conn.prepareStatement(sql1, Statement.RETURN_GENERATED_KEYS);
                ps1.setString(1, fullName);
                ps1.setString(2, phone);
                ps1.setString(3, email);
                ps1.executeUpdate();

                ResultSet rs1 = ps1.getGeneratedKeys();
                rs1.next();
                int guestId = rs1.getInt(1); // Đây là ID khách vừa tạo
                rs1.close(); ps1.close();

                // ==========================================
                // BƯỚC 3: THÊM HÓA ĐƠN (LẤY ID BOOKING)
                // ==========================================
                // Tạo mã: BK-3 số cuối SĐT-Số ngẫu nhiên
                String suffix = phone.length() > 3 ? phone.substring(phone.length() - 3) : phone;
                String bookingCode = "BK-" + suffix + "-" + (System.currentTimeMillis() % 10000);
                
                String sql2 = "INSERT INTO bookings (booking_code, guest_id, check_in_date, check_out_date, total_amount, notes, status) VALUES (?, ?, ?, ?, ?, ?, 'PENDING')";
                PreparedStatement ps2 = conn.prepareStatement(sql2, Statement.RETURN_GENERATED_KEYS);
                ps2.setString(1, bookingCode);
                ps2.setInt(2, guestId); 
                ps2.setString(3, checkIn);
                ps2.setString(4, checkOut);
                ps2.setDouble(5, tongTien); 
                ps2.setString(6, note);
                ps2.executeUpdate();

                ResultSet rs2 = ps2.getGeneratedKeys();
                rs2.next();
                int bookingId = rs2.getInt(1); // Đây là ID hóa đơn vừa tạo
                rs2.close(); ps2.close();

                // ==========================================
                // BƯỚC 4: LƯU CHI TIẾT PHÒNG VÀ KHÓA PHÒNG
                // ==========================================
                // 4.1 Lưu vào bảng chi tiết
                String sql3 = "INSERT INTO booking_rooms (booking_id, room_id, historical_price) VALUES (?, ?, ?)";
                PreparedStatement ps3 = conn.prepareStatement(sql3);
                ps3.setInt(1, bookingId);
                ps3.setInt(2, dbRoomId);
                ps3.setDouble(3, roomPrice);
                ps3.executeUpdate();
                ps3.close();

                // 4.2 Cập nhật trạng thái phòng sang 'OCCUPIED'
                String sql4 = "UPDATE rooms SET status = 'OCCUPIED' WHERE id = ?";
                PreparedStatement ps4 = conn.prepareStatement(sql4);
                ps4.setInt(1, dbRoomId);
                ps4.executeUpdate();
                ps4.close();

                // ==========================================
                // XONG! CHUYỂN TRANG BÁO THÀNH CÔNG
                // ==========================================
                session.setAttribute("thongBao", "Đặt phòng thành công! Mã đơn: " + bookingCode);
                response.sendRedirect("rooms.jsp"); 
                
            } else {
                out.println("Lỗi: Không tìm thấy số phòng này.");
            }
            conn.close();
        } catch (Exception e) {
            out.println("Lỗi hệ thống: " + e.getMessage());
        }
    }
%>