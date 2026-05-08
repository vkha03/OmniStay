<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String currentAdminURL = request.getRequestURI();
    if (currentAdminURL == null) currentAdminURL = "";
%>

<aside class="sidebar d-flex flex-column">
    <div class="brand font-display text-white">
       <a href="<%=request.getContextPath()%>/index.jsp" class="text-decoration-none text-white">Omni<span>Stay</span></a>  
        <div style="font-size: 0.65rem; font-family: 'Outfit'; letter-spacing: 0.2em; color: rgba(255,255,255,0.5); text-transform: uppercase; margin-top: 4px;">Quản trị viên</div>
    </div>
    
    <ul class="nav flex-column nav-sidebar flex-grow-1">
        <li class="nav-item">
            <a class="nav-link <%= currentAdminURL.contains("admin-pages/index.jsp") ? "active" : "" %>" href="<%=request.getContextPath()%>/admin-pages/index.jsp">
                <i class="bi bi-grid"></i> Tổng quan
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link <%= currentAdminURL.contains("admin-rooms.jsp") ? "active" : "" %>" href="<%=request.getContextPath()%>/admin-pages/admin-rooms.jsp">
                <i class="bi bi-door-open"></i> Quản lý Phòng
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link <%= currentAdminURL.contains("admin-bookings.jsp") ? "active" : "" %>" href="<%=request.getContextPath()%>/admin-pages/admin-bookings.jsp">
                <i class="bi bi-calendar-check"></i> Đơn đặt phòng
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link <%= currentAdminURL.contains("admin-guests.jsp") ? "active" : "" %>" href="<%=request.getContextPath()%>/admin-pages/admin-guests.jsp">
                <i class="bi bi-people"></i> Khách hàng
            </a>
        </li>
          <li class="nav-item">
            <a class="nav-link <%= currentAdminURL.contains("admin-staff.jsp") ? "active" : "" %>" href="<%=request.getContextPath()%>/admin-pages/admin-staff.jsp">
                <i class="bi bi-person-circle"></i></i> Quản Lý Nhân Viên
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link <%= currentAdminURL.contains("admin-services.jsp") ? "active" : "" %>" href="<%=request.getContextPath()%>/admin-pages/admin-services.jsp">
                <i class="bi bi-cup-hot"></i> Dịch vụ thêm
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link <%= currentAdminURL.contains("admin-contacts.jsp") ? "active" : "" %>" href="<%=request.getContextPath()%>/admin-pages/admin-contacts.jsp">
                <i class="bi bi-envelope-paper"></i> Quản lý liên hệ
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link <%= currentAdminURL.contains("admin-reviews.jsp") ? "active" : "" %>" href="<%=request.getContextPath()%>/admin-pages/admin-reviews.jsp">
                <i class="bi bi-star"></i> Đánh giá khách hàng
            </a>
        </li>
    </ul>

    <div class="mt-auto mb-4 px-3">
        <a href="<%=request.getContextPath()%>/index.jsp" class="btn w-100 text-white" style="background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.2); border-radius: 10px;">
            <i class="bi bi-arrow-left me-2"></i> Về trang chủ
        </a>
    </div>
</aside>
