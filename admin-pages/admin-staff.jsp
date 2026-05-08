<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../layouts/admin-auth.jsp" %>
<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<%@ include file="../env-secrets.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    Connection conn = null;
    String thongBao = null;
    String loaiThongBao = "success"; // success hoặc danger

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(SECRET_DB_URL, SECRET_DB_USER, SECRET_DB_PASS);

        // ─── XỬ LÝ LOGIC (ADD / EDIT / DELETE) ───
        String action = request.getParameter("action");
        if (action != null) {
            if (action.equals("add")) {
                String name = request.getParameter("fullName");
                String email = request.getParameter("email");
                String pass = request.getParameter("password");
                String role = request.getParameter("role");
                
                PreparedStatement ps = conn.prepareStatement("INSERT INTO staff (full_name, email, password, role) VALUES (?, ?, ?, ?)");
                ps.setString(1, name);
                ps.setString(2, email);
                ps.setString(3, pass);
                ps.setString(4, role);
                ps.executeUpdate();
                thongBao = "Đã thêm nhân viên mới thành công!";
            } 
            else if (action.equals("edit")) {
                int id = Integer.parseInt(request.getParameter("staffId"));
                String name = request.getParameter("fullName");
                String email = request.getParameter("email");
                String role = request.getParameter("role");
                String pass = request.getParameter("password");

                String sql = "UPDATE staff SET full_name=?, email=?, role=? " + (pass != null && !pass.isEmpty() ? ", password=?" : "") + " WHERE id=?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, name);
                ps.setString(2, email);
                ps.setString(3, role);
                if (pass != null && !pass.isEmpty()) {
                    ps.setString(4, pass);
                    ps.setInt(5, id);
                } else {
                    ps.setInt(4, id);
                }
                ps.executeUpdate();
                thongBao = "Đã cập nhật thông tin nhân viên!";
            }
            else if (action.equals("delete")) {
                int id = Integer.parseInt(request.getParameter("staffId"));
                if (id != 1) { // Không cho xóa admin gốc
                    PreparedStatement ps = conn.prepareStatement("DELETE FROM staff WHERE id = ?");
                    ps.setInt(1, id);
                    ps.executeUpdate();
                    thongBao = "Đã thu hồi tài khoản nhân viên!";
                } else {
                    thongBao = "Không thể xóa tài khoản Quản trị viên gốc!";
                    loaiThongBao = "danger";
                }
            }
        }
    } catch(Exception e) {
        thongBao = "Lỗi: " + e.getMessage();
        loaiThongBao = "danger";
    }
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
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
        
        .staff-avatar { width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-weight: 600; margin-right: 12px; }
        .badge-role { padding: 0.5rem 1rem; border-radius: 50px; font-size: 0.75rem; font-weight: 500; display: inline-flex; align-items: center; gap: 6px; }
        .badge-admin { background: rgba(220, 53, 69, 0.1); color: #dc3545; border: 1px solid rgba(220, 53, 69, 0.2); }
        .badge-receptionist { background: rgba(26, 107, 90, 0.1); color: var(--primary); border: 1px solid rgba(26, 107, 90, 0.2); }
        
        .action-btn { width: 32px; height: 32px; display: inline-flex; align-items: center; justify-content: center; border-radius: 8px; transition: 0.2s; color: #666; text-decoration: none; border: 1px solid transparent; cursor: pointer; }
        .action-btn:hover { background: var(--bg-light); color: var(--primary); border-color: var(--border); }
        
        .modal-content { border-radius: 20px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
        .modal-header { border-bottom: 1px solid #eee; padding: 1.5rem 2rem; }
        .modal-body { padding: 2rem; }
        .form-control, .form-select { border-radius: 10px; padding: 0.7rem 1rem; border: 1px solid #ddd; }
        .form-control:focus { box-shadow: 0 0 0 4px rgba(26, 107, 90, 0.1); border-color: var(--primary); }
    </style>
</head>
<body>
    <%@ include file="../layouts/sidebar-admin.jsp" %>
    
    <main class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="font-display fw-normal mb-1">Quản lý Nhân viên</h2>
                <p class="text-muted mb-0" style="font-size: 0.9rem;">Thao tác thêm, sửa, xóa nhân viên ngay trên hệ thống.</p>
            </div>
            <button class="btn text-white rounded-pill px-4" style="background: var(--primary);" data-bs-toggle="modal" data-bs-target="#addStaffModal">
                <i class="bi bi-plus-lg me-1"></i> Thêm nhân viên
            </button>
        </div>

        <% if (thongBao != null) { %>
            <div class="alert alert-<%= loaiThongBao %> alert-dismissible fade show border-0 mb-4 shadow-sm" style="border-radius: 12px;">
                <i class="bi <%= loaiThongBao.equals("success") ? "bi-check-circle-fill" : "bi-exclamation-triangle-fill" %> me-2"></i> <%= thongBao %>
                <button type="button" class="btn-close shadow-none" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <div class="table-custom">
            <div class="table-responsive">
                <table id="staffTable" class="table table-hover align-middle mb-0">
                    <thead>
                        <tr>
                            <th>Nhân viên</th>
                            <th>Email đăng nhập</th>
                            <th>Quyền hạn</th>
                            <th>Ngày gia nhập</th>
                            <th class="text-end">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if(conn != null) {
                                try {
                                    Statement st = conn.createStatement();
                                    ResultSet rs = st.executeQuery("SELECT * FROM staff ORDER BY role ASC, full_name ASC");
                                    while(rs.next()) {
                                        int id = rs.getInt("id");
                                        String name = rs.getString("full_name");
                                        String email = rs.getString("email");
                                        String role = rs.getString("role");
                                        Timestamp createdAt = rs.getTimestamp("created_at");
                                        String initials = (name != null && name.contains(" ")) ? name.substring(name.lastIndexOf(" ")+1, name.lastIndexOf(" ")+2).toUpperCase() : (name != null ? name.substring(0,1).toUpperCase() : "?");
                        %>
                        <tr>
                            <td>
                                <div class="d-flex align-items-center">
                                    <div class="staff-avatar" style="background: <%= role.equals("ADMIN") ? "rgba(220, 53, 69, 0.1)" : "rgba(26, 107, 90, 0.1)" %>; color: <%= role.equals("ADMIN") ? "#dc3545" : "#1a6b5a" %>">
                                        <%= initials %>
                                    </div>
                                    <div>
                                        <div class="fw-500 text-dark"><%= name %></div>
                                        <div class="text-muted small">#STF-<%= id %></div>
                                    </div>
                                </div>
                            </td>
                            <td><div class="small"><i class="bi bi-envelope me-2 text-muted"></i><%= email %></div></td>
                            <td>
                                <span class="badge-role <%= role.equals("ADMIN") ? "badge-admin" : "badge-receptionist" %>">
                                    <i class="bi <%= role.equals("ADMIN") ? "bi-shield-lock" : "bi-person-workspace" %>"></i> 
                                    <%= role.equals("ADMIN") ? "Quản trị viên" : "Lễ tân" %>
                                </span>
                            </td>
                            <td><div class="small text-muted"><%= createdAt != null ? sdf.format(createdAt) : "N/A" %></div></td>
                            <td class="text-end">
                                <a class="action-btn" onclick="openEditModal(<%= id %>, '<%= name %>', '<%= email %>', '<%= role %>')" title="Sửa"><i class="bi bi-pencil-square"></i></a>
                                <% if(id != 1) { %>
                                    <form action="admin-staff.jsp" method="POST" style="display:inline;" onsubmit="return confirm('Thu hồi tài khoản này?')">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="staffId" value="<%= id %>">
                                        <button type="submit" class="action-btn" style="border:none; background:none;"><i class="bi bi-trash3 text-danger"></i></button>
                                    </form>
                                <% } %>
                            </td>
                        </tr>
                        <%
                                    }
                                    rs.close(); st.close();
                                } catch(Exception e) { out.println("Lỗi: " + e.getMessage()); }
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <!-- Modal Thêm nhân viên -->
    <div class="modal fade" id="addStaffModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title font-display fw-bold">Thêm nhân viên mới</h5>
                    <button type="button" class="btn-close shadow-none" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="admin-staff.jsp" method="POST">
                    <input type="hidden" name="action" value="add">
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label small fw-500">Họ và tên</label>
                            <input type="text" name="fullName" class="form-control" placeholder="Nhập tên nhân viên" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-500">Email đăng nhập</label>
                            <input type="email" name="email" class="form-control" placeholder="example@omnistay.vn" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-500">Mật khẩu</label>
                            <input type="password" name="password" class="form-control" placeholder="••••••••" required>
                        </div>
                        <div class="mb-0">
                            <label class="form-label small fw-500">Quyền hạn</label>
                            <select name="role" class="form-select">
                                <option value="RECEPTIONIST">Lễ tân (Receptionist)</option>
                                <option value="ADMIN">Quản trị viên (Admin)</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer border-0 px-4 pb-4">
                        <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn text-white rounded-pill px-4" style="background: var(--primary);">Lưu thông tin</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Modal Sửa nhân viên -->
    <div class="modal fade" id="editStaffModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title font-display fw-bold">Chỉnh sửa nhân viên</h5>
                    <button type="button" class="btn-close shadow-none" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="admin-staff.jsp" method="POST">
                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="staffId" id="editStaffId">
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label small fw-500">Họ và tên</label>
                            <input type="text" name="fullName" id="editFullName" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-500">Email đăng nhập</label>
                            <input type="email" name="email" id="editEmail" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-500">Mật khẩu mới (Để trống nếu không đổi)</label>
                            <input type="password" name="password" class="form-control" placeholder="••••••••">
                        </div>
                        <div class="mb-0">
                            <label class="form-label small fw-500">Quyền hạn</label>
                            <select name="role" id="editRole" class="form-select">
                                <option value="RECEPTIONIST">Lễ tân (Receptionist)</option>
                                <option value="ADMIN">Quản trị viên (Admin)</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer border-0 px-4 pb-4">
                        <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn text-white rounded-pill px-4" style="background: var(--primary);">Cập nhật</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.7.0.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>

    <script>
        $(document).ready(function() {
            $('#staffTable').DataTable({
                "pageLength": 10,
                "lengthChange": false,
                "language": {
                    "search": "Tìm nhân viên:",
                    "paginate": { "previous": "<i class='bi bi-chevron-left'></i>", "next": "<i class='bi bi-chevron-right'></i>" }
                }
            });
        });

        function openEditModal(id, name, email, role) {
            document.getElementById('editStaffId').value = id;
            document.getElementById('editFullName').value = name;
            document.getElementById('editEmail').value = email;
            document.getElementById('editRole').value = role;
            var myModal = new bootstrap.Modal(document.getElementById('editStaffModal'));
            myModal.show();
        }
    </script>
    <% if(conn != null) try { conn.close(); } catch(Exception e) {} %>
</body>
</html>