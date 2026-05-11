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
            if (action.equals("markResolved")) {
                PreparedStatement ps = conn.prepareStatement("UPDATE contacts SET status = 'RESOLVED' WHERE id = ?");
                ps.setInt(1, id);
                ps.executeUpdate();
                thongBao = "Đã đánh dấu là đã giải quyết!";
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
                <div class="page-title-icon"><i class="bi bi-envelope-paper"></i></div>
                <div>
                    <h2 class="font-display fw-normal mb-1">Tin nhắn Liên hệ</h2>
                    <p class="text-muted mb-0">Danh sách khách hàng quan tâm và yêu cầu tư vấn qua Website.</p>
                </div>
            </div>
            <button class="btn btn-outline-secondary rounded-pill px-4" onclick="location.reload()">
                <i class="bi bi-arrow-clockwise me-1"></i> Làm mới
            </button>
        </div>

        <% if (thongBao != null) { %>
            <div class="alert alert-<%= loaiThongBao %> alert-dismissible fade show shadow-sm mb-4">
                <i class="bi bi-check-circle-fill me-2"></i> <%= thongBao %>
                <button type="button" class="btn-close shadow-none" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <%
            String contactSearch = request.getParameter("contactSearch");
        %>

        <!-- Filter Bar -->
        <form action="admin-contacts.jsp" method="GET" class="filter-bar">
            <div class="row g-3 align-items-center">
                <div class="col-md-8">
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-search"></i></span>
                        <input type="text" name="contactSearch" class="form-control" placeholder="Tìm theo tên khách, email hoặc tiêu đề liên hệ..." value="<%= (contactSearch != null) ? contactSearch : "" %>">
                    </div>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-primary-gradient w-100">Tìm kiếm</button>
                </div>
                <div class="col-md-2 text-end">
                    <a href="admin-contacts.jsp" class="btn btn-light w-100 border rounded-pill text-muted small">Xóa lọc</a>
                </div>
            </div>
        </form>

        <div class="table-custom p-4">
            <div class="table-responsive">
                <table id="contactTable" class="table table-hover align-middle mb-0 w-100">
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
                                    String sql = "SELECT * FROM contacts WHERE 1=1 ";
                                    if(contactSearch != null && !contactSearch.trim().isEmpty()) {
                                        sql += " AND (full_name LIKE ? OR email LIKE ? OR subject LIKE ?)";
                                    }
                                    sql += " ORDER BY created_at DESC";
                                    
                                    PreparedStatement ps = conn.prepareStatement(sql);
                                    if(contactSearch != null && !contactSearch.trim().isEmpty()) {
                                        String pat = "%" + contactSearch.trim() + "%";
                                        ps.setString(1, pat); ps.setString(2, pat); ps.setString(3, pat);
                                    }
                                    
                                    ResultSet rs = ps.executeQuery();
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
                                <div class="fw-600 text-dark" style="font-size: 1rem;"><%= name %></div>
                                <div class="text-muted small"><%= email %></div>
                            </td>
                            <td><div class="text-truncate text-dark" style="max-width: 280px; font-weight: <%= status.equals("UNREAD") ? "600" : "400" %>;"><%= subject %></div></td>
                            <td><div class="small text-muted"><%= sdf.format(createdAt) %></div></td>
                            <td>
                                <span class="badge rounded-pill px-3 py-2 <%= status.equals("UNREAD") ? "status-unread" : "status-resolved" %>">
                                    <%= status.equals("UNREAD") ? "Chưa đọc" : "Đã giải quyết" %>
                                </span>
                            </td>
                            <td class="text-end">
                                <a class="action-btn" onclick="viewMessage('<%= name %>', '<%= email %>', '<%= subject %>', `<%= message %>`)" title="Xem nội dung"><i class="bi bi-eye text-primary"></i></a>
                                <% if(status.equals("UNREAD")) { %>
                                    <form action="admin-contacts.jsp" method="POST" style="display:inline;">
                                        <input type="hidden" name="action" value="markResolved">
                                        <input type="hidden" name="id" value="<%= id %>">
                                        <button type="submit" class="action-btn" title="Đánh dấu đã giải quyết"><i class="bi bi-check-circle text-success"></i></button>
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
                                    rs.close(); ps.close();
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
                    <h5 class="modal-title font-display fw-bold" style="color: var(--primary);">Nội dung liên hệ</h5>
                    <button type="button" class="btn-close shadow-none" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-4 d-flex align-items-center gap-3">
                        <div class="guest-avatar" style="width: 48px; height: 48px; font-size: 1.2rem; background: var(--primary-light); color: var(--primary); border-radius: 12px; display: flex; align-items: center; justify-content: center; font-weight: 600;"><i class="bi bi-person"></i></div>
                        <div>
                            <label class="text-muted small mb-0">Người gửi:</label>
                            <h6 id="msgName" class="fw-bold mb-0" style="font-size: 1.1rem;"></h6>
                            <span id="msgEmail" class="small text-primary"></span>
                        </div>
                    </div>
                    <div class="mb-4">
                        <label class="text-muted small mb-1">Chủ đề:</label>
                        <div id="msgSubject" class="fw-bold text-dark" style="font-size: 1.05rem;"></div>
                    </div>
                    <div class="p-3 rounded-3" style="background: var(--bg-light); border: 1px solid var(--border);">
                        <label class="text-muted small mb-2"><i class="bi bi-chat-quote me-1"></i>Nội dung:</label>
                        <p id="msgContent" class="mb-0 text-dark" style="white-space: pre-wrap; line-height: 1.6;"></p>
                    </div>
                </div>
                <div class="modal-footer">
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
                "searching": false,
                "ordering": false,
                "language": {
                    "zeroRecords": "Không tìm thấy liên hệ nào",
                    "info": "Đang xem _START_ đến _END_ trong tổng số _TOTAL_ liên hệ",
                    "infoEmpty": "Không có dữ liệu",
                    "paginate": { "first": "Đầu", "previous": "Trước", "next": "Sau", "last": "Cuối" }
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
