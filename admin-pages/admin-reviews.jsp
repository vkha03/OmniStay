<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- ==========================================================================
     PHÂN HỆ KIỂM DUYỆT ĐÁNH GIÁ KHÁCH HÀNG (ADMIN REVIEWS CONTROLLER)
     Hệ thống xem xét và kiểm duyệt các phản hồi từ khách hàng sau khi lưu trú.
     Cho phép quản trị viên thay đổi trạng thái (hiển thị / ẩn) trên giao diện
     công cộng hoặc xóa bỏ hoàn toàn các nhận xét vi phạm tiêu chuẩn cộng đồng.
     ========================================================================== --%>
<%@ include file="../layouts/admin-auth.jsp" %>
<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<%@ include file="../env-secrets.jsp" %>
<%
    // Gán đồng nhất mã hóa UTF-8 để hiển thị chính xác bình luận tiếng Việt
    request.setCharacterEncoding("UTF-8");
    Connection conn = null;
    String thongBao = null;

    try {
        // Nạp Database Driver và thiết lập kết nối an toàn
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(SECRET_DB_URL, SECRET_DB_USER, SECRET_DB_PASS);

        // ─── 1. BỘ ĐIỀU KHIỂN TÁC VỤ KIỂM DUYỆT (REVIEW CONTROLLER ACTIONS) ───
        String action = request.getParameter("action");
        if (action != null) {
            int id = Integer.parseInt(request.getParameter("id"));
            
            // a) TÁC VỤ ẨN/HIỆN ĐÁNH GIÁ (TOGGLE REVIEW STATUS)
            if (action.equals("toggleStatus")) {
                int currentStatus = Integer.parseInt(request.getParameter("currentStatus"));
                // Đảo ngược trạng thái: nếu đang hiện (1) thì ẩn (0) và ngược lại
                int newStatus = (currentStatus == 1) ? 0 : 1;
                PreparedStatement ps = conn.prepareStatement("UPDATE reviews SET status = ? WHERE id = ?");
                ps.setInt(1, newStatus);
                ps.setInt(2, id);
                ps.executeUpdate();
                thongBao = "Đã cập nhật trạng thái hiển thị!";
            } 
            // b) TÁC VỤ XÓA VĨNH VIỄN ĐÁNH GIÁ (DELETE REVIEW)
            else if (action.equals("delete")) {
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
                <div class="page-title-icon"><i class="bi bi-star"></i></div>
                <div>
                    <h2 class="font-display fw-normal mb-1">Đánh giá khách hàng</h2>
                    <p class="text-muted mb-0">Xem và kiểm duyệt các phản hồi từ khách hàng sau khi lưu trú.</p>
                </div>
            </div>
            <button class="btn btn-outline-secondary rounded-pill px-4" onclick="location.reload()">
                <i class="bi bi-arrow-clockwise me-1"></i> Làm mới
            </button>
        </div>

        <% if (thongBao != null) { %>
            <div class="alert alert-success alert-dismissible fade show shadow-sm mb-4">
                <i class="bi bi-check-circle-fill me-2"></i> <%= thongBao %>
                <button type="button" class="btn-close shadow-none" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <%
            String reviewSearch = request.getParameter("reviewSearch");
        %>

        <!-- Filter Bar -->
        <form action="admin-reviews.jsp" method="GET" class="filter-bar">
            <div class="row g-3 align-items-center">
                <div class="col-md-8">
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-search"></i></span>
                        <input type="text" name="reviewSearch" class="form-control" placeholder="Tìm theo tên khách hoặc nội dung đánh giá..." value="<%= (reviewSearch != null) ? reviewSearch : "" %>">
                    </div>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-primary-gradient w-100">Tìm kiếm</button>
                </div>
                <div class="col-md-2 text-end">
                    <a href="admin-reviews.jsp" class="btn btn-light w-100 border rounded-pill text-muted small">Xóa lọc</a>
                </div>
            </div>
        </form>

        <div class="table-custom p-4">
            <div class="table-responsive">
                <table id="reviewTable" class="table table-hover align-middle mb-0 w-100">
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
                            // 2. TRUY VẤN VÀ ĐỔ DỮ LIỆU ĐÁNH GIÁ (RENDER REVIEWS TABLE)
                            if(conn != null) {
                                try {
                                    // Kết nối 3 bảng: reviews, guests và rooms để hiển thị tường minh ai đánh giá phòng nào
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
                        <%-- Giảm độ sáng (opacity) của dòng nếu đánh giá đó đang bị ẩn khỏi phía người dùng --%>
                        <tr style="<%= status == 0 ? "opacity: 0.6;" : "" %>">
                            <td><div class="fw-600 text-dark"><%= name %></div><div class="text-muted small"><%= sdf.format(createdAt) %></div></td>
                            <td><span class="badge bg-light text-dark border fw-normal py-1 px-2"><i class="bi bi-door-closed text-primary me-1"></i>P.<%= roomNB %></span></td>
                            <td>
                                <div class="star-rating">
                                    <%-- Vòng lặp in chính xác số lượng sao vàng (fill) tương ứng với điểm số rating --%>
                                    <% for(int i=0; i<5; i++) { %>
                                        <i class="bi <%= i < rating ? "bi-star-fill text-warning" : "bi-star text-muted" %>"></i>
                                    <% } %>
                                </div>
                            </td>
                            <td><div class="text-dark small" style="max-width: 280px;"><%= comment %></div></td>
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
                                    } // Kết thúc lặp danh sách đánh giá
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
                    "zeroRecords": "Không tìm thấy đánh giá nào",
                    "info": "Đang xem _START_ đến _END_ trong tổng số _TOTAL_ đánh giá",
                    "infoEmpty": "Không có dữ liệu",
                    "paginate": { "first": "Đầu", "previous": "Trước", "next": "Sau", "last": "Cuối" }
                }
            });
        });
    </script>
    <% if(conn != null) try { conn.close(); } catch(Exception e) {} %>
</body>
</html>
