<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String currentURI = request.getRequestURI();
    String activeNav = "index";
    if (currentURI.contains("rooms.jsp") || currentURI.contains("room-detail.jsp")) {
        activeNav = "rooms";
    } else if (currentURI.contains("contact.jsp")) {
        activeNav = "contact";
    }
%>
<style>
  /* 1. Base Navbar - Gradient tối nhẹ phía trên để nổi trên hình nền */
  .navbar-custom {
    transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    padding: 1.2rem 0;
    background: linear-gradient(180deg, rgba(0, 0, 0, 0.35) 0%, transparent 100%);
  }

  /* 2. Trạng thái Scrolled - Glassmorphism đậm, sắc nét */
  .navbar-custom.navbar-scrolled {
    background: rgba(15, 50, 42, 0.92);
    backdrop-filter: blur(20px) saturate(1.4);
    -webkit-backdrop-filter: blur(20px) saturate(1.4);
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2), 0 1px 0 rgba(255, 255, 255, 0.05) inset;
    padding: 0.6rem 0;
  }

  /* 3. Link Menu - Sáng hơn, có text-shadow để nổi trên mọi nền */
  .nav-link-custom {
    font-size: 0.75rem;
    letter-spacing: 0.15em;
    font-weight: 500;
    text-transform: uppercase;
    color: rgba(255, 255, 255, 0.9) !important;
    text-shadow: 0 1px 4px rgba(0, 0, 0, 0.5);
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
    box-shadow: 0 0 10px rgba(212, 168, 71, 0.8);
  }

  .nav-link-custom:hover::after,
  .nav-link-custom.active::after {
    width: 1.5rem;
  }

  .nav-link-custom:hover,
  .nav-link-custom.active {
    color: #ffffff !important;
    text-shadow: 0 0 14px rgba(255, 255, 255, 0.6), 0 1px 4px rgba(0, 0, 0, 0.4);
  }

  /* 4. Brand logo - Text shadow cho nổi bật */
  .navbar-brand {
    text-shadow: 0 2px 10px rgba(0, 0, 0, 0.35);
  }

  /* 5. Nút Đặt phòng CTA - Glow mạnh hơn */
  .btn-booking {
    background: var(--accent, #d4a847);
    color: #111 !important;
    font-size: 0.85rem;
    font-weight: 600;
    padding: 0.6rem 1.8rem;
    border: none;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    box-shadow: 0 4px 18px rgba(212, 168, 71, 0.4);
  }

  .btn-booking:hover {
    background: #f0c356;
    transform: translateY(-2px) scale(1.02);
    box-shadow: 0 8px 30px rgba(212, 168, 71, 0.65);
  }
</style>

<nav class="navbar navbar-expand-lg fixed-top navbar-custom" id="mainNav">
  <div class="container">
    <a
      class="navbar-brand font-display fs-4 fw-normal text-white"
      href="<%=request.getContextPath()%>/index.jsp"
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
          <a class="nav-link nav-link-custom <%= activeNav.equals("index") ? "active" : "" %>" href="<%=request.getContextPath()%>/index.jsp"
            >Trang chủ</a
          >
        </li>
        <li class="nav-item">
          <a class="nav-link nav-link-custom <%= activeNav.equals("rooms") ? "active" : "" %>" href="<%=request.getContextPath()%>/pages/rooms.jsp">Phòng</a>
        </li>
        <li class="nav-item">
          <a class="nav-link nav-link-custom" href="<%=request.getContextPath()%>/index.jsp#amenities">Tiện ích</a>
        </li>
        <li class="nav-item">
          <a class="nav-link nav-link-custom" href="<%=request.getContextPath()%>/index.jsp#reviews">Đánh giá</a>
        </li>
        <li class="nav-item">
          <a class="nav-link nav-link-custom <%= activeNav.equals("contact") ? "active" : "" %>" href="<%=request.getContextPath()%>/pages/contact.jsp">Liên hệ</a>
        </li>
      </ul>

      <a href="<%=request.getContextPath()%>/pages/rooms.jsp" class="btn btn-booking rounded-pill">
        Đặt phòng
      </a>
    </div>

    <!-- Admin Link moved to the far right -->
    <div class="ms-3 d-none d-lg-block">
      <a href="<%=request.getContextPath()%>/admin-pages/index.jsp" class="text-white-50 text-decoration-none d-flex align-items-center" style="font-size: 0.75rem; font-weight: 500; transition: color 0.3s;" onmouseover="this.style.color='#fff'" onmouseout="this.style.color='rgba(255,255,255,0.5)'">
        <i class="bi bi-shield-lock me-1"></i> Admin
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
