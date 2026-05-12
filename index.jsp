<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.NumberFormat" %>
<%@ include file="env-secrets.jsp" %>
<%-- ==========================================================================
     TRANG CHỦ KHÁCH SẠN (MAIN LANDING PAGE)
     Trang đích đón tiếp người dùng. Chứa toàn bộ các khối quảng bá dịch vụ,
     danh mục phòng nổi bật, tích hợp thanh tìm kiếm và kiểm tra phòng trống.
     Các thao tác truy xuất dữ liệu được thực hiện trực tiếp qua JDBC.
     ========================================================================== --%>
<%! 
    // 1. KHAI BÁO CÁC BIẾN TOÀN CỤC CHO TRANG CHỦ
    // Trích xuất từ hằng số bảo mật trong env-secrets.jsp để nạp vào Chatbot sau này
    public static final String GEMINI_API_KEY = SECRET_GEMINI_KEY; 
    public static final String GEMINI_MODEL = SECRET_GEMINI_MODEL; 
%>
<%
    // 2. KHỞI TẠO KẾT NỐI CƠ SỞ DỮ LIỆU (DATABASE INITIALIZATION)
    // Khai báo đối tượng Connection và chuỗi lưu trữ thông báo lỗi nếu có
    Connection conn = null;
    String dbError = null;
    try {
        // Nạp Driver MySQL JDBC vào bộ nhớ
        Class.forName("com.mysql.cj.jdbc.Driver");
        // Thiết lập kết nối sử dụng các hằng số tĩnh định nghĩa trong env-secrets.jsp
        conn = DriverManager.getConnection(SECRET_DB_URL, SECRET_DB_USER, SECRET_DB_PASS);
    } catch(Exception e) {
        // Bắt lỗi và ghi nhận nguyên nhân (sai tài khoản, mất kết nối, v.v.)
        // để hiển thị cảnh báo thân thiện thay vì ném lỗi 500 ra trình duyệt
        dbError = e.getMessage() != null ? e.getMessage() : e.toString();
    }
%>
<!DOCTYPE html>
<html lang="vi">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>OmniStay — Luxury Hotel</title>
    <link rel="icon" type="image/png" href="<%=request.getContextPath()%>/images/logo.png">
    <link
      href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
      rel="stylesheet"
    />
    <link
      href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
      rel="stylesheet"
    />
    <link
      href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;1,400&family=Outfit:wght@300;400;500&display=swap"
      rel="stylesheet"
    />
    <style>
      :root {
        --primary: #1a6b5a;
        --primary-dark: #134f43;
        --accent: #d4a847;
        --light-bg: #f8f6f2;
        --border: #e8e2d9;
      }
      body {
        font-family: "Outfit", sans-serif;
        font-weight: 300;
        color: #2c2c2c;
        background: #fff;
        overflow-x: hidden;
      }
      .font-display {
        font-family: "Playfair Display", serif;
      }

      /* ── ANIMATIONS ── */
      @keyframes fadeInUp {
        from { opacity: 0; transform: translateY(40px); }
        to { opacity: 1; transform: translateY(0); }
      }
      @keyframes float {
        0%, 100% { transform: translateY(0); }
        50% { transform: translateY(-12px); }
      }
      @keyframes shimmer {
        0% { background-position: -200% center; }
        100% { background-position: 200% center; }
      }
      @keyframes pulseGlow {
        0%, 100% { box-shadow: 0 0 20px rgba(212, 168, 71, 0.3); }
        50% { box-shadow: 0 0 40px rgba(212, 168, 71, 0.6); }
      }
      .animate-fade-in {
        opacity: 0;
        transform: translateY(40px);
        transition: all 0.8s cubic-bezier(0.16, 1, 0.3, 1);
      }
      .animate-fade-in.visible {
        opacity: 1;
        transform: translateY(0);
      }

      #hero {
        min-height: 100vh;
        background: linear-gradient(
          160deg,
          rgba(10, 40, 33, 0.90) 0%,
          rgba(20, 85, 70, 0.78) 50%,
          rgba(30, 110, 90, 0.68) 100%
        ), url('<%=request.getContextPath()%>/images/hero/hotel-exterior.jpg') center/cover no-repeat;
        background-attachment: fixed;
        position: relative;
      }
      #hero::after {
        content: '';
        position: absolute;
        bottom: 0; left: 0; right: 0;
        height: 120px;
        background: linear-gradient(transparent, var(--light-bg));
        pointer-events: none;
      }
      /* ── Hero text enhancements ── */
      #hero h1 {
        text-shadow: 0 4px 20px rgba(0, 0, 0, 0.4), 0 1px 3px rgba(0, 0, 0, 0.3);
      }
      #hero p {
        text-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
      }
      #hero .text-white-50 {
        color: rgba(255, 255, 255, 0.85) !important;
        text-shadow: 0 1px 6px rgba(0, 0, 0, 0.3);
      }
      /* ── Hero buttons ── */
      .btn-hero-primary {
        background: var(--accent) !important;
        color: #111 !important;
        border: none;
        font-weight: 600;
        box-shadow: 0 8px 25px rgba(212, 168, 71, 0.35);
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      }
      .btn-hero-primary:hover {
        background: #f0c356 !important;
        transform: translateY(-3px) scale(1.02);
        box-shadow: 0 12px 35px rgba(212, 168, 71, 0.55);
        color: #111 !important;
      }
      .btn-hero-outline {
        border: 1.5px solid rgba(255, 255, 255, 0.45) !important;
        color: #fff !important;
        background: rgba(255, 255, 255, 0.1) !important;
        backdrop-filter: blur(8px);
        -webkit-backdrop-filter: blur(8px);
        font-weight: 500;
        transition: all 0.3s ease;
      }
      .btn-hero-outline:hover {
        background: rgba(255, 255, 255, 0.22) !important;
        border-color: rgba(255, 255, 255, 0.7) !important;
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(255, 255, 255, 0.1);
      }
      /* ── Hero stats bar ── */
      .hero-stats {
        background: rgba(255, 255, 255, 0.08);
        backdrop-filter: blur(12px);
        -webkit-backdrop-filter: blur(12px);
        border: 1px solid rgba(255, 255, 255, 0.12);
        border-radius: 16px;
        padding: 1.5rem 2rem;
      }
      .hero-stats .stat-number {
        font-size: 2rem;
        text-shadow: 0 2px 10px rgba(0, 0, 0, 0.25);
      }
      .hero-stats .stat-label {
        font-size: 0.7rem;
        letter-spacing: 0.1em;
        text-transform: uppercase;
        color: rgba(255, 255, 255, 0.7);
      }
      .hero-stats .stat-divider {
        width: 1px;
        background: rgba(255, 255, 255, 0.2);
        align-self: stretch;
      }
      /* ── Hero image card ── */
      .hero-img {
        height: 480px;
        object-fit: cover;
        border-radius: 16px;
        box-shadow: 0 32px 64px rgba(0, 0, 0, 0.35), 0 0 0 1px rgba(255, 255, 255, 0.1);
        border: 2px solid rgba(255, 255, 255, 0.15);
      }
      .badge-floating {
        position: absolute;
        bottom: -20px;
        left: 24px;
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(12px);
        -webkit-backdrop-filter: blur(12px);
        border-radius: 14px;
        padding: 16px 22px;
        box-shadow: 0 12px 40px rgba(0, 0, 0, 0.18);
        min-width: 210px;
        border: 1px solid rgba(255, 255, 255, 0.6);
      }

      /* ── BOOKING ── */
      .booking-wrap {
        border-radius: 20px;
        box-shadow: 0 24px 64px rgba(0, 0, 0, 0.12);
        overflow: hidden;
        margin-top: -56px;
        position: relative;
        z-index: 10;
      }
      .booking-header {
        background: linear-gradient(90deg, var(--primary-dark), var(--primary));
        padding: 1rem 2rem;
      }
      .booking-body {
        padding: 1.75rem 2rem;
      }
      .booking-field-label {
        font-size: 0.65rem;
        letter-spacing: 0.18em;
        text-transform: uppercase;
        color: var(--primary);
        font-weight: 600;
        display: block;
        margin-bottom: 0.4rem;
      }
      .booking-input {
        border: 1.5px solid var(--border) !important;
        border-radius: 10px !important;
        padding: 0.6rem 0.9rem !important;
        font-size: 0.88rem !important;
        font-family: "Outfit", sans-serif;
        font-weight: 300;
        transition: border-color 0.2s;
      }
      .booking-input:focus {
        border-color: var(--primary) !important;
        box-shadow: 0 0 0 3px rgba(26, 107, 90, 0.1) !important;
      }
      .btn-book-search {
        background: var(--primary);
        color: #fff;
        border: none;
        border-radius: 12px;
        padding: 0.7rem 1.5rem;
        font-size: 0.85rem;
        font-weight: 500;
        font-family: "Outfit", sans-serif;
        transition: all 0.25s;
        width: 100%;
      }
      .btn-book-search:hover {
        background: var(--primary-dark);
        box-shadow: 0 6px 18px rgba(26, 107, 90, 0.28);
        transform: translateY(-1px);
      }
      .promo-strip {
        background: rgba(212, 168, 71, 0.08);
        border-top: 1px dashed rgba(212, 168, 71, 0.35);
        padding: 0.65rem 2rem;
        font-size: 0.78rem;
        color: #a07820;
      }

      /* ── GENERAL ── */
      .section-tag {
        font-size: 0.7rem;
        letter-spacing: 0.2em;
        text-transform: uppercase;
        color: var(--accent);
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        gap: 8px;
      }
      .section-tag::before,
      .section-tag::after {
        content: '';
        width: 20px;
        height: 1px;
        background: var(--accent);
      }
      .divider {
        width: 50px;
        height: 3px;
        background: linear-gradient(90deg, var(--accent), var(--primary));
        border-radius: 3px;
      }
      .room-img {
        height: 220px;
        object-fit: cover;
      }
      .amenity-icon {
        width: 56px;
        height: 56px;
        border-radius: 14px;
        background: linear-gradient(135deg, rgba(26, 107, 90, 0.1), rgba(212, 168, 71, 0.08));
        color: var(--primary);
        font-size: 1.4rem;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
      }
      .amenity-card {
        transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        position: relative;
        overflow: hidden;
      }
      .amenity-card::before {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0;
        height: 3px;
        background: linear-gradient(90deg, var(--primary), var(--accent));
        transform: scaleX(0);
        transition: transform 0.4s ease;
        transform-origin: left;
      }
      .amenity-card:hover {
        transform: translateY(-8px);
        box-shadow: 0 20px 40px rgba(26, 107, 90, 0.12) !important;
      }
      .amenity-card:hover::before {
        transform: scaleX(1);
      }
      .amenity-card:hover .amenity-icon {
        background: var(--primary);
        color: #fff;
        transform: scale(1.1) rotate(-5deg);
      }
      .review-card {
        border-left: 3px solid var(--accent);
        transition: all 0.3s ease;
      }
      .review-card:hover {
        transform: translateY(-6px);
        box-shadow: 0 16px 40px rgba(0, 0, 0, 0.08) !important;
      }
      .star {
        color: var(--accent);
      }
      /* ── GALLERY ── */
      .gallery-item {
        position: relative;
        overflow: hidden;
        border-radius: 16px !important;
      }
      .gallery-item img {
        transition: transform 0.6s cubic-bezier(0.4, 0, 0.2, 1);
      }
      .gallery-item:hover img {
        transform: scale(1.08);
      }
      .gallery-item::after {
        content: '';
        position: absolute;
        inset: 0;
        background: linear-gradient(to top, rgba(26, 107, 90, 0.6), transparent 60%);
        opacity: 0;
        transition: opacity 0.4s ease;
        pointer-events: none;
      }
      .gallery-item:hover::after {
        opacity: 1;
      }

      /* ── OFFERS ── */
      .offer-img {
        height: 300px;
        object-fit: cover;
        transition: transform 0.6s ease;
      }
      .offer-card:hover .offer-img {
        transform: scale(1.04);
      }
      .offer-badge {
        position: absolute;
        top: 16px;
        left: 16px;
        background: var(--accent);
        color: #111;
        font-size: 0.65rem;
        font-weight: 600;
        letter-spacing: 0.12em;
        text-transform: uppercase;
        padding: 5px 12px;
        border-radius: 30px;
      }

      /* ── NEARBY ── */
      .nearby-icon {
        width: 42px;
        height: 42px;
        border-radius: 10px;
        background: rgba(26, 107, 90, 0.08);
        color: var(--primary);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1rem;
        flex-shrink: 0;
      }

      /* ── EXP DOT ── */
      .exp-dot {
        width: 44px;
        height: 44px;
        border-radius: 50%;
        background: rgba(212, 168, 71, 0.12);
        border: 1.5px solid rgba(212, 168, 71, 0.4);
        color: var(--accent);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1rem;
        flex-shrink: 0;
      }

      /* ── AWARD ── */
      .award-logo {
        opacity: 0.45;
        filter: grayscale(1);
        transition: all 0.3s;
        font-size: 0.75rem;
        font-weight: 500;
        letter-spacing: 0.1em;
        text-transform: uppercase;
        color: #555;
      }
      .award-logo:hover {
        opacity: 0.8;
        filter: grayscale(0);
      }

      /* ── FAQ ── */
      .accordion-button:not(.collapsed) {
        background: rgba(26, 107, 90, 0.06);
        color: var(--primary);
        box-shadow: none;
      }
      .accordion-button:focus {
        box-shadow: none;
      }
      .accordion-button {
        font-family: "Outfit", sans-serif;
        font-weight: 400;
        font-size: 0.92rem;
      }
    </style>
  </head>
  <body>
    <%@ include file="layouts/navbar.jsp" %>

    <!-- ═══ HERO ═══ -->
    <section id="hero" class="d-flex align-items-center">
      <div class="container py-5 mt-5">
        <div class="row align-items-center gy-5">
          <div class="col-lg-6">
            <p
              class="text-uppercase fw-500 mb-3"
              style="font-size: 0.75rem; letter-spacing: 0.2em; color: var(--accent);"
            >
              ✦ Khách sạn 5 sao · TP. Cần Thơ
            </p>
            <h1
              class="font-display fw-normal text-white mb-4"
              style="font-size: clamp(2.5rem, 5vw, 4rem); line-height: 1.1"
            >
              Trải nghiệm<br /><em style="color: var(--accent)">sang trọng</em
              ><br />đỉnh cao
            </h1>
            <p
              class="mb-5"
              style="font-size: 0.95rem; max-width: 420px; line-height: 1.8; color: rgba(255,255,255,0.85);"
            >
              OmniStay kiến tạo chuẩn mực sống thượng lưu bên dòng sông Hậu —
              nơi nghệ thuật hiện đại hòa quyện cùng ẩm thực tinh hoa và dịch vụ
              cá nhân hóa tuyệt đối.
            </p>
            <div class="d-flex gap-3 flex-wrap">
              <a
                href="<%=request.getContextPath()%>/pages/rooms.jsp"
                class="btn btn-lg px-5 py-3 rounded-pill btn-hero-primary"
                style="font-size: 0.85rem"
                >Xem phòng</a
              >
              <a
                href="<%=request.getContextPath()%>/pages/dichvu.jsp"
                class="btn btn-lg px-5 py-3 rounded-pill btn-hero-outline"
                style="font-size: 0.85rem;"
                >Khám phá</a
              >
            </div>
            <div class="hero-stats d-flex gap-4 mt-5">
              <%
                // 3. TRUY VẤN THỐNG KÊ HERO SECTION (HERO DYNAMIC STATS)
                // Khởi tạo các giá trị mặc định tĩnh đề phòng trường hợp CSDL chưa sẵn sàng
                int totalRooms = 128;
                double avgRating = 4.9;
                if(conn != null) {
                    try {
                        // Truy vấn 1: Đếm tổng số lượng phòng thực tế hiện có trong bảng `rooms`
                        PreparedStatement ps1 = conn.prepareStatement("SELECT COUNT(*) FROM rooms");
                        ResultSet rs1 = ps1.executeQuery();
                        if(rs1.next()) totalRooms = rs1.getInt(1);
                        rs1.close(); ps1.close(); // Đóng tài nguyên ngay sau khi lấy dữ liệu

                        // Truy vấn 2: Tính điểm số trung bình (AVG) của tất cả đánh giá hợp lệ (status = 1)
                        // Hàm ROUND(..., 1) làm tròn kết quả đến 1 chữ số thập phân
                        PreparedStatement ps2 = conn.prepareStatement("SELECT ROUND(AVG(rating), 1) FROM reviews WHERE status = 1");
                        ResultSet rs2 = ps2.executeQuery();
                        if(rs2.next() && rs2.getObject(1) != null) avgRating = rs2.getDouble(1);
                        rs2.close(); ps2.close();
                    } catch(Exception e) {
                        // Bỏ qua lỗi ngầm định để không gián đoạn việc hiển thị Hero section
                    }
                }
              %>
              <div>
                <div class="font-display text-white fw-normal stat-number"><%= totalRooms %></div>
                <div class="stat-label">Phòng nghỉ</div>
              </div>
              <div class="stat-divider"></div>
              <div>
                <div class="font-display text-white fw-normal stat-number">
                  <%= avgRating %><span style="font-size: 1rem; color: var(--accent)">★</span>
                </div>
                <div class="stat-label">Đánh giá</div>
              </div>
              <div class="stat-divider"></div>
              <div>
                <div class="font-display text-white fw-normal stat-number">15+</div>
                <div class="stat-label">Năm kinh nghiệm</div>
              </div>
            </div>
          </div>
          <div class="col-lg-6 text-center position-relative pb-4">
            <img
              src="<%=request.getContextPath()%>/images/rooms/room-suite.jpg"
              alt="Presidential Suite"
              class="hero-img w-100"
            />
            <div class="badge-floating">
              <div
                class="text-uppercase fw-500 mb-1"
                style="
                  font-size: 0.6rem;
                  letter-spacing: 0.15em;
                  color: var(--primary);
                "
              >
                Presidential Suite
              </div>
              <div class="font-display" style="font-size: 1.1rem">
                Tầng 12 · River & Bridge View
              </div>
              <div class="mt-1" style="font-size: 0.83rem; color: #888">
                từ
                <strong
                  class="font-display"
                  style="color: var(--accent); font-size: 1.1rem"
                  >4.500.000₫</strong
                >/đêm
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ═══ BOOKING BAR (REDESIGNED) ═══ -->
    <div id="booking" class="pt-5 pb-4" style="background: var(--light-bg)">
      <div class="container">
        <div class="booking-wrap bg-white">
          <!-- Header bar -->
          <div class="booking-header d-flex align-items-center gap-3">
            <i class="bi bi-search text-white" style="font-size: 1rem"></i>
            <div>
              <div class="text-white fw-500" style="font-size: 0.85rem">
                Kiểm tra phòng trống
              </div>
              <div class="text-white-50" style="font-size: 0.72rem">
                Tìm phòng phù hợp cho chuyến đi của bạn
              </div>
            </div>
          </div>
          <!-- Input fields -->
          <div class="booking-body">
            <form action="<%=request.getContextPath()%>/pages/rooms.jsp" method="GET" class="row g-3 align-items-end">
              <div class="col-md-2 col-sm-6">
                <label class="booking-field-label"
                  ><i class="bi bi-box-arrow-in-right me-1"></i>Nhận
                  phòng</label
                >
                <input
                  type="date"
                  name="checkin"
                  class="booking-input form-control"
                  value="2026-03-30"
                  id="checkin"
                />
              </div>
              <div class="col-md-2 col-sm-6">
                <label class="booking-field-label"
                  ><i class="bi bi-box-arrow-right me-1"></i>Trả phòng</label
                >
                <input
                  type="date"
                  name="checkout"
                  class="booking-input form-control"
                  value="2026-04-02"
                  id="checkout"
                />
              </div>
              <div class="col-md-1 col-sm-6 d-none d-md-block text-center">
                <label class="booking-field-label">Đêm</label>
                <div
                  class="rounded-3 d-flex align-items-center justify-content-center fw-500"
                  id="nightsDisplay"
                  style="
                    height: 42px;
                    background: rgba(26, 107, 90, 0.07);
                    color: var(--primary);
                    font-size: 1.2rem;
                    border: 1.5px solid var(--border);
                  "
                >
                  3
                </div>
              </div>
              <div class="col-md-2 col-sm-6">
                <label class="booking-field-label"
                  ><i class="bi bi-people me-1"></i>Khách</label
                >
                <select name="occupancy" class="booking-input form-select">
                  <option value="1">1 người lớn</option>
                  <option value="2" selected>2 người lớn</option>
                  <option value="3">2 lớn + 1 trẻ em</option>
                  <option value="4">2 lớn + 2 trẻ em</option>
                  <option value="5">4+ khách</option>
                </select>
              </div>
              <div class="col-md-2 col-sm-6">
                <label class="booking-field-label"
                  ><i class="bi bi-door-open me-1"></i>Loại phòng</label
                >
                <select name="type" class="booking-input form-select">
                  <option value="all">Tất cả loại phòng</option>
                  <%
                    // 4. NẠP ĐỘNG DANH SÁCH LOẠI PHÒNG (POPULATE ROOM TYPES DROPDOWN)
                    // Lấy danh sách tên loại phòng từ CSDL để người dùng lựa chọn chính xác
                    if(conn != null) {
                        try {
                            PreparedStatement pst = conn.prepareStatement("SELECT type_name FROM room_types ORDER BY id ASC");
                            ResultSet rst = pst.executeQuery();
                            // Duyệt qua từng bản ghi loại phòng tìm được
                            while(rst.next()) {
                                String tName = rst.getString("type_name");
                                // Xuất trực tiếp mã HTML thẻ <option> ra luồng phản hồi
                                out.print("<option value='" + tName + "'>" + tName + "</option>");
                            }
                            rst.close(); pst.close();
                        } catch(Exception e) {
                            // Im lặng bỏ qua nếu lỗi để giữ nguyên tùy chọn "Tất cả loại phòng"
                        }
                    }
                  %>
                </select>
              </div>
              <div class="col-md-2 col-sm-6">
                <label class="booking-field-label"
                  ><i class="bi bi-tag me-1"></i>Mã ưu đãi</label
                >
                <input
                  type="text"
                  name="promo"
                  class="booking-input form-control"
                  placeholder="VD: EARLY20"
                />
              </div>
              <div class="col-md-1 col-sm-12">
                <button type="submit" class="btn-book-search">
                  <i class="bi bi-search"></i>
                </button>
              </div>
            </form>
          </div>
          <!-- Promo strip -->
          <div class="promo-strip d-flex align-items-center gap-2 flex-wrap">
            <i class="bi bi-stars"></i>
            <span
              ><strong>Đặt trực tiếp</strong> — Giá tốt nhất đảm bảo, tặng thêm
              bữa sáng &amp; late check-out miễn phí.</span
            >
            <span
              class="ms-auto d-none d-md-inline"
              style="color: #aaa; font-size: 0.72rem"
            >
              <i class="bi bi-shield-check me-1"></i>Thanh toán bảo mật 100%
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- ═══ AWARDS STRIP ═══ -->
    <div style="background: var(--light-bg); padding-bottom: 3rem">
      <div class="container">
        <div
          class="border-top pt-4 d-flex flex-wrap align-items-center justify-content-center gap-4 gap-md-5"
        >
          <span class="award-logo"
            ><i class="bi bi-trophy me-1" style="color: var(--accent)"></i>
            TripAdvisor's Choice 2025</span
          >
          <span class="award-logo"
            ><i class="bi bi-award me-1" style="color: var(--accent)"></i>
            Booking.com 9.4 Exceptional</span
          >
          <span class="award-logo"
            ><i class="bi bi-star me-1" style="color: var(--accent)"></i> Forbes
            Travel Guide 5★</span
          >
          <span class="award-logo"
            ><i class="bi bi-patch-check me-1" style="color: var(--accent)"></i>
            Agoda Gold Circle</span
          >
          <span class="award-logo"
            ><i class="bi bi-gem me-1" style="color: var(--accent)"></i> Vietnam
            Top Hotel 2024</span
          >
        </div>
      </div>
    </div>

    <!-- ═══ ABOUT ═══ -->
    <section id="about" style="padding: 5rem 0">
      <div class="container">
        <div class="row align-items-center g-5">
          <div class="col-lg-5">
            <div class="row g-3">
              <div class="col-8">
                <img
                  src="<%=request.getContextPath()%>/images/hero/hotel-exterior.jpg"
                  class="w-100 rounded-4 object-fit-cover"
                  style="height: 300px"
                  alt="Lobby"
                />
              </div>
              <div class="col-4 d-flex flex-column gap-3">
                <img
                  src="<%=request.getContextPath()%>/images/rooms/room-deluxe.jpg"
                  class="w-100 rounded-4 object-fit-cover"
                  style="height: 140px"
                  alt="Pool"
                />
                <div
                  class="rounded-4 d-flex flex-column align-items-center justify-content-center text-center p-3"
                  style="background: var(--primary); height: 140px"
                >
                  <div
                    class="font-display text-white"
                    style="font-size: 2.2rem; line-height: 1"
                  >
                    2009
                  </div>
                  <div
                    class="text-white-50 mt-1"
                    style="
                      font-size: 0.65rem;
                      letter-spacing: 0.12em;
                      text-transform: uppercase;
                    "
                  >
                    Năm thành lập
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="col-lg-7">
            <p class="section-tag">Tầm nhìn & Sáng tạo</p>
            <h2
              class="font-display fw-normal mt-2 mb-4"
              style="font-size: clamp(1.8rem, 3vw, 2.8rem); line-height: 1.2"
            >
              Kiến tạo chuẩn mực<br /><em style="color: var(--accent)"
                >phong cách sống Elite</em
              >
            </h2>
            <p
              class="text-muted mb-3"
              style="font-size: 0.92rem; line-height: 1.85"
            >
              OmniStay không chỉ là một khách sạn, chúng tôi là biểu tượng của
              sự thịnh vượng vùng Tây Đô. Với ngôn ngữ kiến trúc tối giản đương
              đại, OmniStay mang đến <%= totalRooms %> không gian lưu trú được thiết kế để
              đánh thức mọi giác quan của giới thượng lưu.
            </p>
            <p
              class="text-muted mb-4"
              style="font-size: 0.92rem; line-height: 1.85"
            >
              Mỗi mét vuông tại đây đều kể câu chuyện về sự tinh khôi và đẳng
              cấp — từ sảnh đón khách sang trọng, nhà hàng Signature hội tụ tinh
              hoa ẩm thực thế giới, đến hồ bơi vô cực nhìn ra vẻ đẹp lộng lẫy
              của cầu Cần Thơ về đêm.
            </p>
            <div class="row g-4">
              <div class="col-4 text-center">
                <div
                  class="font-display"
                  style="font-size: 2rem; color: var(--primary)"
                >
                  <%= totalRooms %>
                </div>
                <div
                  style="
                    font-size: 0.72rem;
                    color: #999;
                    text-transform: uppercase;
                    letter-spacing: 0.1em;
                  "
                >
                  Phòng & Suite
                </div>
              </div>
              <div
                class="col-4 text-center"
                style="
                  border-left: 1px solid var(--border);
                  border-right: 1px solid var(--border);
                "
              >
                <div
                  class="font-display"
                  style="font-size: 2rem; color: var(--primary)"
                >
                  50+
                </div>
                <div
                  style="
                    font-size: 0.72rem;
                    color: #999;
                    text-transform: uppercase;
                    letter-spacing: 0.1em;
                  "
                >
                  Nhân viên
                </div>
              </div>
              <div class="col-4 text-center">
                <div
                  class="font-display"
                  style="font-size: 2rem; color: var(--primary)"
                >
                  200k+
                </div>
                <div
                  style="
                    font-size: 0.72rem;
                    color: #999;
                    text-transform: uppercase;
                    letter-spacing: 0.1em;
                  "
                >
                  Khách lưu trú
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ═══ ROOMS ═══ -->
    <section id="rooms" style="padding: 5rem 0; background: var(--light-bg)">
      <div class="container">
        <div class="row align-items-center mb-5">
          <div class="col">
            <p class="section-tag mb-1">Danh mục phòng</p>
            <h2
              class="font-display fw-normal"
              style="font-size: clamp(1.8rem, 3vw, 2.8rem)"
            >
              Phòng & Suite
            </h2>
            <div class="divider mt-2"></div>
          </div>
          <div class="col-auto">
            <a
              href="<%=request.getContextPath()%>/pages/rooms.jsp"
              class="btn btn-outline-primary rounded-pill px-4"
              style="font-size: 0.8rem; border-color: var(--primary); color: var(--primary);"
              >Xem tất cả</a
            >
          </div>
        </div>
        <div class="row g-4 justify-content-center">
          <%
            // 5. TRUY VẤN VÀ RENDER CÁC LOẠI PHÒNG (RENDER ROOM CARDS)
            // Lấy thông tin chi tiết các hạng phòng từ bảng `room_types` để hiển thị dạng thẻ (card)
            if (conn != null) {
              try {
                Statement st = conn.createStatement();
                ResultSet rs = st.executeQuery("SELECT * FROM room_types ORDER BY id ASC");
                // Bộ định dạng tiền tệ chuẩn Việt Nam (VD: 1.500.000 ₫)
                NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
                
                // Duyệt qua từng loại phòng tìm thấy
                while(rs.next()) {
                  int maxOcc = rs.getInt("max_occupancy");
                  String typeName = rs.getString("type_name");
                  String desc = rs.getString("description");
                  String img = rs.getString("image_url");
                  double price = rs.getDouble("base_price");
          %>
          <div class="col-md-6 col-lg-3">
            <div class="room-card card h-100 border-0 shadow-sm rounded-4 overflow-hidden bg-white">
              <div class="overflow-hidden">
                <img src="<%= img %>" class="room-img w-100" style="transition: transform 0.5s; height: 240px; object-fit: cover;" 
                     onmouseover="this.style.transform = 'scale(1.05)'" onmouseout="this.style.transform = 'scale(1)'" alt="<%= typeName %>" />
              </div>
              <div class="card-body p-4">
                <h5 class="font-display fw-normal mb-2"><%= typeName %></h5>
                <p class="text-muted mb-2" style="font-size: 0.78rem; line-height: 1.6"><%= desc %></p>
                <div class="d-flex flex-wrap gap-1 mb-3">
                  <span class="badge rounded-pill bg-light text-secondary border" style="font-size: 0.65rem"><%= maxOcc %> Khách</span>
                  <span class="badge rounded-pill bg-light text-secondary border" style="font-size: 0.65rem">Wi-Fi</span>
                  <span class="badge rounded-pill bg-light text-secondary border" style="font-size: 0.65rem">Smart TV</span>
                </div>
                <div class="d-flex justify-content-between align-items-center pt-2">
                  <div>
                    <span class="font-display" style="font-size: 1.25rem; color: var(--primary)"><%= nf.format(price).replace("VNĐ", "₫") %></span>
                    <span class="text-muted" style="font-size: 0.75rem">/đêm</span>
                  </div>
                  <a href="#booking" class="btn btn-sm rounded-pill px-3 text-white" style="background: var(--primary); font-size: 0.75rem">Đặt ngay</a>
                </div>
              </div>
            </div>
          </div>
          <%
                } // Kết thúc vòng lặp while duyệt danh sách loại phòng
                rs.close();
                st.close();
              } catch(Exception e) { 
                // Bắt lỗi truy vấn SQL và in thông báo màu đỏ trực quan
                out.println("<div class='col-12 alert alert-danger'>Lỗi thực thi SQL: " + e.getMessage() + "</div>");
              }
            } else {
              // Trường hợp conn == null (Kết nối thất bại từ đầu trang), hiển thị thông báo lỗi DB
          %>
          <div class="col-12 text-center py-5">
            <div class="alert alert-warning d-inline-block">
              <i class="bi bi-exclamation-triangle-fill me-2"></i>
              <strong>LỖI KẾT NỐI:</strong> <%= dbError %>
            </div>
            <p class="text-muted mt-2">Vui lòng kiểm tra lại cấu hình Database OmniStay.</p>
          </div>
          <% } %>
        </div>
        <!-- Policies bar -->
        <div
          class="mt-4 rounded-4 p-4 d-flex flex-wrap align-items-center gap-3 justify-content-between"
          style="
            background: rgba(26, 107, 90, 0.05);
            border: 1px solid rgba(26, 107, 90, 0.1);
          "
        >
          <span style="font-size: 0.82rem; color: var(--primary)"
            ><i class="bi bi-check-circle-fill me-2"></i>Miễn phí huỷ phòng
            trước 24h</span
          >
          <span style="font-size: 0.82rem; color: var(--primary)"
            ><i class="bi bi-check-circle-fill me-2"></i>Bao gồm bữa sáng
            buffet</span
          >
          <span style="font-size: 0.82rem; color: var(--primary)"
            ><i class="bi bi-check-circle-fill me-2"></i>Check-in 14:00 /
            Check-out 12:00</span
          >
          <span style="font-size: 0.82rem; color: var(--primary)"
            ><i class="bi bi-check-circle-fill me-2"></i>Không phụ phí đặt
            phòng</span
          >
        </div>
      </div>
    </section>

    <!-- ═══ AMENITIES ═══ -->
    <section id="amenities" class="py-5">
      <div class="container py-4">
        <div class="text-center mb-5">
          <p class="section-tag">Tiện ích</p>
          <h2
            class="font-display fw-normal mt-1"
            style="font-size: clamp(1.8rem, 3vw, 2.8rem)"
          >
            Dịch vụ đẳng cấp
          </h2>
          <div class="divider mx-auto mt-2"></div>
        </div>
        <div class="row g-4 text-center">
<%
// 6. TRUY VẤN VÀ RENDER DANH SÁCH DỊCH VỤ THÊM (AMENITIES SERVICES)
// Lấy 8 dịch vụ tiêu biểu từ bảng `services` để quảng bá tiện ích khách sạn
if(conn != null){
    try{
        String sql = "SELECT * FROM services LIMIT 8";
        Statement stmt = conn.createStatement();
        ResultSet rsServ = stmt.executeQuery(sql);

        // Mảng biểu tượng Bootstrap Icons luân phiên gán cho từng thẻ dịch vụ
        String[] icons = {"bi-cup-hot", "bi-droplet-half", "bi-water", "bi-car-front", "bi-wifi", "bi-calendar-event", "bi-shield-check", "bi-stars"};
        int iconIndex = 0;
        NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));

        // Duyệt lần lượt qua các dịch vụ nạp được
        while(rsServ.next()){
            String name = rsServ.getString("service_name");
            String des  = rsServ.getString("unit"); 
            double price = rsServ.getDouble("price");

            // Tự động gán mô tả mẫu nếu dữ liệu cột `unit` bị trống
            if(des == null || des.trim().isEmpty()){
                des = "Trải nghiệm dịch vụ cao cấp tại OmniStay với chất lượng phục vụ 5 sao.";
            }
            
            // Xoay vòng chọn icon ngẫu nhiên/tuần tự từ mảng `icons`
            String icon = icons[iconIndex % icons.length];
            iconIndex++;
%>
          <div class="col-6 col-md-3">
            <div class="amenity-card bg-white rounded-4 p-4 h-100 shadow-sm d-flex flex-column" style="border: 1px solid var(--border)">
              <div class="amenity-icon mx-auto mb-3">
                <i class="bi <%= icon %>"></i>
              </div>
              <h6 class="font-display fw-normal mb-2"><%= name %></h6>
              <p class="text-muted mb-3 flex-grow-1" style="font-size: 0.82rem; line-height: 1.6;">
                <%= des %>
              </p>
              <div class="mt-auto pt-3 border-top" style="border-color: var(--border) !important;">
                <span class="font-display" style="font-size: 1.1rem; color: var(--primary); font-weight: 500;">
                  <%= nf.format(price).replace("VNĐ","₫") %>
                </span>
              </div>
            </div>
          </div>
<%
        } // Kết thúc lặp dịch vụ
        rsServ.close();
        stmt.close();
    }catch(Exception e){
        // Xử lý ngoại lệ in lỗi cụ thể nếu truy vấn bảng services thất bại
        out.println("<div class='col-12'><p class='alert alert-danger'>Lỗi lấy dữ liệu dịch vụ: " + e.getMessage() + "</p></div>");
    }
}else{
    out.println("<div class='col-12'><p class='alert alert-danger'>Lỗi kết nối DB: " + dbError + "</p></div>");
}
%>
        </div>
      </div>
    </section>

    <!-- ═══ ARCHITECTURE ═══ -->
    <section id="architecture" style="padding: 6rem 0; background: var(--light-bg)">
      <div class="container">
        <div class="row align-items-center g-5">
          <div class="col-lg-6 order-lg-2">
            <p class="section-tag mb-2">Nghệ thuật & Không gian</p>
            <h2 class="font-display fw-normal mb-4" style="font-size: clamp(2rem, 4vw, 3.2rem); line-height: 1.1">
              Bản giao hưởng của <br/><em style="color: var(--accent)">Kiến trúc Đông Dương</em>
            </h2>
            <p class="text-muted mb-4" style="font-size: 0.95rem; line-height: 1.8">
              Lấy cảm hứng từ nét đẹp hoài cổ của kiến trúc Indochine pha lẫn sự tinh giản của phong cách đương đại, OmniStay là một kiệt tác nghệ thuật giữa lòng thủ phủ miền Tây. Từng đường nét vòm cửa, gạch bông thủ công cho đến ánh sáng tự nhiên đều được tính toán tỉ mỉ để tạo nên không gian nghỉ dưỡng tĩnh lặng và sang trọng tuyệt đối.
            </p>
            <div class="row g-4 mt-2">
              <div class="col-sm-6">
                <div class="d-flex gap-3">
                  <div class="flex-shrink-0" style="color: var(--primary); font-size: 1.8rem"><i class="bi bi-palette"></i></div>
                  <div>
                    <h6 class="font-display mb-1 fw-bold">Thiết kế độc bản</h6>
                    <p class="text-muted mb-0" style="font-size: 0.8rem">Không gian được chế tác riêng biệt, tôn vinh văn hóa bản địa.</p>
                  </div>
                </div>
              </div>
              <div class="col-sm-6">
                <div class="d-flex gap-3">
                  <div class="flex-shrink-0" style="color: var(--primary); font-size: 1.8rem"><i class="bi bi-brightness-high"></i></div>
                  <div>
                    <h6 class="font-display mb-1 fw-bold">Ánh sáng tự nhiên</h6>
                    <p class="text-muted mb-0" style="font-size: 0.8rem">100% phòng nghỉ đều có ban công hoặc cửa kính tràn viền.</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="col-lg-6 order-lg-1">
            <div class="position-relative">
              <img src="<%=request.getContextPath()%>/images/rooms/room-architecture.jpg" alt="Architecture" class="w-100 rounded-4 shadow-lg" style="height: 500px; object-fit: cover;" />
              <div class="position-absolute bg-white rounded-4 shadow p-4 text-center" style="bottom: -30px; right: -30px; width: 200px; border: 1px solid var(--border)">
                <div class="font-display" style="font-size: 2.5rem; color: var(--accent); line-height: 1">100%</div>
                <div class="text-uppercase fw-bold mt-1" style="font-size: 0.65rem; letter-spacing: 2px; color: var(--primary)">Vật liệu tự nhiên</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>


    <!-- ═══ GALLERY ═══ -->
    <section id="gallery" class="py-5">
      <div class="container py-4">
        <div class="text-center mb-5">
          <p class="section-tag">Không gian</p>
          <h2
            class="font-display fw-normal mt-1"
            style="font-size: clamp(1.8rem, 3vw, 2.8rem)"
          >
            Hình ảnh khách sạn
          </h2>
          <div class="divider mx-auto mt-2"></div>
        </div>
        <div class="row g-3">
          <div class="col-md-6">
            <div class="gallery-item" style="height: 320px">
              <img src="<%=request.getContextPath()%>/images/hero/hotel-exterior.jpg" class="w-100 h-100 object-fit-cover" alt="Lobby" />
            </div>
          </div>
          <div class="col-md-3">
            <div class="gallery-item mb-3" style="height: 152px">
              <img src="<%=request.getContextPath()%>/images/rooms/room-deluxe.jpg" class="w-100 h-100 object-fit-cover" alt="Pool" />
            </div>
            <div class="gallery-item" style="height: 152px">
              <img src="<%=request.getContextPath()%>/images/services/service-restaurant.jpg" class="w-100 h-100 object-fit-cover" alt="Restaurant" />
            </div>
          </div>
          <div class="col-md-3">
            <div class="gallery-item mb-3" style="height: 152px">
              <img src="<%=request.getContextPath()%>/images/services/service-spa-2.jpg" class="w-100 h-100 object-fit-cover" alt="Spa" />
            </div>
            <div class="gallery-item" style="height: 152px">
              <img src="<%=request.getContextPath()%>/images/hero/hotel-aerial.jpg" class="w-100 h-100 object-fit-cover" alt="River view" />
            </div>
          </div>
          <div class="col-md-3">
            <div class="gallery-item" style="height: 200px">
              <img src="<%=request.getContextPath()%>/images/hero/hotel-room-hero.jpg" class="w-100 h-100 object-fit-cover" alt="Room" />
            </div>
          </div>
          <div class="col-md-3">
            <div class="gallery-item" style="height: 200px">
              <img src="<%=request.getContextPath()%>/images/services/service-bar.jpg" class="w-100 h-100 object-fit-cover" alt="Bar" />
            </div>
          </div>
          <div class="col-md-3">
            <div class="gallery-item" style="height: 200px">
              <img src="<%=request.getContextPath()%>/images/rooms/room-premium.jpg" class="w-100 h-100 object-fit-cover" alt="Suite" />
            </div>
          </div>
          <div class="col-md-3">
            <div class="gallery-item" style="height: 200px">
              <img src="<%=request.getContextPath()%>/images/rooms/room-deluxe-2.jpg" class="w-100 h-100 object-fit-cover" alt="Deluxe" />
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ═══ BOOKING PROCESS ═══ -->
    <section id="digital-experience" style="padding: 6rem 0; background: #fff">
      <div class="container">
        <div class="text-center mb-5">
          <p class="section-tag mb-2">Trải nghiệm số hóa</p>
          <h2 class="font-display fw-normal mb-3" style="font-size: clamp(2rem, 4vw, 3.2rem)">
            Đặt phòng thông minh & An toàn
          </h2>
          <p class="text-muted mx-auto" style="max-width: 600px; font-size: 0.95rem; line-height: 1.6">
            Hệ thống OmniStay được tích hợp nền tảng thanh toán trực tuyến hiện đại, mang đến cho bạn sự tiện lợi, minh bạch và bảo mật tuyệt đối trong mỗi giao dịch.
          </p>
          <div class="divider mx-auto mt-4"></div>
        </div>
        
        <div class="row g-4 mt-2">
          <div class="col-md-4">
            <div class="card h-100 border-0 shadow-sm rounded-4 p-4 text-center" style="background: rgba(26, 107, 90, 0.03); transition: transform 0.3s;" onmouseover="this.style.transform='translateY(-10px)'" onmouseout="this.style.transform='translateY(0)'">
              <div class="rounded-circle d-flex align-items-center justify-content-center mx-auto mb-4 shadow" style="width: 80px; height: 80px; background: #fff; border: 2px solid var(--accent); font-size: 2rem; color: var(--primary)">
                1
              </div>
              <h5 class="font-display fw-bold mb-3">Chọn phòng linh hoạt</h5>
              <p class="text-muted" style="font-size: 0.85rem">Hệ thống hiển thị trạng thái phòng trống thời gian thực. Bạn có thể dễ dàng lọc và chọn đúng căn phòng ưa thích của mình.</p>
            </div>
          </div>
          <div class="col-md-4">
            <div class="card h-100 border-0 shadow-sm rounded-4 p-4 text-center" style="background: rgba(26, 107, 90, 0.03); transition: transform 0.3s;" onmouseover="this.style.transform='translateY(-10px)'" onmouseout="this.style.transform='translateY(0)'">
              <div class="rounded-circle d-flex align-items-center justify-content-center mx-auto mb-4 shadow" style="width: 80px; height: 80px; background: #fff; border: 2px solid var(--accent); font-size: 2rem; color: var(--primary)">
                2
              </div>
              <h5 class="font-display fw-bold mb-3">Thanh toán VNPAY</h5>
              <p class="text-muted" style="font-size: 0.85rem">Tích hợp cổng thanh toán quốc gia VNPAY. Giao dịch mã hóa SSL an toàn, hỗ trợ quét mã QR, thẻ ATM và thẻ tín dụng.</p>
            </div>
          </div>
          <div class="col-md-4">
            <div class="card h-100 border-0 shadow-sm rounded-4 p-4 text-center" style="background: rgba(26, 107, 90, 0.03); transition: transform 0.3s;" onmouseover="this.style.transform='translateY(-10px)'" onmouseout="this.style.transform='translateY(0)'">
              <div class="rounded-circle d-flex align-items-center justify-content-center mx-auto mb-4 shadow" style="width: 80px; height: 80px; background: #fff; border: 2px solid var(--accent); font-size: 2rem; color: var(--primary)">
                3
              </div>
              <h5 class="font-display fw-bold mb-3">Nhận phòng tức thì</h5>
              <p class="text-muted" style="font-size: 0.85rem">Sau khi thanh toán thành công, hóa đơn điện tử sẽ được gửi ngay về Email. Quá trình check-in tại quầy chỉ mất chưa đầy 1 phút.</p>
            </div>
          </div>
        </div>
      </div>
    </section>


    <!-- ═══ WHY US ═══ -->
    <section style="padding: 5rem 0">
      <div class="container">
        <div class="row align-items-center g-5">
          <div class="col-lg-6">
            <p class="section-tag">Tại sao chọn OmniStay</p>
            <h2
              class="font-display fw-normal mt-2 mb-5"
              style="font-size: clamp(1.8rem, 3vw, 2.8rem)"
            >
              Sự khác biệt nằm ở<br /><em style="color: var(--accent)"
                >từng chi tiết nhỏ</em
              >
            </h2>
            <div class="d-flex gap-4 mb-4">
              <div class="exp-dot flex-shrink-0"><i class="bi bi-gem"></i></div>
              <div>
                <h6 class="font-display fw-normal mb-1">
                  Thiết kế nội thất độc bản
                </h6>
                <p
                  class="text-muted mb-0"
                  style="font-size: 0.85rem; line-height: 1.75"
                >
                  Mỗi phòng là tác phẩm nghệ thuật sống — được thiết kế bởi
                  studio Bill Bensley với vật liệu cao cấp tuyển chọn từ khắp
                  thế giới.
                </p>
              </div>
            </div>
            <div class="d-flex gap-4 mb-4">
              <div class="exp-dot flex-shrink-0">
                <i class="bi bi-heart-pulse"></i>
              </div>
              <div>
                <h6 class="font-display fw-normal mb-1">Dịch vụ cá nhân hoá</h6>
                <p
                  class="text-muted mb-0"
                  style="font-size: 0.85rem; line-height: 1.75"
                >
                  Trước khi bạn đến, đội ngũ của chúng tôi đã chuẩn bị mọi thứ
                  theo đúng sở thích — từ nhiệt độ phòng đến loại gối ưa thích.
                </p>
              </div>
            </div>
            <div class="d-flex gap-4 mb-4">
              <div class="exp-dot flex-shrink-0">
                <i class="bi bi-leaf"></i>
              </div>
              <div>
                <h6 class="font-display fw-normal mb-1">Cam kết bền vững</h6>
                <p
                  class="text-muted mb-0"
                  style="font-size: 0.85rem; line-height: 1.75"
                >
                  Chương trình Green Stay — 30% năng lượng từ solar, sản phẩm
                  hữu cơ trong spa và nhà hàng hợp tác với nông trại địa phương.
                </p>
              </div>
            </div>
            <div class="d-flex gap-4">
              <div class="exp-dot flex-shrink-0">
                <i class="bi bi-translate"></i>
              </div>
              <div>
                <h6 class="font-display fw-normal mb-1">Đội ngũ đa ngôn ngữ</h6>
                <p
                  class="text-muted mb-0"
                  style="font-size: 0.85rem; line-height: 1.75"
                >
                  Nhân viên thông thạo Việt, Anh, Pháp, Trung, Nhật — sẵn sàng
                  hỗ trợ khách quốc tế mọi lúc mọi nơi.
                </p>
              </div>
            </div>
          </div>
          <div class="col-lg-6">
            <div class="row g-3">
              <div class="col-6">
                <img
                  src="<%=request.getContextPath()%>/images/hero/hotel-aerial.jpg"
                  class="w-100 rounded-4 object-fit-cover"
                  style="height: 230px"
                  alt="Pool"
                />
              </div>
              <div class="col-6 pt-4">
                <img
                  src="<%=request.getContextPath()%>/images/rooms/room-deluxe.jpg"
                  class="w-100 rounded-4 object-fit-cover"
                  style="height: 230px"
                  alt="Infinity"
                />
              </div>
              <div class="col-12">
                <div
                  class="rounded-4 p-4 d-flex gap-4 justify-content-around text-center"
                  style="background: var(--primary)"
                >
                  <div>
                    <div
                      class="font-display text-white"
                      style="font-size: 1.75rem"
                    >
                      98%
                    </div>
                    <div
                      class="text-white-50"
                      style="
                        font-size: 0.7rem;
                        text-transform: uppercase;
                        letter-spacing: 0.1em;
                      "
                    >
                      Khách hài lòng
                    </div>
                  </div>
                  <div
                    style="width: 1px; background: rgba(255, 255, 255, 0.15)"
                  ></div>
                  <div>
                    <div
                      class="font-display text-white"
                      style="font-size: 1.75rem"
                    >
                      72%
                    </div>
                    <div
                      class="text-white-50"
                      style="
                        font-size: 0.7rem;
                        text-transform: uppercase;
                        letter-spacing: 0.1em;
                      "
                    >
                      Khách quay lại
                    </div>
                  </div>
                  <div
                    style="width: 1px; background: rgba(255, 255, 255, 0.15)"
                  ></div>
                  <div>
                    <div
                      class="font-display text-white"
                      style="font-size: 1.75rem"
                    >
                      8 phút
                    </div>
                    <div
                      class="text-white-50"
                      style="
                        font-size: 0.7rem;
                        text-transform: uppercase;
                        letter-spacing: 0.1em;
                      "
                    >
                      Phản hồi TB
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ═══ REVIEWS ═══ -->
    <section id="reviews" class="py-5" style="background: #fff;">
      <div class="container py-4">
        <div class="text-center mb-5">
          <p class="section-tag">Khách hàng nói gì</p>
          <h2 class="font-display fw-normal mt-1" style="font-size: clamp(1.8rem, 3vw, 2.8rem)">
            Đánh giá thực tế
          </h2>
          <div class="divider mx-auto mt-2"></div>
        </div>
        <div class="row g-4 justify-content-center">
          <%
            // 7. TRUY VẤN VÀ RENDER CÁC ĐÁNH GIÁ TÍCH CỰC (CUSTOMER REVIEWS)
            // Lấy 3 đánh giá mới nhất có số điểm từ 4 sao trở lên và đã được duyệt (status = 1)
            // Thực hiện phép JOIN với bảng `guests` để lấy ra họ tên đầy đủ của khách hàng
            if(conn != null){
              try {
                String reviewSql = "SELECT r.*, g.full_name FROM reviews r JOIN guests g ON r.guest_id = g.id WHERE r.status = 1 AND r.rating >= 4 ORDER BY r.created_at DESC LIMIT 3";
                PreparedStatement psReview = conn.prepareStatement(reviewSql);
                ResultSet rsReview = psReview.executeQuery();
                
                // Mảng màu nền avatar ngẫu nhiên để tạo sự sinh động cho giao diện
                String[] bgColors = {"var(--primary)", "var(--accent)", "#1a6b5a", "#d4a847"};
                int revIdx = 0;
                
                // Cờ kiểm tra nếu CSDL chưa có đánh giá nào thỏa mãn
                boolean hasDbReviews = false;
                while(rsReview.next()){
                  hasDbReviews = true;
                  String guestName = rsReview.getString("full_name");
                  String comment = rsReview.getString("comment");
                  int rating = rsReview.getInt("rating");
                  Timestamp createdAt = rsReview.getTimestamp("created_at");
                  
                  // Trích xuất chữ cái đầu tiên của Tên để làm Avatar mặc định (Placeholder avatar)
                  // Phân tách chuỗi theo khoảng trắng để lấy từ cuối cùng (Tên)
                  String initial = guestName.substring(0, 1).toUpperCase() + (guestName.contains(" ") ? guestName.split(" ")[guestName.split(" ").length-1].substring(0,1).toUpperCase() : "");
          %>
          <div class="col-md-4">
            <div class="review-card bg-white rounded-4 p-4 shadow-sm h-100 d-flex flex-column" style="border: 1px solid var(--border)">
              <div class="d-flex align-items-center gap-2 mb-3">
                <span class="star fs-5">
                  <% 
                    // Vòng lặp in chính xác số lượng sao đánh giá (sao đặc ★ và sao rỗng ☆)
                    for(int i=0; i<5; i++) { 
                  %>
                    <%= (i < rating) ? "★" : "☆" %>
                  <% } %>
                </span>
              </div>
              <p class="mb-4 flex-grow-1" style="font-size: 0.88rem; line-height: 1.75; color: #444; font-style: italic;">
                "<%= comment %>"
              </p>
              <div class="d-flex align-items-center gap-3 mt-auto">
                <div class="rounded-circle d-flex align-items-center justify-content-center text-white fw-bold shadow-sm" style="width: 42px; height: 42px; background: <%= bgColors[revIdx % bgColors.length] %>; font-size: 0.9rem;">
                  <%= initial %>
                </div>
                <div>
                  <div class="fw-bold" style="font-size: 0.85rem; color: var(--primary)">
                    <%= guestName %>
                  </div>
                  <div class="text-muted" style="font-size: 0.75rem">
                    Khách lưu trú · <%= new java.text.SimpleDateFormat("MM/yyyy").format(createdAt) %>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <%
                  revIdx++;
                } // Kết thúc lặp đánh giá
                rsReview.close();
                psReview.close();
                
                // Hiển thị thông báo dự phòng nếu danh sách rỗng
                if(!hasDbReviews) {
                  out.println("<div class='col-12 text-center py-4'><p class='text-muted'>Đang cập nhật những đánh giá mới nhất...</p></div>");
                }
              } catch(Exception e) {
                // Bắt và in lỗi nếu có sự cố truy vấn bảng reviews
                out.println("<div class='col-12 text-center text-danger'>Lỗi tải đánh giá: " + e.getMessage() + "</div>");
              }
            }
          %>
        </div>
      </div>
    </section>

    <!-- ═══ LOCATION ═══ -->
    <section id="location" style="padding: 5rem 0; background: var(--light-bg)">
      <div class="container">
        <div class="row align-items-end mb-5">
          <div class="col">
            <p class="section-tag">Vị trí</p>
            <h2
              class="font-display fw-normal mt-1"
              style="font-size: clamp(1.8rem, 3vw, 2.8rem)"
            >
              Trung tâm mọi thứ
            </h2>
            <div class="divider mt-2"></div>
          </div>
        </div>
        <div class="row g-5 align-items-center">
          <div class="col-lg-7">
            <div class="rounded-4 overflow-hidden shadow-sm" style="height: 380px">
              <iframe 
                src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3928.793339178906!2d105.785025!3d10.033908!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x31a062a046c82737%3A0xc07c3c2603db02!2zQuG6v24gTmluaCBLaeG7gXU!5e0!3m2!1svi!2s!4v1715312345678!5m2!1svi!2s" 
                width="100%" 
                height="100%" 
                style="border:0;" 
                allowfullscreen="" 
                loading="lazy" 
                referrerpolicy="no-referrer-when-downgrade">
              </iframe>
            </div>
          </div>
          <div class="col-lg-5">
            <h5 class="font-display fw-normal mb-4">Điểm nổi bật lân cận</h5>
            <div>
              <div
                class="d-flex align-items-center gap-3 py-3"
                style="border-bottom: 1px solid var(--border)"
              >
                <div class="nearby-icon"><i class="bi bi-airplane"></i></div>
                <div class="flex-grow-1">
                  <div class="fw-500" style="font-size: 0.88rem">
                    Sân bay Quốc tế Cần Thơ
                  </div>
                  <div class="text-muted" style="font-size: 0.75rem">
                    8 km · ~15 phút xe
                  </div>
                </div>
                <span
                  class="badge rounded-pill"
                  style="
                    background: rgba(26, 107, 90, 0.08);
                    color: var(--primary);
                    font-size: 0.68rem;
                  "
                  >Shuttle sẵn</span
                >
              </div>
              <div
                class="d-flex align-items-center gap-3 py-3"
                style="border-bottom: 1px solid var(--border)"
              >
                <div class="nearby-icon"><i class="bi bi-bank2"></i></div>
                <div class="flex-grow-1">
                  <div class="fw-500" style="font-size: 0.88rem">
                    Chợ nổi & Trải nghiệm Du thuyền
                  </div>
                  <div class="text-muted" style="font-size: 0.75rem">
                    Đón khách tại bến riêng · Tour cao cấp
                  </div>
                </div>
              </div>
              <div
                class="d-flex align-items-center gap-3 py-3"
                style="border-bottom: 1px solid var(--border)"
              >
                <div class="nearby-icon"><i class="bi bi-shop"></i></div>
                <div class="flex-grow-1">
                  <div class="fw-500" style="font-size: 0.88rem">
                    Vincom Plaza Xuân Khánh - Trung tâm tài chính
                  </div>
                  <div class="text-muted" style="font-size: 0.75rem">
                    1.2 km · 5 phút xe
                  </div>
                </div>
              </div>
              <div
                class="d-flex align-items-center gap-3 py-3"
                style="border-bottom: 1px solid var(--border)"
              >
                <div class="nearby-icon"><i class="bi bi-tree"></i></div>
                <div class="flex-grow-1">
                  <div class="fw-500" style="font-size: 0.88rem">
                    Công viên Lưu Hữu Phước
                  </div>
                  <div class="text-muted" style="font-size: 0.75rem">
                    500m · 7 phút đi bộ
                  </div>
                </div>
              </div>
              <div class="d-flex align-items-center gap-3 py-3">
                <div class="nearby-icon">
                  <i class="bi bi-building-check"></i>
                </div>
                <div class="flex-grow-1">
                  <div class="fw-500" style="font-size: 0.88rem">
                    Cầu Tình Yêu Cần Thơ
                  </div>
                  <div class="text-muted" style="font-size: 0.75rem">
                    400m · 6 phút đi bộ
                  </div>
                </div>
              </div>
            </div>
            <div
              class="mt-4 p-3 rounded-3 d-flex align-items-center gap-3"
              style="
                background: rgba(26, 107, 90, 0.05);
                border: 1px solid rgba(26, 107, 90, 0.1);
              "
            >
              <i
                class="bi bi-geo-alt-fill"
                style="color: var(--primary); font-size: 1.2rem"
              ></i>
              <div style="font-size: 0.82rem">
                <div class="fw-500">
                  81 Hai Bà Trưng, Tân An, Ninh Kiều, Cần Thơ
                </div>
                <div class="text-muted mt-1">
                  +84 292 3888 999 · hello@omnistay.vn
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ═══ AI CONCIERGE ═══ -->
    <section id="ai-concierge" class="text-white position-relative py-5" style="background: linear-gradient(135deg, var(--primary-dark), var(--primary)); overflow: hidden;">
      <div style="position: absolute; top: -50%; left: -10%; width: 500px; height: 500px; background: radial-gradient(circle, rgba(212,168,71,0.15) 0%, transparent 70%);"></div>
      <div style="position: absolute; bottom: -50%; right: -10%; width: 600px; height: 600px; background: radial-gradient(circle, rgba(255,255,255,0.05) 0%, transparent 70%);"></div>
      
      <div class="container py-5 position-relative z-1">
        <div class="row align-items-center g-5">
          <div class="col-lg-6 text-center text-lg-start">
            <span class="badge rounded-pill mb-3 px-3 py-2" style="background: rgba(212,168,71,0.2); color: var(--accent); border: 1px solid rgba(212,168,71,0.4); font-size: 0.75rem; letter-spacing: 1px;">CÔNG NGHỆ ĐỘT PHÁ</span>
            <h2 class="font-display fw-normal mb-4" style="font-size: clamp(2rem, 4vw, 3.2rem)">
              Trợ lý ảo <em style="color: var(--accent)">OmniAI</em>
            </h2>
            <p class="mb-4 text-white-50" style="font-size: 1rem; line-height: 1.8; max-width: 500px; margin: 0 auto; margin-lg-0: 0;">
              Lần đầu tiên tại Việt Nam, trải nghiệm dịch vụ chăm sóc khách hàng 24/7 thông qua bộ não nhân tạo tiên tiến, tích hợp trực tiếp trên nền tảng khách sạn.
            </p>
            <ul class="list-unstyled text-start d-inline-block mx-auto mx-lg-0 mb-4" style="font-size: 0.9rem">
              <li class="mb-3 d-flex align-items-center"><i class="bi bi-lightning-charge-fill text-warning me-3 fs-5"></i> Giải đáp thông tin khách sạn lập tức</li>
              <li class="mb-3 d-flex align-items-center"><i class="bi bi-clock-history text-warning me-3 fs-5"></i> Trực tuyến hỗ trợ suốt ngày đêm</li>
              <li class="mb-0 d-flex align-items-center"><i class="bi bi-globe text-warning me-3 fs-5"></i> Giao tiếp thông minh như một lễ tân thực thụ</li>
            </ul>
            <br>
            <button onclick="OmniChat.toggle()" class="btn btn-outline-light rounded-pill px-5 py-3 mt-2 fw-bold" style="border-width: 2px;">
              Trò chuyện ngay <i class="bi bi-robot ms-2"></i>
            </button>
          </div>
          <div class="col-lg-6 position-relative">
            <div class="mx-auto" style="max-width: 350px; position: relative;">
              <div class="position-absolute" style="top: 10%; right: -10%; width: 100px; height: 100px; background: rgba(212,168,71,0.3); filter: blur(20px); border-radius: 50%;"></div>
              <img src="<%=request.getContextPath()%>/images/hero/hotel-room-hero.jpg" class="w-100 rounded-4 shadow-lg" style="border: 2px solid rgba(255,255,255,0.2);" alt="AI Concierge">
              <div class="position-absolute bg-white rounded-4 shadow-lg p-3 d-flex align-items-start gap-3" style="bottom: -20px; left: -40px; width: 280px; animation: float 4s ease-in-out infinite;">
                <div class="rounded-circle text-white d-flex align-items-center justify-content-center flex-shrink-0" style="width: 40px; height: 40px; background: var(--primary)"><i class="bi bi-stars"></i></div>
                <div>
                  <div class="text-dark fw-bold mb-1" style="font-size: 0.8rem;">OmniAI</div>
                  <div class="text-muted" style="font-size: 0.75rem; line-height: 1.4;">Xin chào! Tôi có thể giúp gì cho kỳ nghỉ của bạn tại OmniStay?</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>


    <!-- ═══ FAQ ═══ -->
    <section style="padding: 5rem 0; background: var(--light-bg)">
      <div class="container">
        <div class="row justify-content-center">
          <div class="col-lg-8">
            <div class="text-center mb-5">
              <p class="section-tag">Hỏi đáp</p>
              <h2
                class="font-display fw-normal mt-1"
                style="font-size: clamp(1.8rem, 3vw, 2.8rem)"
              >
                Câu hỏi thường gặp
              </h2>
              <div class="divider mx-auto mt-2"></div>
            </div>
            <div class="accordion" id="faqAccordion">
              <div
                class="accordion-item border-0 rounded-4 mb-3 shadow-sm overflow-hidden"
              >
                <h2 class="accordion-header">
                  <button
                    class="accordion-button rounded-4"
                    type="button"
                    data-bs-toggle="collapse"
                    data-bs-target="#faq1"
                  >
                    Giờ check-in và check-out của khách sạn là mấy giờ?
                  </button>
                </h2>
                <div
                  id="faq1"
                  class="accordion-collapse collapse show"
                  data-bs-parent="#faqAccordion"
                >
                  <div
                    class="accordion-body text-muted"
                    style="font-size: 0.88rem; line-height: 1.75"
                  >
                    Check-in tiêu chuẩn từ <strong>14:00</strong> và check-out
                    trước <strong>12:00 trưa</strong>. Khách đặt gói Early Bird
                    hoặc Romance được check-in từ 11:00 và check-out muộn đến
                    14:00 miễn phí. Chúng tôi cũng hỗ trợ giữ hành lý miễn phí
                    nếu bạn đến sớm hoặc rời muộn hơn giờ tiêu chuẩn.
                  </div>
                </div>
              </div>
              <div
                class="accordion-item border-0 rounded-4 mb-3 shadow-sm overflow-hidden"
              >
                <h2 class="accordion-header">
                  <button
                    class="accordion-button collapsed rounded-4"
                    type="button"
                    data-bs-toggle="collapse"
                    data-bs-target="#faq2"
                  >
                    Khách sạn có bãi đậu xe không?
                  </button>
                </h2>
                <div
                  id="faq2"
                  class="accordion-collapse collapse"
                  data-bs-parent="#faqAccordion"
                >
                  <div
                    class="accordion-body text-muted"
                    style="font-size: 0.88rem; line-height: 1.75"
                  >
                    Có, OmniStay có bãi đỗ xe ngầm với sức chứa 80 xe ô tô. Phí
                    gửi xe <strong>80.000₫/ngày</strong> dành cho khách lưu trú.
                    Dịch vụ valet parking cũng có sẵn tại sảnh chính. Đặt chỗ
                    trước qua lễ tân, đặc biệt dịp cuối tuần và lễ tết.
                  </div>
                </div>
              </div>
              <div
                class="accordion-item border-0 rounded-4 mb-3 shadow-sm overflow-hidden"
              >
                <h2 class="accordion-header">
                  <button
                    class="accordion-button collapsed rounded-4"
                    type="button"
                    data-bs-toggle="collapse"
                    data-bs-target="#faq3"
                  >
                    Có dịch vụ đưa đón sân bay không? Giá bao nhiêu?
                  </button>
                </h2>
                <div
                  id="faq3"
                  class="accordion-collapse collapse"
                  data-bs-parent="#faqAccordion"
                >
                  <div
                    class="accordion-body text-muted"
                    style="font-size: 0.88rem; line-height: 1.75"
                  >
                    Chúng tôi cung cấp dịch vụ đưa đón sân bay Tân Sơn Nhất bằng
                    xe hạng sang 24/7. Giá từ
                    <strong>350.000₫/chuyến</strong> một chiều. Khách lưu trú
                    Suite trở lên được miễn phí 1 chuyến đón sân bay. Vui lòng
                    đặt trước tối thiểu 3 giờ qua lễ tân.
                  </div>
                </div>
              </div>
              <div
                class="accordion-item border-0 rounded-4 mb-3 shadow-sm overflow-hidden"
              >
                <h2 class="accordion-header">
                  <button
                    class="accordion-button collapsed rounded-4"
                    type="button"
                    data-bs-toggle="collapse"
                    data-bs-target="#faq4"
                  >
                    Khách sạn có phù hợp cho trẻ em không?
                  </button>
                </h2>
                <div
                  id="faq4"
                  class="accordion-collapse collapse"
                  data-bs-parent="#faqAccordion"
                >
                  <div
                    class="accordion-body text-muted"
                    style="font-size: 0.88rem; line-height: 1.75"
                  >
                    Hoàn toàn phù hợp! Trẻ em dưới 12 tuổi được ở miễn phí khi
                    dùng chung giường với bố mẹ. Chúng tôi có cũi trẻ em, ghế ăn
                    cao và menu riêng cho trẻ em. Khu vực hồ bơi trẻ em riêng ở
                    tầng 3. Dịch vụ trông trẻ (babysitting) có thể đặt trước với
                    phí 150.000₫/giờ.
                  </div>
                </div>
              </div>
              <div
                class="accordion-item border-0 rounded-4 shadow-sm overflow-hidden"
              >
                <h2 class="accordion-header">
                  <button
                    class="accordion-button collapsed rounded-4"
                    type="button"
                    data-bs-toggle="collapse"
                    data-bs-target="#faq5"
                  >
                    Chính sách huỷ phòng như thế nào?
                  </button>
                </h2>
                <div
                  id="faq5"
                  class="accordion-collapse collapse"
                  data-bs-parent="#faqAccordion"
                >
                  <div
                    class="accordion-body text-muted"
                    style="font-size: 0.88rem; line-height: 1.75"
                  >
                    Đặt phòng tiêu chuẩn có thể huỷ miễn phí trước
                    <strong>24 giờ</strong> so với giờ check-in. Huỷ sau thời
                    hạn sẽ tính phí 1 đêm. Các gói ưu đãi đặc biệt áp dụng chính
                    sách huỷ trước <strong>48 giờ</strong> để hoàn tiền đầy đủ.
                    Vui lòng liên hệ lễ tân để được hỗ trợ.
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ═══ CTA ═══ -->
    <section
      class="py-5 text-white text-center position-relative"
      style="
        background: linear-gradient(
          135deg,
          rgba(19, 79, 67, 0.92),
          rgba(26, 107, 90, 0.88)
        ), url('<%=request.getContextPath()%>/images/rooms/room-deluxe.jpg') center/cover no-repeat;
        background-attachment: fixed;
      "
    >
      <div class="container py-5">
        <p
          class="text-uppercase mb-2"
          style="font-size: 0.72rem; letter-spacing: 0.2em; color: var(--accent);"
        >
          ✦ Ưu đãi đặc biệt ✦
        </p>
        <h2
          class="font-display fw-normal mb-3"
          style="font-size: clamp(1.8rem, 3vw, 2.8rem); text-shadow: 0 3px 15px rgba(0,0,0,0.3);"
        >
          Đặt phòng sớm — <em style="color: var(--accent)">Giảm 20%</em>
        </h2>
        <p
          class="mb-5 mx-auto"
          style="font-size: 0.95rem; max-width: 520px; color: rgba(255,255,255,0.85); text-shadow: 0 1px 6px rgba(0,0,0,0.2);"
        >
          Đặt trước 7 ngày để nhận ưu đãi bao gồm bữa sáng miễn phí và check-in
          sớm. Áp dụng cho tất cả các hạng phòng.
        </p>
        <div class="d-flex gap-3 justify-content-center flex-wrap">
          <a
            href="#booking"
            class="btn btn-lg px-5 py-3 rounded-pill btn-hero-primary"
            style="font-size: 0.85rem; animation: pulseGlow 2s infinite;"
            >Đặt ngay hôm nay</a
          >
          <a
            href="#rooms"
            class="btn btn-lg px-5 py-3 rounded-pill btn-hero-outline"
            style="font-size: 0.85rem;"
            >Xem chi tiết</a
          >
        </div>
      </div>
    </section>

    <%@ include file="layouts/chatbot.jsp" %> <%@ include
    file="layouts/footer.jsp" %>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
      // ======================================================================
      // XỬ LÝ LƯỢNG TƯƠNG TÁC PHÍA MÁY KHÁCH (CLIENT-SIDE INTERACTIONS)
      // ======================================================================
      
      // 1. Hiệu ứng thanh điều hướng (Navbar Scroll Effect)
      // Thêm lớp 'navbar-scrolled' khi cuộn qua 50px để làm nền sẫm lại
      window.addEventListener("scroll", function () {
        const navbar = document.querySelector(".navbar");
        if (navbar) {
          navbar.classList.toggle("navbar-scrolled", window.scrollY > 50);
        }
      });

      // 2. Kích hoạt hiệu ứng xuất hiện dần khi cuộn trang (IntersectionObserver Fade-in)
      // Quan sát các phần tử DOM, khi chúng lọt vào khung nhìn (viewport) sẽ thêm class 'visible'
      const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            entry.target.classList.add('visible');
          }
        });
      }, { threshold: 0.1, rootMargin: '0px 0px -50px 0px' });

      // Đăng ký theo dõi cho các thẻ card dịch vụ, hình ảnh và đánh giá
      document.querySelectorAll('.amenity-card, .review-card, .offer-card, .gallery-item, .dept-card').forEach(el => {
        el.classList.add('animate-fade-in');
        observer.observe(el);
      });

      // 3. Tự động tính toán số đêm lưu trú (Auto Nights Counter)
      // Lắng nghe sự kiện thay đổi ngày check-in/check-out để tự động trừ và cập nhật ô hiển thị
      const ci = document.getElementById("checkin");
      const co = document.getElementById("checkout");
      const nd = document.getElementById("nightsDisplay");
      if (ci && co && nd) {
        function updateNights() {
          // Trừ timestamp và chia cho số mili-giây của 1 ngày (86400000 ms)
          const diff = Math.round(
            (new Date(co.value) - new Date(ci.value)) / 86400000,
          );
          if (diff > 0) nd.textContent = diff;
        }
        ci.addEventListener("change", updateNights);
        co.addEventListener("change", updateNights);
      }
    </script>
    <% 
        // 8. ĐÓNG KẾT NỐI CƠ SỞ DỮ LIỆU (RESOURCE CLEANUP)
        // Đảm bảo Connection luôn được đóng sau khi trang hoàn tất render
        // Tránh tình trạng cạn kiệt pool kết nối (Connection pool exhaustion)
        if(conn != null) try { conn.close(); } catch(Exception e) {} 
    %>
  </body>
</html>
