<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../layouts/admin-auth.jsp" %>
<%@ page import="java.sql.*, java.util.*, java.text.NumberFormat" %>
<%@ include file="../env-secrets.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    Connection conn = null;
    String thongBao = null;
    String loaiThongBao = "success";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(SECRET_DB_URL, SECRET_DB_USER, SECRET_DB_PASS);

        // ─── XỬ LÝ LOGIC (ADD / EDIT / DELETE) ───
        String action = request.getParameter("action");
        if (action != null) {
            if (action.equals("add")) {
                String name = request.getParameter("serviceName");
                double price = Double.parseDouble(request.getParameter("price"));
                String unit = request.getParameter("unit");
                
                PreparedStatement ps = conn.prepareStatement("INSERT INTO services (service_name, price, unit) VALUES (?, ?, ?)");
                ps.setString(1, name);
                ps.setDouble(2, price);
                ps.setString(3, unit);
                ps.executeUpdate();
                thongBao = "Đã thêm dịch vụ mới!";
            } 
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
    NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Dịch vụ — OmniStay Admin</title>
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
        
        .svc-icon { width: 40px; height: 40px; background: rgba(212, 168, 71, 0.1); color: var(--accent); border-radius: 10px; display: flex; align-items: center; justify-content: center; font-weight: 600; margin-right: 12px; }
        .price-tag { font-family: 'Playfair Display', serif; font-weight: 600; color: var(--primary); font-size: 1.1rem; }

        .action-btn { width: 32px; height: 32px; display: inline-flex; align-items: center; justify-content: center; border-radius: 8px; transition: 0.2s; color: #666; text-decoration: none; border: 1px solid transparent; cursor: pointer; }
        .action-btn:hover { background: var(--bg-light); color: var(--primary); border-color: var(--border); }
        
        .modal-content { border-radius: 20px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
        .modal-header { border-bottom: 1px solid #eee; padding: 1.5rem 2rem; }
        .form-control, .form-select { border-radius: 10px; padding: 0.7rem 1rem; border: 1px solid #ddd; }
        .form-control:focus { box-shadow: 0 0 0 4px rgba(26, 107, 90, 0.1); border-color: var(--primary); }
    </style>
</head>
<body>
    <%@ include file="../layouts/sidebar-admin.jsp" %>
    
    <main class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="font-display fw-normal mb-1">Dịch vụ bổ sung</h2>
                <p class="text-muted mb-0" style="font-size: 0.9rem;">Quản lý danh mục sản phẩm và dịch vụ tiện ích của khách sạn.</p>
            </div>
            <button class="btn text-white rounded-pill px-4" style="background: var(--primary);" data-bs-toggle="modal" data-bs-target="#addServiceModal">
                <i class="bi bi-plus-lg me-1"></i> Thêm dịch vụ
            </button>
        </div>

        <% if (thongBao != null) { %>
            <div class="alert alert-<%= loaiThongBao %> alert-dismissible fade show border-0 mb-4 shadow-sm" style="border-radius: 12px;">
                <i class="bi <%= loaiThongBao.equals("success") ? "bi-check-circle-fill" : "bi-exclamation-triangle-fill" %> me-2"></i> <%= thongBao %>
                <button type="button" class="btn-close shadow-none" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <%
            String serviceSearch = request.getParameter("serviceSearch");
        %>

        <!-- Filter Bar -->
        <form action="admin-services.jsp" method="GET" class="bg-white p-3 rounded-4 border mb-4 shadow-sm" style="border-color: var(--border) !important;">
            <div class="row g-3 align-items-center">
                <div class="col-md-8">
                    <div class="input-group">
                        <span class="input-group-text bg-light border-0"><i class="bi bi-search"></i></span>
                        <input type="text" name="serviceSearch" class="form-control border-0 bg-light" placeholder="Tìm theo tên dịch vụ hoặc sản phẩm..." value="<%= (serviceSearch != null) ? serviceSearch : "" %>">
                    </div>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn text-white w-100" style="background: var(--primary); border-radius: 10px;">Tìm kiếm</button>
                </div>
                <div class="col-md-2 text-end">
                    <a href="admin-services.jsp" class="btn btn-light w-100 border rounded-pill text-muted small">Xóa lọc</a>
                </div>
            </div>
        </form>

        <div class="table-custom">
            <div class="table-responsive">
                <table id="serviceTable" class="table table-hover align-middle mb-0">
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
                            if(conn != null) {
                                try {
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
                                    <div class="fw-500 text-dark"><%= name %></div>
                                </div>
                            </td>
                            <td><span class="badge bg-light text-muted border fw-normal px-3 py-2"><%= unit %></span></td>
                            <td><span class="price-tag"><%= nf.format(price).replace("VNĐ", "₫") %></span></td>
                            <td class="text-end">
                                <a class="action-btn" onclick="openEditModal(<%= id %>, '<%= name %>', <%= price %>, '<%= unit %>')" title="Sửa"><i class="bi bi-pencil-square"></i></a>
                                <form action="admin-services.jsp" method="POST" style="display:inline;" onsubmit="return confirm('Xóa dịch vụ này?')">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="serviceId" value="<%= id %>">
                                    <button type="submit" class="action-btn" style="border:none; background:none;"><i class="bi bi-trash3 text-danger"></i></button>
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

    <!-- Modal Thêm dịch vụ -->
    <div class="modal fade" id="addServiceModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title font-display fw-bold">Thêm dịch vụ mới</h5>
                    <button type="button" class="btn-close shadow-none" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="admin-services.jsp" method="POST">
                    <input type="hidden" name="action" value="add">
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label small fw-500">Tên dịch vụ / Sản phẩm</label>
                            <input type="text" name="serviceName" class="form-control" placeholder="Ví dụ: Giặt ủi cao cấp" required>
                        </div>
                        <div class="row">
                            <div class="col-md-7 mb-3">
                                <label class="form-label small fw-500">Đơn giá (VNĐ)</label>
                                <input type="number" name="price" class="form-control" placeholder="50000" required>
                            </div>
                            <div class="col-md-5 mb-3">
                                <label class="form-label small fw-500">Đơn vị tính</label>
                                <input type="text" name="unit" class="form-control" placeholder="Chai / Suất / Giờ" required>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer border-0 px-4 pb-4">
                        <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn text-white rounded-pill px-4" style="background: var(--primary);">Lưu dịch vụ</button>
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
                    <h5 class="modal-title font-display fw-bold">Chỉnh sửa dịch vụ</h5>
                    <button type="button" class="btn-close shadow-none" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="admin-services.jsp" method="POST">
                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="serviceId" id="editServiceId">
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label small fw-500">Tên dịch vụ / Sản phẩm</label>
                            <input type="text" name="serviceName" id="editServiceName" class="form-control" required>
                        </div>
                        <div class="row">
                            <div class="col-md-7 mb-3">
                                <label class="form-label small fw-500">Đơn giá (VNĐ)</label>
                                <input type="number" name="price" id="editPrice" class="form-control" required>
                            </div>
                            <div class="col-md-5 mb-3">
                                <label class="form-label small fw-500">Đơn vị tính</label>
                                <input type="text" name="unit" id="editUnit" class="form-control" required>
                            </div>
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
            $('#serviceTable').DataTable({
                "pageLength": 10,
                "lengthChange": false,
                "searching": false,
                "ordering": false,
                "language": {
                    "paginate": { "previous": "<i class='bi bi-chevron-left'></i>", "next": "<i class='bi bi-chevron-right'></i>" }
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
