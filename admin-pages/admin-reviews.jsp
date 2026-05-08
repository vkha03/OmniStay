<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../layouts/admin-auth.jsp" %>
<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<%@ include file="../env-secrets.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    Connection conn = null;
    String thongBao = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(SECRET_DB_URL, SECRET_DB_USER, SECRET_DB_PASS);

        String action = request.getParameter("action");
        if (action != null) {
            int id = Integer.parseInt(request.getParameter("id"));
            if (action.equals("toggleStatus")) {
                int currentStatus = Integer.parseInt(request.getParameter("currentStatus"));
                int newStatus = (currentStatus == 1) ? 0 : 1;
                PreparedStatement ps = conn.prepareStatement("UPDATE reviews SET status = ? WHERE id = ?");
                ps.setInt(1, newStatus);
                ps.setInt(2, id);
                ps.executeUpdate();
                thongBao = "Đã cập nhật trạng thái hiển thị!";
            } else if (action.equals("delete")) {
                PreparedStatement ps = conn.prepareStatement("DELETE FROM reviews WHERE id = ?");
                ps.setInt(1, id);
                ps.executeUpdate();
                thongBao = "Đã xóa đánh giá khỏi hệ thống!";
            }
        }
    } catch(Exception e) {
        thongBao = "Lỗi: " + e.getMessage();
    }
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Đánh giá — OmniStay Admin</title>
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
        
        .sidebar { width: 260px; background: var(--primary-dark); min-height: 100vh; position: fixed; top: 0; left: 0; z-index: 1000; padding-top: 1.5rem; box-shadow: 4px 0 20px rgba(0,0,0,0.05); }
        .sidebar .brand { padding: 0 1.5rem 2rem; border-bottom: 1px solid rgba(255,255,255,0.05); margin-bottom: 1rem; }
        .sidebar .brand a { font-size: 1.6rem; letter-spacing: 1px; color: #fff !important; text-decoration: none; }
        .sidebar .brand span { color: var(--accent); font-weight: 600; }
        
        .nav-sidebar .nav-link { color: rgba(255,255,255,0.7) !important; padding: 0.8rem 1.5rem; margin: 0.2rem 1rem; border-radius: 8px; transition: all 0.3s; display: flex; align-items: center; font-weight: 400; text-decoration: none; }
        .nav-sidebar .nav-link i { margin-right: 12px; font-size: 1.1rem; }
        .nav-sidebar .nav-link:hover, .nav-sidebar .nav-link.active { color: #fff !important; background: rgba(255,255,255,0.1); }
        .nav-sidebar .nav-link.active { background: var(--primary) !important; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }

        .main-content { margin-left: 260px; padding: 2rem; min-height: 100vh; }
        .table-custom { background: #fff; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); border: 1px solid rgba(0,0,0,0.05); overflow: hidden; padding: 1.5rem; }
        .table-custom th { background-color: #f8f9fa; color: #6c757d; font-weight: 500; text-transform: uppercase; font-size: 0.75rem; letter-spacing: 0.5px; padding: 1rem 1.5rem; border-bottom: 2px solid #edf2f9; }
        .table-custom td { padding: 1.2rem 1.5rem; vertical-align: middle; color: #495057; font-size: 0.9rem; border-bottom: 1px solid #edf2f9; }
        
        .star-rating { color: #ffc107; font-size: 0.85rem; }
        .action-btn { width: 32px; height: 32px; display: inline-flex; align-items: center; justify-content: center; border-radius: 8px; transition: 0.2s; color: #666; text-decoration: none; border: 1px solid transparent; cursor: pointer; }
        .action-btn:hover { background: var(--bg-light); color: var(--primary); border-color: var(--border); }
        
        .badge-visible { background: rgba(26, 107, 90, 0.1); color: var(--primary); }
        .badge-hidden { background: #f8f9fa; color: #6c757d; border: 1px solid #eee; }
    </style>
</head>
<body>
    <%@ include file="../layouts/sidebar-admin.jsp" %>
    
    <main class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="font-display fw-normal mb-1">Đánh giá khách hàng</h2>
                <p class="text-muted mb-0" style="font-size: 0.9rem;">Xem và kiểm duyệt các phản hồi từ khách hàng.</p>
            </div>
            <button class="btn btn-outline-secondary rounded-pill px-4" style="font-size: 0.85rem;" onclick="location.reload()">
                <i class="bi bi-arrow-clockwise me-1"></i> Làm mới
            </button>
        </div>

        <% if (thongBao != null) { %>
            <div class="alert alert-success alert-dismissible fade show border-0 mb-4 shadow-sm" style="border-radius: 12px;">
                <i class="bi bi-check-circle-fill me-2"></i> <%= thongBao %>
                <button type="button" class="btn-close shadow-none" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <%
            String reviewSearch = request.getParameter("reviewSearch");
        %>

        <!-- Filter Bar -->
        <form action="admin-reviews.jsp" method="GET" class="bg-white p-3 rounded-4 border mb-4 shadow-sm" style="border-color: var(--border) !important;">
            <div class="row g-3 align-items-center">
                <div class="col-md-8">
                    <div class="input-group">
                        <span class="input-group-text bg-light border-0"><i class="bi bi-search"></i></span>
                        <input type="text" name="reviewSearch" class="form-control border-0 bg-light" placeholder="Tìm theo tên khách hoặc nội dung đánh giá..." value="<%= (reviewSearch != null) ? reviewSearch : "" %>">
                    </div>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn text-white w-100" style="background: var(--primary); border-radius: 10px;">Tìm kiếm</button>
                </div>
                <div class="col-md-2 text-end">
                    <a href="admin-reviews.jsp" class="btn btn-light w-100 border rounded-pill text-muted small">Xóa lọc</a>
                </div>
            </div>
        </form>

        <div class="table-custom">
            <div class="table-responsive">
                <table id="reviewTable" class="table table-hover align-middle mb-0">
                    <thead>
                        <tr>
                            <th>Khách hàng</th>
                            <th>Phòng</th>
                            <th>Đánh giá</th>
                            <th>Nhận xét</th>
                            <th>Trạng thái</th>
                            <th class="text-end">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if(conn != null) {
                                try {
                                    String sql = "SELECT r.*, g.full_name, rs.room_number FROM reviews r " +
                                                 "JOIN guests g ON r.guest_id = g.id " +
                                                 "JOIN rooms rs ON r.room_id = rs.id WHERE 1=1 ";
                                    
                                    if(reviewSearch != null && !reviewSearch.trim().isEmpty()) {
                                        sql += " AND (g.full_name LIKE ? OR r.comment LIKE ?)";
                                    }
                                    
                                    sql += " ORDER BY r.created_at DESC";
                                    
                                    PreparedStatement ps = conn.prepareStatement(sql);
                                    if(reviewSearch != null && !reviewSearch.trim().isEmpty()) {
                                        String pat = "%" + reviewSearch.trim() + "%";
                                        ps.setString(1, pat); ps.setString(2, pat);
                                    }
                                    
                                    ResultSet rs = ps.executeQuery();
                                    while(rs.next()) {
                                        int id = rs.getInt("id");
                                        String name = rs.getString("full_name");
                                        String roomNB = rs.getString("room_number");
                                        int rating = rs.getInt("rating");
                                        String comment = rs.getString("comment");
                                        int status = rs.getInt("status");
                                        Timestamp createdAt = rs.getTimestamp("created_at");
                        %>
                        <tr style="<%= status == 0 ? "opacity: 0.6;" : "" %>">
                            <td><div class="fw-600 text-dark"><%= name %></div><div class="text-muted small"><%= sdf.format(createdAt) %></div></td>
                            <td><span class="badge bg-light text-dark border fw-normal">P.<%= roomNB %></span></td>
                            <td>
                                <div class="star-rating">
                                    <% for(int i=0; i<5; i++) { %>
                                        <i class="bi <%= i < rating ? "bi-star-fill" : "bi-star" %>"></i>
                                    <% } %>
                                </div>
                            </td>
                            <td><div class="text-muted small" style="max-width: 250px;"><%= comment %></div></td>
                            <td>
                                <span class="badge rounded-pill px-3 py-2 <%= status == 1 ? "badge-visible" : "badge-hidden" %>">
                                    <i class="bi <%= status == 1 ? "bi-eye-fill" : "bi-eye-slash" %> me-1"></i>
                                    <%= status == 1 ? "Hiển thị" : "Đã ẩn" %>
                                </span>
                            </td>
                            <td class="text-end">
                                <form action="admin-reviews.jsp" method="POST" style="display:inline;">
                                    <input type="hidden" name="action" value="toggleStatus">
                                    <input type="hidden" name="id" value="<%= id %>">
                                    <input type="hidden" name="currentStatus" value="<%= status %>">
                                    <button type="submit" class="action-btn" title="<%= status == 1 ? "Ẩn đánh giá" : "Hiện đánh giá" %>">
                                        <i class="bi <%= status == 1 ? "bi-eye-slash text-warning" : "bi-eye text-success" %>"></i>
                                    </button>
                                </form>
                                <form action="admin-reviews.jsp" method="POST" style="display:inline;" onsubmit="return confirm('Xóa vĩnh viễn đánh giá này?')">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<%= id %>">
                                    <button type="submit" class="action-btn" title="Xóa"><i class="bi bi-trash3 text-danger"></i></button>
                                </form>
                            </td>
                        </tr>
                        <%
                                    }
                                    rs.close(); ps.close();
                                } catch(Exception e) { out.println("Lỗi: " + e.getMessage()); }
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
            $('#reviewTable').DataTable({
                "pageLength": 10,
                "lengthChange": false,
                "searching": false,
                "ordering": false,
                "language": {
                    "paginate": { "previous": "<i class='bi bi-chevron-left'></i>", "next": "<i class='bi bi-chevron-right'></i>" }
                }
            });
        });
    </script>
    <% if(conn != null) try { conn.close(); } catch(Exception e) {} %>
</body>
</html>
