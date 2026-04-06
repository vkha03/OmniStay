<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.NumberFormat" %>
<%
    // =====================================================================
    // KHU VỰC BACKEND: Hứng ID Phòng (Mới làm mộc, Khang tự code thêm SQL sau)
    // =====================================================================
    String roomId = request.getParameter("room_id");
    
    // (Dữ liệu giả lập - Tưởng tượng bạn đã dùng SQL SELECT * FROM rooms WHERE room_number = roomId)
    String roomType = "";
    double price = 0;
    Connection conn = null;
    String dbError = null;
    try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/omnistay", "root", "");
    }catch(Exception e){
        dbError = e.getMessage();
    }
    NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    
    String SQL = "SELECT rt.type_name, rt.base_price " +
           		 "FROM rooms rs JOIN room_types rt ON rs.room_type_id = rt.id " +
           		 "WHERE rs.room_number = ?";
    PreparedStatement ps = conn.prepareStatement(SQL);
    ps.setString(1,roomId);
    ResultSet rs = ps.executeQuery();
    
    if(rs.next()){
    	roomType = rs.getString("type_name");
    	price = rs.getDouble("base_price");
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Hoàn tất đặt phòng — OmniStay</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;1,400&family=Outfit:wght@300;400;500;600&display=swap" rel="stylesheet" />
    <style>
        :root {
            --primary: #1a6b5a;
            --primary-dark: #134f43;
            --accent: #d4a847;
            --light-bg: #f8f6f2;
            --border: #e8e2d9;
        }
        body { font-family: "Outfit", sans-serif; font-weight: 300; color: #2c2c2c; background: var(--light-bg); }
        .font-display { font-family: "Playfair Display", serif; }

        /* HEADER NHỎ GỌN */
        .page-header {
            background: var(--primary-dark);
            padding: 8rem 0 3rem;
            border-bottom: 5px solid var(--accent);
        }

        /* CARD CHỨA FORM */
        .booking-card {
            background: #fff;
            border-radius: 20px;
            border: 1px solid var(--border);
            box-shadow: 0 10px 30px rgba(0,0,0,0.03);
            padding: 2rem;
        }

        /* Ô NHẬP LIỆU (INPUT) ĐẸP MẮT */
        .form-control, .form-select {
            border: 1px solid var(--border);
            padding: 0.8rem 1.2rem;
            border-radius: 10px;
            box-shadow: none !important;
            transition: 0.3s;
        }
        .form-control:focus, .form-select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(26, 107, 90, 0.1) !important;
        }
        .form-label { font-weight: 500; color: var(--text-main); margin-bottom: 0.5rem; font-size: 0.95rem; }

        /* HÓA ĐƠN BÊN PHẢI (STICKY) */
        .bill-card {
            background: #fff;
            border-radius: 20px;
            border: 1px solid var(--border);
            padding: 2rem;
            position: sticky;
            top: 100px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.05);
        }
        .bill-divider { border-bottom: 2px dashed var(--border); margin: 1.5rem 0; }

        .btn-submit { background: var(--accent); color: #fff; border-radius: 10px; font-weight: 600; padding: 1rem; transition: 0.3s; font-size: 1.1rem; }
        .btn-submit:hover { background: #c2983b; color: #fff; transform: translateY(-3px); box-shadow: 0 8px 20px rgba(212,168,71,0.4); }
    </style>
</head>
<body>
    <%@ include file="../layouts/navbar.jsp" %>

    <header class="page-header text-center">
        <div class="container">
            <h1 class="font-display text-white mb-2">Hoàn tất đặt phòng</h1>
            <p class="text-white-50 mb-0">Chỉ còn một bước nữa để tận hưởng kỳ nghỉ của bạn</p>
        </div>
    </header>

    <section class="py-5 mb-5">
        <div class="container">
            <a href="javascript:history.back()" class="text-decoration-none text-muted mb-4 d-inline-block">
                <i class="bi bi-arrow-left me-2"></i> Quay lại chọn phòng
            </a>

            <form action="process-booking.jsp" method="POST" class="row g-5">
                
                <div class="col-lg-8">
                    
                    <div class="booking-card mb-4">
                        <h4 class="font-display mb-4" style="color: var(--primary);"><i class="bi bi-calendar-check me-2"></i>Thông tin lưu trú</h4>
                        <div class="row g-4">
                            <div class="col-md-6">
                                <label class="form-label">Ngày nhận phòng (Check-in)</label>
                                <input type="date" name="checkIn" class="form-control" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Ngày trả phòng (Check-out)</label>
                                <input type="date" name="checkOut" class="form-control" required>
                            </div>
                        </div>
                    </div>

                    <div class="booking-card">
                        <h4 class="font-display mb-4" style="color: var(--primary);"><i class="bi bi-person-lines-fill me-2"></i>Thông tin khách hàng</h4>
                        <div class="row g-4">
                            <div class="col-md-12">
                                <label class="form-label">Họ và tên người đặt</label>
                                <input type="text" name="fullName" class="form-control" placeholder="Nhập đầy đủ họ tên..." required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Số điện thoại</label>
                                <input type="tel" name="phone" class="form-control" placeholder="09xx xxx xxx" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Email</label>
                                <input type="email" name="email" class="form-control" placeholder="Nhập email...." required>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Yêu cầu đặc biệt (Không bắt buộc)</label>
                                <textarea name="note" class="form-control" rows="3" placeholder="Ví dụ: Cần thêm giường phụ, phòng không hút thuốc..."></textarea>
                            </div>
                        </div>
                    </div>

                </div>

                <div class="col-lg-4">
                    <div class="bill-card">
                        <h4 class="font-display mb-4" style="color: var(--primary);">Chi tiết đặt phòng</h4>
                        
                        <div class="d-flex align-items-center gap-3 mb-4 p-3 rounded-3" style="background: rgba(26, 107, 90, 0.05);">
                            <div class="bg-white rounded-circle d-flex align-items-center justify-content-center shadow-sm" style="width: 50px; height: 50px;">
                                <i class="bi bi-key-fill fs-4" style="color: var(--accent);"></i>
                            </div>
                            <div>
                                <div class="text-muted small">Phòng bạn chọn</div>
                                <h4 class="font-display mb-0" style="color: var(--primary);"><%= roomId != null ? roomId : "Chưa chọn" %></h4>
                            </div>
                        </div>

                        <div class="d-flex justify-content-between mb-2">
                            <span class="text-muted">Hạng phòng</span>
                            <span class="fw-500"><%= roomType %></span>
                        </div>
                        <div class="d-flex justify-content-between mb-2">
                            <span class="text-muted">Giá mỗi đêm</span>
                            <span class="fw-500"><%= nf.format(price).replace("VNĐ", "₫") %>
                        </div>
                        
                        <div class="bill-divider"></div>

                        <div class="alert alert-warning border-0 small py-2 d-flex align-items-start gap-2" style="background: rgba(212, 168, 71, 0.1); color: #9c7823;">
                            <i class="bi bi-info-circle mt-1"></i>
                            <div>Tổng tiền chính xác sẽ được tính tại quầy lễ tân dựa trên số ngày lưu trú thực tế của quý khách.</div>
                        </div>

                        <input type="hidden" name="roomId" value="<%= roomId %>">
                        <button type="submit" class="btn btn-submit w-100 mt-3 d-flex justify-content-between align-items-center">
                            <span>Xác nhận đặt phòng</span>
                            <i class="bi bi-arrow-right-circle fs-5"></i>
                        </button>
                        
                        <div class="text-center mt-3 text-muted" style="font-size: 0.8rem;">
                            <i class="bi bi-shield-check text-success me-1"></i> Thông tin của bạn được bảo mật tuyệt đối
                        </div>
                    </div>
                </div>

            </form>
        </div>
    </section>

    <%@ include file="../layouts/chatbot.jsp" %>
    <%@ include file="../layouts/footer.jsp" %>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>