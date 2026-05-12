<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- ==========================================================================
     PHÂN HỆ QUẢN LÝ ĐƠN ĐẶT PHÒNG VÀ HÓA ĐƠN LƯU TRÚ (ADMIN BOOKINGS CONTROLLER)
     Xử lý toàn bộ logic tài chính và vòng đời của một đơn đặt phòng:
     từ bước tiếp nhận thông tin, gán phòng, tính toán số đêm tự động, đính kèm
     dịch vụ phát sinh, cập nhật thanh toán cho tới khi Check-out hoàn tất.
     ========================================================================== --%>
<%@ include file="../layouts/admin-auth.jsp" %>
<%@ page import="java.sql.*, java.util.*, java.text.NumberFormat, java.text.SimpleDateFormat, java.util.concurrent.TimeUnit" %>
<%@ include file="../env-secrets.jsp" %>
<%
    // Bắt buộc mã hóa chuỗi đầu vào theo UTF-8 để lưu trữ chính xác thông tin khách hàng
    request.setCharacterEncoding("UTF-8");
    Connection conn = null;
    String thongBao = null;
    String loaiThongBao = "success";

    try {
        // Nạp Driver và kết nối an toàn tới MySQL
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(SECRET_DB_URL, SECRET_DB_USER, SECRET_DB_PASS);

        // ─── 1. BỘ ĐIỀU KHIỂN TÁC VỤ ĐƠN HÀNG (ACTION CONTROLLER) ───
        String action = request.getParameter("action");
        if (action != null) {
            // a) TÁC VỤ LẬP HÓA ĐƠN / ĐẶT PHÒNG MỚI (CREATE BOOKING & INVOICE)
            if (action.equals("addBooking")) {
                String name = request.getParameter("fullName");
                String phone = request.getParameter("phone");
                String email = request.getParameter("email");
                String idCard = request.getParameter("idCard");
                int roomId = Integer.parseInt(request.getParameter("roomId"));
                java.sql.Date checkIn = java.sql.Date.valueOf(request.getParameter("checkIn"));
                java.sql.Date checkOut = java.sql.Date.valueOf(request.getParameter("checkOut"));
                String notes = request.getParameter("notes");
                double extraAmount = 0;
                try { 
                    extraAmount = Double.parseDouble(request.getParameter("extraAmount")); 
                } catch(Exception e) {}
                
                long diff = Math.abs(checkOut.getTime() - checkIn.getTime());
                long nights = TimeUnit.DAYS.convert(diff, TimeUnit.MILLISECONDS);
                if(nights == 0) nights = 1;
                
                PreparedStatement psRoomPrice = conn.prepareStatement("SELECT base_price FROM room_types rt JOIN rooms r ON r.room_type_id = rt.id WHERE r.id = ?");
                psRoomPrice.setInt(1, roomId); ResultSet rsRP = psRoomPrice.executeQuery();
                double roomBasePrice = 0; if(rsRP.next()) roomBasePrice = rsRP.getDouble("base_price");
                double roomTotal = roomBasePrice * nights;
                
                String bookingCode = "OS" + System.currentTimeMillis() % 1000000;
                PreparedStatement psB = conn.prepareStatement("INSERT INTO bookings (booking_code, customer_full_name, customer_email, customer_phone, customer_id_card, check_in_date, check_out_date, total_amount, paid_amount, status, payment_status, notes) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)", Statement.RETURN_GENERATED_KEYS);
                psB.setString(1, bookingCode); psB.setString(2, name); psB.setString(3, email); psB.setString(4, phone); psB.setString(5, idCard); psB.setDate(6, checkIn); psB.setDate(7, checkOut); 
                psB.setDouble(8, roomTotal + extraAmount); psB.setDouble(9, 0); psB.setString(10, "CHECKED_IN"); psB.setString(11, "UNPAID"); psB.setString(12, notes);
                psB.executeUpdate();
                
                ResultSet generatedKeys = psB.getGeneratedKeys();
                if (generatedKeys.next()) {
                    int newBookingId = generatedKeys.getInt(1);
                    PreparedStatement psBR = conn.prepareStatement("INSERT INTO booking_rooms (booking_id, room_id) VALUES (?,?)");
                    psBR.setInt(1, newBookingId); psBR.setInt(2, roomId); psBR.executeUpdate();
                    PreparedStatement psRoomUp = conn.prepareStatement("UPDATE rooms SET status = 'OCCUPIED' WHERE id = ?");
                    psRoomUp.setInt(1, roomId); psRoomUp.executeUpdate();
                    
                    String[] selectedServices = request.getParameterValues("services");
                    double totalSvc = 0;
                    if (selectedServices != null) {
                        for (String sid : selectedServices) {
                            int svcId = Integer.parseInt(sid);
                            int qty = Integer.parseInt(request.getParameter("qty_" + svcId));
                            PreparedStatement psSInfo = conn.prepareStatement("SELECT price FROM services WHERE id = ?");
                            psSInfo.setInt(1, svcId); ResultSet rsS = psSInfo.executeQuery();
                            if(rsS.next()) {
                                double sPrice = rsS.getDouble("price"); totalSvc += sPrice * qty;
                                PreparedStatement psBS = conn.prepareStatement("INSERT INTO booking_services (booking_id, service_id, quantity, historical_price) VALUES (?,?,?,?)");
                                psBS.setInt(1, newBookingId); psBS.setInt(2, svcId); psBS.setInt(3, qty); psBS.setDouble(4, sPrice); psBS.executeUpdate();
                            }
                        }
                    }
                    PreparedStatement psFinal = conn.prepareStatement("UPDATE bookings SET total_amount = ? WHERE id = ?");
                    psFinal.setDouble(1, roomTotal + totalSvc); psFinal.setInt(2, newBookingId); psFinal.executeUpdate();
                }
                thongBao = "Đã lập hóa đơn thành công!";
            }
            // ─── LOGIC SỬA HÓA ĐƠN ───
            else if (action.equals("editBooking")) {
                int bid = Integer.parseInt(request.getParameter("id"));
                String name = request.getParameter("fullName");
                String phone = request.getParameter("phone");
                String idCard = request.getParameter("idCard");
                int newRoomId = Integer.parseInt(request.getParameter("roomId"));
                int oldRoomId = Integer.parseInt(request.getParameter("oldRoomId"));
                java.sql.Date checkIn = java.sql.Date.valueOf(request.getParameter("checkIn"));
                java.sql.Date checkOut = java.sql.Date.valueOf(request.getParameter("checkOut"));
                String notes = request.getParameter("notes");
                
                double paidAmount = 0;
                try { paidAmount = Double.parseDouble(request.getParameter("paidAmount")); } catch(Exception e){}
                
                // --- LOGIC TÍNH TOÁN TỔNG TIỀN THÔNG MINH (BẢO TOÀN ĐIỀU CHỈNH CŨ) ---
                // 1. Lấy thông tin cũ để tính "Chênh lệch thủ công" hiện tại
                double oldTotalDB = 0;
                int oldRoomIdFromDB = 0;
                PreparedStatement psOldB = conn.prepareStatement("SELECT b.total_amount, br.room_id, b.check_in_date, b.check_out_date FROM bookings b JOIN booking_rooms br ON b.id = br.booking_id WHERE b.id = ? LIMIT 1");
                psOldB.setInt(1, bid);
                ResultSet rsOldB = psOldB.executeQuery();
                long oldNights = 0;
                if(rsOldB.next()) {
                    oldTotalDB = rsOldB.getDouble("total_amount");
                    oldRoomIdFromDB = rsOldB.getInt("room_id");
                    java.sql.Date d1 = rsOldB.getDate("check_in_date");
                    java.sql.Date d2 = rsOldB.getDate("check_out_date");
                    long dDiff = Math.abs(d2.getTime() - d1.getTime());
                    oldNights = TimeUnit.DAYS.convert(dDiff, TimeUnit.MILLISECONDS);
                    if(oldNights == 0) oldNights = 1;
                }
                
                // 2. Tính giá phòng cũ
                PreparedStatement psOldP = conn.prepareStatement("SELECT base_price FROM room_types rt JOIN rooms r ON r.room_type_id = rt.id WHERE r.id = ?");
                psOldP.setInt(1, oldRoomIdFromDB); ResultSet rsOldP = psOldP.executeQuery();
                double oldRoomPrice = 0; if(rsOldP.next()) oldRoomPrice = rsOldP.getDouble("base_price");
                
                // 3. Tính tiền dịch vụ hiện tại
                PreparedStatement psS = conn.prepareStatement("SELECT SUM(quantity * historical_price) as svc_total FROM booking_services WHERE booking_id = ?");
                psS.setInt(1, bid); ResultSet rsS = psS.executeQuery();
                double svcTotal = 0; if(rsS.next()) svcTotal = rsS.getDouble("svc_total");
                
                // 4. Khoản điều chỉnh thủ công cũ = Tổng hiện tại - (Giá phòng cũ * Số đêm cũ + Dịch vụ)
                double previousManualAdj = oldTotalDB - (oldRoomPrice * oldNights + svcTotal);
                
                // 5. Tính toán giá trị mới cho phòng
                long diff = Math.abs(checkOut.getTime() - checkIn.getTime());
                long nights = TimeUnit.DAYS.convert(diff, TimeUnit.MILLISECONDS);
                if(nights == 0) nights = 1;
                
                PreparedStatement psP = conn.prepareStatement("SELECT base_price FROM room_types rt JOIN rooms r ON r.room_type_id = rt.id WHERE r.id = ?");
                psP.setInt(1, newRoomId); ResultSet rsP = psP.executeQuery();
                double roomBasePrice = 0; if(rsP.next()) roomBasePrice = rsP.getDouble("base_price");
                double newRoomTotal = roomBasePrice * nights;

                // 6. Tổng mới = (Giá phòng mới * Số đêm mới + Dịch vụ) + Khoản điều chỉnh cũ + Khoản điều chỉnh mới
                double currentTotal = (newRoomTotal + svcTotal) + previousManualAdj;
                
                String adjType = request.getParameter("adjType");
                double adjAmount = 0;
                try { adjAmount = Double.parseDouble(request.getParameter("adjAmount")); } catch(Exception e){}
                
                if("increase".equals(adjType)) currentTotal += adjAmount;
                else if("decrease".equals(adjType)) currentTotal -= adjAmount;
                
                // --- XỬ LÝ GHI CHÚ BỔ SUNG (APPEND) ---
                String existingNotes = "";
                PreparedStatement psGetNotes = conn.prepareStatement("SELECT notes FROM bookings WHERE id = ?");
                psGetNotes.setInt(1, bid);
                ResultSet rsGetNotes = psGetNotes.executeQuery();
                if(rsGetNotes.next()) existingNotes = rsGetNotes.getString("notes");
                if(existingNotes == null) existingNotes = "";
                
                if (notes != null && !notes.trim().isEmpty()) {
                    SimpleDateFormat noteTime = new SimpleDateFormat("dd/MM HH:mm");
                    String logEntry = "[" + noteTime.format(new java.util.Date()) + "] " + notes.trim();
                    if (!existingNotes.isEmpty()) {
                        notes = existingNotes + "\n" + logEntry;
                    } else {
                        notes = logEntry;
                    }
                } else {
                    notes = existingNotes;
                }
                
                PreparedStatement psUp = conn.prepareStatement("UPDATE bookings SET customer_full_name=?, customer_phone=?, customer_id_card=?, check_in_date=?, check_out_date=?, total_amount=?, paid_amount=?, notes=? WHERE id=?");
                psUp.setString(1, name); psUp.setString(2, phone); psUp.setString(3, idCard); psUp.setDate(4, checkIn); psUp.setDate(5, checkOut); 
                psUp.setDouble(6, currentTotal); psUp.setDouble(7, paidAmount); psUp.setString(8, notes); psUp.setInt(9, bid);
                psUp.executeUpdate();
                
                if (newRoomId != oldRoomId) {
                    PreparedStatement psOld = conn.prepareStatement("UPDATE rooms SET status = 'AVAILABLE' WHERE id = ?");
                    psOld.setInt(1, oldRoomId); psOld.executeUpdate();
                    PreparedStatement psNew = conn.prepareStatement("UPDATE rooms SET status = 'OCCUPIED' WHERE id = ?");
                    psNew.setInt(1, newRoomId); psNew.executeUpdate();
                    PreparedStatement psBR = conn.prepareStatement("UPDATE booking_rooms SET room_id = ? WHERE booking_id = ?");
                    psBR.setInt(1, newRoomId); psBR.setInt(2, bid); psBR.executeUpdate();
                }
                thongBao = "Đã cập nhật hóa đơn!";
            }
            // ─── LOGIC ĐỔI TRẠNG THÁI ───
            else if (action.equals("updateStatus")) {
                int bid = Integer.parseInt(request.getParameter("id"));
                String newStatus = request.getParameter("newStatus");
                if(newStatus.equals("CHECKED_IN")) {
                    PreparedStatement psRoom = conn.prepareStatement("UPDATE rooms SET status = 'OCCUPIED' WHERE id = (SELECT room_id FROM booking_rooms WHERE booking_id = ? LIMIT 1)");
                    psRoom.setInt(1, bid); psRoom.executeUpdate();
                } else if(newStatus.equals("COMPLETED") || newStatus.equals("CANCELLED")) {
                    PreparedStatement psRoom = conn.prepareStatement("UPDATE rooms SET status = 'CLEANING' WHERE id = (SELECT room_id FROM booking_rooms WHERE booking_id = ? LIMIT 1)");
                    psRoom.setInt(1, bid); psRoom.executeUpdate();
                    if(newStatus.equals("COMPLETED")) {
                        PreparedStatement psPay = conn.prepareStatement("UPDATE bookings SET payment_status = 'PAID', paid_amount = total_amount WHERE id = ?");
                        psPay.setInt(1, bid); psPay.executeUpdate();
                    }
                }
                PreparedStatement ps = conn.prepareStatement("UPDATE bookings SET status = ? WHERE id = ?");
                ps.setString(1, newStatus); ps.setInt(2, bid); ps.executeUpdate();
                thongBao = "Đã cập nhật trạng thái!";
            }
            else if (action.equals("delete")) {
                int bid = Integer.parseInt(request.getParameter("id"));
                PreparedStatement ps = conn.prepareStatement("DELETE FROM bookings WHERE id = ?");
                ps.setInt(1, bid); ps.executeUpdate();
                thongBao = "Đã xóa hóa đơn!";
            }
        }
    } catch(Exception e) {
        thongBao = "Lỗi: " + e.getMessage(); loaiThongBao = "danger";
    }
    NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");

    // Helper translation
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
    <title>Quản lý Hóa đơn — OmniStay Admin</title>
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
                <div class="page-title-icon"><i class="bi bi-calendar-check"></i></div>
                <div>
                    <h2 class="font-display fw-normal mb-1">Quản lý Đơn đặt phòng & Hóa đơn</h2>
                    <p class="text-muted mb-0">Hệ thống quản lý lưu trú và tài chính của OmniStay.</p>
                </div>
            </div>
            <button class="btn btn-primary-gradient rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#addBookingModal">
                <i class="bi bi-plus-lg me-1"></i> Lập hóa đơn mới
            </button>
        </div>

        <% if (thongBao != null) { %>
            <div class="alert alert-<%= loaiThongBao %> shadow-sm mb-4">
                <i class="bi bi-info-circle-fill me-2"></i> <%= thongBao %>
            </div>
        <% } %>

        <%
            String search = request.getParameter("search");
            String statusFilter = request.getParameter("statusFilter");
        %>

        <!-- Filter Bar -->
        <form action="admin-bookings.jsp" method="GET" class="filter-bar">
            <div class="row g-3 align-items-center">
                <div class="col-md-5">
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-search"></i></span>
                        <input type="text" name="search" class="form-control" placeholder="Tìm tên khách, SĐT, CCCD hoặc mã đơn..." value="<%= (search != null) ? search : "" %>">
                    </div>
                </div>
                <div class="col-md-3">
                    <select name="statusFilter" class="form-select">
                        <option value="">Tất cả trạng thái</option>
                        <option value="PENDING" <%= "PENDING".equals(statusFilter) ? "selected" : "" %>>Chờ xử lý</option>
                        <option value="CONFIRMED" <%= "CONFIRMED".equals(statusFilter) ? "selected" : "" %>>Đã xác nhận</option>
                        <option value="CHECKED_IN" <%= "CHECKED_IN".equals(statusFilter) ? "selected" : "" %>>Đang lưu trú</option>
                        <option value="COMPLETED" <%= "COMPLETED".equals(statusFilter) ? "selected" : "" %>>Đã hoàn thành</option>
                        <option value="CANCELLED" <%= "CANCELLED".equals(statusFilter) ? "selected" : "" %>>Đã hủy</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-primary-gradient w-100">Lọc dữ liệu</button>
                </div>
                <div class="col-md-2 text-end">
                    <a href="admin-bookings.jsp" class="btn btn-light w-100 border rounded-pill text-muted small">Xóa lọc</a>
                </div>
            </div>
        </form>

        <div class="table-custom p-4">
            <div class="table-responsive">
                <table id="bookingTable" class="table table-hover mb-0 w-100">
                    <thead>
                        <tr>
                            <th>Hóa đơn</th>
                            <th>Khách hàng & CCCD</th>
                            <th>Phòng & Lịch</th>
                            <th>Tổng tiền</th>
                            <th>Đã trả</th>
                            <th>Còn lại</th>
                            <th>Thanh toán</th>
                            <th>Trạng thái</th>
                            <th class="text-end">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            // 2. TRUY VẤN VÀ ĐỔ DỮ LIỆU DANH SÁCH ĐƠN ĐẶT PHÒNG / HÓA ĐƠN (RENDER BOOKINGS TABLE)
                            if(conn != null) {
                                try {
                                    // Thực hiện truy vấn JOIN 3 bảng: `bookings`, `booking_rooms` và `rooms` để lấy đầy đủ số phòng
                                    String sql = "SELECT b.*, r.id as room_id, r.room_number FROM bookings b " +
                                                 "LEFT JOIN booking_rooms br ON b.id = br.booking_id " +
                                                 "LEFT JOIN rooms r ON br.room_id = r.id WHERE 1=1 ";
                                    
                                    if(search != null && !search.trim().isEmpty()) {
                                        sql += " AND (b.booking_code LIKE ? OR b.customer_full_name LIKE ? OR b.customer_phone LIKE ? OR b.customer_id_card LIKE ?)";
                                    }
                                    if(statusFilter != null && !statusFilter.isEmpty()) {
                                        sql += " AND b.status = ?";
                                    }
                                    
                                    sql += " ORDER BY b.created_at DESC";
                                    
                                    PreparedStatement ps = conn.prepareStatement(sql);
                                    int pIdx = 1;
                                    if(search != null && !search.trim().isEmpty()) {
                                        String pat = "%" + search.trim() + "%";
                                        ps.setString(pIdx++, pat); ps.setString(pIdx++, pat); ps.setString(pIdx++, pat); ps.setString(pIdx++, pat);
                                    }
                                    if(statusFilter != null && !statusFilter.isEmpty()) {
                                        ps.setString(pIdx++, statusFilter);
                                    }
                                    
                                    ResultSet rs = ps.executeQuery();
                                    while(rs.next()) {
                                        int id = rs.getInt("id");
                                        String code = rs.getString("booking_code");
                                        String name = rs.getString("customer_full_name");
                                        String phone = rs.getString("customer_phone");
                                        String idCard = rs.getString("customer_id_card");
                                        int roomId = rs.getInt("room_id");
                                        String roomNB = rs.getString("room_number");
                                        java.sql.Date checkIn = rs.getDate("check_in_date");
                                        java.sql.Date checkOut = rs.getDate("check_out_date");
                                        double total = rs.getDouble("total_amount");
                                        double paid = rs.getDouble("paid_amount");
                                        String status = rs.getString("status");
                                        String notes = rs.getString("notes") != null ? rs.getString("notes") : "";
                        %>
                        <tr>
                            <td><span class="fw-bold" style="color: var(--primary);"><%= code %></span></td>
                            <td><div class="fw-600"><%= name %></div><div class="text-muted small"><%= idCard %></div></td>
                            <td><span class="badge bg-light text-dark border fw-normal mb-1">P.<%= roomNB %></span><br><small class="text-muted"><%= sdf.format(checkIn) %> - <%= sdf.format(checkOut) %></small></td>
                            <td><div class="fw-600 font-display text-dark" style="font-size: 1.05rem;"><%= nf.format(total).replace("VNĐ", "₫") %></div></td>
                            <td><div class="text-success"><%= nf.format(paid).replace("VNĐ", "₫") %></div></td>
                            <%-- Tính toán khoản nợ/còn lại trực tiếp (total - paid) để hiển thị cảnh báo đỏ nếu chưa thanh toán hết --%>
                            <td><div class="<%= (total-paid) > 0 ? "text-danger fw-bold" : "text-muted" %>"><%= nf.format(total-paid).replace("VNĐ", "₫") %></div></td>
                            <td><span class="<%= rs.getString("payment_status").equals("PAID") ? "text-success" : "text-danger" %> fw-bold small"><%= rs.getString("payment_status").equals("PAID") ? "ĐÃ THANH TOÁN" : "CHƯA THANH TOÁN" %></span></td>
                            <td>
                                <% 
                                    // Chuyển đổi mã trạng thái sang nhãn tiếng Việt tương ứng kèm style riêng biệt
                                    String stClass = "st-pending"; String stText = "Chờ xử lý";
                                    if(status.equals("CONFIRMED")) { stClass = "st-confirmed"; stText = "Đã xác nhận"; }
                                    else if(status.equals("CHECKED_IN")) { stClass = "st-checked_in"; stText = "Đang lưu trú"; }
                                    else if(status.equals("COMPLETED")) { stClass = "st-completed"; stText = "Hoàn tất"; }
                                    else if(status.equals("CANCELLED")) { stClass = "st-cancelled"; stText = "Đã hủy"; }
                                %>
                                <span class="st-badge <%= stClass %>"><%= stText %></span>
                            </td>
                            <td class="text-end">
                                <div class="dropdown">
                                    <button class="action-btn dropdown-toggle no-caret border-0 bg-transparent" data-bs-toggle="dropdown"><i class="bi bi-three-dots-vertical"></i></button>
                                    <ul class="dropdown-menu dropdown-menu-end shadow-sm" style="border-radius: 12px; font-size: 0.85rem; border: 1px solid var(--border);">
                                        <li><a class="dropdown-item py-2" href="javascript:void(0)" onclick="openEditModal(<%=id%>, '<%=name%>', '<%=phone%>', '<%=idCard%>', <%=roomId%>, '<%=checkIn%>', '<%=checkOut%>', '<%=notes%>', <%=total%>, <%=paid%>)"><i class="bi bi-pencil-square me-2 text-primary"></i>Quản lý & Sửa hóa đơn</a></li>
                                        <% if(status.equals("CONFIRMED")) { %>
                                            <li><a class="dropdown-item py-2" href="admin-bookings.jsp?action=updateStatus&newStatus=CHECKED_IN&id=<%=id%>"><i class="bi bi-box-arrow-in-right me-2 text-success"></i>Check-in khách</a></li>
                                        <% } %>
                                        <% if(status.equals("CHECKED_IN")) { %>
                                            <li><a class="dropdown-item py-2" href="admin-bookings.jsp?action=updateStatus&newStatus=COMPLETED&id=<%=id%>" onclick="return confirm('Xác nhận thanh toán toàn bộ và Check-out?')"><i class="bi bi-box-arrow-right me-2 text-primary"></i>Check-out (Tất toán)</a></li>
                                        <% } %>
                                        <li><hr class="dropdown-divider"></li>
                                        <li><a class="dropdown-item py-2 text-danger" href="admin-bookings.jsp?action=delete&id=<%=id%>" onclick="return confirm('Xóa hóa đơn?')"><i class="bi bi-trash me-2"></i>Xóa</a></li>
                                    </ul>
                                </div>
                            </td>
                        </tr>
                        <% } rs.close(); ps.close(); } catch(Exception e) { out.println(e.getMessage()); } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <!-- Modal Sửa hóa đơn -->
    <div class="modal fade" id="editBookingModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title font-display fw-bold" style="color: var(--primary);">Chỉnh sửa hóa đơn</h5>
                    <button type="button" class="btn-close shadow-none" data-bs-dismiss="modal"></button>
                </div>
                <form action="admin-bookings.jsp" method="POST" onsubmit="return validateBookingForm(this)">
                    <input type="hidden" name="action" value="editBooking">
                    <input type="hidden" name="id" id="editId">
                    <input type="hidden" name="oldRoomId" id="oldRoomId">
                    <div class="modal-body px-4">
                        <div class="mb-3"><label class="form-label">Họ và tên khách</label><input type="text" name="fullName" id="editName" class="form-control" required></div>
                        <div class="row mb-3"><div class="col-6"><label class="form-label">Số điện thoại</label><input type="text" name="phone" id="editPhone" class="form-control" required></div><div class="col-6"><label class="form-label">CCCD/Passport</label><input type="text" name="idCard" id="editIdCard" class="form-control" required></div></div>
                        <div class="mb-3"><label class="form-label">Phòng lưu trú</label>
                            <select name="roomId" id="editRoomId" class="form-select" required>
                                <% try { PreparedStatement psR = conn.prepareStatement("SELECT r.id, r.room_number, rt.type_name FROM rooms r JOIN room_types rt ON r.room_type_id = rt.id WHERE r.status = 'AVAILABLE' OR r.status = 'OCCUPIED'"); ResultSet rsR = psR.executeQuery(); while(rsR.next()){ %>
                                <option value="<%= rsR.getInt("id") %>">P.<%= rsR.getString("room_number") %> - <%= translateType.apply(rsR.getString("type_name")) %></option>
                                <% } } catch(Exception e){} %>
                            </select></div>
                        <div class="row mb-3">
                            <div class="col-6"><label class="form-label">Ngày nhận</label><input type="date" name="checkIn" id="editCheckIn" class="form-control" required></div>
                            <div class="col-6"><label class="form-label">Ngày trả</label><input type="date" name="checkOut" id="editCheckOut" class="form-control" required></div>
                        </div>
                        <div class="p-3 bg-light rounded-4 mb-3 border">
                            <label class="form-label fw-bold text-primary">Điều chỉnh Tài chính</label>
                            <div class="d-flex gap-3 mb-2">
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="adjType" value="none" id="adjNone" checked>
                                    <label class="form-check-label small" for="adjNone">Không đổi</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="adjType" value="increase" id="adjPlus">
                                    <label class="form-check-label small text-danger" for="adjPlus">Tăng (+)</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="adjType" value="decrease" id="adjMinus">
                                    <label class="form-check-label small text-success" for="adjMinus">Giảm (-)</label>
                                </div>
                            </div>
                            <input type="number" name="adjAmount" class="form-control form-control-sm" placeholder="Nhập số tiền điều chỉnh (₫)..." value="0">
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-success fw-bold">Số tiền khách đã trả (₫)</label>
                            <input type="number" name="paidAmount" id="editPaidAmount" class="form-control fw-bold text-success" required>
                            <div class="small text-muted mt-1">Tổng bill hiện tại: <span id="displayTotal" class="fw-bold text-dark"></span></div>
                        </div>
                        <div class="mb-0">
                            <label class="form-label">Ghi chú bổ sung</label>
                            <textarea name="notes" id="editNotes" class="form-control" rows="2" placeholder="Nhập nội dung cần lưu ý thêm..."></textarea>
                            <div class="small text-muted mt-1">Nội dung này sẽ được tự động nối vào sau ghi chú cũ.</div>
                        </div>
                    </div>
                    <div class="modal-footer"><button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button><button type="submit" class="btn btn-primary-gradient px-4">Lưu thay đổi</button></div>
                </form>
            </div>
        </div>
    </div>

    <!-- Modal Lập hóa đơn mới -->
    <div class="modal fade" id="addBookingModal" tabindex="-1">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header"><h5 class="modal-title font-display fw-bold" style="color: var(--primary);">Lập hóa đơn mới</h5><button type="button" class="btn-close shadow-none" data-bs-dismiss="modal"></button></div>
                <form action="admin-bookings.jsp" method="POST" onsubmit="return validateBookingForm(this)">
                    <input type="hidden" name="action" value="addBooking">
                    <div class="modal-body px-4"><div class="row g-3">
                        <div class="col-md-6"><label class="form-label">Họ và tên</label><input type="text" name="fullName" class="form-control" required></div>
                        <div class="col-md-6"><label class="form-label">Số điện thoại</label><input type="text" name="phone" class="form-control" required></div>
                        <div class="col-md-6"><label class="form-label">Email</label><input type="email" name="email" class="form-control"></div>
                        <div class="col-md-6"><label class="form-label">Số CCCD</label><input type="text" name="idCard" class="form-control" required></div>
                        <div class="col-md-4"><label class="form-label">Phòng</label><select name="roomId" class="form-select">
                            <% try { PreparedStatement psR = conn.prepareStatement("SELECT r.id, r.room_number, rt.type_name FROM rooms r JOIN room_types rt ON r.room_type_id = rt.id WHERE r.status = 'AVAILABLE'"); ResultSet rsR = psR.executeQuery(); while(rsR.next()){ %>
                            <option value="<%= rsR.getInt("id") %>">P.<%= rsR.getString("room_number") %> - <%= translateType.apply(rsR.getString("type_name")) %></option>
                            <% } } catch(Exception e){} %>
                        </select></div>
                        <div class="col-md-4"><label class="form-label">Nhận</label><input type="date" name="checkIn" class="form-control" value="<%= new java.sql.Date(System.currentTimeMillis()) %>" min="<%= new java.sql.Date(System.currentTimeMillis()) %>"></div>
                        <div class="col-md-4"><label class="form-label">Trả</label><input type="date" name="checkOut" class="form-control" required></div>
                        <div class="col-md-4"><label class="form-label fw-bold text-danger">Tiền cộng thêm (₫)</label><input type="number" name="extraAmount" class="form-control" value="0" min="0"></div>
                        <div class="col-12 mt-3">
                            <label class="form-label fw-bold text-success">Dịch vụ đính kèm</label>
                            <div class="row g-2 p-3 bg-light rounded-4" style="max-height: 150px; overflow-y: auto; border: 1px solid var(--border);">
                                <% try { PreparedStatement psS = conn.prepareStatement("SELECT * FROM services"); ResultSet rsS = psS.executeQuery(); while(rsS.next()) { int sid = rsS.getInt("id"); %>
                                <div class="col-md-6 d-flex align-items-center justify-content-between border-bottom pb-2 mb-2"><div class="form-check"><input class="form-check-input" type="checkbox" name="services" value="<%= sid %>" id="sv_<%= sid %>"><label class="form-check-label small" for="sv_<%= sid %>"><%= rsS.getString("service_name") %></label></div><input type="number" name="qty_<%= sid %>" class="form-control form-control-sm w-25" value="1" min="1"></div>
                                <% } } catch(Exception e){} %>
                            </div>
                        </div>
                        <div class="col-12"><label class="form-label">Ghi chú hóa đơn</label><textarea name="notes" class="form-control" rows="2" placeholder="Nhập ghi chú tại đây..."></textarea></div>
                    </div></div>
                    <div class="modal-footer"><button type="submit" class="btn btn-primary-gradient px-4">Xác nhận tạo đơn</button></div>
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
            $('#bookingTable').DataTable({ 
                "pageLength": 10, 
                "lengthChange": false, 
                "ordering": false, 
                "searching": false,
                "language": {
                    "processing": "Đang xử lý...",
                    "lengthMenu": "Hiển thị _MENU_ mục",
                    "zeroRecords": "Không tìm thấy hóa đơn nào phù hợp",
                    "info": "Hiển thị _START_ - _END_ trong tổng số _TOTAL_ hóa đơn",
                    "infoEmpty": "Hiển thị 0 - 0 trong tổng số 0 hóa đơn",
                    "infoFiltered": "(lọc từ _MAX_ hóa đơn)",
                    "search": "Tìm kiếm nhanh:",
                    "emptyTable": "Chưa có dữ liệu hóa đơn trong hệ thống",
                    "paginate": { "first": "Đầu", "previous": "Trước", "next": "Sau", "last": "Cuối" }
                }
            }); 
        });
        
        function validateBookingForm(form) {
            const checkIn = new Date(form.checkIn.value);
            const checkOut = new Date(form.checkOut.value);
            const today = new Date();
            today.setHours(0,0,0,0);
            
            // 1. Kiểm tra ngày nhận (Chỉ áp dụng khi lập hóa đơn mới)
            if (form.action.value === "addBooking" && checkIn < today) {
                alert("Ngày nhận phòng không được ở trong quá khứ!");
                return false;
            }
            
            // 2. Kiểm tra ngày trả
            if (checkOut <= checkIn) {
                alert("Ngày trả phòng phải sau ngày nhận phòng ít nhất 1 ngày!");
                return false;
            }
            
            // 3. Kiểm tra CCCD (9 hoặc 12 số)
            const idCard = form.idCard.value;
            const idRegex = /^[0-9]{9}$|^[0-9]{12}$/;
            if (!idRegex.test(idCard)) {
                alert("Số CCCD không hợp lệ! Phải bao gồm 9 hoặc 12 chữ số.");
                return false;
            }
            
            // 4. Kiểm tra số tiền âm
            if (form.extraAmount && form.extraAmount.value < 0) {
                alert("Số tiền cộng thêm không được nhỏ hơn 0!");
                return false;
            }
            
            if (form.paidAmount && form.paidAmount.value < 0) {
                alert("Số tiền đã thanh toán không được nhỏ hơn 0!");
                return false;
            }
            
            return true;
        }

        function openEditModal(id, name, phone, idCard, roomId, checkIn, checkOut, notes, total, paid) {
            $('#editId').val(id); $('#editName').val(name); $('#editPhone').val(phone); $('#editIdCard').val(idCard);
            $('#editRoomId').val(roomId); $('#oldRoomId').val(roomId); $('#editCheckIn').val(checkIn); $('#editCheckOut').val(checkOut); 
            $('#editNotes').val(''); // Luôn để trống để nhập nội dung mới
            $('#editPaidAmount').val(paid);
            $('#displayTotal').text(new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(total));
            $('#adjNone').prop('checked', true); // Reset radio
            new bootstrap.Modal(document.getElementById('editBookingModal')).show();
        }
    </script>
    <% if(conn != null) try { conn.close(); } catch(Exception e) {} %>
</body>
</html>
