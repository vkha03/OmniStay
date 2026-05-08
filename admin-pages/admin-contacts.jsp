<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../layouts/admin-auth.jsp" %>
<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<%@ include file="../env-secrets.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    Connection conn = null;
    String thongBao = null;
    String loaiThongBao = "success";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(SECRET_DB_URL, SECRET_DB_USER, SECRET_DB_PASS);

        String action = request.getParameter("action");
        if (action != null) {
            int id = Integer.parseInt(request.getParameter("id"));
            if (action.equals("markRead")) {
                PreparedStatement ps = conn.prepareStatement("UPDATE contacts SET status = 'READ' WHERE id = ?");
                ps.setInt(1, id);
                ps.executeUpdate();
                thongBao = "Đã đánh dấu là đã đọc!";
            } else if (action.equals("delete")) {
                PreparedStatement ps = conn.prepareStatement("DELETE FROM contacts WHERE id = ?");
                ps.setInt(1, id);
                ps.executeUpdate();
                thongBao = "Đã xóa liên hệ!";
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
    <title>Quản lý Liên hệ — OmniStay Admin</title>
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
        
        .status-unread { background: rgba(220, 53, 69, 0.1); color: #dc3545; }
        .status-read { background: rgba(26, 107, 90, 0.1); color: var(--primary); }
        
        .action-btn { width: 32px; height: 32px; display: inline-flex; align-items: center; justify-content: center; border-radius: 8px; transition: 0.2s; color: #666; text-decoration: none; border: 1px solid transparent; cursor: pointer; }
        .action-btn:hover { background: var(--bg-light); color: var(--primary); border-color: var(--border); }
        
        .modal-content { border-radius: 20px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
    </style>
</head>
<body>
    <%@ include file="../layouts/sidebar-admin.jsp" %>
    
    <main class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="font-display fw-normal mb-1">Tin nhắn Liên hệ</h2>
                <p class="text-muted mb-0" style="font-size: 0.9rem;">Danh sách khách hàng quan tâm và yêu cầu tư vấn qua Website.</p>
            </div>
            <button class="btn btn-outline-secondary rounded-pill px-4" style="font-size: 0.85rem;" onclick="location.reload()">
                <i class="bi bi-arrow-clockwise me-1"></i> Làm mới
            </button>
        </div>

        <% if (thongBao != null) { %>
            <div class="alert alert-<%= loaiThongBao %> alert-dismissible fade show border-0 mb-4 shadow-sm" style="border-radius: 12px;">
                <i class="bi bi-check-circle-fill me-2"></i> <%= thongBao %>
                <button type="button" class="btn-close shadow-none" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <div class="table-custom">
            <div class="table-responsive">
                <table id="contactTable" class="table table-hover align-middle mb-0">
                    <thead>
                        <tr>
                            <th>Khách hàng</th>
                            <th>Tiêu đề</th>
                            <th>Ngày gửi</th>
                            <th>Trạng thái</th>
                            <th class="text-end">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if(conn != null) {
                                try {
                                    Statement st = conn.createStatement();
                                    ResultSet rs = st.executeQuery("SELECT * FROM contacts ORDER BY created_at DESC");
                                    while(rs.next()) {
                                        int id = rs.getInt("id");
                                        String name = rs.getString("full_name");
                                        String email = rs.getString("email");
                                        String subject = rs.getString("subject");
                                        String message = rs.getString("message");
                                        String status = rs.getString("status");
                                        Timestamp createdAt = rs.getTimestamp("created_at");
                        %>
                        <tr style="<%= status.equals("UNREAD") ? "font-weight: 500;" : "" %>">
                            <td>
                                <div class="fw-600 text-dark"><%= name %></div>
                                <div class="text-muted small"><%= email %></div>
                            </td>
                            <td><div class="text-truncate" style="max-width: 250px;"><%= subject %></div></td>
                            <td><div class="small text-muted"><%= sdf.format(createdAt) %></div></td>
                            <td>
                                <span class="badge rounded-pill px-3 py-2 <%= status.equals("UNREAD") ? "status-unread" : "status-read" %>">
                                    <%= status.equals("UNREAD") ? "Chưa đọc" : "Đã đọc" %>
                                </span>
                            </td>
                            <td class="text-end">
                                <a class="action-btn" onclick="viewMessage('<%= name %>', '<%= email %>', '<%= subject %>', `<%= message %>`)" title="Xem nội dung"><i class="bi bi-eye"></i></a>
                                <% if(status.equals("UNREAD")) { %>
                                    <form action="admin-contacts.jsp" method="POST" style="display:inline;">
                                        <input type="hidden" name="action" value="markRead">
                                        <input type="hidden" name="id" value="<%= id %>">
                                        <button type="submit" class="action-btn" title="Đánh dấu đã đọc"><i class="bi bi-check2-circle text-success"></i></button>
                                    </form>
                                <% } %>
                                <form action="admin-contacts.jsp" method="POST" style="display:inline;" onsubmit="return confirm('Xóa liên hệ này?')">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<%= id %>">
                                    <button type="submit" class="action-btn" title="Xóa"><i class="bi bi-trash3 text-danger"></i></button>
                                </form>
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

    <!-- Modal Xem tin nhắn -->
    <div class="modal fade" id="viewModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title font-display fw-bold">Nội dung liên hệ</h5>
                    <button type="button" class="btn-close shadow-none" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-4">
                        <label class="text-muted small mb-1">Người gửi:</label>
                        <h6 id="msgName" class="fw-bold mb-0"></h6>
                        <span id="msgEmail" class="small text-primary"></span>
                    </div>
                    <div class="mb-4">
                        <label class="text-muted small mb-1">Tiêu đề:</label>
                        <div id="msgSubject" class="fw-bold"></div>
                    </div>
                    <div class="p-3 bg-light rounded-3">
                        <label class="text-muted small mb-2">Lời nhắn:</label>
                        <p id="msgContent" class="mb-0" style="white-space: pre-wrap; line-height: 1.6;"></p>
                    </div>
                </div>
                <div class="modal-footer border-0">
                    <button type="button" class="btn btn-secondary rounded-pill px-4" data-bs-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.7.0.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>

    <script>
        $(document).ready(function() {
            $('#contactTable').DataTable({
                "pageLength": 10,
                "lengthChange": false,
                "language": {
                    "search": "Tìm kiếm:",
                    "paginate": { "previous": "<i class='bi bi-chevron-left'></i>", "next": "<i class='bi bi-chevron-right'></i>" }
                }
            });
        });

        function viewMessage(name, email, subject, message) {
            document.getElementById('msgName').innerText = name;
            document.getElementById('msgEmail').innerText = email;
            document.getElementById('msgSubject').innerText = subject;
            document.getElementById('msgContent').innerText = message;
            new bootstrap.Modal(document.getElementById('viewModal')).show();
        }
    </script>
    <% if(conn != null) try { conn.close(); } catch(Exception e) {} %>
</body>
</html>
