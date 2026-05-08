<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.NumberFormat" %>
<%@ include file="env-secrets.jsp" %>
<%! 
    public static final String GEMINI_API_KEY = SECRET_GEMINI_KEY; 
    public static final String GEMINI_MODEL = SECRET_GEMINI_MODEL; 
%>
<%
    Connection conn = null;
    String dbError = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(SECRET_DB_URL, SECRET_DB_USER, SECRET_DB_PASS);
    } catch(Exception e) {
        dbError = e.getMessage() != null ? e.getMessage() : e.toString();
    }
%>
<!DOCTYPE html>
<html lang="vi">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>OmniStay — Luxury Hotel</title>
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
        ), url('https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=1600&q=80') center/cover no-repeat;
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
              <div>
                <div class="font-display text-white fw-normal stat-number">128</div>
                <div class="stat-label">Phòng nghỉ</div>
              </div>
              <div class="stat-divider"></div>
              <div>
                <div class="font-display text-white fw-normal stat-number">
                  4.9<span style="font-size: 1rem; color: var(--accent)">★</span>
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
              src="https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800&q=80"
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
                  <option value="standard">Standard</option>
                  <option value="deluxe">Deluxe</option>
                  <option value="suite">Superior Suite</option>
                  <option value="presidential">Presidential Suite</option>
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
                  src="https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=600&q=80"
                  class="w-100 rounded-4 object-fit-cover"
                  style="height: 300px"
                  alt="Lobby"
                />
              </div>
              <div class="col-4 d-flex flex-column gap-3">
                <img
                  src="https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=300&q=80"
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
              đại, OmniStay mang đến 128 không gian lưu trú được thiết kế để
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
                  128
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
            if (conn != null) {
              try {
                Statement st = conn.createStatement();
                ResultSet rs = st.executeQuery("SELECT * FROM room_types ORDER BY id ASC");
                NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
                while(rs.next()) {
                  int maxOcc = rs.getInt("max_occupancy");
                  String typeName = rs.getString("type_name");
                  String desc = rs.getString("description");
                  String img = rs.getString("image_url");
                  double price = rs.getDouble("base_price");
          %>
          <div class="col-md-6 col-lg-4">
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
                }
                rs.close();
                st.close();
              } catch(Exception e) { 
                out.println("<div class='col-12 alert alert-danger'>Lỗi thực thi SQL: " + e.getMessage() + "</div>");
              }
            } else {
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
if(conn != null){
    try{
        String sql = "SELECT * FROM services LIMIT 8";
        Statement stmt = conn.createStatement();
        ResultSet rsServ = stmt.executeQuery(sql);

        String[] icons = {"bi-cup-hot", "bi-droplet-half", "bi-water", "bi-car-front", "bi-wifi", "bi-calendar-event", "bi-shield-check", "bi-stars"};
        int iconIndex = 0;
        NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));

        while(rsServ.next()){
            String name = rsServ.getString("service_name");
            String des  = rsServ.getString("unit"); 
            double price = rsServ.getDouble("price");

            if(des == null || des.trim().isEmpty()){
                des = "Trải nghiệm dịch vụ cao cấp tại OmniStay với chất lượng phục vụ 5 sao.";
            }
            
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
        }
        rsServ.close();
        stmt.close();
    }catch(Exception e){
        out.println("<div class='col-12'><p class='alert alert-danger'>Lỗi lấy dữ liệu dịch vụ: " + e.getMessage() + "</p></div>");
    }
}else{
    out.println("<div class='col-12'><p class='alert alert-danger'>Lỗi kết nối DB: " + dbError + "</p></div>");
}
%>
        </div>
      </div>
    </section>

    <!-- ═══ DINING ═══ -->
    <section id="dining" style="padding: 5rem 0; background: var(--light-bg)">
      <div class="container">
        <div class="row align-items-end mb-5">
          <div class="col">
            <p class="section-tag">Ẩm thực</p>
            <h2
              class="font-display fw-normal mt-1"
              style="font-size: clamp(1.8rem, 3vw, 2.8rem)"
            >
              Nghệ thuật ẩm thực
            </h2>
            <div class="divider mt-2"></div>
          </div>
        </div>
        <div class="row g-4">
          <div class="col-lg-5">
            <div
              class="card border-0 rounded-4 overflow-hidden shadow-sm h-100"
            >
              <div class="overflow-hidden">
                <img
                  src="https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80"
                  class="w-100 object-fit-cover"
                  style="height: 260px; transition: transform 0.5s"
                  onmouseover="this.style.transform = 'scale(1.04)'"
                  onmouseout="this.style.transform = 'scale(1)'"
                />
              </div>
              <div class="card-body p-4">
                <div class="d-flex align-items-center gap-2 mb-2">
                  <span
                    class="badge rounded-pill"
                    style="
                      background: rgba(212, 168, 71, 0.12);
                      color: #a07820;
                      font-size: 0.65rem;
                    "
                    >NHÀ HÀNG CHÍNH</span
                  >
                  <span class="text-muted" style="font-size: 0.75rem"
                    >Tầng 2 · 06:00 – 23:00</span
                  >
                </div>
                <h5 class="font-display fw-normal mb-2">The Verdant Kitchen</h5>
                <p
                  class="text-muted mb-3"
                  style="font-size: 0.85rem; line-height: 1.75"
                >
                  Thực đơn Signature đương đại được chế tác bởi bếp trưởng từ
                  khách sạn 5 sao quốc tế. Trải nghiệm bữa sáng thượng hạng giữa
                  không gian kiến trúc tối giản và thanh lịch.
                </p>
                <div
                  class="d-flex gap-3 flex-wrap"
                  style="font-size: 0.78rem; color: #888"
                >
                  <span><i class="bi bi-people me-1"></i>120 chỗ ngồi</span>
                  <span><i class="bi bi-globe me-1"></i>Ẩm thực Quốc tế</span>
                  <span><i class="bi bi-suit-heart me-1"></i>Lãng mạn</span>
                </div>
              </div>
            </div>
          </div>
          <div class="col-lg-7">
            <div class="row g-4">
              <div class="col-sm-6">
                <div
                  class="card border-0 rounded-4 overflow-hidden shadow-sm h-100"
                >
                  <div class="overflow-hidden">
                    <img
                      src="https://images.unsplash.com/photo-1572116469696-31de0f17cc34?w=500&q=80"
                      class="w-100 object-fit-cover"
                      style="height: 180px; transition: transform 0.5s"
                      onmouseover="this.style.transform = 'scale(1.04)'"
                      onmouseout="this.style.transform = 'scale(1)'"
                    />
                  </div>
                  <div class="card-body p-3">
                    <span
                      class="badge rounded-pill mb-2"
                      style="
                        background: rgba(26, 107, 90, 0.1);
                        color: var(--primary);
                        font-size: 0.65rem;
                      "
                      >COCKTAIL BAR</span
                    >
                    <h6 class="font-display fw-normal mb-1">Jade Lounge</h6>
                    <p
                      class="text-muted mb-2"
                      style="font-size: 0.78rem; line-height: 1.6"
                    >
                      Hơn 200 loại cocktail thủ công và whisky nhập khẩu. Nhạc
                      live mỗi tối thứ 6 – thứ 7.
                    </p>
                    <div style="font-size: 0.72rem; color: #aaa">
                      <i class="bi bi-clock me-1"></i>17:00 – 02:00
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-sm-6">
                <div
                  class="card border-0 rounded-4 overflow-hidden shadow-sm h-100"
                >
                  <div class="overflow-hidden">
                    <img
                      src="https://images.unsplash.com/photo-1559329007-40df8a9345d8?w=500&q=80"
                      class="w-100 object-fit-cover"
                      style="height: 180px; transition: transform 0.5s"
                      onmouseover="this.style.transform = 'scale(1.04)'"
                      onmouseout="this.style.transform = 'scale(1)'"
                    />
                  </div>
                  <div class="card-body p-3">
                    <span
                      class="badge rounded-pill mb-2"
                      style="
                        background: rgba(212, 168, 71, 0.15);
                        color: #a07820;
                        font-size: 0.65rem;
                      "
                      >ROOFTOP</span
                    >
                    <h6 class="font-display fw-normal mb-1">Sky 15 Bar</h6>
                    <p
                      class="text-muted mb-2"
                      style="font-size: 0.78rem; line-height: 1.6"
                    >
                      Tận hưởng ly Signature Cocktail trong không gian âm nhạc
                      Chill-out. Tầm nhìn panorama vô cực ôm trọn nhịp sống
                      thịnh vượng của Cần Thơ hiện đại.
                    </p>
                    <div style="font-size: 0.72rem; color: #aaa">
                      <i class="bi bi-clock me-1"></i>16:00 – 00:00
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-12">
                <div
                  class="rounded-4 d-flex align-items-center gap-4 p-3"
                  style="
                    background: linear-gradient(
                      90deg,
                      var(--primary-dark),
                      var(--primary)
                    );
                  "
                >
                  <div
                    class="amenity-icon flex-shrink-0"
                    style="background: rgba(255, 255, 255, 0.15); color: #fff"
                  >
                    <i class="bi bi-cup-straw"></i>
                  </div>
                  <div class="flex-grow-1">
                    <div class="text-white fw-500" style="font-size: 0.88rem">
                      Afternoon Tea
                    </div>
                    <div class="text-white-50" style="font-size: 0.78rem">
                      Thứ 7 & Chủ nhật · 14:00 – 17:00 · Tại The Verdant Kitchen
                    </div>
                  </div>
                  <a
                    href="#booking"
                    class="btn btn-sm rounded-pill px-3 text-dark flex-shrink-0"
                    style="
                      background: var(--accent);
                      font-size: 0.75rem;
                      white-space: nowrap;
                    "
                    >Đặt bàn</a
                  >
                </div>
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
              <img src="https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&q=80" class="w-100 h-100 object-fit-cover" alt="Lobby" />
            </div>
          </div>
          <div class="col-md-3">
            <div class="gallery-item mb-3" style="height: 152px">
              <img src="https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&q=80" class="w-100 h-100 object-fit-cover" alt="Pool" />
            </div>
            <div class="gallery-item" style="height: 152px">
              <img src="https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&q=80" class="w-100 h-100 object-fit-cover" alt="Restaurant" />
            </div>
          </div>
          <div class="col-md-3">
            <div class="gallery-item mb-3" style="height: 152px">
              <img src="https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=400&q=80" class="w-100 h-100 object-fit-cover" alt="Spa" />
            </div>
            <div class="gallery-item" style="height: 152px">
              <img src="https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&q=80" class="w-100 h-100 object-fit-cover" alt="River view" />
            </div>
          </div>
          <div class="col-md-3">
            <div class="gallery-item" style="height: 200px">
              <img src="https://images.unsplash.com/photo-1590490360182-c33d57733427?w=400&q=80" class="w-100 h-100 object-fit-cover" alt="Room" />
            </div>
          </div>
          <div class="col-md-3">
            <div class="gallery-item" style="height: 200px">
              <img src="https://images.unsplash.com/photo-1559329007-40df8a9345d8?w=400&q=80" class="w-100 h-100 object-fit-cover" alt="Bar" />
            </div>
          </div>
          <div class="col-md-3">
            <div class="gallery-item" style="height: 200px">
              <img src="https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&q=80" class="w-100 h-100 object-fit-cover" alt="Suite" />
            </div>
          </div>
          <div class="col-md-3">
            <div class="gallery-item" style="height: 200px">
              <img src="https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400&q=80" class="w-100 h-100 object-fit-cover" alt="Deluxe" />
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ═══ SPECIAL OFFERS ═══ -->
    <section id="offers" style="padding: 5rem 0; background: var(--light-bg)">
      <div class="container">
        <div class="row align-items-end mb-5">
          <div class="col">
            <p class="section-tag">Ưu đãi</p>
            <h2
              class="font-display fw-normal mt-1"
              style="font-size: clamp(1.8rem, 3vw, 2.8rem)"
            >
              Gói đặc biệt
            </h2>
            <div class="divider mt-2"></div>
          </div>
        </div>
        <div class="row g-4">
          <div class="col-md-4">
            <div
              class="offer-card card border-0 rounded-4 overflow-hidden shadow-sm h-100"
            >
              <div class="overflow-hidden position-relative">
                <img
                  src="https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=600&q=80"
                  class="offer-img w-100"
                  alt="Early Bird"
                />
                <span class="offer-badge">Giảm 20%</span>
              </div>
              <div class="card-body p-4">
                <h5 class="font-display fw-normal mb-2">
                  Đặt sớm — Early Bird
                </h5>
                <p
                  class="text-muted mb-3"
                  style="font-size: 0.85rem; line-height: 1.7"
                >
                  Đặt phòng trước 7 ngày nhận ngay ưu đãi 20%, bao gồm bữa sáng
                  miễn phí và check-in sớm từ 11:00.
                </p>
                <ul class="list-unstyled mb-3" style="font-size: 0.82rem">
                  <li class="mb-1">
                    <i class="bi bi-check2 me-2 text-success"></i>Bữa sáng
                    buffet cho 2 người
                  </li>
                  <li class="mb-1">
                    <i class="bi bi-check2 me-2 text-success"></i>Check-in sớm
                    11:00
                  </li>
                  <li class="mb-1">
                    <i class="bi bi-check2 me-2 text-success"></i>Huỷ miễn phí
                    trước 48h
                  </li>
                </ul>
                <a
                  href="#booking"
                  class="btn rounded-pill px-4 text-white w-100"
                  style="background: var(--primary); font-size: 0.82rem"
                  >Đặt gói này</a
                >
              </div>
            </div>
          </div>
          <div class="col-md-4">
            <div
              class="offer-card card border-0 rounded-4 overflow-hidden shadow-sm h-100"
            >
              <div class="overflow-hidden position-relative">
                <img
                  src="https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=600&q=80"
                  class="offer-img w-100"
                  alt="Spa Package"
                />
                <span class="offer-badge">Gói mới</span>
              </div>
              <div class="card-body p-4">
                <h5 class="font-display fw-normal mb-2">Gói Spa & Relax</h5>
                <p
                  class="text-muted mb-3"
                  style="font-size: 0.85rem; line-height: 1.7"
                >
                  2 đêm lưu trú kèm 2 buổi spa thư giãn cao cấp. Chăm sóc sức
                  khoẻ toàn diện trong từng khoảnh khắc.
                </p>
                <ul class="list-unstyled mb-3" style="font-size: 0.82rem">
                  <li class="mb-1">
                    <i class="bi bi-check2 me-2 text-success"></i>2 buổi spa 90
                    phút / người
                  </li>
                  <li class="mb-1">
                    <i class="bi bi-check2 me-2 text-success"></i>Trà chiều tại
                    Jade Lounge
                  </li>
                  <li class="mb-1">
                    <i class="bi bi-check2 me-2 text-success"></i>Welcome
                    amenities
                  </li>
                </ul>
                <a
                  href="#booking"
                  class="btn rounded-pill px-4 text-white w-100"
                  style="background: var(--primary); font-size: 0.82rem"
                  >Đặt gói này</a
                >
              </div>
            </div>
          </div>
          <div class="col-md-4">
            <div
              class="offer-card card border-0 rounded-4 overflow-hidden shadow-sm h-100"
            >
              <div class="overflow-hidden position-relative">
                <img
                  src="https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600&q=80"
                  class="offer-img w-100"
                  alt="Romance"
                />
                <span class="offer-badge">Phổ biến</span>
              </div>
              <div class="card-body p-4">
                <h5 class="font-display fw-normal mb-2">Gói Lãng Mạn</h5>
                <p
                  class="text-muted mb-3"
                  style="font-size: 0.85rem; line-height: 1.7"
                >
                  Dành cho các cặp đôi — bữa tối candlelight, champagne phòng và
                  hoa tươi đón khách.
                </p>
                <ul class="list-unstyled mb-3" style="font-size: 0.82rem">
                  <li class="mb-1">
                    <i class="bi bi-check2 me-2 text-success"></i>Bữa tối set
                    menu cho 2 người
                  </li>
                  <li class="mb-1">
                    <i class="bi bi-check2 me-2 text-success"></i>Champagne &
                    hoa tươi phòng
                  </li>
                  <li class="mb-1">
                    <i class="bi bi-check2 me-2 text-success"></i>Late check-out
                    14:00
                  </li>
                </ul>
                <a
                  href="#booking"
                  class="btn rounded-pill px-4 text-white w-100"
                  style="background: var(--primary); font-size: 0.82rem"
                  >Đặt gói này</a
                >
              </div>
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
                  src="https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500&q=80"
                  class="w-100 rounded-4 object-fit-cover"
                  style="height: 230px"
                  alt="Pool"
                />
              </div>
              <div class="col-6 pt-4">
                <img
                  src="https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=500&q=80"
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
            <div
              class="rounded-4 overflow-hidden shadow-sm position-relative"
              style="height: 380px"
            >
              <img
                src="https://images.unsplash.com/photo-1508780709619-79562169bc64?w=900&q=60"
                class="w-100 h-100 object-fit-cover"
                style="opacity: 0.4"
                alt="HCMC"
              />
              <div
                style="
                  position: absolute;
                  top: 50%;
                  left: 50%;
                  transform: translate(-50%, -60%);
                "
              >
                <div class="d-flex flex-column align-items-center">
                  <div
                    class="rounded-circle d-flex align-items-center justify-content-center text-white shadow"
                    style="
                      width: 52px;
                      height: 52px;
                      background: var(--primary);
                      font-size: 1.3rem;
                    "
                  >
                    <i class="bi bi-building"></i>
                  </div>
                  <div
                    class="rounded-3 bg-white shadow mt-2 px-3 py-2 text-center"
                    style="font-size: 0.75rem; min-width: 140px"
                  >
                    <div class="fw-500">OmniStay Hotel</div>
                    <div class="text-muted" style="font-size: 0.7rem">
                      12 Lê Lợi, Quận 1
                    </div>
                  </div>
                </div>
              </div>
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

    <!-- ═══ REVIEWS ═══ -->
    <section id="reviews" class="py-5">
      <div class="container py-4">
        <div class="text-center mb-5">
          <p class="section-tag">Khách hàng nói gì</p>
          <h2
            class="font-display fw-normal mt-1"
            style="font-size: clamp(1.8rem, 3vw, 2.8rem)"
          >
            Đánh giá thực tế
          </h2>
          <div class="divider mx-auto mt-2"></div>
        </div>
        <div class="row g-4">
          <%
            if(conn != null){
              try {
                String reviewSql = "SELECT r.*, g.full_name FROM reviews r JOIN guests g ON r.guest_id = g.id WHERE r.status = 1 ORDER BY r.created_at DESC LIMIT 3";
                PreparedStatement psReview = conn.prepareStatement(reviewSql);
                ResultSet rsReview = psReview.executeQuery();
                
                String[] avatars = {"NT", "TM", "PH", "LK", "HA"};
                String[] bgColors = {"var(--primary)", "var(--accent)", "#6c757d", "#1a6b5a", "#d4a847"};
                int revIdx = 0;
                
                boolean hasDbReviews = false;
                while(rsReview.next()){
                  hasDbReviews = true;
                  String guestName = rsReview.getString("full_name");
                  String comment = rsReview.getString("comment");
                  int rating = rsReview.getInt("rating");
                  Timestamp createdAt = rsReview.getTimestamp("created_at");
                  String initial = guestName.substring(0, 1).toUpperCase() + (guestName.contains(" ") ? guestName.split(" ")[guestName.split(" ").length-1].substring(0,1).toUpperCase() : "");
                  
                  // Simple platform tags for variety
                  String[] platforms = {"Booking.com", "TripAdvisor", "Google", "Agoda"};
                  String platform = platforms[revIdx % platforms.length];
          %>
          <div class="col-md-4">
            <div class="review-card bg-white rounded-4 p-4 shadow-sm h-100">
              <div class="d-flex align-items-center gap-2 mb-3">
                <span class="star">
                  <% for(int i=0; i<5; i++) { %>
                    <%= (i < rating) ? "★" : "☆" %>
                  <% } %>
                </span>
                <span
                  class="badge rounded-pill"
                  style="
                    background: rgba(26, 107, 90, 0.08);
                    color: var(--primary);
                    font-size: 0.62rem;
                  "
                  ><%= platform %></span
                >
              </div>
              <p
                class="mb-3"
                style="font-size: 0.88rem; line-height: 1.75; color: #444"
              >
                "<%= comment %>"
              </p>
              <div class="d-flex align-items-center gap-3">
                <div
                  class="rounded-circle d-flex align-items-center justify-content-center text-white fw-500"
                  style="
                    width: 40px;
                    height: 40px;
                    background: <%= bgColors[revIdx % bgColors.length] %>;
                    font-size: 0.85rem;
                    flex-shrink: 0;
                  "
                >
                  <%= initial %>
                </div>
                <div>
                  <div class="fw-500" style="font-size: 0.85rem">
                    <%= guestName %>
                  </div>
                  <div class="text-muted" style="font-size: 0.75rem">
                    Đã ở · <%= new java.text.SimpleDateFormat("MM/yyyy").format(createdAt) %>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <%
                  revIdx++;
                }
                rsReview.close();
                psReview.close();
                
                if(!hasDbReviews) {
                  // Fallback to static if no reviews in DB (though we saw some in SQL)
                  out.println("<div class='col-12 text-center py-4'><p class='text-muted'>Đang cập nhật những đánh giá mới nhất...</p></div>");
                }
              } catch(Exception e) {
                out.println("<div class='col-12 text-center text-danger'>Lỗi tải đánh giá: " + e.getMessage() + "</div>");
              }
            }
          %>
        </div>
        <!-- Rating breakdown -->
        <div class="row justify-content-center mt-5">
          <div class="col-lg-8">
            <div class="bg-white rounded-4 p-4 shadow-sm">
              <div class="row align-items-center g-4">
                <div
                  class="col-md-3 text-center"
                  style="border-right: 1px solid var(--border)"
                >
                  <div
                    class="font-display"
                    style="
                      font-size: 3.5rem;
                      color: var(--primary);
                      line-height: 1;
                    "
                  >
                    4.9
                  </div>
                  <div class="star fs-5 mb-1">★★★★★</div>
                  <div class="text-muted" style="font-size: 0.72rem">
                    2.400+ đánh giá
                  </div>
                </div>
                <div class="col-md-9">
                  <div class="row g-2">
                    <div class="col-12 d-flex align-items-center gap-3">
                      <span style="font-size: 0.78rem; min-width: 80px"
                        >Dịch vụ</span
                      >
                      <div class="progress flex-grow-1" style="height: 6px">
                        <div
                          class="progress-bar"
                          style="width: 98%; background: var(--primary)"
                        ></div>
                      </div>
                      <span
                        style="
                          font-size: 0.78rem;
                          color: var(--primary);
                          min-width: 26px;
                        "
                        >4.9</span
                      >
                    </div>
                    <div class="col-12 d-flex align-items-center gap-3">
                      <span style="font-size: 0.78rem; min-width: 80px"
                        >Phòng nghỉ</span
                      >
                      <div class="progress flex-grow-1" style="height: 6px">
                        <div
                          class="progress-bar"
                          style="width: 96%; background: var(--primary)"
                        ></div>
                      </div>
                      <span
                        style="
                          font-size: 0.78rem;
                          color: var(--primary);
                          min-width: 26px;
                        "
                        >4.8</span
                      >
                    </div>
                    <div class="col-12 d-flex align-items-center gap-3">
                      <span style="font-size: 0.78rem; min-width: 80px"
                        >Vị trí</span
                      >
                      <div class="progress flex-grow-1" style="height: 6px">
                        <div
                          class="progress-bar"
                          style="width: 100%; background: var(--primary)"
                        ></div>
                      </div>
                      <span
                        style="
                          font-size: 0.78rem;
                          color: var(--primary);
                          min-width: 26px;
                        "
                        >5.0</span
                      >
                    </div>
                    <div class="col-12 d-flex align-items-center gap-3">
                      <span style="font-size: 0.78rem; min-width: 80px"
                        >Ẩm thực</span
                      >
                      <div class="progress flex-grow-1" style="height: 6px">
                        <div
                          class="progress-bar"
                          style="width: 94%; background: var(--primary)"
                        ></div>
                      </div>
                      <span
                        style="
                          font-size: 0.78rem;
                          color: var(--primary);
                          min-width: 26px;
                        "
                        >4.7</span
                      >
                    </div>
                    <div class="col-12 d-flex align-items-center gap-3">
                      <span style="font-size: 0.78rem; min-width: 80px"
                        >Sạch sẽ</span
                      >
                      <div class="progress flex-grow-1" style="height: 6px">
                        <div
                          class="progress-bar"
                          style="width: 98%; background: var(--primary)"
                        ></div>
                      </div>
                      <span
                        style="
                          font-size: 0.78rem;
                          color: var(--primary);
                          min-width: 26px;
                        "
                        >4.9</span
                      >
                    </div>
                  </div>
                  <div class="mt-3 text-muted" style="font-size: 0.75rem">
                    <i
                      class="bi bi-patch-check-fill me-1"
                      style="color: var(--accent)"
                    ></i>
                    Tổng hợp từ Google · Booking.com · TripAdvisor · Agoda
                  </div>
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
        ), url('https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=1400&q=80') center/cover no-repeat;
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
      // Navbar scroll
      window.addEventListener("scroll", function () {
        const navbar = document.querySelector(".navbar");
        if (navbar) {
          navbar.classList.toggle("navbar-scrolled", window.scrollY > 50);
        }
      });

      // Scroll-triggered fade-in animations
      const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            entry.target.classList.add('visible');
          }
        });
      }, { threshold: 0.1, rootMargin: '0px 0px -50px 0px' });

      document.querySelectorAll('.amenity-card, .review-card, .offer-card, .gallery-item, .dept-card').forEach(el => {
        el.classList.add('animate-fade-in');
        observer.observe(el);
      });

      // Auto nights counter
      const ci = document.getElementById("checkin");
      const co = document.getElementById("checkout");
      const nd = document.getElementById("nightsDisplay");
      if (ci && co && nd) {
        function updateNights() {
          const diff = Math.round(
            (new Date(co.value) - new Date(ci.value)) / 86400000,
          );
          if (diff > 0) nd.textContent = diff;
        }
        ci.addEventListener("change", updateNights);
        co.addEventListener("change", updateNights);
      }
    </script>
    <% if(conn != null) try { conn.close(); } catch(Exception e) {} %>
  </body>
</html>
