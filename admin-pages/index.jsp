<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../layouts/admin-auth.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    Connection conn = null;
    String dbError = null;
    
    // Thống kê
    int totalRooms = 0;
    int totalBookings = 0;
    int newContacts = 0;
    double totalRevenue = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/omnistay", "root", "");
        
        // Lấy tổng số phòng
        Statement st1 = conn.createStatement();
        ResultSet rs1 = st1.executeQuery("SELECT COUNT(*) FROM rooms");
        if(rs1.next()) totalRooms = rs1.getInt(1);
        rs1.close();
        st1.close();
        
        // Lấy số đặt phòng (chưa bao gồm trạng thái CANCELLED)
        Statement st2 = conn.createStatement();
        ResultSet rs2 = st2.executeQuery("SELECT COUNT(*) FROM bookings WHERE status != 'CANCELLED'");
        if(rs2.next()) totalBookings = rs2.getInt(1);
        rs2.close();
        st2.close();
        
        // Lấy doanh thu (COMPLETED)
        Statement st3 = conn.createStatement();
        ResultSet rs3 = st3.executeQuery("SELECT SUM(total_amount) FROM bookings WHERE status = 'COMPLETED'");
        if(rs3.next()) totalRevenue = rs3.getDouble(1);
        rs3.close();
        st3.close();
        
        // Lấy số liên hệ mới
        Statement st4 = conn.createStatement();
        ResultSet rs4 = st4.executeQuery("SELECT COUNT(*) FROM contacts WHERE status = 'UNREAD'");
        if(rs4.next()) newContacts = rs4.getInt(1);
        rs4.close();
        st4.close();
        
    } catch(Exception e) {
        dbError = e.getMessage();
    }
    
    NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản trị Hệ thống — OmniStay</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;1,400&family=Outfit:wght@300;400;500;600&display=swap" rel="stylesheet">
    
    <style>
        :root {
            --primary: #1a6b5a;
            --primary-dark: #124a3e;
            --accent: #d4a847;
            --bg-light: #f5f8f7;
            --text-main: #2c3e50;
        }
        body {
            font-family: 'Outfit', sans-serif;
            background-color: var(--bg-light);
            color: var(--text-main);
            overflow-x: hidden;
        }
        .font-display { font-family: "Playfair Display", serif; }
        
        /* Sidebar Styles */
        .sidebar {
            width: 260px;
            background: var(--primary-dark);
            min-height: 100vh;
            position: fixed;
            top: 0;
            left: 0;
            z-index: 1000;
            padding-top: 1.5rem;
            box-shadow: 4px 0 20px rgba(0,0,0,0.05);
        }
        .sidebar .brand {
            padding: 0 1.5rem 2rem;
            border-bottom: 1px solid rgba(255,255,255,0.05);
            margin-bottom: 1rem;
        }
        .sidebar .brand a {
            font-size: 1.6rem;
            letter-spacing: 1px;
        }
        .sidebar .brand span {
            color: var(--accent);
            font-weight: 600;
        }
        .nav-sidebar .nav-link {
            color: rgba(255,255,255,0.7);
            padding: 0.8rem 1.5rem;
            margin: 0.2rem 1rem;
            border-radius: 8px;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            font-weight: 400;
        }
        .nav-sidebar .nav-link i {
            margin-right: 12px;
            font-size: 1.1rem;
        }
        .nav-sidebar .nav-link:hover, .nav-sidebar .nav-link.active {
            color: #fff;
            background: rgba(255,255,255,0.1);
        }
        .nav-sidebar .nav-link.active {
            background: var(--primary);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        
        /* Main Content */
        .main-content {
            margin-left: 260px;
            padding: 2rem;
        }
        
        /* Dashboard Cards */
        .stat-card {
            background: #fff;
            border-radius: 16px;
            padding: 1.8rem;
            border: 1px solid rgba(0,0,0,0.05);
            box-shadow: 0 4px 15px rgba(0,0,0,0.02);
            transition: all 0.3s ease;
            height: 100%;
        }
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.05);
        }
        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }
        
        /* Table Styles */
        .table-card {
            background: #fff;
            border-radius: 16px;
            border: 1px solid rgba(0,0,0,0.05);
            box-shadow: 0 4px 15px rgba(0,0,0,0.02);
            overflow: hidden;
        }
        .table-custom th {
            background-color: #f8f9fa;
            color: #6c757d;
            font-weight: 500;
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 0.5px;
            padding: 1rem 1.5rem;
            border-bottom: 2px solid #edf2f9;
        }
        .table-custom td {
            padding: 1rem 1.5rem;
            vertical-align: middle;
            color: #495057;
            font-size: 0.9rem;
            border-bottom: 1px solid #edf2f9;
        }
        .table-custom tbody tr:hover {
            background-color: #f8f9fa;
        }
        .status-badge {
            padding: 0.4rem 0.8rem;
            border-radius: 50px;
            font-size: 0.75rem;
            font-weight: 500;
        }
    </style>
</head>
<body>

    <!-- SIDEBAR -->
    <%@ include file="../layouts/sidebar-admin.jsp" %>

    <!-- MAIN CONTENT -->
    <div class="main-content">
        <!-- Topbar -->
        <div class="d-flex justify-content-between align-items-center mb-4 pb-3 border-bottom">
            <div>
                <h3 class="font-display fw-bold text-dark mb-1">Tổng quan (Dashboard)</h3>
                <p class="text-muted mb-0" style="font-size: 0.85rem">Chào mừng trở lại, trang tổng quan hoạt động OmniStay.</p>
            </div>
            <div class="d-flex align-items-center gap-3">
                <div class="dropdown">
                    <button class="btn btn-light position-relative border-0 shadow-sm rounded-circle d-flex align-items-center justify-content-center" style="width: 40px; height: 40px;">
                        <i class="bi bi-bell"></i>
                        <% if(newContacts > 0) { %>
                        <span class="position-absolute top-0 start-100 translate-middle p-1 bg-danger border border-light rounded-circle">
                            <span class="visually-hidden">Tín hiệu mới</span>
                        </span>
                        <% } %>
                    </button>
                </div>
                <div class="d-flex align-items-center gap-2 px-3 py-2 bg-white rounded-pill shadow-sm border">
                    <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 32px; height: 32px; font-weight: 600;">
                        <%= (adminEmail != null && !adminEmail.isEmpty()) ? adminEmail.substring(0, 1).toUpperCase() : "A" %>
                    </div>
                    <span class="fw-500" style="font-size: 0.85rem;"><%= adminEmail %></span>
                </div>
            </div>
        </div>

        <% if (dbError != null) { %>
            <div class="alert alert-danger shadow-sm rounded-3">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> Lỗi kết nối CSDL: <%= dbError %>
            </div>
        <% } %>

        <!-- Statistics Cards -->
        <div class="row g-4 mb-5">
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <div class="stat-icon" style="background: rgba(26, 107, 90, 0.1); color: var(--primary);">
                            <i class="bi bi-door-open"></i>
                        </div>
                        <span class="badge bg-light text-success"><i class="bi bi-arrow-up me-1"></i>Hoạt động</span>
                    </div>
                    <p class="text-muted mb-1 text-uppercase fw-500" style="font-size: 0.75rem;">Tổng số Phòng</p>
                    <h3 class="fw-bold mb-0 text-dark"><%= totalRooms %></h3>
                </div>
            </div>
            
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <div class="stat-icon" style="background: rgba(212, 168, 71, 0.15); color: #b08d3a;">
                            <i class="bi bi-calendar-check"></i>
                        </div>
                        <span class="badge bg-light text-muted">Tháng này</span>
                    </div>
                    <p class="text-muted mb-1 text-uppercase fw-500" style="font-size: 0.75rem;">Đơn đặt phòng</p>
                    <h3 class="fw-bold mb-0 text-dark"><%= totalBookings %></h3>
                </div>
            </div>
            
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <div class="stat-icon" style="background: rgba(13, 110, 253, 0.1); color: #0d6efd;">
                            <i class="bi bi-cash-coin"></i>
                        </div>
                        <span class="badge bg-light text-success"><i class="bi bi-graph-up-arrow"></i></span>
                    </div>
                    <p class="text-muted mb-1 text-uppercase fw-500" style="font-size: 0.75rem;">Doanh thu (VNĐ)</p>
                    <h4 class="fw-bold mb-0 text-dark" style="letter-spacing: -0.5px;"><%= nf.format(totalRevenue).replace("VNĐ","") %></h4>
                </div>
            </div>
            
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <div class="stat-icon" style="background: rgba(220, 53, 69, 0.1); color: #dc3545;">
                            <i class="bi bi-envelope"></i>
                        </div>
                        <% if(newContacts > 0) { %>
                        <span class="badge bg-danger rounded-pill"><%= newContacts %> mới</span>
                        <% } else { %>
                        <span class="badge bg-light text-muted rounded-pill">Không có</span>
                        <% } %>
                    </div>
                    <p class="text-muted mb-1 text-uppercase fw-500" style="font-size: 0.75rem;">Yêu cầu liên hệ</p>
                    <h3 class="fw-bold mb-0 text-dark"><%= newContacts %></h3>
                </div>
            </div>
        </div>

        <!-- Recent Bookings Table -->
        <div class="table-card">
            <div class="d-flex justify-content-between align-items-center p-4 border-bottom">
                <h5 class="fw-bold mb-0 text-dark">Đặt phòng gần đây</h5>
                <a href="admin-bookings.jsp" class="btn btn-sm btn-outline-secondary rounded-pill px-3">Xem tất cả</a>
            </div>
            <div class="table-responsive">
                <table class="table table-custom table-hover mb-0">
                    <thead>
                        <tr>
                            <th>Mã đơn</th>
                            <th>Khách hàng</th>
                            <th>Ngày Check-in</th>
                            <th>Ngày Check-out</th>
                            <th>Tổng tiền</th>
                            <th>Trạng thái</th>
                            <th class="text-end">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if(conn != null) {
                                try {
                                    String sql = "SELECT b.*, g.full_name FROM bookings b JOIN guests g ON b.guest_id = g.id ORDER BY b.created_at DESC LIMIT 5";
                                    Statement st = conn.createStatement();
                                    ResultSet rs = st.executeQuery(sql);
                                    
                                    while(rs.next()) {
                                        String status = rs.getString("status");
                                        String statusClass = "bg-secondary text-white";
                                        String statusLabel = status;
                                        
                                        switch(status) {
                                            case "PENDING": statusClass = "bg-warning text-dark"; statusLabel = "Chờ xử lý"; break;
                                            case "CONFIRMED": statusClass = "bg-info text-white"; statusLabel = "Đã xác nhận"; break;
                                            case "CHECKED_IN": statusClass = "bg-primary text-white"; statusLabel = "Đang lưu trú"; break;
                                            case "COMPLETED": statusClass = "bg-success text-white"; statusLabel = "Hoàn thành"; break;
                                            case "CANCELLED": statusClass = "bg-danger text-white"; statusLabel = "Đã hủy"; break;
                                        }
                        %>
                        <tr>
                            <td><span class="fw-bold font-monospace" style="color: var(--primary)"><%= rs.getString("booking_code") %></span></td>
                            <td class="fw-500"><%= rs.getString("full_name") %></td>
                            <td><%= rs.getDate("check_in_date") %></td>
                            <td><%= rs.getDate("check_out_date") %></td>
                            <td class="fw-500"><%= nf.format(rs.getDouble("total_amount")).replace("VNĐ", "₫") %></td>
                            <td><span class="status-badge <%= statusClass %>"><%= statusLabel %></span></td>
                            <td class="text-end">
                                <a href="#" class="btn btn-sm btn-light rounded-circle shadow-sm" style="width: 32px; height: 32px;"><i class="bi bi-eye"></i></a>
                            </td>
                        </tr>
                        <%
                                    }
                                    rs.close();
                                    st.close();
                                } catch(Exception e) {
                                    out.println("<tr><td colspan='7' class='text-danger'>Lỗi: " + e.getMessage() + "</td></tr>");
                                }
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <% if(conn != null) try { conn.close(); } catch(Exception e) {} %>
</body>
</html>
