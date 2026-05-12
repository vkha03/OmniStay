<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.NumberFormat" %>
<%@ include file="../env-secrets.jsp" %>
<%-- ==========================================================================
     TRANG NHẬP THÔNG TIN ĐẶT PHÒNG (BOOKING FORM PAGE)
     Thu thập thông tin khách hàng (Họ tên, Liên hệ, Thời gian lưu trú).
     Hiển thị tóm tắt đơn giá phòng và chuẩn bị tải trọng (payload) để chuyển
     sang cổng thanh toán trực tuyến (VNPAY) ở bước tiếp theo.
     ========================================================================== --%>
<%
    // 1. NHẬN THAM SỐ PHÒNG TỪ BƯỚC TRƯỚC (EXTRACT TARGET ROOM ID)
    // Lấy mã số phòng cụ thể mà khách hàng đã chọn (Query parameter: room_id)
    String roomId = request.getParameter("room_id");
    String roomType = "";
    double price = 0;
    // Đặt hình nền mặc định sang trọng cho phần Header trang đặt phòng
    String imgURL = request.getContextPath() + "/images/hero/hotel-pool-hero.jpg"; 

    // 2. TRUY VẤN CHI TIẾT ĐƠN GIÁ VÀ HÌNH ẢNH (QUERY ROOM PRICING DETAILS)
    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(SECRET_DB_URL, SECRET_DB_USER, SECRET_DB_PASS);
        
        // Thực hiện phép JOIN giữa bảng `rooms` và `room_types` để lấy Tên loại phòng, Giá cơ bản và Ảnh
        String SQL = "SELECT rt.type_name, rt.base_price, rt.image_url " +
                     "FROM rooms rs JOIN room_types rt ON rs.room_type_id = rt.id " +
                     "WHERE rs.room_number = ?";
        PreparedStatement ps = conn.prepareStatement(SQL);
        ps.setString(1, roomId);
        ResultSet rs = ps.executeQuery();
        
        if(rs.next()){
            roomType = rs.getString("type_name");
            price = rs.getDouble("base_price");
            // Ghi đè hình nền mặc định nếu hạng phòng này có hình ảnh minh họa riêng
            String dbImg = rs.getString("image_url");
            if(dbImg != null && !dbImg.isEmpty()) imgURL = dbImg;
        }
        // Giải phóng tài nguyên ngay khi hoàn tất thao tác đọc
        rs.close(); ps.close();
        conn.close();
    } catch(Exception e) {
        // In log chi tiết ra console server nếu xảy ra lỗi để hỗ trợ gỡ lỗi ngầm
        e.printStackTrace();
    }
    
    // Bộ định dạng tiền tệ chuẩn cho thị trường Việt Nam
    NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Hoàn tất đặt phòng — OmniStay</title>
    <link rel="icon" type="image/png" href="<%=request.getContextPath()%>/images/logo.png">
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
            --text-main: #2c2c2c;
        }
        body { font-family: "Outfit", sans-serif; font-weight: 300; color: var(--text-main); background: var(--light-bg); overflow-x: hidden; }
        .font-display { font-family: "Playfair Display", serif; }

        /* HEADER BANNER */
        .page-header {
            background: linear-gradient(rgba(10, 40, 33, 0.75), rgba(10, 40, 33, 0.9)), url('<%= imgURL %>') center/cover no-repeat;
            padding: 10rem 0 5rem;
            border-bottom: 5px solid var(--accent);
            background-attachment: fixed;
        }

        /* CARD STYLING */
        .booking-card {
            background: #fff;
            border-radius: 24px;
            border: 1px solid var(--border);
            box-shadow: 0 10px 35px rgba(0,0,0,0.03);
            padding: 2.5rem;
            margin-bottom: 2rem;
            transition: 0.3s;
        }
        .booking-card:hover { transform: translateY(-5px); box-shadow: 0 15px 45px rgba(0,0,0,0.06); }
        .card-title { color: var(--primary); font-size: 1.4rem; font-weight: 600; margin-bottom: 2rem; border-bottom: 1px solid #f0f0f0; padding-bottom: 1rem; }

        /* FORM INPUTS */
        .form-label { font-weight: 500; color: #555; font-size: 0.9rem; margin-bottom: 0.5rem; }
        .form-control, .form-select {
            border: 1px solid var(--border);
            padding: 0.85rem 1.2rem;
            border-radius: 12px;
            font-weight: 400;
            transition: 0.3s;
            background-color: #fafafa;
        }
        .form-control:focus { border-color: var(--primary); box-shadow: 0 0 0 4px rgba(26, 107, 90, 0.1); background-color: #fff; }

        /* RIGHT STICKY SUMMARY */
        .summary-card {
            background: #fff;
            border-radius: 24px;
            border: 1px solid var(--border);
            padding: 2rem;
            position: sticky;
            top: 100px;
            box-shadow: 0 20px 50px rgba(0,0,0,0.08);
        }
        .room-tag {
            background: rgba(212, 168, 71, 0.1);
            color: var(--accent);
            padding: 0.5rem 1rem;
            border-radius: 50px;
            font-weight: 600;
            font-size: 0.8rem;
            display: inline-block;
            margin-bottom: 1rem;
        }

        /* PAYMENT BOX */
        .vnpay-notice-box {
            background: linear-gradient(135deg, #1a6b5a, #134f43);
            color: white;
            border-radius: 20px;
            padding: 2.5rem;
            margin-bottom: 2rem;
            position: relative;
            overflow: hidden;
        }
        .vnpay-logo-container {
            background: #fff;
            padding: 8px 15px;
            border-radius: 12px;
            display: inline-block;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        .vnpay-logo { height: 35px; width: auto; object-fit: contain; }

        /* BUTTON SUBMIT */
        .btn-confirm {
            background: var(--primary);
            color: white;
            border-radius: 15px;
            padding: 1.1rem 2rem;
            font-weight: 600;
            border: none;
            width: 100%;
            transition: 0.4s;
            font-size: 1.1rem;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .btn-confirm:hover { background: var(--primary-dark); transform: scale(1.02); box-shadow: 0 10px 25px rgba(26,107,90,0.3); }

        .divider { border-top: 1px dashed var(--border); margin: 1.5rem 0; }
    </style>
</head>
<body>
    <%@ include file="../layouts/navbar.jsp" %>

    <header class="page-header text-center">
        <div class="container">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb justify-content-center mb-3 small text-uppercase" style="letter-spacing: 2px;">
                    <li class="breadcrumb-item"><a href="rooms.jsp" class="text-white-50 text-decoration-none">Phòng nghỉ</a></li>
                    <li class="breadcrumb-item active" style="color: var(--accent);">Hoàn tất đặt phòng</li>
                </ol>
            </nav>
            <h1 class="font-display text-white mb-2" style="font-size: 3.5rem;">Hoàn tất <em style="color: var(--accent);">Đặt phòng</em></h1>
            <p class="text-white-50 mb-0">Quý khách vui lòng cung cấp thông tin để chúng tôi phục vụ chu đáo nhất</p>
        </div>
    </header>

    <main class="container py-5 mb-5">
        <form action="process-booking.jsp" method="POST" class="row g-5">
            
            <!-- CỘT TRÁI: FORM NHẬP -->
            <div class="col-lg-8">
                
                <!-- Section 1: Thông báo VNPAY -->
                <div class="vnpay-notice-box">
                    <div class="vnpay-logo-container mb-3">
                        <img src="https://cdn.haitrieu.com/wp-content/uploads/2022/10/Logo-VNPAY-QR.png" 
                             alt="VNPAY" 
                             class="vnpay-logo" 
                             onerror="this.style.display='none'; document.getElementById('vnpay-text-fallback').style.display='block';">
                        <div id="vnpay-text-fallback" style="display:none; font-weight: 800; font-size: 1.5rem; letter-spacing: -1px;">
                            <span style="color: #005baa;">VN</span><span style="color: #ed1c24;">PAY</span>
                        </div>
                    </div>
                    <h4 class="font-display mb-2 text-white">Thanh toán Trực tuyến An toàn</h4>
                    <p class="opacity-75 small mb-0">
                        Hệ thống OmniStay yêu cầu thanh toán qua VNPAY để đảm bảo giữ chỗ 100%. 
                        Giao dịch của bạn được bảo mật bởi tiêu chuẩn quốc tế. 
                        Phòng sẽ được xác nhận ngay sau khi hoàn tất.
                    </p>
                    <input type="hidden" name="paymentMethod" value="VNPAY">
                </div>

                <!-- Section 2: Thời gian -->
                <div class="booking-card">
                    <h4 class="font-display card-title"><i class="bi bi-calendar-check me-2"></i>Thời gian lưu trú</h4>
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

                <!-- Section 3: Khách hàng -->
                <div class="booking-card">
                    <h4 class="font-display card-title"><i class="bi bi-person-badge me-2"></i>Hồ sơ khách hàng</h4>
                    <div class="row g-4">
                        <div class="col-md-12">
                            <label class="form-label">Họ và tên người đặt</label>
                            <input type="text" name="fullName" class="form-control" placeholder="Ví dụ: Nguyễn Văn A" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Số điện thoại liên hệ</label>
                            <input type="tel" name="phone" class="form-control" placeholder="0xxx xxx xxx" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Địa chỉ Email</label>
                            <input type="email" name="email" class="form-control" placeholder="name@example.com" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Số CCCD / Hộ chiếu</label>
                            <input type="text" name="idCard" class="form-control" placeholder="Dùng để đối soát khi nhận phòng" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Ngày sinh</label>
                            <input type="date" name="birthDate" class="form-control" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Số người lớn</label>
                            <input type="number" name="adults" class="form-control" value="1" min="1" max="10">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Số trẻ em</label>
                            <input type="number" name="children" class="form-control" value="0" min="0" max="10">
                        </div>
                        <div class="col-12">
                            <label class="form-label">Yêu cầu đặc biệt</label>
                            <textarea name="note" class="form-control" rows="3" placeholder="Ví dụ: Phòng tầng cao, chuẩn bị hoa hồng, kỷ niệm ngày cưới..."></textarea>
                        </div>
                    </div>
                </div>

            </div>

            <!-- CỘT PHẢI: SUMMARY -->
            <div class="col-lg-4">
                <div class="summary-card">
                    <div class="room-tag text-uppercase">Phòng đang đặt</div>
                    <h3 class="font-display mb-1" style="color: var(--primary);">Phòng <%= roomId %></h3>
                    <p class="text-muted small mb-4"><%= roomType %></p>
                    
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-muted small">Giá cơ bản / đêm</span>
                        <span class="fw-500"><%= nf.format(price).replace("VNĐ", "₫") %></span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-muted small">Dịch vụ đi kèm</span>
                        <span class="text-success fw-500">Tiêu chuẩn 5 sao</span>
                    </div>
                    <div class="d-flex justify-content-between mb-0">
                        <span class="text-muted small">VAT & Phí phục vụ</span>
                        <span class="fw-500">Đã bao gồm</span>
                    </div>

                    <div class="divider"></div>
                    
                    <div class="p-4 rounded-4 mb-4" style="background: rgba(26, 107, 90, 0.03); border: 1px solid rgba(26, 107, 90, 0.08);">
                        <div class="text-muted small text-uppercase mb-1" style="letter-spacing: 1px;">Dự kiến tổng cộng</div>
                        <h2 class="font-display mb-0" style="color: var(--primary);"><%= nf.format(price).replace("VNĐ", "₫") %></h2>
                        <div class="text-muted" style="font-size: 0.72rem; margin-top: 5px;">* Giá cuối sẽ dựa trên số đêm ở thực tế</div>
                    </div>

                    <input type="hidden" name="roomId" value="<%= roomId %>">
                    <button type="submit" class="btn btn-confirm">
                        Tiến hành Thanh toán <i class="bi bi-shield-lock-fill ms-2"></i>
                    </button>
                    
                    <div class="text-center mt-4">
                        <img src="https://img.icons8.com/color/48/verified-badge.png" alt="Verified" style="width: 18px;" class="me-1">
                        <span class="text-muted" style="font-size: 0.75rem;">An toàn - Bảo mật - Nhanh chóng</span>
                    </div>
                </div>
            </div>

        </form>
    </main>

    <%@ include file="../layouts/footer.jsp" %>
    <%@ include file="../layouts/chatbot.jsp" %>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // ====================================================================
        // XỬ LÝ LƯỢNG TƯƠNG TÁC GIAO DIỆN PHÍA CLIENT (CLIENT-SIDE LOGIC)
        // ====================================================================
        
        // Tự động thiết lập mốc thời gian mặc định ngay khi trang tải xong
        window.addEventListener('load', () => {
            const checkInInput = document.getElementsByName('checkIn')[0];
            const checkOutInput = document.getElementsByName('checkOut')[0];
            
            // Khởi tạo đối tượng Date đại diện cho Hôm nay (Check-in) và Ngày mai (Check-out)
            const now = new Date();
            const tomorrow = new Date();
            tomorrow.setDate(now.getDate() + 1);
            
            // Chuyển đổi sang định dạng chuỗi YYYY-MM-DD tương thích tuyệt đối với thẻ <input type="date">
            if(!checkInInput.value) checkInInput.value = now.toISOString().split('T')[0];
            if(!checkOutInput.value) checkOutInput.value = tomorrow.toISOString().split('T')[0];
            
            // Ràng buộc tính hợp lệ: Ngày trả phòng bắt buộc phải lớn hơn hoặc bằng Ngày nhận phòng
            // Lắng nghe sự kiện thay đổi ngày check-in để tự động dời giới hạn cực tiểu (min) của check-out
            checkInInput.addEventListener('change', () => {
                checkOutInput.min = checkInInput.value;
            });
        });
    </script>
</body>
</html>