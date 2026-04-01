<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Lấy tên trang hiện tại để xử lý tự động bôi vàng menu (active)
    String currentAdminURL = request.getRequestURI();
    if (currentAdminURL == null) currentAdminURL = "";
%>

<aside class="sidebar d-flex flex-column">
    <div class="brand font-display text-white">
        Omni<span>Stay</span>
        <div style="font-size: 0.65rem; font-family: 'Outfit'; letter-spacing: 0.2em; color: rgba(255,255,255,0.5); text-transform: uppercase; margin-top: 4px;">Quản trị viên</div>
    </div>
    
    <ul class="nav flex-column nav-sidebar flex-grow-1">
        <li class="nav-item">
            <a class="nav-link <%= currentAdminURL.endsWith("admin-dashboard.jsp") ? "active" : "" %>" href="dashboard.jsp">
                <i class="bi bi-grid"></i> Tổng quan
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link <%= currentAdminURL.endsWith("admin-rooms.jsp") ? "active" : "" %>" href="admin-rooms.jsp">
                <i class="bi bi-door-open"></i> Quản lý Phòng
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link <%= currentAdminURL.endsWith("admin-bookings.jsp") ? "active" : "" %>" href="admin-bookings.jsp">
                <i class="bi bi-calendar-check"></i> Đơn đặt phòng
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link <%= currentAdminURL.endsWith("admin-guests.jsp") ? "active" : "" %>" href="admin-guests.jsp">
                <i class="bi bi-people"></i> Khách hàng
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link <%= currentAdminURL.endsWith("admin-services.jsp") ? "active" : "" %>" href="admin-services.jsp">
                <i class="bi bi-cup-hot"></i> Dịch vụ thêm
            </a>
        </li>
    </ul>

    <div class="mt-auto mb-4 px-3">
        <a href="logout.jsp" class="btn w-100 text-white" style="background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.2); border-radius: 10px;">
            <i class="bi bi-box-arrow-left me-2"></i> Đăng xuất
        </a>
    </div>
</aside>