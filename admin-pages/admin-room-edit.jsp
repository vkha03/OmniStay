<%@page import="java.lang.reflect.Executable"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../layouts/admin-auth.jsp" %>
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
    <title>Chỉnh sửa Phòng — OmniStay</title>
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
        
        /* ─── FORM CARD ─── */
        .card-custom {
            border: 1px solid rgba(0,0,0,0.05);
            border-radius: 16px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.02);
        }
        .form-control, .form-select {
            border-radius: 8px;
            padding: 0.6rem 1rem;
            border-color: #edf2f9;
        }
        .form-control:focus, .form-select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 0.25rem rgba(26, 107, 90, 0.25);
        }
        .input-group-text {
            background-color: #f8f9fa;
            border-color: #edf2f9;
            border-radius: 8px;
            color: #6c757d;
        }
    </style>
</head>
<body>
    <%@ include file="../layouts/sidebar-admin.jsp" %>
    
    <div class="main-content">
        <%
            String id = request.getParameter("id");
            String upNumber = "";   // khai báo ngoài if để có thể nhận giá trị
            String upStatus = "";
            String upType = "1";
            
            if(id != null){
                String sqlGet = "SELECT * FROM rooms WHERE id = ?";
                PreparedStatement psGet = conn.prepareStatement(sqlGet);
                psGet.setString(1,id);
                ResultSet rsGet = psGet.executeQuery();
                if(rsGet.next()){
                 upNumber = rsGet.getString("room_number");
                 upStatus = rsGet.getString("status");
                 upType = rsGet.getString("room_type_id");
                }
                rsGet.close();
                psGet.close();
            }
        
            if("POST".equalsIgnoreCase(request.getMethod())){
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
                
                session.setAttribute("thongBao", "Sửa phòng mới thành công!");
                
                response.sendRedirect("admin-rooms.jsp");
                return; 
            }
        %>
        
        <div style="max-width: 650px; margin: 0 auto;">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="mb-0 font-display fw-normal" style="color: var(--primary);">Chỉnh sửa Phòng</h3>
                <a href="admin-rooms.jsp" class="btn btn-outline-secondary btn-sm rounded-pill px-3">
                    <i class="bi bi-arrow-left me-1"></i> Quay lại
                </a>
            </div>

            <div class="card card-custom p-4 bg-white">
                <form method="POST">
                    <input type="hidden" name="id" value="<%= id %>">

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label fw-500 text-muted" style="font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.05em;">Số phòng (Bảng rooms)</label>
                            <input type="text" name="room_NB" class="form-control bg-light" value="<%= upNumber %>" required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-500 text-muted" style="font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.05em;">Trạng thái (Bảng rooms)</label>
                            <select name="status" class="form-select bg-light">
                                <option value="AVAILABLE" <%= "AVAILABLE".equals(upStatus) ? "selected" : "" %>>Sẵn sàng</option>
                                <option value="OCCUPIED" <%= "OCCUPIED".equals(upStatus) ? "selected" : "" %>>Đang có khách</option>
                                <option value="MAINTENANCE" <%= "MAINTENANCE".equals(upStatus) ? "selected" : "" %>>Bảo trì</option>
                            </select>
                        </div>
                    </div>

                    <hr class="text-muted opacity-25 my-4">

                    <div class="mb-3">
                        <label class="form-label fw-500 text-muted" style="font-size: 0.85rem; text-transform: uppercase;">Tên loại phòng</label>
                        <select name="room_type_id" id="selectLoaiPhong" class="form-select bg-light" onchange="doiLoaiPhong()" required>
                            <option value="1" <%= "1".equals(upType) ? "selected" : "" %>>Standard</option>
                            <option value="2" <%= "2".equals(upType) ? "selected" : "" %>>Premium</option>
                            <option value="3" <%= "3".equals(upType) ? "selected" : "" %>>Luxury</option>
                        </select>
                    </div>
                    
                    <div class="row mb-4">
                        <div class="col-md-5">
                            <label class="form-label fw-500 text-muted" style="font-size: 0.85rem; text-transform: uppercase;">Sức chứa</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-people"></i></span>
                                <input type="text" id="oNguoi" class="form-control bg-white" readonly>
                            </div>
                        </div>

                        <div class="col-md-7">
                            <label class="form-label fw-500 text-muted" style="font-size: 0.85rem; text-transform: uppercase;">Giá niêm yết</label>
                            <div class="input-group">
                                <input type="text" id="oGia" class="form-control bg-white text-primary fw-bold" readonly>
                                <span class="input-group-text">VNĐ / đêm</span>
                            </div>
                        </div>
                    </div>

                    <div class="text-end pt-3 border-top" style="border-color: var(--border) !important;">
                        <button type="submit" class="btn text-white px-4 py-2" style="background-color: var(--primary); border-radius: 8px; font-weight: 500;">
                            Lưu thay đổi
                        </button>
                    </div>
                </form>
                
                <script>
                    const dataLoaiPhong = {
                        "1": { nguoi: "2", gia: 950000 },
                        "2": { nguoi: "2", gia: 1600000 },
                        "3": { nguoi: "3", gia: 3200000 }
                    };

                    function doiLoaiPhong() {
                        let maLoai = document.getElementById("selectLoaiPhong").value;
                        let thongTin = dataLoaiPhong[maLoai];
                        if(thongTin) {
                            document.getElementById("oNguoi").value = thongTin.nguoi;
                            document.getElementById("oGia").value = new Intl.NumberFormat('vi-VN').format(thongTin.gia);
                        }
                    }

                    window.onload = function() {
                        doiLoaiPhong();
                    };
                </script>
            </div> </div> </div> <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>