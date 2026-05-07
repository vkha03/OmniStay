<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../layouts/admin-auth.jsp" %>
<%
    // Trang này chỉ cho phép ADMIN truy cập
    if (!"ADMIN".equals((String)session.getAttribute("role"))) {
        out.println("<script>alert('Bạn không có quyền truy cập vào trang quản lý nhân sự!'); window.location.href='dashboard.jsp';</script>");
        return;
    }
%>
<%@ page import="java.sql.*" %>
<%
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    String dbError = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/omnistay", "root", "");

        // 1. XỬ LÝ THÊM NHÂN VIÊN (Đã fix lỗi bắt POST)
        if("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("name") != null){
            String sql = "INSERT INTO staff(full_name, email, password, role) VALUES(?,?,?,?)";
            ps = conn.prepareStatement(sql);
            ps.setString(1, request.getParameter("name"));
            ps.setString(2, request.getParameter("email"));
            ps.setString(3, request.getParameter("password"));
            ps.setString(4, request.getParameter("role"));
            ps.executeUpdate();
            
            // Lưu thông báo vào session
            session.setAttribute("thongBao", "Đã thêm nhân viên " + request.getParameter("name") + " thành công!");
            response.sendRedirect("admin-staff.jsp");
            return;
        }

        // 2. XỬ LÝ XÓA NHÂN VIÊN
        if(request.getParameter("delete") != null){
            String sql = "DELETE FROM staff WHERE id=?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(request.getParameter("delete")));
            ps.executeUpdate();
            
            session.setAttribute("thongBao", "Đã xóa nhân viên khỏi hệ thống!");
            response.sendRedirect("admin-staff.jsp");
            return;
        }

    } catch(Exception e){
        dbError = e.getMessage();
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Nhân viên — OmniStay Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;1,400&family=Outfit:wght@300;400;500;600&display=swap" rel="stylesheet" />
    <style>
        :root {
            --primary: #1a6b5a;
            --primary-dark: #124a3e;
            --accent: #d4a847;
            --bg-light: #f5f8f7;
            --border: #e8e2d9;
            --text-main: #2c3e50;
        }
        body { font-family: 'Outfit', sans-serif; background-color: var(--bg-light); color: var(--text-main); overflow-x: hidden; }
        .font-display { font-family: "Playfair Display", serif; }
        
        /* ─── SIDEBAR ─── */
        .sidebar { width: 260px; background: var(--primary-dark); min-height: 100vh; position: fixed; top: 0; left: 0; z-index: 1000; padding-top: 1.5rem; box-shadow: 4px 0 20px rgba(0,0,0,0.05); }
        .sidebar .brand { padding: 0 1.5rem 2rem; border-bottom: 1px solid rgba(255,255,255,0.05); margin-bottom: 1rem; }
        .sidebar .brand a { font-size: 1.6rem; letter-spacing: 1px; }
        .sidebar .brand span { color: var(--accent); font-weight: 600; }
        .nav-sidebar .nav-link { color: rgba(255,255,255,0.7); padding: 0.8rem 1.5rem; margin: 0.2rem 1rem; border-radius: 8px; transition: all 0.3s; display: flex; align-items: center; font-weight: 400; }
        .nav-sidebar .nav-link i { margin-right: 12px; font-size: 1.1rem; }
        .nav-sidebar .nav-link:hover, .nav-sidebar .nav-link.active { color: #fff; background: rgba(255,255,255,0.1); }
        .nav-sidebar .nav-link.active { background: var(--primary); box-shadow: 0 4px 12px rgba(0,0,0,0.1); }

        /* ─── MAIN CONTENT ─── */
        .main-content { margin-left: 260px; padding: 2rem; }
        
        /* ─── UI COMPONENTS ─── */
        .card-custom { border: 1px solid rgba(0,0,0,0.05); border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); }
        .form-control, .form-select { border-radius: 8px; padding: 0.6rem 1rem; border-color: #edf2f9; }
        .form-control:focus, .form-select:focus { border-color: var(--primary); box-shadow: 0 0 0 0.25rem rgba(26, 107, 90, 0.25); }
        
        /* ─── TABLE ─── */
        .table-custom { background: #fff; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); border: 1px solid rgba(0,0,0,0.05); overflow: hidden; }
        .table-custom th { background-color: #f8f9fa; color: #6c757d; font-weight: 500; text-transform: uppercase; font-size: 0.75rem; letter-spacing: 0.5px; padding: 1.2rem 1.5rem; border-bottom: 2px solid #edf2f9; }
        .table-custom td { padding: 1rem 1.5rem; vertical-align: middle; color: #495057; font-size: 0.9rem; border-bottom: 1px solid #edf2f9; }
        .table-custom tbody tr:hover { background-color: #f8f9fa; }
        .table-custom tr:last-child td { border-bottom: none; }
        
        .action-btn { width: 32px; height: 32px; display: inline-flex; align-items: center; justify-content: center; border-radius: 8px; transition: 0.2s; }
        .action-btn:hover { background: var(--bg-light); }
    </style>
</head>
<body>
    <%@ include file="../layouts/sidebar-admin.jsp" %>

    <main class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="font-display fw-normal mb-1">Quản lý Nhân sự</h2>
                <p class="text-muted mb-0" style="font-size: 0.9rem;">Thêm mới và quản lý quyền truy cập của nhân viên hệ thống.</p>
            </div>
        </div>

        <%
            String msg = (String) session.getAttribute("thongBao");
            if (msg != null) {
        %>
            <div class="alert alert-success alert-dismissible fade show shadow-sm border-0 mb-4" role="alert" style="border-radius: 12px; background-color: #d1e7dd; color: #0f5132;">
                <i class="bi bi-check-circle-fill me-2"></i> <%= msg %>
                <button type="button" class="btn-close shadow-none" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <%
                session.removeAttribute("thongBao");
            }
            if (dbError != null) { out.println("<div class='alert alert-danger'>Lỗi DB: " + dbError + "</div>"); }
        %>

        <div class="card card-custom p-4 bg-white mb-4">
            <h5 class="font-display fw-500 mb-3" style="color: var(--primary);">Thêm nhân viên mới</h5>
            
            <form method="POST" class="row g-3 align-items-end">
                <div class="col-md-3">
                    <label class="form-label text-muted" style="font-size: 0.8rem; text-transform: uppercase;">Họ và tên</label>
                    <input type="text" name="name" class="form-control bg-light" placeholder="Nhập họ tên..." required>
                </div>

                <div class="col-md-3">
                    <label class="form-label text-muted" style="font-size: 0.8rem; text-transform: uppercase;">Email</label>
                    <input type="email" name="email" class="form-control bg-light" placeholder="Ví dụ: nhanvien@omnistay.com" required>
                </div>

                <div class="col-md-3">
                    <label class="form-label text-muted" style="font-size: 0.8rem; text-transform: uppercase;">Mật khẩu</label>
                    <input type="password" name="password" class="form-control bg-light" placeholder="••••••••" required>
                </div>

                <div class="col-md-2">
                    <label class="form-label text-muted" style="font-size: 0.8rem; text-transform: uppercase;">Vai trò</label>
                    <select name="role" class="form-select bg-light">
                        <option value="STAFF">Staff (Nhân viên)</option>
                        <option value="ADMIN">Admin (Quản trị)</option>
                    </select>
                </div>

                <div class="col-md-1 text-end">
                    <button class="btn text-white w-100 py-2" style="background-color: var(--primary); border-radius: 8px;">
                        <i class="bi bi-plus-lg"></i>
                    </button>
                </div>
            </form>
        </div>

        <div class="table-custom">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead>
                        <tr>
                            <th class="text-center" style="width: 80px;">ID</th>
                            <th>Họ và Tên</th>
                            <th>Tài khoản Email</th>
                            <th>Vai trò (Role)</th>
                            <th class="text-end">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if(conn != null) {
                                String sqlSelect = "SELECT * FROM staff ORDER BY id DESC";
                                PreparedStatement psSelect = conn.prepareStatement(sqlSelect);
                                rs = psSelect.executeQuery();

                                while(rs.next()){
                                    int id = rs.getInt("id");
                                    String role = rs.getString("role");
                        %>
                        <tr>
                            <td class="text-center text-muted fw-500"><%= id %></td>
                            <td class="fw-500" style="color: var(--text-main);"><%= rs.getString("full_name") %></td>
                            <td class="text-muted"><i class="bi bi-envelope me-2"></i><%= rs.getString("email") %></td>
                            <td>
                                <% if("ADMIN".equals(role)){ %>
                                    <span class="badge" style="background-color: rgba(212, 168, 71, 0.15); color: #b8860b; border: 1px solid rgba(212, 168, 71, 0.3);">
                                        <i class="bi bi-shield-lock me-1"></i> Quản trị viên
                                    </span>
                                <% } else { %>
                                    <span class="badge bg-light text-dark border"><i class="bi bi-person me-1"></i> Nhân viên</span>
                                <% } %>
                            </td>
                            <td class="text-end">
                                <a href="admin-staff.jsp?delete=<%= id %>" 
                                   onclick="return confirm('Bạn có chắc chắn muốn xóa nhân viên này khỏi hệ thống? Hành động này không thể hoàn tác.')" 
                                   class="action-btn text-danger" title="Xóa nhân viên">
                                    <i class="bi bi-trash3"></i>
                                </a>
                            </td>
                        </tr>
                        <%
                                }
                                rs.close();
                                psSelect.close();
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
<%
    if(conn != null) conn.close();
%>