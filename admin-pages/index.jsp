<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../layouts/admin-auth.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ include file="../env-secrets.jsp" %>
<%
    Connection conn = null;
    String dbError = null;
    
    // Thống kê
    int totalRooms = 0;
    int availableRooms = 0;
    int todayBookings = 0;
    int monthBookings = 0;
    int newContacts = 0;
    int monthGuests = 0;
    int totalStaff = 0;
    int totalServices = 0;
    int todayReviews = 0;
    double todayRevenue = 0;
    double monthRevenue = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(SECRET_DB_URL, SECRET_DB_USER, SECRET_DB_PASS);
        
        // Lấy tổng số phòng và số phòng trống
        Statement st1 = conn.createStatement();
        ResultSet rs1 = st1.executeQuery("SELECT COUNT(*), SUM(CASE WHEN status = 'AVAILABLE' THEN 1 ELSE 0 END) FROM rooms");
        if(rs1.next()) {
            totalRooms = rs1.getInt(1);
            availableRooms = rs1.getInt(2);
        }
        rs1.close();
        st1.close();
        
        // Lấy số đặt phòng (Hôm nay & Tháng này)
        Statement st2 = conn.createStatement();
        ResultSet rs2 = st2.executeQuery("SELECT SUM(CASE WHEN DATE(created_at) = CURDATE() THEN 1 ELSE 0 END), SUM(CASE WHEN MONTH(created_at) = MONTH(CURDATE()) AND YEAR(created_at) = YEAR(CURDATE()) THEN 1 ELSE 0 END) FROM bookings WHERE status != 'CANCELLED'");
        if(rs2.next()) {
            todayBookings = rs2.getInt(1);
            monthBookings = rs2.getInt(2);
        }
        rs2.close();
        st2.close();
        
        // Lấy doanh thu (Hôm nay & Tháng này) - Chỉ tính các đơn đã COMPLETED hoặc CHECKED_IN
        Statement st3 = conn.createStatement();
        ResultSet rs3 = st3.executeQuery("SELECT SUM(CASE WHEN DATE(created_at) = CURDATE() THEN total_amount ELSE 0 END), SUM(CASE WHEN MONTH(created_at) = MONTH(CURDATE()) AND YEAR(created_at) = YEAR(CURDATE()) THEN total_amount ELSE 0 END) FROM bookings WHERE status IN ('COMPLETED', 'CHECKED_IN')");
        if(rs3.next()) {
            todayRevenue = rs3.getDouble(1);
            monthRevenue = rs3.getDouble(2);
        }
        rs3.close();
        st3.close();
        
        // Lấy số liên hệ mới
        Statement st4 = conn.createStatement();
        ResultSet rs4 = st4.executeQuery("SELECT COUNT(*) FROM contacts WHERE status = 'UNREAD'");
        if(rs4.next()) newContacts = rs4.getInt(1);
        rs4.close();
        st4.close();

        // Lấy số khách hàng mới (có booking trong tháng này)
        Statement st5 = conn.createStatement();
        ResultSet rs5 = st5.executeQuery("SELECT COUNT(DISTINCT guest_id) FROM bookings WHERE MONTH(created_at) = MONTH(CURDATE()) AND YEAR(created_at) = YEAR(CURDATE())");
        if(rs5.next()) monthGuests = rs5.getInt(1);
        rs5.close();
        st5.close();

        // Lấy tổng số nhân viên
        Statement st6 = conn.createStatement();
        ResultSet rs6 = st6.executeQuery("SELECT COUNT(*) FROM staff");
        if(rs6.next()) totalStaff = rs6.getInt(1);
        rs6.close();
        st6.close();

        // Lấy tổng số dịch vụ
        Statement st7 = conn.createStatement();
        ResultSet rs7 = st7.executeQuery("SELECT COUNT(*) FROM services");
        if(rs7.next()) totalServices = rs7.getInt(1);
        rs7.close();
        st7.close();

        // Lấy số đánh giá mới hôm nay
        Statement st8 = conn.createStatement();
        ResultSet rs8 = st8.executeQuery("SELECT COUNT(*) FROM reviews WHERE DATE(created_at) = CURDATE()");
        if(rs8.next()) todayReviews = rs8.getInt(1);
        rs8.close();
        st8.close();

        // Lấy dữ liệu biểu đồ (7 ngày gần nhất)
        // Lưu ý: Sẽ trả về chuỗi JSON-like để JS xử lý
        StringBuilder chartLabels = new StringBuilder();
        StringBuilder chartData = new StringBuilder();
        Statement stChart = conn.createStatement();
        ResultSet rsChart = stChart.executeQuery(
            "SELECT DATE_FORMAT(d.date, '%d/%m') as day_label, COALESCE(SUM(b.total_amount), 0) as total " +
            "FROM (SELECT CURDATE() - INTERVAL (a.a + (10 * b.a)) DAY as date " +
            "      FROM (SELECT 0 as a UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) as a " +
            "      CROSS JOIN (SELECT 0 as a UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) as b " +
            "     ) d " +
            "LEFT JOIN bookings b ON DATE(b.created_at) = d.date AND b.status IN ('COMPLETED', 'CHECKED_IN') " +
            "WHERE d.date BETWEEN DATE_SUB(CURDATE(), INTERVAL 6 DAY) AND CURDATE() " +
            "GROUP BY d.date ORDER BY d.date ASC"
        );
        while(rsChart.next()) {
            chartLabels.append("'").append(rsChart.getString("day_label")).append("',");
            chartData.append(rsChart.getDouble("total")).append(",");
        }
        rsChart.close();
        stChart.close();

        String labelsStr = chartLabels.toString();
        String dataStr = chartData.toString();
        if (labelsStr.endsWith(",")) labelsStr = labelsStr.substring(0, labelsStr.length() - 1);
        if (dataStr.endsWith(",")) dataStr = dataStr.substring(0, dataStr.length() - 1);

        request.setAttribute("chartLabels", labelsStr);
        request.setAttribute("chartData", dataStr);
        
    } catch(Exception e) {
        dbError = e.getMessage();
    }
    
    NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    
    // Helper translation
    java.util.function.Function<String, String> translateType = (type) -> {
        if(type == null) return "Chưa xác định";
        switch(type.trim().toUpperCase()) {
            case "STANDARD": return "Tiêu chuẩn (Standard)";
            case "DELUXE": return "Sang trọng (Deluxe)";
            case "PREMIUM": return "Cao cấp (Premium)";
            default: return type;
        }
    };
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản trị Hệ thống — OmniStay</title>
    <link rel="icon" type="image/png" href="<%=request.getContextPath()%>/images/logo.png">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;1,400&family=Outfit:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="admin-theme.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>

    <!-- SIDEBAR -->
    <%@ include file="../layouts/sidebar-admin.jsp" %>

    <!-- MAIN CONTENT -->
    <div class="main-content">
        <!-- Topbar -->
        <div class="topbar">
            <div>
                <h3 class="font-display fw-bold text-dark mb-1">Tổng quan hệ thống</h3>
                <p class="text-muted mb-0" style="font-size: 0.85rem">Chào mừng trở lại, trang tổng quan hoạt động OmniStay.</p>
            </div>
            <div class="d-flex align-items-center gap-3">

                <div class="topbar-user">
                    <div class="topbar-avatar">
                        <%= (adminEmail != null && !adminEmail.isEmpty()) ? adminEmail.substring(0, 1).toUpperCase() : "A" %>
                    </div>
                    <span class="fw-500"><%= adminEmail %></span>
                </div>
            </div>
        </div>

        <% if (dbError != null) { %>
            <div class="alert alert-danger shadow-sm rounded-3">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> Lỗi kết nối CSDL: <%= dbError %>
            </div>
        <% } %>

        <!-- Top 4 Main KPIs -->
        <div class="row g-4 mb-4">
            <div class="col-xl-3 col-md-6 fade-in-up fade-in-up-1">
                <a href="admin-bookings.jsp" class="stat-card card-grad-revenue">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <div class="stat-icon">
                            <i class="bi bi-cash-coin"></i>
                        </div>
                        <span class="badge bg-white bg-opacity-25 text-white">Tháng này</span>
                    </div>
                    <p class="text-muted mb-1 text-uppercase fw-500" style="font-size: 0.72rem;">Doanh thu</p>
                    <h3 class="fw-bold mb-0"><%= nf.format(monthRevenue).replace("VNĐ","") %><small style="font-size: 0.6em; opacity: 0.8"> đ</small></h3>
                </a>
            </div>
            
            <div class="col-xl-3 col-md-6 fade-in-up fade-in-up-2">
                <a href="admin-bookings.jsp" class="stat-card card-grad-booking">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <div class="stat-icon">
                            <i class="bi bi-calendar-plus"></i>
                        </div>
                        <span class="badge bg-white bg-opacity-25 text-white">Hôm nay: <%= todayBookings %></span>
                    </div>
                    <p class="text-muted mb-1 text-uppercase fw-500" style="font-size: 0.72rem;">Đơn đặt phòng mới</p>
                    <h3 class="fw-bold mb-0"><%= monthBookings %></h3>
                </a>
            </div>
            
            <div class="col-xl-3 col-md-6 fade-in-up fade-in-up-3">
                <a href="admin-rooms.jsp" class="stat-card card-grad-rooms">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <div class="stat-icon">
                            <i class="bi bi-door-open"></i>
                        </div>
                        <span class="badge bg-white bg-opacity-25 text-white">Sẵn sàng</span>
                    </div>
                    <p class="text-muted mb-1 text-uppercase fw-500" style="font-size: 0.72rem;">Phòng trống / Tổng</p>
                    <h3 class="fw-bold mb-0"><%= availableRooms %> / <%= totalRooms %></h3>
                </a>
            </div>
            
            <div class="col-xl-3 col-md-6 fade-in-up fade-in-up-4">
                <a href="admin-contacts.jsp" class="stat-card card-grad-contacts">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <div class="stat-icon">
                            <i class="bi bi-chat-dots"></i>
                        </div>
                        <% if(newContacts > 0) { %>
                        <span class="badge bg-white text-danger fw-bold"><%= newContacts %> mới</span>
                        <% } else { %>
                        <span class="badge bg-white bg-opacity-25 text-white">0 mới</span>
                        <% } %>
                    </div>
                    <p class="text-muted mb-1 text-uppercase fw-500" style="font-size: 0.72rem;">Liên hệ chưa đọc</p>
                    <h3 class="fw-bold mb-0"><%= newContacts %></h3>
                </a>
            </div>
        </div>

        <!-- Middle Section: Chart & Recent Bookings (Left) | Secondary Stats (Right) -->
        <div class="row g-4 mb-4">
            <!-- Left Column (8) -->
            <div class="col-lg-8">
                <!-- Revenue Chart -->
                <div class="table-card p-4 mb-4">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h5 class="fw-bold mb-0"><i class="bi bi-graph-up-arrow text-success me-2"></i>Xu hướng doanh thu (7 ngày qua)</h5>
                    </div>
                    <canvas id="revenueChart" style="max-height: 300px;"></canvas>
                </div>

                <!-- Recent Bookings Table -->
                <div class="table-card">
                    <div class="d-flex justify-content-between align-items-center p-4 border-bottom">
                        <h5 class="fw-bold mb-0">Đơn đặt phòng gần đây</h5>
                        <a href="admin-bookings.jsp" class="btn btn-sm btn-light border rounded-pill px-3">Xem tất cả</a>
                    </div>
                    <div class="table-responsive">
                        <table class="table mb-0">
                            <thead>
                                <tr>
                                    <th>Mã đơn</th>
                                    <th>Khách hàng</th>
                                    <th>Ngày đặt</th>
                                    <th>Tổng tiền</th>
                                    <th>Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if(conn != null) {
                                        try {
                                            String sqlRecent = "SELECT b.*, g.full_name FROM bookings b JOIN guests g ON b.guest_id = g.id ORDER BY b.created_at DESC LIMIT 5";
                                            Statement stRecent = conn.createStatement();
                                            ResultSet rsRecent = stRecent.executeQuery(sqlRecent);
                                            while(rsRecent.next()) {
                                                String status = rsRecent.getString("status");
                                                String badgeClass = "bg-secondary";
                                                String statusVi = status;
                                                if("PENDING".equals(status)) { badgeClass = "bg-warning text-dark"; statusVi = "Chờ duyệt"; }
                                                else if("CONFIRMED".equals(status)) { badgeClass = "bg-primary"; statusVi = "Đã xác nhận"; }
                                                else if("CHECKED_IN".equals(status)) { badgeClass = "bg-info text-white"; statusVi = "Đã nhận phòng"; }
                                                else if("COMPLETED".equals(status)) { badgeClass = "bg-success"; statusVi = "Hoàn tất"; }
                                                else if("CANCELLED".equals(status)) { badgeClass = "bg-danger"; statusVi = "Đã hủy"; }
                                %>
                                <tr>
                                    <td class="fw-bold">#<%= rsRecent.getInt("id") %></td>
                                    <td><%= rsRecent.getString("full_name") %></td>
                                    <td><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(rsRecent.getTimestamp("created_at")) %></td>
                                    <td class="fw-bold text-dark"><%= nf.format(rsRecent.getDouble("total_amount")).replace("VNĐ","") %></td>
                                    <td><span class="status-badge <%= badgeClass %>"><%= statusVi %></span></td>
                                </tr>
                                <%
                                            }
                                            rsRecent.close(); stRecent.close();
                                        } catch(Exception e) {}
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Right Column (4) -->
            <div class="col-lg-4">
                <div class="table-card p-4 h-100">
                    <h5 class="fw-bold mb-4">Thống kê bổ sung</h5>
                    
                    <div class="quick-stat-item">
                        <div class="quick-stat-icon" style="background: rgba(25, 135, 84, 0.1); color: #198754;">
                            <i class="bi bi-people"></i>
                        </div>
                        <div class="flex-grow-1">
                            <p class="text-muted mb-0 small">Khách hàng mới</p>
                            <h5 class="fw-bold mb-0"><%= monthGuests %></h5>
                        </div>
                        <a href="admin-guests.jsp" class="btn btn-sm btn-light border-0"><i class="bi bi-chevron-right"></i></a>
                    </div>

                    <div class="quick-stat-item">
                        <div class="quick-stat-icon" style="background: rgba(102, 16, 242, 0.1); color: #6610f2;">
                            <i class="bi bi-gift"></i>
                        </div>
                        <div class="flex-grow-1">
                            <p class="text-muted mb-0 small">Dịch vụ hiện có</p>
                            <h5 class="fw-bold mb-0"><%= totalServices %></h5>
                        </div>
                        <a href="admin-services.jsp" class="btn btn-sm btn-light border-0"><i class="bi bi-chevron-right"></i></a>
                    </div>

                    <div class="quick-stat-item">
                        <div class="quick-stat-icon" style="background: rgba(255, 193, 7, 0.1); color: #ffc107;">
                            <i class="bi bi-star"></i>
                        </div>
                        <div class="flex-grow-1">
                            <p class="text-muted mb-0 small">Đánh giá mới</p>
                            <h5 class="fw-bold mb-0"><%= todayReviews %></h5>
                        </div>
                        <a href="admin-reviews.jsp" class="btn btn-sm btn-light border-0"><i class="bi bi-chevron-right"></i></a>
                    </div>

                    <% if ("ADMIN".equals(adminRole)) { %>
                    <div class="quick-stat-item">
                        <div class="quick-stat-icon" style="background: rgba(13, 202, 240, 0.1); color: #0dcaf0;">
                            <i class="bi bi-person-badge"></i>
                        </div>
                        <div class="flex-grow-1">
                            <p class="text-muted mb-0 small">Đội ngũ nhân sự</p>
                            <h5 class="fw-bold mb-0"><%= totalStaff %></h5>
                        </div>
                        <a href="admin-staff.jsp" class="btn btn-sm btn-light border-0"><i class="bi bi-chevron-right"></i></a>
                    </div>
                    <% } %>

                    <div class="mt-4 p-3 rounded-4 border" style="background: var(--primary-light);">
                        <p class="small mb-0" style="color: var(--primary);"><i class="bi bi-lightbulb me-1"></i> Mẹo: Click vào các ô thống kê để xem chi tiết.</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Room Status Map -->
        <div class="table-card mb-5">
            <div class="d-flex justify-content-between align-items-center p-4 border-bottom flex-wrap gap-3">
                <div>
                    <h5 class="fw-bold mb-1 text-dark">Sơ đồ trạng thái phòng</h5>
                    <p class="text-muted mb-0 small">Tổng quan tình trạng phòng nghỉ thời điểm hiện tại.</p>
                </div>
                <div class="d-flex gap-4 flex-wrap">
                    <div class="legend-item"><span class="legend-dot" style="background: #bbf7d0;"></span> Sẵn sàng</div>
                    <div class="legend-item"><span class="legend-dot" style="background: #fecaca;"></span> Có khách</div>
                    <div class="legend-item"><span class="legend-dot" style="background: #fef3c7;"></span> Đang dọn</div>
                    <div class="legend-item"><span class="legend-dot" style="background: #e2e8f0;"></span> Bảo trì</div>
                </div>
                <a href="admin-rooms.jsp" class="btn btn-sm btn-primary-gradient rounded-pill px-3">Quản lý phòng</a>
            </div>
            
            <div class="room-grid">
                <%
                    if(conn != null) {
                        try {
                            String sqlRooms = "SELECT r.*, rt.type_name FROM rooms r LEFT JOIN room_types rt ON r.room_type_id = rt.id ORDER BY r.room_number ASC";
                            Statement stRooms = conn.createStatement();
                            ResultSet rsRooms = stRooms.executeQuery(sqlRooms);
                            
                            while(rsRooms.next()) {
                                String rStatus = rsRooms.getString("status");
                                if (rStatus == null) rStatus = "AVAILABLE";
                                rStatus = rStatus.trim().toUpperCase();
                                
                                String rClass = "status-available";
                                if("OCCUPIED".equals(rStatus)) rClass = "status-occupied";
                                else if("CLEANING".equals(rStatus)) rClass = "status-cleaning";
                                else if("MAINTENANCE".equals(rStatus)) rClass = "status-maintenance";
                                
                                String tName = rsRooms.getString("type_name");
                                if (tName == null) tName = "Chưa thiết lập";
                                else tName = translateType.apply(tName);
                %>
                <a href="admin-rooms.jsp" class="room-item">
                    <div class="room-box <%= rClass %>">
                        <div class="room-no"><%= rsRooms.getString("room_number") %></div>
                        <div class="room-type text-truncate w-100"><%= tName %></div>
                    </div>
                </a>
                <%
                            }
                            rsRooms.close(); stRooms.close();
                        } catch(Exception e) { out.println("Lỗi: " + e.getMessage()); }
                    }
                %>
            </div>
        </div>

    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const ctx = document.getElementById('revenueChart').getContext('2d');
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: [<%= request.getAttribute("chartLabels") %>],
                datasets: [{
                    label: 'Doanh thu (VNĐ)',
                    data: [<%= request.getAttribute("chartData") %>],
                    borderColor: '#1a6b5a',
                    backgroundColor: 'rgba(26, 107, 90, 0.08)',
                    borderWidth: 3,
                    fill: true,
                    tension: 0.4,
                    pointBackgroundColor: '#d4a847',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2,
                    pointRadius: 5,
                    pointHoverRadius: 7
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: { borderDash: [5, 5], color: 'rgba(0,0,0,0.04)' },
                        ticks: {
                            callback: function(value) {
                                return value.toLocaleString('vi-VN') + ' đ';
                            },
                            font: { family: 'Outfit' }
                        }
                    },
                    x: {
                        grid: { display: false },
                        ticks: { font: { family: 'Outfit' } }
                    }
                }
            }
        });
    </script>
    <% if(conn != null) try { conn.close(); } catch(Exception e) {} %>
</body>
</html>
