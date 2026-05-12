<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- ==========================================================================
     PHÂN HỆ QUẢN LÝ DANH SÁCH PHÒNG NGHỈ (ADMIN ROOMS CONTROLLER)
     Chịu trách nhiệm hiển thị toàn bộ sơ đồ và danh sách phòng chi tiết.
     Tích hợp logic xử lý CRUD (Create - Read - Update - Delete) qua phương thức
     POST và GET nhằm cập nhật trạng thái phòng, giá cả và thiết lập phòng mới.
     ========================================================================== --%>
<%@ include file="../layouts/admin-auth.jsp" %>
<%@ page import="java.sql.*, java.util.*, java.text.NumberFormat" %>
<%@ include file="../env-secrets.jsp" %>
<%
    // 1. KHỞI TẠO KẾT NỐI VÀ BỘ ĐIỀU KHIỂN CRUD (CONNECTION & CRUD CONTROLLER)
    Connection conn = null;
    String dbError = null;
    try {
        // Nạp trình điều khiển cơ sở dữ liệu MySQL
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(SECRET_DB_URL, SECRET_DB_USER, SECRET_DB_PASS);
        
        // --- XỬ LÝ POST ACTION (ADD / EDIT / DELETE) ---
        // Bắt yêu cầu POST gửi lên từ các form Modal (Thêm/Sửa/Xóa)
        if("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("action") != null) {
            String action = request.getParameter("action");
            
            // a) TÁC VỤ THÊM PHÒNG MỚI (CREATE ROOM)
            if(action.equals("addRoom")) {
                int room_NB = Integer.parseInt(request.getParameter("room_NB"));
                String status = request.getParameter("status");
                String room_type = request.getParameter("room_type_id");
                
                // Chuẩn bị câu lệnh chèn an toàn chống SQL Injection
                String addSQL = "INSERT INTO rooms (room_number, status, room_type_id) VALUES (?,?,?)";
                PreparedStatement psADD = conn.prepareStatement(addSQL);
                psADD.setInt(1, room_NB);
                psADD.setString(2, status);
                psADD.setInt(3, Integer.parseInt(room_type));
                psADD.executeUpdate();
                psADD.close();
                
                // Gán thông báo thành công vào phiên làm việc và chuyển hướng trang để tránh submit lặp
                session.setAttribute("thongBao", "Thêm phòng mới thành công!");
                response.sendRedirect("admin-rooms.jsp");
                return;
                
            // b) TÁC VỤ CẬP NHẬT THÔNG TIN PHÒNG (UPDATE ROOM)
            } else if(action.equals("editRoom")) {
                String ID = request.getParameter("id"); 
                int roomNB = Integer.parseInt(request.getParameter("room_NB"));
                String status = request.getParameter("status");
                String roomType = request.getParameter("room_type_id"); 
                
                String sql = "UPDATE rooms SET room_number = ?, status = ?, room_type_id = ? WHERE id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, roomNB);
                ps.setString(2, status);
                ps.setInt(3, Integer.parseInt(roomType)); 
                ps.setString(4, ID); 
                ps.executeUpdate();
                ps.close();    
                
                session.setAttribute("thongBao", "Cập nhật phòng thành công!");
                response.sendRedirect("admin-rooms.jsp");
                return; 
                
            // c) TÁC VỤ XÓA PHÒNG NGHỈ (DELETE ROOM)
            } else if(action.equals("deleteRoom")) {
                String ID = request.getParameter("id");
                String sql = "DELETE FROM rooms WHERE id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, ID);
                ps.executeUpdate();
                ps.close();
                
                session.setAttribute("thongBao", "Đã xóa phòng khỏi hệ thống!");
                response.sendRedirect("admin-rooms.jsp");
                return;
            }
        }
    } catch(Exception e) {
        dbError = e.getMessage();
    }
    
    // Bộ định dạng tiền tệ chuẩn Việt Nam
    NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    
    // 2. HÀM PHỤ TRỢ DỊCH TÊN LOẠI PHÒNG BẰNG LAMBDA EXPRESSION (JAVA FUNCTIONAL)
    // Tận dụng cú pháp Lambda hiện đại hỗ trợ trên môi trường Java 8+ / Tomcat 10
    java.util.function.Function<String, String> translateType = (type) -> {
        if(type == null) return "Chưa xác định";
        switch(type.trim().toUpperCase()) {
            case "STANDARD": return "Tiêu chuẩn (Standard)";
            case "DELUXE": return "Sang trọng (Deluxe)";
            case "PREMIUM": return "Cao cấp (Premium)";
            default: return type;
        }
    };
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Phòng — OmniStay Admin</title>
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
                <div class="page-title-icon"><i class="bi bi-door-open"></i></div>
                <div>
                    <h2 class="font-display fw-normal mb-1">Danh sách Phòng nghỉ</h2>
                    <p class="text-muted mb-0">Quản lý thông tin, giá cả và trạng thái của toàn bộ hệ thống phòng.</p>
                </div>
            </div>
            <% if ("ADMIN".equals(adminRole)) { %>
            <button class="btn btn-primary-gradient rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#addRoomModal">
                <i class="bi bi-plus-lg me-1"></i> Thêm phòng mới
            </button>
            <% } %>
        </div>

        <%
            String loaiphong = request.getParameter("loaiphong");
            String trangthai = request.getParameter("trangthai");
        %>

        <form action="admin-rooms.jsp" method="GET" class="filter-bar d-flex justify-content-end align-items-center">
            <div class="d-flex gap-2">
                <select name="loaiphong" class="form-select" style="width: 160px;">
                    <option value="" <%= (loaiphong == null || loaiphong.isEmpty()) ? "selected" : "" %> >Tất cả loại phòng</option>
                    <option value="Standard" <%= "Standard".equals(loaiphong) ? "selected" : "" %>>Tiêu chuẩn</option>
                    <option value="Deluxe" <%= "Deluxe".equals(loaiphong) ? "selected" : "" %>>Sang trọng</option>
                    <option value="Premium" <%= "Premium".equals(loaiphong) ? "selected" : "" %>>Cao cấp</option>
                </select>
                <select name="trangthai" class="form-select" style="width: 150px;">
                    <option value="" <%= (trangthai == null || trangthai.isEmpty()) ? "selected" : "" %>>Tất cả trạng thái</option>
                    <option value="AVAILABLE" <%= "AVAILABLE".equals(trangthai) ? "selected" : "" %>>Sẵn sàng</option>
                    <option value="OCCUPIED" <%= "OCCUPIED".equals(trangthai) ? "selected" : "" %>>Đang có khách</option>
                    <option value="CLEANING" <%= "CLEANING".equals(trangthai) ? "selected" : "" %>>Đang dọn dẹp</option>
                    <option value="MAINTENANCE" <%= "MAINTENANCE".equals(trangthai) ? "selected" : "" %>>Bảo trì</option>
                </select>
                <button type="submit" class="btn btn-primary-gradient px-4">Lọc</button>
            </div>
        </form>

        <%
            String msg = (String) session.getAttribute("thongBao");
            if (msg != null) {
        %>
            <div class="alert alert-success alert-dismissible fade show shadow-sm mb-4" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i> <strong>Thành công!</strong> <%= msg %>
                <button type="button" class="btn-close shadow-none" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <%
                session.removeAttribute("thongBao");
            }
        %>

        <!-- Room Status Map -->
        <div class="table-card mb-5">
            <div class="d-flex justify-content-between align-items-center p-4 border-bottom flex-wrap gap-3">
                <div>
                    <h5 class="fw-bold mb-1 text-dark">Sơ đồ trạng thái phòng</h5>
                    <p class="text-muted mb-0 small">Tổng quan tình trạng phòng nghỉ thời điểm hiện tại.</p>
                </div>
                <div class="d-flex gap-4 flex-wrap">
                    <div class="legend-item"><span class="legend-dot" style="background: #bbf7d0;"></span> Sẵn sàng</div>
                    <div class="legend-item"><span class="legend-dot" style="background: #fecaca;"></span> Có khách</div>
                    <div class="legend-item"><span class="legend-dot" style="background: #fef3c7;"></span> Đang dọn</div>
                    <div class="legend-item"><span class="legend-dot" style="background: #e2e8f0;"></span> Bảo trì</div>
                </div>
            </div>
            
            <div class="room-grid">
                <%
                    // 3. TRUY VẤN VÀ VẼ SƠ ĐỒ LƯỚI TRẠNG THÁI PHÒNG (ROOM MATRIX OVERVIEW)
                    // Lấy ra tất cả các phòng để hiển thị dạng ma trận trực quan cho lễ tân dễ thao tác
                    if(conn != null) {
                        try {
                            String sqlRoomsMap = "SELECT r.*, rt.type_name FROM rooms r LEFT JOIN room_types rt ON r.room_type_id = rt.id ORDER BY r.room_number ASC";
                            Statement stRoomsMap = conn.createStatement();
                            ResultSet rsRoomsMap = stRoomsMap.executeQuery(sqlRoomsMap);
                            
                            while(rsRoomsMap.next()) {
                                // Gán class tương ứng với mã trạng thái để tô màu background cho từng ô phòng
                                String rStatus = rsRoomsMap.getString("status");
                                if (rStatus == null) rStatus = "AVAILABLE";
                                rStatus = rStatus.trim().toUpperCase();
                                
                                String rClass = "status-available";
                                if("OCCUPIED".equals(rStatus)) rClass = "status-occupied";
                                else if("CLEANING".equals(rStatus)) rClass = "status-cleaning";
                                else if("MAINTENANCE".equals(rStatus)) rClass = "status-maintenance";
                                
                                String tNameMap = rsRoomsMap.getString("type_name");
                                if (tNameMap == null) tNameMap = "Chưa thiết lập";
                                else tNameMap = translateType.apply(tNameMap);
                %>
                <a href="#roomTable" class="room-item">
                    <div class="room-box <%= rClass %>">
                        <div class="room-no"><%= rsRoomsMap.getString("room_number") %></div>
                        <div class="room-type text-truncate w-100"><%= tNameMap %></div>
                    </div>
                </a>
                <%
                            } // Kết thúc lặp sơ đồ
                            rsRoomsMap.close(); stRoomsMap.close();
                        } catch(Exception e) { out.println("Lỗi tải sơ đồ phòng: " + e.getMessage()); }
                    }
                %>
            </div>
        </div>

        <div class="table-custom" style="padding: 1.5rem;">
            <div class="table-responsive">
                <table id="roomTable" class="table table-hover align-middle mb-0 w-100">
                    <thead>
                        <tr>
                            <th style="width: 120px;" class="text-center">Số phòng</th>
                                  <%
                        // 4. TRUY VẤN DANH SÁCH PHÒNG VÀ XỬ LÝ CẬP NHẬT TRẠNG THÁI NHANH (TABLE RENDERER & INLINE STATUS UPDATE)
                        if(conn!=null){
                            try{	
                                // a) XỬ LÝ ĐỔI TRẠNG THÁI TRỰC TIẾP TỪ BẢNG (Inline Status Update)
                                // Khi người dùng chọn trạng thái mới ở cột Trạng thái, form sẽ tự động gửi yêu cầu GET
                                String updateId = request.getParameter("updateId");
                                String newStatus = request.getParameter("newStatus");

                                if (updateId != null && newStatus != null) {
                                    String updateSQL = "UPDATE rooms SET status = ? WHERE id = ?";
                                    PreparedStatement upStatus = conn.prepareStatement(updateSQL);
                                    upStatus.setString(1, newStatus);
                                    upStatus.setInt(2, Integer.parseInt(updateId));
                                    upStatus.executeUpdate();
                                    upStatus.close();
                                }
                                
                                // b) LẤY TOÀN BỘ DỮ LIỆU ĐỔ RA BẢNG KẾT HỢP BỘ LỌC (Fetch Table Data with Filters)
                                // Nối bảng `rooms` với `room_types` và linh hoạt bổ sung điều kiện WHERE dựa trên tham số GET
                                String SQL = "SELECT rs.id, rs.room_number, rs.room_type_id, rs.status, rt.* " + 
                                             "FROM rooms rs JOIN room_types rt ON rs.room_type_id = rt.id WHERE 1=1 ";
                                if(loaiphong != null && !loaiphong.isEmpty()){ SQL += " AND rt.type_name = '" + loaiphong +"'"; }
                                if(trangthai != null && !trangthai.isEmpty()){ SQL += " AND rs.status = '"+ trangthai +"'"; }
                					
                                SQL += " ORDER BY rs.room_number ASC";
                                PreparedStatement ps = conn.prepareStatement(SQL);
                                ResultSet rs = ps.executeQuery();
                                
                                while(rs.next()){
                                	int id = rs.getInt("id");
                                	int roomsNB = rs.getInt("room_number");
                                	String status = rs.getString("status");
                                	double price = rs.getDouble("base_price");
                                	int people = rs.getInt("max_occupancy");
                                	String typeName = rs.getString("type_name");
                                    int typeId = rs.getInt("room_type_id");
                        %>
                        <tr>
                            <td class="text-center fw-500 text-muted"><%= roomsNB %></td> 
                            <td><div class="fw-500 font-display" style="font-size: 1.05rem; color: var(--primary);"><%= translateType.apply(typeName) %></div></td>
                            <td><span class="badge bg-light text-dark border fw-normal"><i class="bi bi-people me-1"></i><%= people %> Người lớn</span></td>
                            <td class="font-display fw-600" style="color: var(--primary); font-size: 1.05rem;">
                                <%= nf.format(price).replace("VNĐ", "₫") %> <span class="text-muted fw-normal" style="font-size: 0.72rem;">/ đêm</span>
                            </td>
                          	<td>
                                <!-- Form cập nhật trạng thái tự động nộp khi thay đổi lựa chọn -->
                                <form action="admin-rooms.jsp" method="GET" style="margin: 0;">
                                    <input type="hidden" name="updateId" value="<%= id %>">
                                    <input type="hidden" name="loaiphong" value="<%= loaiphong != null ? loaiphong : "" %>">
                                    <input type="hidden" name="trangthai" value="<%= trangthai != null ? trangthai : "" %>">
                                    <select name="newStatus" class="form-select form-select-sm shadow-none" onchange="this.form.submit()" style="width: 140px; cursor: pointer;">
                                        <option value="AVAILABLE" <%= "AVAILABLE".equals(status) ? "selected" : "" %>>Sẵn sàng</option>
                                        <option value="OCCUPIED" <%= "OCCUPIED".equals(status) ? "selected" : "" %>>Đang có khách</option>
                                        <option value="CLEANING" <%= "CLEANING".equals(status) ? "selected" : "" %>>Đang dọn dẹp</option>
                                        <option value="MAINTENANCE" <%= "MAINTENANCE".equals(status) ? "selected" : "" %>>Bảo trì</option>
                                    </select>
                                </form>
                            </td>
                            <% if ("ADMIN".equals(adminRole)) { %>
                            <td class="text-end">
                                <a onclick="openEditModal(<%= id %>, <%= roomsNB %>, <%= typeId %>, '<%= status %>')" class="action-btn" title="Chỉnh sửa"><i class="bi bi-pencil-square text-primary"></i></a>
                                <form action="admin-rooms.jsp" method="POST" style="display:inline;" onsubmit="return confirm('Bạn có chắc muốn xóa phòng này?')">
                                    <input type="hidden" name="action" value="deleteRoom">
                                    <input type="hidden" name="id" value="<%= id %>">
                                    <button type="submit" class="action-btn" style="border:none; background:none;"><i class="bi bi-trash3 text-danger"></i></button>
                                </form>
                            </td>
                            <% } %>
                        </tr>
                        <%
                                } // Kết thúc lặp dữ liệu bảng phòng
                                rs.close(); ps.close();
                            } catch(Exception e) { out.println("<tr><td colspan='6'>Lỗi: " + e.getMessage() + "</td></tr>"); }
                    	} else { out.println("<tr><td colspan='6'>Lỗi kết nối database</td></tr>"); }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <!-- Modal Thêm Phòng -->
    <div class="modal fade" id="addRoomModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title font-display fw-bold" style="color: var(--primary);">Thêm phòng mới</h5>
                    <button type="button" class="btn-close shadow-none" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="admin-rooms.jsp" method="POST">
                    <input type="hidden" name="action" value="addRoom">
                    <div class="modal-body p-4">
                        <div class="row mb-4">
                            <div class="col-md-6">
                                <label class="form-label fw-600 text-muted small text-uppercase">Số phòng mới</label>
                                <input type="text" name="room_NB" class="form-control" placeholder="Ví dụ: 401" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-600 text-muted small text-uppercase">Trạng thái ban đầu</label>
                                <select name="status" class="form-select">
                                    <option value="AVAILABLE">Sẵn sàng</option>
                                    <option value="OCCUPIED">Đang có khách</option>
                                    <option value="MAINTENANCE">Bảo trì</option>
                                </select>
                            </div>
                        </div>
                        <div class="mb-4">
                            <label class="form-label fw-600 text-muted small text-uppercase">Loại phòng</label>
                            <select name="room_type_id" id="add_roomType" class="form-select" onchange="doiLoaiPhongAdd()" required>
                                <option value="1">Tiêu chuẩn (Standard)</option>
                                <option value="2">Sang trọng (Deluxe)</option>
                                <option value="3">Cao cấp (Premium)</option>
                            </select>
                        </div>
                        <div class="row">
                            <div class="col-md-5">
                                <label class="form-label fw-600 text-muted small text-uppercase">Sức chứa</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light"><i class="bi bi-people"></i></span>
                                    <input type="text" id="add_oNguoi" class="form-control bg-light" readonly>
                                </div>
                            </div>
                            <div class="col-md-7">
                                <label class="form-label fw-600 text-muted small text-uppercase">Giá niêm yết mặc định</label>
                                <div class="input-group">
                                    <input type="text" id="add_oGia" class="form-control bg-light text-primary fw-bold" readonly>
                                    <span class="input-group-text bg-light">VNĐ / đêm</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-primary-gradient rounded-pill px-4">Tạo phòng ngay</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Modal Sửa Phòng -->
    <div class="modal fade" id="editRoomModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title font-display fw-bold" style="color: var(--primary);">Chỉnh sửa Phòng</h5>
                    <button type="button" class="btn-close shadow-none" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="admin-rooms.jsp" method="POST">
                    <input type="hidden" name="action" value="editRoom">
                    <input type="hidden" name="id" id="editRoomId">
                    <div class="modal-body p-4">
                        <div class="row mb-4">
                            <div class="col-md-6">
                                <label class="form-label fw-600 text-muted small text-uppercase">Số phòng</label>
                                <input type="text" name="room_NB" id="editRoomNB" class="form-control" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-600 text-muted small text-uppercase">Trạng thái</label>
                                <select name="status" id="editStatus" class="form-select">
                                    <option value="AVAILABLE">Sẵn sàng</option>
                                    <option value="OCCUPIED">Đang có khách</option>
                                    <option value="MAINTENANCE">Bảo trì</option>
                                    <option value="CLEANING">Đang dọn dẹp</option>
                                </select>
                            </div>
                        </div>
                        <div class="mb-4">
                            <label class="form-label fw-600 text-muted small text-uppercase">Loại phòng</label>
                            <select name="room_type_id" id="edit_roomType" class="form-select" onchange="doiLoaiPhongEdit()" required>
                                <option value="1">Tiêu chuẩn (Standard)</option>
                                <option value="2">Sang trọng (Deluxe)</option>
                                <option value="3">Cao cấp (Premium)</option>
                            </select>
                        </div>
                        <div class="row">
                            <div class="col-md-5">
                                <label class="form-label fw-600 text-muted small text-uppercase">Sức chứa</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light"><i class="bi bi-people"></i></span>
                                    <input type="text" id="edit_oNguoi" class="form-control bg-light" readonly>
                                </div>
                            </div>
                            <div class="col-md-7">
                                <label class="form-label fw-600 text-muted small text-uppercase">Giá niêm yết</label>
                                <div class="input-group">
                                    <input type="text" id="edit_oGia" class="form-control bg-light text-primary fw-bold" readonly>
                                    <span class="input-group-text bg-light">VNĐ / đêm</span>
                                </div>
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

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.7.0.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>

    <script>
        const dataLoaiPhong = {
            "1": { nguoi: "2", gia: 950000 },
            "2": { nguoi: "2", gia: 1600000 },
            "3": { nguoi: "3", gia: 3200000 }
        };

        function doiLoaiPhongAdd() {
            let maLoai = document.getElementById("add_roomType").value;
            let thongTin = dataLoaiPhong[maLoai];
            if(thongTin) {
                document.getElementById("add_oNguoi").value = thongTin.nguoi;
                document.getElementById("add_oGia").value = new Intl.NumberFormat('vi-VN').format(thongTin.gia);
            }
        }

        function doiLoaiPhongEdit() {
            let maLoai = document.getElementById("edit_roomType").value;
            let thongTin = dataLoaiPhong[maLoai];
            if(thongTin) {
                document.getElementById("edit_oNguoi").value = thongTin.nguoi;
                document.getElementById("edit_oGia").value = new Intl.NumberFormat('vi-VN').format(thongTin.gia);
            }
        }

        function openEditModal(id, number, typeId, status) {
            document.getElementById('editRoomId').value = id;
            document.getElementById('editRoomNB').value = number;
            document.getElementById('edit_roomType').value = typeId;
            document.getElementById('editStatus').value = status;
            doiLoaiPhongEdit();
            var editModal = new bootstrap.Modal(document.getElementById('editRoomModal'));
            editModal.show();
        }

        $(document).ready(function() {
            doiLoaiPhongAdd(); // Khởi tạo giá trị mặc định cho Modal Add

            $('#roomTable').DataTable({
                "pageLength": 10,
                "lengthChange": false,
                "ordering": false,
                "searching": false,
                "language": {
                    "processing": "Đang xử lý...",
                    "lengthMenu": "Hiển thị _MENU_ mục",
                    "zeroRecords": "Không tìm thấy phòng nào phù hợp",
                    "info": "Hiển thị _START_ - _END_ trong tổng số _TOTAL_ phòng",
                    "infoEmpty": "Hiển thị 0 - 0 trong tổng số 0 phòng",
                    "infoFiltered": "(lọc từ _MAX_ phòng)",
                    "search": "Tìm kiếm nhanh:",
                    "emptyTable": "Chưa có dữ liệu phòng trong hệ thống",
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
    
    <% if(conn != null) try { conn.close(); } catch(Exception e) {} %>
</body>
</html>