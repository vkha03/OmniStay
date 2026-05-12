<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- ==========================================================================
     PHÂN HỆ QUẢN LÝ DỊCH VỤ VÀ TIỆN ÍCH KHÁCH SẠN (ADMIN SERVICES CONTROLLER)
     Xử lý hiển thị danh mục các dịch vụ bổ sung (spa, ăn uống, giặt ủi...)
     Cung cấp trọn gói các thao tác thêm mới, cập nhật giá thành, đơn vị tính
     và xóa dịch vụ thông qua cơ chế xử lý POST đồng bộ với giao diện Modal.
     ========================================================================== --%>
<%@ include file="../layouts/admin-auth.jsp" %>
<%@ page import="java.sql.*, java.util.*, java.text.NumberFormat" %>
<%@ include file="../env-secrets.jsp" %>
<%
    // Thiết lập bảng mã UTF-8 để nhận dữ liệu tiếng Việt có dấu từ form chính xác
    request.setCharacterEncoding("UTF-8");
    Connection conn = null;
    String thongBao = null;
    String loaiThongBao = "success";

    try {
        // Khởi tạo trình điều khiển kết nối MySQL
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(SECRET_DB_URL, SECRET_DB_USER, SECRET_DB_PASS);

        // ─── 1. XỬ LÝ LOGIC CRUD BỔ SUNG DỊCH VỤ (ADD / EDIT / DELETE ACTION) ───
        String action = request.getParameter("action");
        if (action != null) {
            // a) TÁC VỤ THÊM MỚI DỊCH VỤ (CREATE SERVICE)
            if (action.equals("add")) {
                String name = request.getParameter("serviceName");
                double price = Double.parseDouble(request.getParameter("price"));
                String unit = request.getParameter("unit");
                
                // Dùng PreparedStatement gán tham số tránh rủi ro SQL Injection
                PreparedStatement ps = conn.prepareStatement("INSERT INTO services (service_name, price, unit) VALUES (?, ?, ?)");
                ps.setString(1, name);
                ps.setDouble(2, price);
                ps.setString(3, unit);
                ps.executeUpdate();
                thongBao = "Đã thêm dịch vụ mới!";
            } 
            // b) TÁC VỤ CẬP NHẬT THÔNG TIN DỊCH VỤ (UPDATE SERVICE)
            else if (action.equals("edit")) {
                int id = Integer.parseInt(request.getParameter("serviceId"));
                String name = request.getParameter("serviceName");
                double price = Double.parseDouble(request.getParameter("price"));
                String unit = request.getParameter("unit");

                PreparedStatement ps = conn.prepareStatement("UPDATE services SET service_name=?, price=?, unit=? WHERE id=?");
                ps.setString(1, name);
                ps.setDouble(2, price);
                ps.setString(3, unit);
                ps.setInt(4, id);
                ps.executeUpdate();
                thongBao = "Đã cập nhật dịch vụ!";
            }
            // c) TÁC VỤ XÓA DỊCH VỤ (DELETE SERVICE)
            else if (action.equals("delete")) {
                int id = Integer.parseInt(request.getParameter("serviceId"));
                PreparedStatement ps = conn.prepareStatement("DELETE FROM services WHERE id = ?");
                ps.setInt(1, id);
                ps.executeUpdate();
                thongBao = "Đã xóa dịch vụ khỏi hệ thống!";
            }
        }
    } catch(Exception e) {
        thongBao = "Lỗi: " + e.getMessage();
        loaiThongBao = "danger";
    }
    // Bộ định dạng hiển thị giá tiền tệ chuẩn VNĐ
    NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Dịch vụ — OmniStay Admin</title>
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
                <div class="page-title-icon"><i class="bi bi-cup-hot"></i></div>
                <div>
                    <h2 class="font-display fw-normal mb-1">Dịch vụ bổ sung</h2>
                    <p class="text-muted mb-0">Quản lý danh mục sản phẩm và dịch vụ tiện ích của khách sạn.</p>
                </div>
            </div>
            <button class="btn btn-primary-gradient rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#addServiceModal">
                <i class="bi bi-plus-lg me-1"></i> Thêm dịch vụ
            </button>
        </div>

        <% if (thongBao != null) { %>
            <div class="alert alert-<%= loaiThongBao %> alert-dismissible fade show shadow-sm mb-4">
                <i class="bi <%= loaiThongBao.equals("success") ? "bi-check-circle-fill" : "bi-exclamation-triangle-fill" %> me-2"></i> <%= thongBao %>
                <button type="button" class="btn-close shadow-none" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <%
            String serviceSearch = request.getParameter("serviceSearch");
        %>

        <!-- Filter Bar -->
        <form action="admin-services.jsp" method="GET" class="filter-bar">
            <div class="row g-3 align-items-center">
                <div class="col-md-8">
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-search"></i></span>
                        <input type="text" name="serviceSearch" class="form-control" placeholder="Tìm theo tên dịch vụ hoặc sản phẩm..." value="<%= (serviceSearch != null) ? serviceSearch : "" %>">
                    </div>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-primary-gradient w-100">Tìm kiếm</button>
                </div>
                <div class="col-md-2 text-end">
                    <a href="admin-services.jsp" class="btn btn-light w-100 border rounded-pill text-muted small">Xóa lọc</a>
                </div>
            </div>
        </form>

        <div class="table-custom p-4">
            <div class="table-responsive">
                <table id="serviceTable" class="table table-hover align-middle mb-0 w-100">
                    <thead>
                        <tr>
                            <th>Tên dịch vụ</th>
                            <th>Đơn vị tính</th>
                            <th>Đơn giá</th>
                            <th class="text-end">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            // 2. TRUY VẤN VÀ ĐỔ DỮ LIỆU DANH SÁCH DỊCH VỤ (RENDER SERVICES TABLE)
                            if(conn != null) {
                                try {
                                    // Tạo truy vấn SQL cơ sở, bổ sung điều kiện lọc LIKE nếu có từ khóa tìm kiếm
                                    String sql = "SELECT * FROM services WHERE 1=1 ";
                                    if(serviceSearch != null && !serviceSearch.trim().isEmpty()) {
                                        sql += " AND service_name LIKE ?";
                                    }
                                    sql += " ORDER BY service_name ASC";
                                    
                                    PreparedStatement ps = conn.prepareStatement(sql);
                                    if(serviceSearch != null && !serviceSearch.trim().isEmpty()) {
                                        ps.setString(1, "%" + serviceSearch.trim() + "%");
                                    }
                                    
                                    ResultSet rs = ps.executeQuery();
                                    while(rs.next()) {
                                        int id = rs.getInt("id");
                                        String name = rs.getString("service_name");
                                        double price = rs.getDouble("price");
                                        String unit = rs.getString("unit");
                                        
                                        // Thuật toán tự động nhận diện từ khóa trong tên dịch vụ để gán icon Bootstrap phù hợp
                                        String icon = "bi-box";
                                        if(name.toLowerCase().contains("buffet") || name.toLowerCase().contains("ăn")) icon = "bi-egg-fried";
                                        if(name.toLowerCase().contains("uống") || name.toLowerCase().contains("coca")) icon = "bi-cup-straw";
                                        if(name.toLowerCase().contains("giặt")) icon = "bi-water";
                                        if(name.toLowerCase().contains("spa")) icon = "bi-flower1";
                        %>
                        <tr>
                            <td>
                                <div class="d-flex align-items-center">
                                    <div class="svc-icon"><i class="bi <%= icon %>"></i></div>
                                    <div class="fw-500 text-dark" style="font-size: 1rem;"><%= name %></div>
                                </div>
                            </td>
                            <td><span class="badge bg-light text-muted border fw-normal px-3 py-2"><%= unit %></span></td>
                            <td><span class="price-tag"><%= nf.format(price).replace("VNĐ", "₫") %></span></td>
                            <td class="text-end">
                                <a class="action-btn" onclick="openEditModal(<%= id %>, '<%= name %>', <%= price %>, '<%= unit %>')" title="Sửa"><i class="bi bi-pencil-square text-primary"></i></a>
                                <form action="admin-services.jsp" method="POST" style="display:inline;" onsubmit="return confirm('Xóa dịch vụ này?')">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="serviceId" value="<%= id %>">
                                    <button type="submit" class="action-btn" style="border:none; background:none;"><i class="bi bi-trash3 text-danger"></i></button>
                                </form>
                            </td>
                        </tr>
                        <%
                                    } // Kết thúc lặp danh sách dịch vụ
                                    rs.close(); ps.close();
                                } catch(Exception e) { out.println("Lỗi: " + e.getMessage()); }
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <!-- Modal Thêm dịch vụ -->
    <div class="modal fade" id="addServiceModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title font-display fw-bold" style="color: var(--primary);">Thêm dịch vụ mới</h5>
                    <button type="button" class="btn-close shadow-none" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="admin-services.jsp" method="POST">
                    <input type="hidden" name="action" value="add">
                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label class="form-label">Tên dịch vụ / Sản phẩm</label>
                            <input type="text" name="serviceName" class="form-control" placeholder="Ví dụ: Giặt ủi cao cấp" required>
                        </div>
                        <div class="row">
                            <div class="col-md-7 mb-3">
                                <label class="form-label">Đơn giá (VNĐ)</label>
                                <input type="number" name="price" class="form-control" placeholder="50000" required>
                            </div>
                            <div class="col-md-5 mb-3">
                                <label class="form-label">Đơn vị tính</label>
                                <input type="text" name="unit" class="form-control" placeholder="Chai / Suất / Giờ" required>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-primary-gradient px-4">Lưu dịch vụ</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Modal Sửa dịch vụ -->
    <div class="modal fade" id="editServiceModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title font-display fw-bold" style="color: var(--primary);">Chỉnh sửa dịch vụ</h5>
                    <button type="button" class="btn-close shadow-none" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="admin-services.jsp" method="POST">
                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="serviceId" id="editServiceId">
                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label class="form-label">Tên dịch vụ / Sản phẩm</label>
                            <input type="text" name="serviceName" id="editServiceName" class="form-control" required>
                        </div>
                        <div class="row">
                            <div class="col-md-7 mb-3">
                                <label class="form-label">Đơn giá (VNĐ)</label>
                                <input type="number" name="price" id="editPrice" class="form-control" required>
                            </div>
                            <div class="col-md-5 mb-3">
                                <label class="form-label">Đơn vị tính</label>
                                <input type="text" name="unit" id="editUnit" class="form-control" required>
                            </div>
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
            $('#serviceTable').DataTable({
                "pageLength": 10,
                "lengthChange": false,
                "searching": false,
                "ordering": false,
                "language": {
                    "zeroRecords": "Không tìm thấy dịch vụ nào",
                    "info": "Đang xem _START_ đến _END_ trong tổng số _TOTAL_ dịch vụ",
                    "infoEmpty": "Không có dữ liệu",
                    "paginate": { "first": "Đầu", "previous": "Trước", "next": "Sau", "last": "Cuối" }
                }
            });
        });

        function openEditModal(id, name, price, unit) {
            document.getElementById('editServiceId').value = id;
            document.getElementById('editServiceName').value = name;
            document.getElementById('editPrice').value = price;
            document.getElementById('editUnit').value = unit;
            var myModal = new bootstrap.Modal(document.getElementById('editServiceModal'));
            myModal.show();
        }
    </script>
    <% if(conn != null) try { conn.close(); } catch(Exception e) {} %>
</body>
</html>
