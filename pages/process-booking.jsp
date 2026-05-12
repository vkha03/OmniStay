<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.SimpleDateFormat, java.util.*, java.net.URLEncoder, java.nio.charset.StandardCharsets" %>
<%@ include file="vnpay-config.jsp" %>
<%
    // Thiết lập bảng mã UTF-8 cho yêu cầu để đọc chính xác tiếng Việt có dấu
    request.setCharacterEncoding("UTF-8");

    // 1. TRÍCH XUẤT VÀ CHUẨN HÓA DỮ LIỆU TỪ FORM (FORM DATA EXTRACTION)
    // Các tham số này được POST từ giao diện booking.jsp
    String roomNumber = request.getParameter("roomId"); 
    String checkIn = request.getParameter("checkIn");
    String checkOut = request.getParameter("checkOut");
    String fullName = request.getParameter("fullName");
    String phone = request.getParameter("phone");
    String email = request.getParameter("email");
    String note = request.getParameter("note");
    String idCard = request.getParameter("idCard");
    String birthDate = request.getParameter("birthDate");
    String adults = request.getParameter("adults");
    String children = request.getParameter("children");
    String paymentMethod = request.getParameter("paymentMethod");

    if(roomNumber != null && fullName != null) {
        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(SECRET_DB_URL, SECRET_DB_USER, SECRET_DB_PASS);

            // 2. TRUY VẤN XÁC THỰC PHÒNG VÀ ĐƠN GIÁ (VALIDATE ROOM & FETCH BASE PRICE)
            // Đảm bảo số phòng tồn tại và trích xuất đúng khóa chính (id) cùng giá cơ bản
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
                // 3. THUẬT TOÁN TÍNH TOÁN SỐ ĐÊM LƯU TRÚ (NIGHTS & TOTAL COST CALCULATION)
                // Phân tích chuỗi ngày sang đối tượng Date để tính khoảng cách thời gian chính xác
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                java.util.Date d1 = sdf.parse(checkIn);
                java.util.Date d2 = sdf.parse(checkOut);
                // Trừ thời gian quy ra mili-giây
                long diff = d2.getTime() - d1.getTime();
                // Chuyển đổi mili-giây sang số ngày (1 ngày = 24h * 60m * 60s * 1000ms)
                long soDem = diff / (24 * 60 * 60 * 1000);
                // Xử lý an toàn: Nếu khách đặt check-out cùng ngày check-in, tính tối thiểu là 1 đêm
                if (soDem <= 0) { soDem = 1; }
                double tongTien = roomPrice * soDem;

                // 4. QUẢN LÝ HỒ SƠ KHÁCH HÀNG - CƠ CHẾ UPSERT (GUEST RECORD MANAGEMENT)
                // Sử dụng Số CCCD/Hộ chiếu (id_card) làm định danh duy nhất để tránh trùng lặp dữ liệu
                int guestId = 0;
                String sqlCheckGuest = "SELECT id FROM guests WHERE id_card = ?";
                PreparedStatement psCheck = conn.prepareStatement(sqlCheckGuest);
                psCheck.setString(1, idCard);
                ResultSet rsCheck = psCheck.executeQuery();
                
                if(rsCheck.next()) {
                    // TRƯỜNG HỢP 1: Khách hàng cũ đã từng lưu trú -> Trích xuất ID và cập nhật thông tin mới nhất
                    guestId = rsCheck.getInt("id");
                    String sqlUpdateGuest = "UPDATE guests SET full_name = ?, phone_number = ?, email = ?, birth_date = ? WHERE id = ?";
                    PreparedStatement psUpdate = conn.prepareStatement(sqlUpdateGuest);
                    psUpdate.setString(1, fullName);
                    psUpdate.setString(2, phone);
                    psUpdate.setString(3, email);
                    psUpdate.setString(4, birthDate);
                    psUpdate.setInt(5, guestId);
                    psUpdate.executeUpdate();
                    psUpdate.close();
                } else {
                    // TRƯỜNG HỢP 2: Khách hàng hoàn toàn mới -> Thêm mới bản ghi vào bảng `guests`
                    // Sử dụng cờ Statement.RETURN_GENERATED_KEYS để lấy ngay ID tự tăng vừa khởi tạo
                    String sql1 = "INSERT INTO guests (full_name, phone_number, email, id_card, birth_date) VALUES (?, ?, ?, ?, ?)";
                    PreparedStatement ps1 = conn.prepareStatement(sql1, Statement.RETURN_GENERATED_KEYS);
                    ps1.setString(1, fullName);
                    ps1.setString(2, phone);
                    ps1.setString(3, email);
                    ps1.setString(4, idCard);
                    ps1.setString(5, birthDate);
                    ps1.executeUpdate();
                    ResultSet rs1 = ps1.getGeneratedKeys();
                    if(rs1.next()) guestId = rs1.getInt(1);
                    rs1.close(); ps1.close();
                }
                rsCheck.close(); psCheck.close();

                // 5. KHỞI TẠO ĐƠN ĐẶT PHÒNG VỚI TRẠNG THÁI PENDING (CREATE PENDING BOOKING)
                // Đơn hàng mang trạng thái PENDING nhằm giữ chỗ tạm thời trong quá trình chờ thanh toán VNPAY
                // Mã đặt phòng phát sinh ngẫu nhiên mang tiền tố BK (Booking Code)
                String bookingCode = "BK" + (System.currentTimeMillis() % 1000000);
                String sql2 = "INSERT INTO bookings (booking_code, guest_id, check_in_date, check_out_date, total_amount, notes, status, customer_full_name, customer_email, customer_phone, customer_id_card, num_adults, num_children, payment_method) VALUES (?, ?, ?, ?, ?, ?, 'PENDING', ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement ps2 = conn.prepareStatement(sql2, Statement.RETURN_GENERATED_KEYS);
                ps2.setString(1, bookingCode);
                ps2.setInt(2, guestId);
                ps2.setString(3, checkIn);
                ps2.setString(4, checkOut);
                ps2.setDouble(5, tongTien);
                ps2.setString(6, note);
                ps2.setString(7, fullName);
                ps2.setString(8, email);
                ps2.setString(9, phone);
                ps2.setString(10, idCard);
                ps2.setInt(11, Integer.parseInt(adults != null ? adults : "1"));
                ps2.setInt(12, Integer.parseInt(children != null ? children : "0"));
                ps2.setString(13, paymentMethod);
                ps2.executeUpdate();
                ResultSet rs2 = ps2.getGeneratedKeys();
                rs2.next();
                int bookingId = rs2.getInt(1);
                rs2.close(); ps2.close();

                // 6. ÁNH XẠ CHI TIẾT CÁC PHÒNG ĐƯỢC ĐẶT (INSERT BOOKING_ROOMS MAPPING)
                // Lưu lại mức giá lịch sử (historical_price) để đối soát kế toán sau này,
                // Tránh tình trạng thay đổi giá gốc làm sai lệch báo cáo doanh thu cũ.
                // LƯU Ý: Chưa cập nhật cột `status` của phòng sang OCCUPIED, việc này chỉ làm khi thanh toán thành công
                String sql3 = "INSERT INTO booking_rooms (booking_id, room_id, historical_price) VALUES (?, ?, ?)";
                PreparedStatement ps3 = conn.prepareStatement(sql3);
                ps3.setInt(1, bookingId);
                ps3.setInt(2, dbRoomId);
                ps3.setDouble(3, roomPrice);
                ps3.executeUpdate();
                ps3.close();

                // 7. TÍCH HỢP CỔNG THANH TOÁN QUỐC GIA VNPAY (VNPAY GATEWAY REDIRECTION)
                
                // Chuẩn hóa địa chỉ IP của Client theo chuẩn IPv4 đề phòng môi trường thử nghiệm trả về IPv6 loopback
                String vnp_IpAddr = request.getRemoteAddr();
                if ("0:0:0:0:0:0:0:1".equals(vnp_IpAddr)) {
                    vnp_IpAddr = "127.0.0.1";
                }

                // Cấu trúc danh sách tham số gửi sang VNPAY theo tài liệu kỹ thuật chính thức
                Map<String, String> vnp_Params = new HashMap<>();
                vnp_Params.put("vnp_Version", vnp_TmnVersion);
                vnp_Params.put("vnp_Command", vnp_Command);
                vnp_Params.put("vnp_TmnCode", vnp_TmnCode);
                // VNPAY quy định số tiền gửi đi phải nhân với 100 (xóa hai chữ số thập phân ngầm định)
                vnp_Params.put("vnp_Amount", String.valueOf((long)Math.round(tongTien * 100)));
                vnp_Params.put("vnp_CurrCode", "VND");
                vnp_Params.put("vnp_TxnRef", bookingCode); // Mã tham chiếu đối soát duy nhất
                vnp_Params.put("vnp_OrderInfo", "Thanhtoandonhang" + bookingCode);
                vnp_Params.put("vnp_OrderType", "other");
                vnp_Params.put("vnp_Locale", "vn");
                vnp_Params.put("vnp_ReturnUrl", vnp_Returnurl);
                vnp_Params.put("vnp_IpAddr", vnp_IpAddr); 
                vnp_Params.put("vnp_CreateDate", new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date()));

                // Sắp xếp các trường tham số theo thứ tự Alphabet để tạo chuỗi băm (Secure Hash) chính xác
                List fieldNames = new ArrayList(vnp_Params.keySet());
                Collections.sort(fieldNames);
                StringBuilder hashData = new StringBuilder();
                StringBuilder query = new StringBuilder();
                Iterator itr = fieldNames.iterator();
                
                while (itr.hasNext()) {
                    String fieldName = (String) itr.next();
                    String fieldValue = (String) vnp_Params.get(fieldName);
                    if ((fieldValue != null) && (fieldValue.length() > 0)) {
                        if (hashData.length() > 0) {
                            hashData.append('&');
                            query.append('&');
                        }
                        
                        // KỸ THUẬT QUAN TRỌNG: Mã hóa URL (URL Encoding) chuẩn UTF-8 cho CẢ Tên trường VÀ Giá trị
                        // Thay thế dấu cộng (+) sinh ra mặc định thành chuỗi %20 để tuân thủ RFC 3986 của VNPAY
                        String encodedFieldName = URLEncoder.encode(fieldName, StandardCharsets.UTF_8.toString()).replace("+", "%20");
                        String encodedFieldValue = URLEncoder.encode(fieldValue, StandardCharsets.UTF_8.toString()).replace("+", "%20");
                        
                        hashData.append(encodedFieldName).append('=').append(encodedFieldValue);
                        query.append(encodedFieldName).append('=').append(encodedFieldValue);
                    }
                }
                
                // Tạo chữ ký bảo mật SHA-512 sử dụng Chuỗi bí mật (Hash Secret) để chống giả mạo gói tin
                String vnp_SecureHash = hmacSHA512(vnp_HashSecret, hashData.toString());
                String paymentUrl = vnp_Url + "?" + query.toString() + "&vnp_SecureHash=" + vnp_SecureHash;
                
                // Chuyển hướng ngay lập tức trình duyệt của khách hàng sang trang cổng thanh toán VNPAY
                response.sendRedirect(paymentUrl);
            }
            conn.close();
        } catch (Exception e) {
            out.println("Lỗi hệ thống: " + e.getMessage());
            e.printStackTrace();
        }
    }
%>