<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../layouts/admin-auth.jsp" %>
<%
    if (!"ADMIN".equals(adminRole)) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
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
    <link rel="icon" type="image/png" href="<%=request.getContextPath()%>/images/logo.png">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;1,400&family=Outfit:wght@300;400;500;600&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
    <link rel="stylesheet" href="admin-theme.css">
</head>
<body>
    <%@ include file="../layouts/sidebar-admin.jsp" %>
    
    <main class="main-content">
        <div class="page-header">
            <div class="d-flex align-items-center">
                <div class="page-title-icon"><i class="bi bi-person-badge"></i></div>
                <div>
                    <h2 class="font-display fw-normal mb-1">Quản lý Nhân viên</h2>
                    <p class="text-muted mb-0">Thao tác thêm, sửa, xóa nhân viên ngay trên hệ thống.</p>
                </div>
            </div>
            <button class="btn btn-primary-gradient rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#addStaffModal">
                <i class="bi bi-person-plus me-1"></i> Thêm nhân viên
            </button>
        </div>

        <% if (thongBao != null) { %>
            <div class="alert alert-<%= loaiThongBao %> alert-dismissible fade show shadow-sm mb-4">
                <i class="bi <%= loaiThongBao.equals("success") ? "bi-check-circle-fill" : "bi-exclamation-triangle-fill" %> me-2"></i> <%= thongBao %>
                <button type="button" class="btn-close shadow-none" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <%
            String staffSearch = request.getParameter("staffSearch");
        %>

        <!-- Filter Bar -->
        <form action="admin-staff.jsp" method="GET" class="filter-bar">
            <div class="row g-3 align-items-center">
                <div class="col-md-8">
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-search"></i></span>
                        <input type="text" name="staffSearch" class="form-control" placeholder="Tìm theo tên hoặc email nhân viên..." value="<%= (staffSearch != null) ? staffSearch : "" %>">
                    </div>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-primary-gradient w-100">Tìm kiếm</button>
                </div>
                <div class="col-md-2 text-end">
                    <a href="admin-staff.jsp" class="btn btn-light w-100 border rounded-pill text-muted small">Xóa lọc</a>
                </div>
            </div>
        </form>

        <div class="table-custom p-4">
            <div class="table-responsive">
                <table id="staffTable" class="table table-hover align-middle mb-0 w-100">
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
                                    String sql = "SELECT * FROM staff WHERE 1=1 ";
                                    if(staffSearch != null && !staffSearch.trim().isEmpty()) {
                                        sql += " AND (full_name LIKE ? OR email LIKE ?)";
                                    }
                                    sql += " ORDER BY role ASC, full_name ASC";
                                    
                                    PreparedStatement ps = conn.prepareStatement(sql);
                                    if(staffSearch != null && !staffSearch.trim().isEmpty()) {
                                        String pat = "%" + staffSearch.trim() + "%";
                                        ps.setString(1, pat); ps.setString(2, pat);
                                    }
                                    
                                    ResultSet rs = ps.executeQuery();
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
                                    <div class="guest-avatar" style="background: <%= role.equals("ADMIN") ? "rgba(220, 53, 69, 0.1)" : "rgba(26, 107, 90, 0.1)" %>; color: <%= role.equals("ADMIN") ? "#dc3545" : "var(--primary)" %>">
                                        <%= initials %>
                                    </div>
                                    <div>
                                        <div class="fw-500 text-dark" style="font-size: 1rem;"><%= name %></div>
                                        <div class="text-muted small">#STF-<%= id %></div>
                                    </div>
                                </div>
                            </td>
                            <td><div class="text-muted"><i class="bi bi-envelope me-2"></i><%= email %></div></td>
                            <td>
                                <% if(role.equals("ADMIN")) { %>
                                    <span class="badge rounded-pill" style="background: rgba(220, 53, 69, 0.1); color: #dc3545; border: 1px solid rgba(220, 53, 69, 0.2); padding: 0.4rem 0.8rem; font-weight: 500;">
                                        <i class="bi bi-shield-lock me-1"></i> Quản trị viên
                                    </span>
                                <% } else { %>
                                    <span class="badge rounded-pill" style="background: rgba(26, 107, 90, 0.1); color: var(--primary); border: 1px solid rgba(26, 107, 90, 0.2); padding: 0.4rem 0.8rem; font-weight: 500;">
                                        <i class="bi bi-person-workspace me-1"></i> Lễ tân
                                    </span>
                                <% } %>
                            </td>
                            <td><div class="small text-muted"><%= createdAt != null ? sdf.format(createdAt) : "N/A" %></div></td>
                            <td class="text-end">
                                <a class="action-btn" onclick="openEditModal(<%= id %>, '<%= name %>', '<%= email %>', '<%= role %>')" title="Sửa"><i class="bi bi-pencil-square text-primary"></i></a>
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
                                    rs.close(); ps.close();
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
                    <h5 class="modal-title font-display fw-bold" style="color: var(--primary);">Thêm nhân viên mới</h5>
                    <button type="button" class="btn-close shadow-none" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="admin-staff.jsp" method="POST">
                    <input type="hidden" name="action" value="add">
                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label class="form-label">Họ và tên</label>
                            <input type="text" name="fullName" class="form-control" placeholder="Nhập tên nhân viên" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Email đăng nhập</label>
                            <input type="email" name="email" class="form-control" placeholder="example@omnistay.vn" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Mật khẩu</label>
                            <input type="password" name="password" class="form-control" placeholder="••••••••" required>
                        </div>
                        <div class="mb-0">
                            <label class="form-label">Quyền hạn</label>
                            <select name="role" class="form-select">
                                <option value="RECEPTIONIST">Lễ tân (Receptionist)</option>
                                <option value="ADMIN">Quản trị viên (Admin)</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-primary-gradient px-4">Lưu thông tin</button>
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
                    <h5 class="modal-title font-display fw-bold" style="color: var(--primary);">Chỉnh sửa nhân viên</h5>
                    <button type="button" class="btn-close shadow-none" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="admin-staff.jsp" method="POST">
                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="staffId" id="editStaffId">
                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label class="form-label">Họ và tên</label>
                            <input type="text" name="fullName" id="editFullName" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Email đăng nhập</label>
                            <input type="email" name="email" id="editEmail" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Mật khẩu mới (Để trống nếu không đổi)</label>
                            <input type="password" name="password" class="form-control" placeholder="••••••••">
                        </div>
                        <div class="mb-0">
                            <label class="form-label">Quyền hạn</label>
                            <select name="role" id="editRole" class="form-select">
                                <option value="RECEPTIONIST">Lễ tân (Receptionist)</option>
                                <option value="ADMIN">Quản trị viên (Admin)</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-primary-gradient px-4">Cập nhật</button>
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
                "searching": false,
                "ordering": false,
                "language": {
                    "zeroRecords": "Không tìm thấy nhân viên nào",
                    "info": "Đang xem _START_ đến _END_ trong tổng số _TOTAL_ nhân viên",
                    "infoEmpty": "Không có dữ liệu",
                    "paginate": { "first": "Đầu", "previous": "Trước", "next": "Sau", "last": "Cuối" }
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