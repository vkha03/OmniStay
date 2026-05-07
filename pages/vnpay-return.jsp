<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
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

                    // 3.2 Cập nhật trạng thái đơn hàng sang CONFIRMED
                    String sqlUp = "UPDATE bookings SET status = 'CONFIRMED' WHERE id = ?";
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

                    // 4. LẤY THÔNG TIN HIỂN THỊ UI VÀ GỬI ZALO
                    String sqlDetail = "SELECT b.booking_code, b.total_amount, g.full_name, g.phone_number, r.room_number " +
                                     "FROM bookings b " +
                                     "JOIN guests g ON b.guest_id = g.id " +
                                     "JOIN booking_rooms br ON b.id = br.booking_id " +
                                     "JOIN rooms r ON br.room_id = r.id " +
                                     "WHERE b.id = ?";
                    PreparedStatement psD = conn.prepareStatement(sqlDetail);
                    psD.setInt(1, bookingId);
                    ResultSet rsD = psD.executeQuery();
                    if(rsD.next()) {
                        uiGuestName = rsD.getString("full_name");
                        uiGuestPhone = rsD.getString("phone_number");
                        uiRoomNumber = rsD.getString("room_number");
                        uiAmount = rsD.getDouble("total_amount");

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
                    <a href="../index.jsp" class="btn btn-omni">
                        <i class="bi bi-house-door me-2"></i> Quay về Trang chủ
                    </a>
                    <% if(!isSuccess) { %>
                    <a href="rooms.jsp" class="btn btn-outline-omni">
                        <i class="bi bi-arrow-repeat me-2"></i> Thử lại
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

