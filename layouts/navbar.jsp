<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<style>
  /* 1. Base Navbar - Xóa hẳn style inline */
  .navbar-custom {
    transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    padding: 1.2rem 0;
    background-color: transparent;
  }

  /* 2. Trạng thái Scrolled - Màu xanh ngọc sâu, mờ ảo như kính */
  .navbar-custom.navbar-scrolled {
    background-color: rgba(26, 107, 90, 0.95); /* Xanh primary mờ */
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
    padding: 0.6rem 0;
  }

  /* 3. Link Menu - Tinh tế, rõ ràng */
  .nav-link-custom {
    font-size: 0.75rem;
    letter-spacing: 0.15em;
    font-weight: 500;
    text-transform: uppercase;
    color: rgba(255, 255, 255, 0.75) !important;
    transition: all 0.3s ease;
    position: relative;
    padding: 0.5rem 1.2rem !important;
  }

  /* Hiệu ứng gạch chân phát sáng (Glow) */
  .nav-link-custom::after {
    content: "";
    position: absolute;
    bottom: 0;
    left: 50%;
    width: 0;
    height: 2px;
    background: var(--accent, #d4a847);
    transition:
      width 0.3s ease,
      transform 0.3s ease;
    transform: translateX(-50%);
    border-radius: 2px;
    box-shadow: 0 0 10px rgba(212, 168, 71, 0.8); /* Glow vàng kim */
  }

  .nav-link-custom:hover::after,
  .nav-link-custom.active::after {
    width: 1.5rem;
  }

  .nav-link-custom:hover,
  .nav-link-custom.active {
    color: #ffffff !important;
    text-shadow: 0 0 12px rgba(255, 255, 255, 0.5); /* Chữ cũng phát sáng nhẹ */
  }

  /* 4. Nút Đặt phòng CTA (Call To Action) - Điểm nhấn "sặc sỡ" một cách có gu */
  .btn-booking {
    background: var(--accent, #d4a847);
    color: #111 !important;
    font-size: 0.85rem;
    font-weight: 600;
    padding: 0.6rem 1.8rem;
    border: none;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    box-shadow: 0 4px 15px rgba(212, 168, 71, 0.3);
  }

  .btn-booking:hover {
    background: #f0c356;
    transform: translateY(-2px) scale(1.02);
    box-shadow: 0 8px 25px rgba(212, 168, 71, 0.6); /* Nổi bật lên khi rê chuột vào */
  }
</style>

<nav class="navbar navbar-expand-lg fixed-top navbar-custom" id="mainNav">
  <div class="container">
    <a
      class="navbar-brand font-display fs-4 fw-normal text-white"
      href="index.jsp"
    >
      Omni<span
        style="
          color: var(--accent, #d4a847);
          font-weight: 600;
          text-shadow: 0 0 8px rgba(212, 168, 71, 0.5);
        "
        >Stay</span
      >
    </a>

    <button
      class="navbar-toggler border-0 shadow-none"
      type="button"
      data-bs-toggle="collapse"
      data-bs-target="#navMenu"
    >
      <i class="bi bi-list text-white fs-2"></i>
    </button>

    <div class="collapse navbar-collapse" id="navMenu">
      <ul class="navbar-nav mx-auto gap-2">
        <li class="nav-item">
          <a class="nav-link nav-link-custom active" href="index.jsp"
            >Trang chủ</a
          >
        </li>
        <li class="nav-item">
          <a class="nav-link nav-link-custom" href="./pages/rooms.jsp">Phòng</a>
        </li>
        <li class="nav-item">
          <a class="nav-link nav-link-custom" href="#amenities">Tiện ích</a>
        </li>
        <li class="nav-item">
          <a class="nav-link nav-link-custom" href="#reviews">Đánh giá</a>
        </li>
        <li class="nav-item">
          <a class="nav-link nav-link-custom" href="contact.jsp">Liên hệ</a>
        </li>
      </ul>

      <a href="./pages/rooms.jsp" class="btn btn-booking rounded-pill">
        Đặt phòng
      </a>
    </div>
  </div>
</nav>

<script>
  // Script chuẩn: Chỉ quan tâm đến Class, thả cho CSS lo phần hiển thị
  document.addEventListener("DOMContentLoaded", () => {
    const nav = document.getElementById("mainNav");

    window.addEventListener("scroll", () => {
      if (window.scrollY > 60) {
        nav.classList.add("navbar-scrolled");
      } else {
        nav.classList.remove("navbar-scrolled");
      }
    });
  });
</script>
