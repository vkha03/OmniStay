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
        
        // --- XỬ LÝ POST ACTION (EDIT / DELETE GUEST) ---
        if("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("action") != null) {
            String action = request.getParameter("action");
            if(action.equals("editGuest")) {
                int id = Integer.parseInt(request.getParameter("id"));
                String fullName = request.getParameter("full_name");
                String idCard = request.getParameter("id_card");
                String phone = request.getParameter("phone_number");
                String email = request.getParameter("email");
                
                String sql = "UPDATE guests SET full_name = ?, id_card = ?, phone_number = ?, email = ? WHERE id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, fullName);
                ps.setString(2, idCard);
                ps.setString(3, phone);
                ps.setString(4, email);
                ps.setInt(5, id);
                ps.executeUpdate();
                ps.close();
                
                session.setAttribute("thongBao", "Đã cập nhật thông tin khách hàng!");
                response.sendRedirect("admin-guests.jsp");
                return;
            } else if(action.equals("deleteGuest")) {
                int id = Integer.parseInt(request.getParameter("id"));
                String sql = "DELETE FROM guests WHERE id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, id);
                ps.executeUpdate();
                ps.close();
                
                session.setAttribute("thongBao", "Đã xóa khách hàng khỏi hệ thống!");
                response.sendRedirect("admin-guests.jsp");
                return;
            }
        }
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
        <!-- Header -->
        <div class="page-header">
            <div class="d-flex align-items-center">
                <div class="page-title-icon"><i class="bi bi-people"></i></div>
                <div>
                    <h2 class="font-display fw-normal mb-1">Quản lý Khách hàng</h2>
                    <p class="text-muted mb-0">Danh sách khách hàng đã từng lưu trú và đặt phòng tại hệ thống.</p>
                </div>
            </div>
            <div class="d-flex gap-2">
                <button class="btn btn-outline-secondary rounded-pill px-4" onclick="location.reload()">
                    <i class="bi bi-arrow-clockwise me-1"></i> Làm mới
                </button>
            </div>
        </div>

        <%
            String msg = (String) session.getAttribute("thongBao");
            if (msg != null) {
        %>
            <div class="alert alert-success alert-dismissible fade show shadow-sm mb-4">
                <i class="bi bi-check-circle-fill me-2"></i> <%= msg %>
                <button type="button" class="btn-close shadow-none" data-bs-dismiss="alert"></button>
            </div>
        <%
                session.removeAttribute("thongBao");
            }
            String guestSearch = request.getParameter("guestSearch");
        %>

        <!-- Filter Bar -->
        <form action="admin-guests.jsp" method="GET" class="filter-bar">
            <div class="row g-3 align-items-center">
                <div class="col-md-8">
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-search"></i></span>
                        <input type="text" name="guestSearch" class="form-control" placeholder="Tìm theo tên, số điện thoại, email hoặc CCCD của khách..." value="<%= (guestSearch != null) ? guestSearch : "" %>">
                    </div>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-primary-gradient w-100">Tìm kiếm</button>
                </div>
                <div class="col-md-2 text-end">
                    <a href="admin-guests.jsp" class="btn btn-light w-100 border rounded-pill text-muted small">Xóa lọc</a>
                </div>
            </div>
        </form>

        <!-- Table Card -->
        <div class="table-custom p-4">
            <div class="table-responsive">
                <table id="guestTable" class="table table-hover align-middle mb-0 w-100">
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
                                    String sql = "SELECT g.*, " +
                                                 "(SELECT COUNT(*) FROM bookings b WHERE b.guest_id = g.id) as booking_count, " +
                                                 "(SELECT SUM(total_amount) FROM bookings b WHERE b.guest_id = g.id AND b.status != 'CANCELLED') as total_spent " +
                                                 "FROM guests g WHERE 1=1 ";
                                    
                                    if(guestSearch != null && !guestSearch.trim().isEmpty()) {
                                        sql += " AND (g.full_name LIKE ? OR g.phone_number LIKE ? OR g.email LIKE ? OR g.id_card LIKE ?)";
                                    }
                                    
                                    sql += " ORDER BY total_spent DESC, full_name ASC";
                                    
                                    PreparedStatement ps = conn.prepareStatement(sql);
                                    if(guestSearch != null && !guestSearch.trim().isEmpty()) {
                                        String pat = "%" + guestSearch.trim() + "%";
                                        ps.setString(1, pat); ps.setString(2, pat); ps.setString(3, pat); ps.setString(4, pat);
                                    }
                                    
                                    ResultSet rs = ps.executeQuery();
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
                                        <div class="fw-600 text-dark" style="font-size: 1rem;"><%= name %></div>
                                        <div class="text-muted" style="font-size: 0.8rem;">ID: #GST-<%= id %></div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div><i class="bi bi-telephone text-muted" style="width: 16px; display: inline-block;"></i> <%= phone %></div>
                                <div class="text-muted"><i class="bi bi-envelope" style="width: 16px; display: inline-block;"></i> <%= email != null ? email : "N/A" %></div>
                            </td>
                            <td>
                                <span class="badge bg-light text-dark border fw-normal py-1 px-2">
                                    <i class="bi bi-person-vcard text-primary me-1"></i> <%= idCard != null ? idCard : "N/A" %>
                                </span>
                            </td>
                            <td class="text-center">
                                <% if(bookingCount > 5) { %>
                                <span class="badge bg-primary rounded-pill px-2 py-1"><i class="bi bi-star-fill text-warning me-1"></i><%= bookingCount %></span>
                                <% } else { %>
                                <span class="badge bg-light text-dark border rounded-pill px-2 py-1"><%= bookingCount %></span>
                                <% } %>
                            </td>
                            <td class="text-end fw-bold" style="color: var(--primary);">
                                <%= nf.format(totalSpent).replace("VNĐ", "₫") %>
                            </td>
                            <td class="text-end">
                                <a onclick="openEditGuestModal(<%= id %>, '<%= name %>', '<%= idCard != null ? idCard : "" %>', '<%= phone %>', '<%= email != null ? email : "" %>')" class="action-btn" title="Sửa thông tin"><i class="bi bi-pencil-square text-primary"></i></a>
                                <form action="admin-guests.jsp" method="POST" style="display:inline;" onsubmit="return confirm('Xóa khách hàng này sẽ ảnh hưởng đến lịch sử đặt phòng. Bạn chắc chắn chứ?')">
                                    <input type="hidden" name="action" value="deleteGuest">
                                    <input type="hidden" name="id" value="<%= id %>">
                                    <button type="submit" class="action-btn" style="border:none; background:none;"><i class="bi bi-trash3 text-danger"></i></button>
                                </form>
                            </td>
                        </tr>
                        <%
                                    }
                                    rs.close(); ps.close();
                                    conn.close();
                                } catch(Exception e) {
                                    out.println("<tr><td colspan='6'>Lỗi: " + e.getMessage() + "</td></tr>");
                                }
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <!-- Modal Sửa Khách hàng -->
    <div class="modal fade" id="editGuestModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title font-display fw-bold" style="color: var(--primary);">Chỉnh sửa Thông tin Khách</h5>
                    <button type="button" class="btn-close shadow-none" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="admin-guests.jsp" method="POST">
                    <input type="hidden" name="action" value="editGuest">
                    <input type="hidden" name="id" id="editGuestId">
                    <div class="modal-body p-4">
                        <div class="row mb-4">
                            <div class="col-md-6">
                                <label class="form-label fw-600 text-muted small text-uppercase">Họ và tên</label>
                                <input type="text" name="full_name" id="editGuestName" class="form-control" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-600 text-muted small text-uppercase">Số CCCD / Hộ chiếu</label>
                                <input type="text" name="id_card" id="editGuestIdCard" class="form-control" required>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <label class="form-label fw-600 text-muted small text-uppercase">Số điện thoại</label>
                                <input type="text" name="phone_number" id="editGuestPhone" class="form-control" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-600 text-muted small text-uppercase">Email</label>
                                <input type="email" name="email" id="editGuestEmail" class="form-control">
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-primary-gradient rounded-pill px-4">Lưu thay đổi</button>
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
        function openEditGuestModal(id, name, idCard, phone, email) {
            document.getElementById('editGuestId').value = id;
            document.getElementById('editGuestName').value = name;
            document.getElementById('editGuestIdCard').value = idCard;
            document.getElementById('editGuestPhone').value = phone;
            document.getElementById('editGuestEmail').value = email;
            var editModal = new bootstrap.Modal(document.getElementById('editGuestModal'));
            editModal.show();
        }

        $(document).ready(function() {
            $('#guestTable').DataTable({
                "pageLength": 10,
                "lengthChange": false,
                "searching": false,
                "ordering": false,
                "language": {
                    "zeroRecords": "Không tìm thấy khách hàng nào",
                    "info": "Đang xem _START_ đến _END_ trong tổng số _TOTAL_ khách",
                    "infoEmpty": "Không có dữ liệu",
                    "paginate": {
                        "first": "Đầu",
                        "previous": "Trước",
                        "next": "Sau",
                        "last": "Cuối"
                    }
                }
            });
        });
    </script>
</body>
</html>
