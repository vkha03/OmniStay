<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../layouts/admin-auth.jsp" %>
<%@ page import="java.sql.*, java.util.*, java.text.NumberFormat, java.text.SimpleDateFormat, java.util.concurrent.TimeUnit" %>
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
            // ─── LOGIC THÊM HÓA ĐƠN ───
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
                
                long diff = Math.abs(checkOut.getTime() - checkIn.getTime());
                long nights = TimeUnit.DAYS.convert(diff, TimeUnit.MILLISECONDS);
                if(nights == 0) nights = 1;
                
                PreparedStatement psP = conn.prepareStatement("SELECT base_price FROM room_types rt JOIN rooms r ON r.room_type_id = rt.id WHERE r.id = ?");
                psP.setInt(1, newRoomId); ResultSet rsP = psP.executeQuery();
                double roomBasePrice = 0; if(rsP.next()) roomBasePrice = rsP.getDouble("base_price");
                double newRoomTotal = roomBasePrice * nights;
                
                PreparedStatement psS = conn.prepareStatement("SELECT SUM(quantity * historical_price) as svc_total FROM booking_services WHERE booking_id = ?");
                psS.setInt(1, bid); ResultSet rsS = psS.executeQuery();
                double svcTotal = 0; if(rsS.next()) svcTotal = rsS.getDouble("svc_total");
                
                double currentTotal = newRoomTotal + svcTotal;
                
                String adjType = request.getParameter("adjType");
                double adjAmount = 0;
                try { adjAmount = Double.parseDouble(request.getParameter("adjAmount")); } catch(Exception e){}
                
                if("increase".equals(adjType)) currentTotal += adjAmount;
                else if("decrease".equals(adjType)) currentTotal -= adjAmount;
                
                double paidAmount = 0;
                try { paidAmount = Double.parseDouble(request.getParameter("paidAmount")); } catch(Exception e){}
                
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
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Hóa đơn — OmniStay Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;1,400&family=Outfit:wght@300;400;500;600&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
    
    <style>
        :root { --primary: #1a6b5a; --primary-dark: #124a3e; --accent: #d4a847; --bg-light: #f5f8f7; --border: #e8e2d9; --text-main: #2c3e50; }
        body { font-family: 'Outfit', sans-serif; background-color: var(--bg-light); color: var(--text-main); overflow-x: hidden; margin: 0; }
        .font-display { font-family: "Playfair Display", serif; }
        
        /* ─── SIDEBAR FIXED (Copy chuẩn 100% từ admin-staff) ─── */
        .sidebar { width: 260px; background: var(--primary-dark); min-height: 100vh; position: fixed; top: 0; left: 0; z-index: 1000; padding-top: 1.5rem; box-shadow: 4px 0 20px rgba(0,0,0,0.05); }
        .sidebar .brand { padding: 0 1.5rem 2rem; border-bottom: 1px solid rgba(255,255,255,0.05); margin-bottom: 1rem; }
        .sidebar .brand a { font-size: 1.6rem; letter-spacing: 1px; color: #fff !important; text-decoration: none; }
        .sidebar .brand span { color: var(--accent); font-weight: 600; }
        
        .nav-sidebar .nav-link { color: rgba(255,255,255,0.7) !important; padding: 0.8rem 1.5rem; margin: 0.2rem 1rem; border-radius: 8px; transition: all 0.3s; display: flex; align-items: center; font-weight: 400; text-decoration: none; }
        .nav-sidebar .nav-link i { margin-right: 12px; font-size: 1.1rem; }
        .nav-sidebar .nav-link:hover, .nav-sidebar .nav-link.active { color: #fff !important; background: rgba(255,255,255,0.1); }
        .nav-sidebar .nav-link.active { background: var(--primary) !important; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }

        /* ─── MAIN CONTENT ─── */
        .main-content { margin-left: 260px; padding: 2rem; min-height: 100vh; }
        .table-custom { background: #fff; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); border: 1px solid rgba(0,0,0,0.05); padding: 1.5rem; }
        .table-custom th { background-color: #f8f9fa; color: #6c757d; font-size: 0.7rem; text-transform: uppercase; padding: 1rem; border-bottom: 2px solid #edf2f9; }
        .table-custom td { padding: 1.2rem 1rem; vertical-align: middle; border-bottom: 1px solid #edf2f9; font-size: 0.85rem; }
        
        .st-badge { padding: 0.4rem 0.8rem; border-radius: 50px; font-size: 0.7rem; font-weight: 600; text-transform: uppercase; }
        .st-pending { background: #fff3cd; color: #856404; }
        .st-confirmed { background: #cce5ff; color: #004085; }
        .st-checked_in { background: #d4edda; color: #155724; }
        .st-completed { background: #e2e3e5; color: #383d41; }
        .st-cancelled { background: #f8d7da; color: #721c24; }
        
        .action-btn { width: 32px; height: 32px; display: inline-flex; align-items: center; justify-content: center; border-radius: 8px; transition: 0.2s; color: #666; cursor: pointer; border: 1px solid transparent; }
        .action-btn:hover { background: var(--bg-light); border-color: var(--border); }
        .modal-content { border-radius: 20px; border: none; }
    </style>
</head>
<body>
    <%@ include file="../layouts/sidebar-admin.jsp" %>
    <main class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="font-display fw-normal mb-1">Quản lý Hóa đơn</h2>
                <p class="text-muted mb-0" style="font-size: 0.9rem;">Hệ thống quản lý lưu trú và hóa đơn OmniStay.</p>
            </div>
            <button class="btn text-white rounded-pill px-4" style="background: var(--primary);" data-bs-toggle="modal" data-bs-target="#addBookingModal">
                <i class="bi bi-plus-lg me-1"></i> Lập hóa đơn mới
            </button>
        </div>

        <% if (thongBao != null) { %>
            <div class="alert alert-<%= loaiThongBao %> border-0 shadow-sm mb-4" style="border-radius: 12px;">
                <i class="bi bi-info-circle-fill me-2"></i> <%= thongBao %>
            </div>
        <% } %>

        <div class="table-custom">
            <div class="table-responsive">
                <table id="bookingTable" class="table table-hover mb-0">
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
                            <th class="text-end"></th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if(conn != null) {
                                try {
                                    String sql = "SELECT b.*, r.id as room_id, r.room_number FROM bookings b LEFT JOIN booking_rooms br ON b.id = br.booking_id LEFT JOIN rooms r ON br.room_id = r.id ORDER BY b.created_at DESC";
                                    Statement st = conn.createStatement();
                                    ResultSet rs = st.executeQuery(sql);
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
                            <td><span class="fw-bold text-primary"><%= code %></span></td>
                            <td><div class="fw-600"><%= name %></div><div class="text-muted small"><%= idCard %></div></td>
                            <td><span class="badge bg-light text-dark border fw-normal mb-1">P.<%= roomNB %></span><br><small class="text-muted"><%= sdf.format(checkIn) %> - <%= sdf.format(checkOut) %></small></td>
                            <td><div class="fw-600"><%= nf.format(total).replace("VNĐ", "₫") %></div></td>
                            <td><div class="text-success"><%= nf.format(paid).replace("VNĐ", "₫") %></div></td>
                            <td><div class="<%= (total-paid) > 0 ? "text-danger fw-bold" : "text-muted" %>"><%= nf.format(total-paid).replace("VNĐ", "₫") %></div></td>
                            <td><span class="<%= rs.getString("payment_status").equals("PAID") ? "text-success" : "text-danger" %> fw-bold"><%= rs.getString("payment_status") %></span></td>
                            <td>
                                <% 
                                    String stClass = "st-pending"; String stText = "Chờ";
                                    if(status.equals("CONFIRMED")) { stClass = "st-confirmed"; stText = "Xác nhận"; }
                                    else if(status.equals("CHECKED_IN")) { stClass = "st-checked_in"; stText = "Đang ở"; }
                                    else if(status.equals("COMPLETED")) { stClass = "st-completed"; stText = "Xong"; }
                                    else if(status.equals("CANCELLED")) { stClass = "st-cancelled"; stText = "Hủy"; }
                                %>
                                <span class="st-badge <%= stClass %>"><%= stText %></span>
                            </td>
                            <td class="text-end">
                                <div class="dropdown">
                                    <button class="action-btn dropdown-toggle no-caret" data-bs-toggle="dropdown"><i class="bi bi-three-dots-vertical"></i></button>
                                    <ul class="dropdown-menu dropdown-menu-end shadow border-0" style="border-radius: 12px; font-size: 0.85rem;">
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
                        <% } rs.close(); st.close(); } catch(Exception e) { out.println(e.getMessage()); } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <!-- Modal Sửa hóa đơn -->
    <div class="modal fade" id="editBookingModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content shadow-lg">
                <div class="modal-header border-0 px-4 pt-4">
                    <h5 class="modal-title font-display fw-bold">Chỉnh sửa hóa đơn</h5>
                    <button type="button" class="btn-close shadow-none" data-bs-dismiss="modal"></button>
                </div>
                <form action="admin-bookings.jsp" method="POST">
                    <input type="hidden" name="action" value="editBooking">
                    <input type="hidden" name="id" id="editId">
                    <input type="hidden" name="oldRoomId" id="oldRoomId">
                    <div class="modal-body px-4">
                        <div class="mb-3"><label class="form-label small fw-bold">Họ và tên khách</label><input type="text" name="fullName" id="editName" class="form-control" required></div>
                        <div class="row mb-3"><div class="col-6"><label class="form-label small fw-bold">Số điện thoại</label><input type="text" name="phone" id="editPhone" class="form-control" required></div><div class="col-6"><label class="form-label small fw-bold">CCCD/Passport</label><input type="text" name="idCard" id="editIdCard" class="form-control" required></div></div>
                        <div class="mb-3"><label class="form-label small fw-bold">Phòng lưu trú</label>
                            <select name="roomId" id="editRoomId" class="form-select" required>
                                <% try { PreparedStatement psR = conn.prepareStatement("SELECT r.id, r.room_number, rt.type_name FROM rooms r JOIN room_types rt ON r.room_type_id = rt.id WHERE r.status = 'AVAILABLE' OR r.status = 'OCCUPIED'"); ResultSet rsR = psR.executeQuery(); while(rsR.next()){ %>
                                <option value="<%= rsR.getInt("id") %>">P.<%= rsR.getString("room_number") %> - <%= rsR.getString("type_name") %></option>
                                <% } } catch(Exception e){} %>
                            </select></div>
                        <div class="row mb-3">
                            <div class="col-6"><label class="form-label small fw-bold">Ngày nhận</label><input type="date" name="checkIn" id="editCheckIn" class="form-control" required></div>
                            <div class="col-6"><label class="form-label small fw-bold">Ngày trả</label><input type="date" name="checkOut" id="editCheckOut" class="form-control" required></div>
                        </div>
                        <div class="p-3 bg-light rounded-4 mb-3 border">
                            <label class="form-label small fw-bold text-primary">Điều chỉnh Tài chính</label>
                            <div class="d-flex gap-3 mb-2">
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="adjType" value="none" id="adjNone" checked>
                                    <label class="form-check-label small" for="adjNone">Không đổi</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="adjType" value="increase" id="adjPlus">
                                    <label class="form-check-label small text-danger" for="adjPlus">Tăng tổng tiền (+)</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="adjType" value="decrease" id="adjMinus">
                                    <label class="form-check-label small text-success" for="adjMinus">Giảm tổng tiền (-)</label>
                                </div>
                            </div>
                            <input type="number" name="adjAmount" class="form-control form-control-sm" placeholder="Nhập số tiền điều chỉnh (₫)..." value="0">
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold text-success">Số tiền khách đã trả (₫)</label>
                            <input type="number" name="paidAmount" id="editPaidAmount" class="form-control fw-bold text-success" required>
                            <div class="small text-muted mt-1">Tổng bill hiện tại: <span id="displayTotal" class="fw-bold"></span></div>
                        </div>
                        <div class="mb-0"><label class="form-label small fw-bold">Ghi chú</label><textarea name="notes" id="editNotes" class="form-control" rows="2"></textarea></div>
                    </div>
                    <div class="modal-footer border-0 px-4 pb-4"><button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button><button type="submit" class="btn text-white rounded-pill px-4" style="background: var(--primary);">Lưu thay đổi</button></div>
                </form>
            </div>
        </div>
    </div>

    <!-- Modal Lập hóa đơn mới -->
    <div class="modal fade" id="addBookingModal" tabindex="-1">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content shadow-lg">
                <div class="modal-header border-0 px-4 pt-4"><h5 class="modal-title font-display fw-bold">Lập hóa đơn mới</h5><button type="button" class="btn-close shadow-none" data-bs-dismiss="modal"></button></div>
                <form action="admin-bookings.jsp" method="POST">
                    <input type="hidden" name="action" value="addBooking">
                    <div class="modal-body px-4"><div class="row g-3">
                        <div class="col-md-6"><label class="form-label small fw-bold">Họ và tên</label><input type="text" name="fullName" class="form-control" required></div>
                        <div class="col-md-6"><label class="form-label small fw-bold">Số điện thoại</label><input type="text" name="phone" class="form-control" required></div>
                        <div class="col-md-6"><label class="form-label small fw-bold">Email</label><input type="email" name="email" class="form-control"></div>
                        <div class="col-md-6"><label class="form-label small fw-bold">Số CCCD</label><input type="text" name="idCard" class="form-control" required></div>
                        <div class="col-md-4"><label class="form-label small fw-bold">Phòng</label><select name="roomId" class="form-select">
                            <% try { PreparedStatement psR = conn.prepareStatement("SELECT r.id, r.room_number, rt.type_name FROM rooms r JOIN room_types rt ON r.room_type_id = rt.id WHERE r.status = 'AVAILABLE'"); ResultSet rsR = psR.executeQuery(); while(rsR.next()){ %>
                            <option value="<%= rsR.getInt("id") %>">P.<%= rsR.getString("room_number") %></option>
                            <% } } catch(Exception e){} %>
                        </select></div>
                        <div class="col-md-4"><label class="form-label small fw-bold">Nhận</label><input type="date" name="checkIn" class="form-control" value="<%= new java.sql.Date(System.currentTimeMillis()) %>"></div>
                        <div class="col-md-4"><label class="form-label small fw-bold">Trả</label><input type="date" name="checkOut" class="form-control"></div>
                        <div class="col-md-4"><label class="form-label small fw-bold text-danger">Tiền cộng thêm (₫)</label><input type="number" name="extraAmount" class="form-control" value="0"></div>
                        <div class="col-12 mt-3">
                            <label class="form-label small fw-bold text-success">Dịch vụ</label>
                            <div class="row g-2 p-3 bg-light rounded-4" style="max-height: 150px; overflow-y: auto;">
                                <% try { PreparedStatement psS = conn.prepareStatement("SELECT * FROM services"); ResultSet rsS = psS.executeQuery(); while(rsS.next()) { int sid = rsS.getInt("id"); %>
                                <div class="col-md-6 d-flex align-items-center justify-content-between border-bottom pb-2 mb-2"><div class="form-check"><input class="form-check-input" type="checkbox" name="services" value="<%= sid %>" id="sv_<%= sid %>"><label class="form-check-label small" for="sv_<%= sid %>"><%= rsS.getString("service_name") %></label></div><input type="number" name="qty_<%= sid %>" class="form-control form-control-sm w-25" value="1" min="1"></div>
                                <% } } catch(Exception e){} %>
                            </div>
                        </div>
                        <div class="col-12"><label class="form-label small fw-bold">Ghi chú hóa đơn</label><textarea name="notes" class="form-control" rows="2" placeholder="Nhập ghi chú tại đây..."></textarea></div>
                    </div></div>
                    <div class="modal-footer border-0 px-4 pb-4"><button type="submit" class="btn text-white rounded-pill px-4" style="background: var(--primary);">Xác nhận</button></div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.7.0.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
    <script>
        $(document).ready(function() { $('#bookingTable').DataTable({ "pageLength": 10, "lengthChange": false, "ordering": false, "language": { "search": "Tìm kiếm:" } }); });
        function openEditModal(id, name, phone, idCard, roomId, checkIn, checkOut, notes, total, paid) {
            $('#editId').val(id); $('#editName').val(name); $('#editPhone').val(phone); $('#editIdCard').val(idCard);
            $('#editRoomId').val(roomId); $('#oldRoomId').val(roomId); $('#editCheckIn').val(checkIn); $('#editCheckOut').val(checkOut); $('#editNotes').val(notes);
            $('#editPaidAmount').val(paid);
            $('#displayTotal').text(new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(total));
            $('#adjNone').prop('checked', true); // Reset radio
            new bootstrap.Modal(document.getElementById('editBookingModal')).show();
        }
    </script>
    <% if(conn != null) try { conn.close(); } catch(Exception e) {} %>
</body>
</html>
