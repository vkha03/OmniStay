<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<style>
  /* 1. Base Footer */
  .footer-custom {
    background-color: #111;
    color: rgba(255, 255, 255, 0.6);
  }

  /* 2. Brand & Text */
  .footer-brand {
    text-shadow: 0 0 8px rgba(212, 168, 71, 0.3);
  }
  .footer-desc {
    font-size: 0.85rem;
    line-height: 1.8;
    max-width: 280px;
  }

  /* 3. Social Icons - Hiệu ứng nảy lên và phát sáng vàng */
  .social-icon {
    width: 38px;
    height: 38px;
    background: rgba(255, 255, 255, 0.05);
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    font-size: 0.95rem;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    text-decoration: none;
  }
  .social-icon:hover {
    background: var(--accent, #d4a847);
    color: #111;
    transform: translateY(-4px);
    box-shadow: 0 6px 15px rgba(212, 168, 71, 0.4);
  }

  /* 4. Footer Links - Hiệu ứng trượt sang phải khi hover */
  .footer-title {
    font-size: 0.7rem;
    letter-spacing: 0.18em;
    font-weight: 600;
    color: #fff;
    text-transform: uppercase;
  }
  .footer-link {
    color: rgba(255, 255, 255, 0.5);
    text-decoration: none;
    font-size: 0.85rem;
    transition: all 0.3s ease;
    display: inline-block;
  }
  .footer-link:hover {
    color: var(--accent, #d4a847);
    transform: translateX(6px); /* Trượt nhẹ sang phải */
    text-shadow: 0 0 8px rgba(212, 168, 71, 0.4);
  }

  /* 5. Khung Đăng ký Email */
  .subscribe-input {
    background: rgba(255, 255, 255, 0.05) !important;
    border: 1px solid rgba(255, 255, 255, 0.1) !important;
    color: #fff !important;
    font-size: 0.85rem;
    box-shadow: none !important;
    transition: all 0.3s ease;
  }
  .subscribe-input:focus {
    border-color: var(--accent, #d4a847) !important;
    background: rgba(255, 255, 255, 0.08) !important;
  }
  .subscribe-input::placeholder {
    color: rgba(255, 255, 255, 0.3);
  }
  .btn-subscribe {
    background: var(--accent, #d4a847);
    color: #111;
    font-weight: 600;
    font-size: 0.85rem;
    padding: 0.5rem 1.2rem;
    border: none;
    transition: all 0.3s ease;
  }
  .btn-subscribe:hover {
    background: #f0c356;
    box-shadow: 0 0 15px rgba(212, 168, 71, 0.5);
  }
</style>

<footer class="py-5 footer-custom">
  <div class="container mt-3">
    <div class="row g-4 mb-5">
      <div class="col-lg-4">
        <div class="font-display fs-3 fw-bold text-white mb-3 footer-brand d-flex align-items-center gap-2">
          <img src="<%=request.getContextPath()%>/images/logo.png" alt="Logo" style="height: 40px; border-radius: 6px;" />
          <div>Omni<span style="color: var(--accent, #d4a847)">Stay</span></div>
        </div>
        <p class="footer-desc mb-4">
          Khách sạn 5 sao tại trung tâm TP. Cần Thơ — nơi nghỉ dưỡng lý tưởng
          cho cả du khách và doanh nhân.
        </p>
        <div class="d-flex gap-2">
          <a href="#" class="social-icon"><i class="bi bi-facebook"></i></a>
          <a href="#" class="social-icon"><i class="bi bi-instagram"></i></a>
          <a href="#" class="social-icon"><i class="bi bi-twitter-x"></i></a>
          <a href="#" class="social-icon"><i class="bi bi-youtube"></i></a>
        </div>
      </div>

      <div class="col-6 col-lg-2 offset-lg-1">
        <div class="footer-title mb-4">Khách sạn</div>
        <div class="d-flex flex-column gap-3">
          <a href="<%=request.getContextPath()%>/pages/rooms.jsp" class="footer-link">Phòng nghỉ</a>
          <a href="#amenities" class="footer-link">Dịch vụ</a>
          <a href="#" class="footer-link">Ưu đãi</a>
          <a href="#reviews" class="footer-link">Đánh giá</a>
        </div>
      </div>

      <div class="col-6 col-lg-2">
        <div class="footer-title mb-4">Hỗ trợ</div>
        <div class="d-flex flex-column gap-3">
          <a href="#" class="footer-link">Câu hỏi thường gặp</a>
          <a href="<%=request.getContextPath()%>/pages/contact.jsp" class="footer-link">Liên hệ</a>
          <a href="#" class="footer-link">Chính sách bảo mật</a>
          <a href="#" class="footer-link">Điều khoản dịch vụ</a>
        </div>
      </div>

      <div class="col-lg-3">
        <div class="footer-title mb-4">Nhận ưu đãi</div>
        <p style="font-size: 0.82rem; color: rgba(255, 255, 255, 0.5)">
          Đăng ký nhận thông tin khuyến mãi độc quyền từ hệ thống của chúng tôi.
        </p>
        <div class="input-group mt-3">
          <input
            type="email"
            class="form-control rounded-start-2 subscribe-input"
            placeholder="Email của bạn"
          />
          <button class="btn rounded-end-2 btn-subscribe">Đăng ký</button>
        </div>
      </div>
    </div>

    <hr
      style="
        border-color: rgba(255, 255, 255, 0.1);
        margin-top: 3rem;
        margin-bottom: 1.5rem;
      "
    />
    <div
      class="d-flex justify-content-between flex-wrap gap-2 text-white-50"
      style="font-size: 0.8rem"
    >
      <span>&copy; 2026 OmniStay. All rights reserved.</span>
      <span>81-83 Hai Bà Trưng, Quận Ninh Kiều, TP. Cần Thơ</span>
    </div>
  </div>
</footer>


