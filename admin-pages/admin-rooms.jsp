<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.NumberFormat" %>
<%
    Connection conn = null;
    String dbError = null;
    try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/omnistay", "root", "");
    }catch(Exception e){
        dbError = e.getMessage();
    }
    NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Phòng — OmniStay Admin</title>
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
        body {
            font-family: 'Outfit', sans-serif;
            background-color: var(--bg-light);
            color: var(--text-main);
            overflow-x: hidden;
        }
        .font-display { font-family: "Playfair Display", serif; }
        
        /* ─── SIDEBAR (Đồng bộ từ index.jsp) ─── */
        .sidebar {
            width: 260px;
            background: var(--primary-dark);
            min-height: 100vh;
            position: fixed;
            top: 0;
            left: 0;
            z-index: 1000;
            padding-top: 1.5rem;
            box-shadow: 4px 0 20px rgba(0,0,0,0.05);
        }
        .sidebar .brand {
            padding: 0 1.5rem 2rem;
            border-bottom: 1px solid rgba(255,255,255,0.05);
            margin-bottom: 1rem;
        }
        .sidebar .brand a {
            font-size: 1.6rem;
            letter-spacing: 1px;
        }
        .sidebar .brand span {
            color: var(--accent);
            font-weight: 600;
        }
        .nav-sidebar .nav-link {
            color: rgba(255,255,255,0.7);
            padding: 0.8rem 1.5rem;
            margin: 0.2rem 1rem;
            border-radius: 8px;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            font-weight: 400;
        }
        .nav-sidebar .nav-link i {
            margin-right: 12px;
            font-size: 1.1rem;
        }
        .nav-sidebar .nav-link:hover, .nav-sidebar .nav-link.active {
            color: #fff;
            background: rgba(255,255,255,0.1);
        }
        .nav-sidebar .nav-link.active {
            background: var(--primary);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        /* ─── MAIN CONTENT ─── */
        .main-content {
            margin-left: 260px;
            padding: 2rem;
        }
        
        /* ─── TABLE ─── */
        .table-custom {
            background: #fff;
            border-radius: 16px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.02);
            border: 1px solid rgba(0,0,0,0.05);
            overflow: hidden;
        }
        .table-custom th {
            background-color: #f8f9fa;
            color: #6c757d;
            font-weight: 500;
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 0.5px;
            padding: 1rem 1.5rem;
            border-bottom: 2px solid #edf2f9;
        }
        .table-custom td {
            padding: 1rem 1.5rem;
            vertical-align: middle;
            color: #495057;
            font-size: 0.9rem;
            border-bottom: 1px solid #edf2f9;
        }
        .table-custom tbody tr:hover {
            background-color: #f8f9fa;
        }
        .table-custom tr:last-child td { border-bottom: none; }
        
        .action-btn {
            width: 32px; height: 32px;
            display: inline-flex;
            align-items: center; justify-content: center;
            border-radius: 8px;
            transition: 0.2s;
        }
        .action-btn:hover { background: var(--bg-light); }
        
        /* Custom form elements */
        .search-input {
            border: 1px solid rgba(0,0,0,0.05);
            border-radius: 8px;
            padding: 0.5rem 1rem 0.5rem 2.5rem;
            font-size: 0.9rem;
            width: 300px;
        }
        .search-icon {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #888;
        }
        .room-thumbnail {
            width: 80px;
            height: 50px;
            border-radius: 8px;
            object-fit: cover;
        }
    </style>
</head>
<body>
    <%@ include file="../layouts/sidebar-admin.jsp" %>
    <main class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="font-display fw-normal mb-1">Danh sách Phòng nghỉ</h2>
                <p class="text-muted mb-0" style="font-size: 0.9rem;">Quản lý thông tin, giá cả và trạng thái của toàn bộ hệ thống phòng.</p>
            </div>
            <div class="d-flex align-items-center gap-3">
                <a href="admin-room-add.jsp" class="btn text-white fw-500 rounded-pill px-4" style="background: var(--primary); font-size: 0.85rem;">
                    <i class="bi bi-plus-lg me-1"></i> Thêm phòng mới
                </a>
            </div>
        </div>	
        <%
        String loaiphong = request.getParameter("loaiphong");
    	String trangthai = request.getParameter("trangthai");
        %>

         <form action="admin-rooms.jsp" method="GET" class="bg-white p-3 rounded-4 border mb-4 d-flex justify-content-end align-items-center" style="border-color: var(--border) !important;">
            
            <div class="d-flex gap-2">
                <select name="loaiphong" class="form-select border-0 bg-light rounded-3" style="font-size: 0.85rem; width: 160px;">
                    <option value=""<%= (loaiphong == null || loaiphong.isEmpty()) ? "selected" : "" %> >Tất cả loại phòng</option>
                    <option value="Standard" <%= "Standard".equals(loaiphong) ? "selected" : "" %>>Standard</option>
                    <option value="Prenium"<%= "Prenium".equals(loaiphong) ? "selected" : "" %>>Prenium</option>
                    <option value="Luxury"<%= "Luxury".equals(loaiphong) ? "selected" : "" %>>Luxury</option>
                </select>
                <select name="trangthai" class="form-select border-0 bg-light rounded-3" style="font-size: 0.85rem; width: 150px;">
                    <option value=""<%= (trangthai == null || trangthai.isEmpty()) ? "selected" : "" %>>Tất cả trạng thái</option>
                    <option value="AVAILABLE" <%= "AVAILABLE".equals(trangthai) ? "selected" : "" %>>Sẵn sàng</option>
                    <option value="OCCUPIED" <%= "OCCUPIED".equals(trangthai) ? "selected" : "" %>>Đang có khách</option>
                    <option value="MAINTENANCE" <%= "MAINTENANCE".equals(trangthai) ? "selected" : "" %>>Bảo trì</option>
                </select>
                <button type="submit" class="btn text-white px-4" style="background: var(--primary); border-radius: 8px;">Lọc</button>
            </div>
        </form>
			<%
            // 1. Thò tay vào túi session lấy tin nhắn ra
            String msg = (String) session.getAttribute("thongBao");
            
            // 2. Nếu có tin nhắn thì in cái bảng màu xanh lá ra
            if (msg != null) {
        	%>
            <div class="alert alert-success alert-dismissible fade show shadow-sm border-0" role="alert" style="border-radius: 12px; background-color: #d1e7dd; color: #0f5132;">
                <i class="bi bi-check-circle-fill me-2"></i> <strong>Thành công!</strong> <%= msg %>
                <button type="button" class="btn-close shadow-none" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <%
                // 3. QUAN TRỌNG NHẤT: Lấy ra xài xong thì phải xóa nó đi
                // Nếu không xóa, mỗi lần bạn F5 tải lại trang nó lại hiện ra tiếp!
                session.removeAttribute("thongBao");
            }
       		%>
        <div class="table-custom">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead>
                        <tr>
                           
                            <th style="width: 120px;">Số phòng</th>
                            <th>Tên loại phòng</th>
                            <th>Sức chứa</th>
                            <th>Giá niêm yết</th>
                            <th>Trạng thái</th>
                            <th class="text-end">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        if(conn!=null){
                        	
                            try{	
                                String SQL = "SELECT rs.id, rs.room_number, rs.room_type_id, rs.status, rt.* "+ 
                            				 "FROM rooms rs "+
                            				 "JOIN room_types rt ON rs.room_type_id = rt.id ";
                                
                                String updateId = request.getParameter("updateId");
                                String newStatus = request.getParameter("newStatus");

                                // Nếu phát hiện có tín hiệu đổi trạng thái -> Cập nhật CSDL ngay (Lấy ID để sửa trạng thái "status")
                                if (updateId != null && newStatus != null) {
                                    String updateSQL = "UPDATE rooms SET status = ? WHERE id = ?";
                                    PreparedStatement upStatus = conn.prepareStatement(updateSQL);
                                    upStatus.setString(1, newStatus);
                                    upStatus.setInt(2, Integer.parseInt(updateId));
                                    upStatus.executeUpdate();
                                    upStatus.close();
                                }
                                
                                //Tìm loại phòng - trạng thái
                                if(loaiphong != null && !loaiphong.isEmpty()){
                               	 SQL = SQL + "WHERE rt.type_name = '" + loaiphong +"'";
                                }
                            	if(trangthai != null && !trangthai.isEmpty()){
                            	 SQL = SQL + " AND rs.status = '"+ trangthai +"'";
                            	}
               					// Sắp xếp phòng theo thứ tự tăng dần 
                                SQL = SQL + " ORDER BY rs.room_number ASC";
                                PreparedStatement ps = conn.prepareStatement(SQL);
                                ResultSet rs = ps.executeQuery();
                                
                                // Hiện tất cả phòng trong DB
                                while(rs.next()){
                                	int id = rs.getInt("id");
                                	int roomsNB = rs.getInt("room_number");
                                	int roomsID = rs.getInt("room_type_id");
                                	String status = rs.getString("status");
                                	double price = rs.getDouble("base_price");
                                	int people = rs.getInt("max_occupancy");
                                	String typeName = rs.getString("type_name");
                                	                    	
                        %>
                        
                        <tr>
                               
                            <td class="text-center fw-500 text-muted"><%= roomsNB %></td> 
                            <td>
                                <div class="fw-500 font-display" style="font-size: 1.1rem; color: var(--primary);"><%= typeName %></div>
                                
                            </td>
                            <td>
                                <span class="badge bg-light text-dark border fw-normal"><i class="bi bi-people me-1"></i><%= people %> Người lớn</span>
                            </td>
                            <td class="font-display fw-600" style="color: var(--primary); font-size: 1.1rem;">
                                <%= nf.format(price).replace("VNĐ", "₫") %> <span class="text-muted fw-normal" style="font-size: 0.75rem;">/ đêm</span>
                            </td>
                          	<td>
                                <form action="admin-rooms.jsp" method="GET" style="margin: 0;">
                                    
                                    <input type="hidden" name="updateId" value="<%= id %>">
                                    
                                    <input type="hidden" name="loaiphong" value="<%= loaiphong != null ? loaiphong : "" %>">
                                    <input type="hidden" name="trangthai" value="<%= trangthai != null ? trangthai : "" %>">
                                    
                                    <select name="newStatus" class="form-select form-select-sm shadow-none" onchange="this.form.submit()" style="border-radius: 8px; width: 140px; cursor: pointer; border-color: var(--border);">
                                        <option value="AVAILABLE" <%= "AVAILABLE".equals(status) ? "selected" : "" %>>Sẵn sàng</option>
                                        <option value="OCCUPIED" <%= "OCCUPIED".equals(status) ? "selected" : "" %>>Đang có khách</option>
                                        <option value="MAINTENANCE" <%= "MAINTENANCE".equals(status) ? "selected" : "" %>>Bảo trì</option>
                                    </select>
                                </form>
                            </td>
                            <td class="text-end">
                                <a href="admin-room-edit.jsp?id=<%=id %>" class="action-btn text-primary" title="Chỉnh sửa"><i class="bi bi-pencil-square"></i></a>
                                <a href="#" class="action-btn text-danger" title="Xóa"><i class="bi bi-trash3"></i></a>
                            </td>
                        </tr>

                    
                        
                       
                   <%
                        } // 1. Đây là ngoặc đóng của vòng lặp while(rs.next())
                            rs.close();
                            ps.close();
                        } catch(Exception e) { // 2. Ngoặc đóng của try và mở của catch
                            out.println("<p>Lỗi: " + e.getMessage() + "</p>");
                        }
                    	} else { // 3. RẤT QUAN TRỌNG: Ngoặc đóng của if(conn != null) trước chữ else
                        out.println("<p>Lỗi kết nối database</p>");
                    	}
                  %>
                   
                    </tbody>
                </table>
            </div>
            
            <div class="d-flex justify-content-between align-items-center p-3 border-top" style="border-color: var(--border) !important;">
                <div class="text-muted" style="font-size: 0.8rem;">Hiển thị 1 - 10 trong số 24 loại phòng</div>
                <ul class="pagination pagination-sm mb-0">
                    <li class="page-item disabled"><a class="page-link" href="#"><i class="bi bi-chevron-left"></i></a></li>
                    <li class="page-item active"><a class="page-link" style="background-color: var(--primary); border-color: var(--primary);" href="#">1</a></li>
                    <li class="page-item"><a class="page-link text-dark" href="#">2</a></li>
                    <li class="page-item"><a class="page-link text-dark" href="#">3</a></li>
                    <li class="page-item"><a class="page-link" href="#"><i class="bi bi-chevron-right text-dark"></i></a></li>
                </ul>
            </div>
        </div>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>