<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../layouts/admin-auth.jsp" %>
<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat, java.text.NumberFormat" %>
<%@ include file="../env-secrets.jsp" %>
<%
    Connection conn = null;
    String dbError = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(SECRET_DB_URL, SECRET_DB_USER, SECRET_DB_PASS);
    } catch(Exception e) {
        dbError = e.getMessage();
    }
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Khách hàng — OmniStay Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;1,400&family=Outfit:wght@300;400;500;600&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
    
    <style>
        :root {
            --primary: #1a6b5a;
            --primary-dark: #124a3e;
            --accent: #d4a847;
            --bg-light: #f5f8f7;
            --border: #e8e2d9;
            --text-main: #2c3e50;
        }
        body { font-family: 'Outfit', sans-serif; background-color: var(--bg-light); color: var(--text-main); overflow-x: hidden; margin: 0; }
        .font-display { font-family: "Playfair Display", serif; }
        
        /* ─── SIDEBAR FIXED ─── */
        .sidebar { width: 260px; background: var(--primary-dark); min-height: 100vh; position: fixed; top: 0; left: 0; z-index: 1000; padding-top: 1.5rem; box-shadow: 4px 0 20px rgba(0,0,0,0.05); }
        .sidebar .brand { padding: 0 1.5rem 2rem; border-bottom: 1px solid rgba(255,255,255,0.05); margin-bottom: 1rem; }
        .sidebar .brand a { font-size: 1.6rem; letter-spacing: 1px; color: white !important; text-decoration: none; }
        .sidebar .brand span { color: var(--accent); font-weight: 600; }
        
        .nav-sidebar .nav-link { color: rgba(255,255,255,0.7) !important; padding: 0.8rem 1.5rem; margin: 0.2rem 1rem; border-radius: 8px; transition: all 0.3s; display: flex; align-items: center; font-weight: 400; text-decoration: none; }
        .nav-sidebar .nav-link i { margin-right: 12px; font-size: 1.1rem; }
        .nav-sidebar .nav-link:hover, .nav-sidebar .nav-link.active { color: #fff !important; background: rgba(255,255,255,0.1); }
        .nav-sidebar .nav-link.active { background: var(--primary) !important; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }

        /* ─── MAIN CONTENT ─── */
        .main-content { margin-left: 260px; padding: 2rem; min-height: 100vh; }
        
        /* Table Custom Styling */
        .table-custom { background: #fff; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); border: 1px solid rgba(0,0,0,0.05); overflow: hidden; padding: 1.5rem; }
        .table-custom th { background-color: #f8f9fa; color: #6c757d; font-weight: 500; text-transform: uppercase; font-size: 0.75rem; letter-spacing: 0.5px; padding: 1rem 1.5rem; border-bottom: 2px solid #edf2f9; }
        .table-custom td { padding: 1.2rem 1.5rem; vertical-align: middle; color: #495057; font-size: 0.9rem; border-bottom: 1px solid #edf2f9; }
        .table-custom tbody tr:hover { background-color: #f8f9fa; }
        
        .guest-avatar { width: 40px; height: 40px; background: rgba(26, 107, 90, 0.1); color: var(--primary); border-radius: 10px; display: flex; align-items: center; justify-content: center; font-weight: 600; margin-right: 12px; }
        
        /* DataTables Custom UI */
        div.dataTables_filter input { border: 1px solid var(--border); border-radius: 50px; padding: 0.4rem 1.2rem; outline: none; transition: 0.3s; background-color: var(--bg-light); margin-left: 10px; }
        div.dataTables_filter input:focus { border-color: var(--primary); box-shadow: 0 0 0 4px rgba(26, 107, 90, 0.1); background-color: #fff; }
        
        .dataTables_wrapper .pagination .page-item.active .page-link { background-color: var(--primary) !important; color: white !important; border: none; }
        .dataTables_wrapper .pagination .page-link { border-radius: 50% !important; margin: 0 2px; width: 35px; height: 35px; display: flex; align-items: center; justify-content: center; color: var(--primary); border: none; }

        .btn-action { width: 34px; height: 34px; border-radius: 8px; display: inline-flex; align-items: center; justify-content: center; transition: 0.2s; border: 1px solid #eee; background: #fff; color: #666; text-decoration: none; }
        .btn-action:hover { background: var(--bg-light); color: var(--primary); border-color: var(--primary); }
        .btn-delete:hover { color: #dc3545; border-color: #dc3545; background: rgba(220, 53, 69, 0.05); }
    </style>
</head>
<body>
    <%@ include file="../layouts/sidebar-admin.jsp" %>
    
    <main class="main-content">
        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="font-display fw-normal mb-1">Quản lý Khách hàng</h2>
                <p class="text-muted mb-0" style="font-size: 0.9rem;">Danh sách khách hàng đã từng lưu trú và đặt phòng tại hệ thống.</p>
            </div>
            <div class="d-flex gap-2">
                <button class="btn btn-outline-secondary rounded-pill px-4" style="font-size: 0.85rem;" onclick="location.reload()">
                    <i class="bi bi-arrow-clockwise me-1"></i> Làm mới
                </button>
            </div>
        </div>

        <%
            String msg = (String) session.getAttribute("thongBao");
            if (msg != null) {
        %>
            <div class="alert alert-success alert-dismissible fade show border-0 mb-4 shadow-sm" style="border-radius: 12px;">
                <i class="bi bi-check-circle-fill me-2"></i> <%= msg %>
                <button type="button" class="btn-close shadow-none" data-bs-dismiss="alert"></button>
            </div>
        <%
                session.removeAttribute("thongBao");
            }
        %>

        <!-- Table Card -->
        <div class="table-custom">
            <div class="table-responsive">
                <table id="guestTable" class="table table-hover align-middle mb-0">
                    <thead>
                        <tr>
                            <th>Khách hàng</th>
                            <th>Liên hệ</th>
                            <th>Định danh (CCCD)</th>
                            <th class="text-center">Số lần đặt</th>
                            <th class="text-end">Doanh thu</th>
                            <th class="text-end">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if(conn != null) {
                                try {
                                    NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
                                    Statement st = conn.createStatement();
                                    String sql = "SELECT g.*, " +
                                                 "(SELECT COUNT(*) FROM bookings b WHERE b.guest_id = g.id) as booking_count, " +
                                                 "(SELECT SUM(total_amount) FROM bookings b WHERE b.guest_id = g.id AND b.status != 'CANCELLED') as total_spent " +
                                                 "FROM guests g ORDER BY total_spent DESC, full_name ASC";
                                    ResultSet rs = st.executeQuery(sql);
                                    while(rs.next()) {
                                        int id = rs.getInt("id");
                                        String name = rs.getString("full_name");
                                        String phone = rs.getString("phone_number");
                                        String email = rs.getString("email");
                                        String idCard = rs.getString("id_card");
                                        int bookingCount = rs.getInt("booking_count");
                                        double totalSpent = rs.getDouble("total_spent");
                                        
                                        String initials = "";
                                        if(name != null && !name.isEmpty()) {
                                            String[] parts = name.split(" ");
                                            initials = parts[parts.length-1].substring(0,1).toUpperCase();
                                        }
                        %>
                        <tr>
                            <td>
                                <div class="d-flex align-items-center">
                                    <div class="guest-avatar"><%= initials %></div>
                                    <div>
                                        <div class="fw-600 text-dark"><%= name %></div>
                                        <div class="text-muted small">ID: #GST-<%= id %></div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div class="small"><i class="bi bi-telephone me-2 text-muted"></i><%= phone %></div>
                                <div class="small text-muted"><i class="bi bi-envelope me-2"></i><%= email != null ? email : "N/A" %></div>
                            </td>
                            <td>
                                <span class="badge bg-light text-dark border fw-normal px-3 py-2">
                                    <i class="bi bi-card-text me-2 text-primary"></i><%= idCard != null ? idCard : "N/A" %>
                                </span>
                            </td>
                            <td class="text-center">
                                <span class="badge rounded-pill <%= bookingCount > 5 ? "bg-primary" : "bg-light text-dark border" %>" style="min-width: 40px;">
                                    <%= bookingCount %>
                                </span>
                            </td>
                            <td class="text-end fw-600 text-primary">
                                <%= nf.format(totalSpent).replace("VNĐ", "₫") %>
                            </td>
                            <td class="text-end">
                                <a href="admin-guest-edit.jsp?id=<%= id %>" class="btn-action" title="Sửa thông tin"><i class="bi bi-pencil-square"></i></a>
                                <a href="admin-guest-delete.jsp?id=<%= id %>" class="btn-action btn-delete" title="Xóa" onclick="return confirm('Xóa khách hàng này sẽ ảnh hưởng đến lịch sử đặt phòng. Bạn chắc chắn chứ?')">
                                    <i class="bi bi-trash3"></i>
                                </a>
                            </td>
                        </tr>
                        <%
                                    }
                                    rs.close(); st.close();
                                    conn.close();
                                } catch(Exception e) {
                                    out.println("<tr><td colspan='5'>Lỗi: " + e.getMessage() + "</td></tr>");
                                }
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <script src="https://code.jquery.com/jquery-3.7.0.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>

    <script>
        $(document).ready(function() {
            $('#guestTable').DataTable({
                "pageLength": 10,
                "lengthChange": false,
                "language": {
                    "search": "Tìm khách hàng:",
                    "zeroRecords": "Không tìm thấy khách hàng nào",
                    "info": "Đang xem _START_ đến _END_ trong tổng số _TOTAL_ khách",
                    "infoEmpty": "Không có dữ liệu",
                    "paginate": {
                        "previous": "<i class='bi bi-chevron-left'></i>",
                        "next": "<i class='bi bi-chevron-right'></i>"
                    }
                }
            });
        });
    </script>
</body>
</html>
