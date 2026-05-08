<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.NumberFormat" %>
<%@ page import="jakarta.mail.*, jakarta.mail.internet.*" %>
<%@ include file="vnpay-config.jsp" %>
<%
    // 1. THU THẬP THAM SỐ
    Map<String, String> fields = new HashMap<>();
    for (Enumeration<String> params = request.getParameterNames(); params.hasMoreElements();) {
        String fieldName = params.nextElement();
        String fieldValue = request.getParameter(fieldName);
        if ((fieldValue != null) && (fieldValue.length() > 0)) {
            fields.put(fieldName, fieldValue);
        }
    }

    String vnp_SecureHash = request.getParameter("vnp_SecureHash");
    fields.remove("vnp_SecureHashType");
    fields.remove("vnp_SecureHash");
    
    // 2. KIỂM TRA CHỮ KÝ
    String signValue = hashAllFields(fields);
    
    boolean isSuccess = false;
    String statusText = "Thanh toán thất bại";
    String message = "";
    String vnp_TxnRef = request.getParameter("vnp_TxnRef"); // Đây là mã booking_code
    
    // Khai báo biến hiển thị UI
    String uiGuestName = "N/A";
    String uiGuestPhone = "N/A";
    String uiGuestEmail = "N/A";
    String uiRoomNumber = "N/A";
    double uiAmount = 0;
    String vnp_TransactionNo = request.getParameter("vnp_TransactionNo");
    
    if (signValue.equals(vnp_SecureHash)) {
        if ("00".equals(request.getParameter("vnp_ResponseCode"))) {
            
            // 3. XỬ LÝ DATABASE KHI THÀNH CÔNG
            Connection conn = null;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(SECRET_DB_URL, SECRET_DB_USER, SECRET_DB_PASS);
                conn.setAutoCommit(false);

                // 3.1 Tìm ID đơn hàng từ booking_code
                String sqlFind = "SELECT id FROM bookings WHERE booking_code = ?";
                PreparedStatement psF = conn.prepareStatement(sqlFind);
                psF.setString(1, vnp_TxnRef);
                ResultSet rsF = psF.executeQuery();
                if(rsF.next()) {
                    int bookingId = rsF.getInt("id");

                    // 3.2 Cập nhật trạng thái đơn hàng sang CONFIRMED và thanh toán PAID, cập nhật số tiền đã trả
                    String sqlUp = "UPDATE bookings SET status = 'CONFIRMED', payment_status = 'PAID', paid_amount = total_amount WHERE id = ?";
                    PreparedStatement psU = conn.prepareStatement(sqlUp);
                    psU.setInt(1, bookingId);
                    psU.executeUpdate();

                    // 3.3 Tìm và Khóa phòng liên quan
                    String sqlRoom = "SELECT room_id FROM booking_rooms WHERE booking_id = ?";
                    PreparedStatement psR = conn.prepareStatement(sqlRoom);
                    psR.setInt(1, bookingId);
                    ResultSet rsR = psR.executeQuery();
                    while(rsR.next()) {
                        int roomId = rsR.getInt("room_id");
                        String sqlLock = "UPDATE rooms SET status = 'OCCUPIED' WHERE id = ?";
                        PreparedStatement psL = conn.prepareStatement(sqlLock);
                        psL.setInt(1, roomId);
                        psL.executeUpdate();
                    }

                    conn.commit();
                    isSuccess = true;
                    statusText = "Thanh toán thành công";
                    message = "Cảm ơn bạn đã sử dụng dịch vụ của OmniStay. Phòng của bạn đã được xác nhận!";

                    // 4. LẤY THÔNG TIN HIỂN THỊ UI VÀ GỬI ZALO/EMAIL
                    String sqlDetail = "SELECT b.booking_code, b.total_amount, b.check_in_date, b.check_out_date, b.customer_full_name, b.customer_phone, b.customer_email, r.room_number " +
                                     "FROM bookings b " +
                                     "JOIN booking_rooms br ON b.id = br.booking_id " +
                                     "JOIN rooms r ON br.room_id = r.id " +
                                     "WHERE b.id = ?";
                    PreparedStatement psD = conn.prepareStatement(sqlDetail);
                    psD.setInt(1, bookingId);
                    ResultSet rsD = psD.executeQuery();
                    if(rsD.next()) {
                        uiGuestName = rsD.getString("customer_full_name");
                        uiGuestPhone = rsD.getString("customer_phone");
                        uiGuestEmail = rsD.getString("customer_email");
                        uiRoomNumber = rsD.getString("room_number");
                        uiAmount = rsD.getDouble("total_amount");
                        String checkIn = rsD.getString("check_in_date");
                        String checkOut = rsD.getString("check_out_date");

                        // Gửi Zalo
                        try {
                            String zaloMsg = "🏨 THÔNG BÁO: CÓ ĐƠN ĐẶT PHÒNG MỚI!\n"
                                    + "Hệ thống vừa ghi nhận một giao dịch thành công qua VNPAY.\n\n"
                                    + "📍 Chi tiết đơn hàng:\n"
                                    + "- Mã đơn: " + vnp_TxnRef + "\n"
                                    + "- Khách hàng: " + uiGuestName + "\n"
                                    + "- SĐT: " + uiGuestPhone + "\n"
                                    + "- Phòng: " + uiRoomNumber + "\n"
                                    + "- Tổng tiền: " + String.format("%,.0f", uiAmount) + " VND\n"
                                    + "- Trạng thái: Đã thanh toán trực tuyến";
                            
                            zaloMsg = zaloMsg.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
                            String jsonPayload = "{\"chat_id\": \"" + SECRET_ZALO_CHATID + "\", \"text\": \"" + zaloMsg + "\"}";
                            String apiUrl = "https://bot-api.zaloplatforms.com/bot" + SECRET_ZALO_TOKEN + "/sendMessage";
                            
                            java.net.URL url = new java.net.URL(apiUrl);
                            java.net.HttpURLConnection httpConn = (java.net.HttpURLConnection) url.openConnection();
                            httpConn.setRequestMethod("POST");
                            httpConn.setRequestProperty("Content-Type", "application/json");
                            httpConn.setDoOutput(true);
                            try (java.io.OutputStream os = httpConn.getOutputStream()) {
                                os.write(jsonPayload.getBytes("utf-8"));
                            }
                            httpConn.getResponseCode();
                        } catch (Exception zEx) {
                            System.out.println("Lỗi gửi Zalo: " + zEx.getMessage());
                        }

                        // ─── GỬI EMAIL HÓA ĐƠN ───
                        try {
                            if (uiGuestEmail != null && uiGuestEmail.contains("@")) {
                                Properties props = new Properties();
                                props.put("mail.smtp.auth", "true");
                                props.put("mail.smtp.starttls.enable", "true");
                                props.put("mail.smtp.host", SECRET_MAIL_HOST);
                                props.put("mail.smtp.port", SECRET_MAIL_PORT);
                                props.put("mail.smtp.ssl.trust", SECRET_MAIL_HOST);

                                Session mailSession = Session.getInstance(props, new jakarta.mail.Authenticator() {
                                    protected PasswordAuthentication getPasswordAuthentication() {
                                        return new PasswordAuthentication(SECRET_MAIL_USER, SECRET_MAIL_PASS);
                                    }
                                });

                                Message mailMessage = new MimeMessage(mailSession);
                                mailMessage.setFrom(new InternetAddress(SECRET_MAIL_USER, "OmniStay Luxury Hotel"));
                                mailMessage.setRecipients(Message.RecipientType.TO, InternetAddress.parse(uiGuestEmail));
                                mailMessage.setSubject("[OmniStay] Xác nhận đặt phòng thành công - " + vnp_TxnRef);

                                NumberFormat mailNf = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
                                String mailAmount = mailNf.format(uiAmount);

                                String htmlContent = 
                                    "<div style=\"font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7f6; padding: 50px 20px; color: #333;\">" +
                                    "  <div style=\"max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 20px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.05); border: 1px solid #eef2f1;\">" +
                                    "    <div style=\"background-color: #1a6b5a; padding: 40px; text-align: center; color: #ffffff;\">" +
                                    "      <h1 style=\"margin: 0; font-size: 32px; letter-spacing: 2px;\">OmniStay</h1>" +
                                    "      <p style=\"margin: 10px 0 0; opacity: 0.7; font-size: 12px; text-transform: uppercase; letter-spacing: 3px;\">Luxury Hotel & Resort</p>" +
                                    "    </div>" +
                                    "    <div style=\"padding: 45px;\">" +
                                    "      <h2 style=\"color: #1a6b5a; margin-top: 0; font-weight: 600;\">Xác nhận đặt phòng</h2>" +
                                    "      <p style=\"font-size: 16px; line-height: 1.6;\">Chào <strong>" + uiGuestName + "</strong>,</p>" +
                                    "      <p style=\"font-size: 15px; line-height: 1.6; color: #666;\">Cảm ơn bạn đã lựa chọn OmniStay cho kỳ nghỉ của mình. Chúng tôi xin xác nhận đơn đặt phòng của bạn đã được thanh toán thành công qua cổng VNPAY.</p>" +
                                    "      <div style=\"background-color: #f9fbfb; border-radius: 15px; padding: 30px; margin: 35px 0; border: 1px solid #f0f4f3;\">" +
                                    "        <h3 style=\"margin-top: 0; font-size: 14px; text-transform: uppercase; color: #1a6b5a; border-bottom: 1px solid #e8eeec; padding-bottom: 12px; margin-bottom: 20px; letter-spacing: 1px;\">Chi tiết giao dịch</h3>" +
                                    "        <table style=\"width: 100%; border-collapse: collapse; font-size: 15px;\">" +
                                    "          <tr><td style=\"padding: 10px 0; color: #888;\">Mã đặt phòng:</td><td style=\"padding: 10px 0; text-align: right; font-weight: 700; color: #1a6b5a;\">" + vnp_TxnRef + "</td></tr>" +
                                    "          <tr><td style=\"padding: 10px 0; color: #888;\">Hạng phòng:</td><td style=\"padding: 10px 0; text-align: right; font-weight: 500;\">" + uiRoomNumber + "</td></tr>" +
                                    "          <tr><td style=\"padding: 10px 0; color: #888;\">Ngày nhận phòng:</td><td style=\"padding: 10px 0; text-align: right; font-weight: 500;\">" + checkIn + "</td></tr>" +
                                    "          <tr><td style=\"padding: 10px 0; color: #888;\">Ngày trả phòng:</td><td style=\"padding: 10px 0; text-align: right; font-weight: 500;\">" + checkOut + "</td></tr>" +
                                    "          <tr><td style=\"padding: 25px 0 10px; border-top: 1px solid #e8eeec; font-weight: 600;\">Tổng cộng đã thanh toán:</td><td style=\"padding: 25px 0 10px; border-top: 1px solid #e8eeec; text-align: right; font-size: 22px; font-weight: 800; color: #d4a847;\">" + mailAmount + "</td></tr>" +
                                    "        </table>" +
                                    "      </div>" +
                                    "      <p style=\"font-size: 14px; color: #999; text-align: center; font-style: italic; margin-top: 30px;\">Vui lòng xuất trình email này khi làm thủ tục nhận phòng.</p>" +
                                    "    </div>" +
                                    "    <div style=\"background-color: #fafafa; padding: 35px; text-align: center; border-top: 1px solid #f0f0f0; font-size: 13px; color: #aaa;\">" +
                                    "      <p style=\"margin: 0 0 10px; color: #1a6b5a; font-weight: 600;\">OmniStay Luxury Hotel & Resort</p>" +
                                    "      <p style=\"margin: 5px 0;\">123 Luxury Road, Da Nang, Vietnam</p>" +
                                    "      <p style=\"margin: 5px 0;\">Hotline: 1900 1234 | Email: support@omnistay.vn</p>" +
                                    "    </div>" +
                                    "  </div>" +
                                    "</div>";

                                mailMessage.setContent(htmlContent, "text/html; charset=UTF-8");
                                Transport.send(mailMessage);
                            }
                        } catch (Exception mEx) {
                            System.out.println("Lỗi gửi Email: " + mEx.getMessage());
                        }
                    }
                } else {
                    message = "Lỗi: Không tìm thấy mã đơn hàng trong hệ thống.";
                }
                conn.close();
            } catch (Exception e) {
                if(conn != null) conn.rollback();
                message = "Lỗi hệ thống: " + e.getMessage();
            }
        } else {
            message = "Giao dịch không thành công (Mã lỗi: " + request.getParameter("vnp_ResponseCode") + ")";
        }
    } else {
        message = "Lỗi bảo mật: Chữ ký không hợp lệ.";
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= statusText %> — OmniStay Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;1,400&family=Outfit:wght@300;400;500;600&display=swap" rel="stylesheet" />
    <style>
        :root {
            --primary: #1a6b5a;
            --primary-dark: #134f43;
            --accent: #d4a847;
            --light-bg: #f8f6f2;
            --border: #e8e2d9;
            --success: #1a6b5a;
            --danger: #c84343;
        }
        body {
            font-family: "Outfit", sans-serif;
            background: var(--light-bg);
            color: #2c2c2c;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        .font-display { font-family: "Playfair Display", serif; }

        /* ── HERO HEADER ── */
        .page-header {
            background: linear-gradient(
                160deg,
                rgba(10, 40, 33, 0.92) 0%,
                rgba(20, 85, 70, 0.85) 50%,
                rgba(30, 110, 90, 0.75) 100%
            ), url('https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=1600&q=80') center/cover no-repeat;
            padding: 8rem 0 4rem;
            text-align: center;
            border-bottom: 5px solid var(--accent);
        }

        /* ── RESULT CARD ── */
        .result-container {
            margin-top: -3rem;
            margin-bottom: 5rem;
            position: relative;
            z-index: 10;
        }
        .result-card {
            background: #fff;
            border-radius: 24px;
            overflow: hidden;
            box-shadow: 0 20px 60px rgba(0,0,0,0.1);
            border: 1px solid rgba(255,255,255,0.6);
            max-width: 700px;
            margin: 0 auto;
        }
        .status-icon {
            font-size: 4rem;
            margin-bottom: 1rem;
            display: inline-block;
            animation: scaleUp 0.6s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }
        @keyframes scaleUp {
            from { transform: scale(0); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }
        
        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 1rem 1.5rem;
            border-bottom: 1px solid var(--border);
        }
        .detail-row:last-child { border-bottom: none; }
        .detail-label { color: #777; font-weight: 400; font-size: 0.9rem; }
        .detail-value { font-weight: 500; color: #111; }

        .btn-omni {
            background: var(--primary);
            color: #white;
            border-radius: 12px;
            padding: 0.8rem 2rem;
            font-weight: 500;
            transition: all 0.3s;
            border: none;
            color: white;
        }
        .btn-omni:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(26, 107, 90, 0.25);
            color: white;
        }
        .btn-outline-omni {
            border: 1.5px solid var(--primary);
            color: var(--primary);
            border-radius: 12px;
            padding: 0.8rem 2rem;
            font-weight: 500;
            transition: all 0.3s;
            background: transparent;
        }
        .btn-outline-omni:hover {
            background: var(--primary);
            color: white;
        }

        .success-accent { color: var(--success); }
        .danger-accent { color: var(--danger); }
    </style>
</head>
<body>
    <%@ include file="../layouts/navbar.jsp" %>

    <section class="page-header">
        <div class="container">
            <h1 class="font-display text-white mb-2" style="font-size: clamp(2rem, 5vw, 3rem)">
                Kết quả <em style="color: var(--accent)">Thanh toán</em>
            </h1>
            <p class="text-white-50 small text-uppercase tracking-widest" style="letter-spacing: 3px">
                OmniStay Luxury Hotel & Resort
            </p>
        </div>
    </section>

    <div class="container result-container">
        <div class="result-card">
            <div class="p-5 text-center">
                <% if(isSuccess) { %>
                    <div class="status-icon success-accent">
                        <i class="bi bi-check-circle-fill"></i>
                    </div>
                    <h2 class="font-display mb-3">Thanh toán Thành công!</h2>
                    <p class="text-muted mb-4 px-lg-5"><%= message %></p>
                <% } else { %>
                    <div class="status-icon danger-accent">
                        <i class="bi bi-x-circle-fill"></i>
                    </div>
                    <h2 class="font-display mb-3">Thanh toán Thất bại</h2>
                    <p class="text-muted mb-4 px-lg-5"><%= message %></p>
                <% } %>
                
                <div class="bg-light rounded-4 p-2 mb-4 text-start">
                    <div class="detail-row">
                        <span class="detail-label">Mã giao dịch VNPAY</span>
                        <span class="detail-value"><%= (vnp_TransactionNo != null) ? vnp_TransactionNo : "N/A" %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Mã đơn hàng (Booking)</span>
                        <span class="detail-value text-uppercase fw-bold"><%= vnp_TxnRef %></span>
                    </div>
                    <% if(isSuccess) { %>
                    <div class="detail-row">
                        <span class="detail-label">Khách hàng</span>
                        <span class="detail-value"><%= uiGuestName %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Phòng</span>
                        <span class="detail-value">Phòng <%= uiRoomNumber %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Tổng số tiền</span>
                        <span class="detail-value text-success fw-bold" style="font-size: 1.1rem">
                            <%= String.format("%,.0f", uiAmount) %> ₫
                        </span>
                    </div>
                    <% } %>
                </div>

                <div class="d-flex flex-column flex-sm-row gap-3 justify-content-center mt-4">
                    <% if(isSuccess) { %>
                        <a href="invoice-detail.jsp?code=<%= vnp_TxnRef %>&phone=<%= uiGuestPhone %>" class="btn btn-omni">
                            <i class="bi bi-receipt me-2"></i> Xem hóa đơn
                        </a>
                        <a href="../index.jsp" class="btn btn-outline-omni">
                            <i class="bi bi-house-door me-2"></i> Trang chủ
                        </a>
                    <% } else { %>
                        <a href="../index.jsp" class="btn btn-omni">
                            <i class="bi bi-house-door me-2"></i> Quay về Trang chủ
                        </a>
                        <a href="rooms.jsp" class="btn btn-outline-omni">
                            <i class="bi bi-arrow-left me-2"></i> Thử lại
                        </a>
                    <% } %>
                </div>
            </div>
            
            <div class="bg-light p-4 text-center border-top" style="border-color: var(--border) !important;">
                <p class="small text-muted mb-0">
                    Bạn cần hỗ trợ? Liên hệ Hotline: <span class="fw-bold text-dark">1900 1234</span> hoặc 
                    <a href="contact.jsp" class="text-decoration-none" style="color: var(--primary)">Trang Liên hệ</a>
                </p>
            </div>
        </div>
    </div>

    <div style="margin-top: auto;">
        <%@ include file="../layouts/chatbot.jsp" %>
        <%@ include file="../layouts/footer.jsp" %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

