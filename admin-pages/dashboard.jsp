<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../layouts/admin-auth.jsp" %>
    <%@ page import="java.sql.*, java.util.*, java.text.NumberFormat" %>
        <%
    // Khởi tạo kết nối Backend của bạn ở đây (Kiểm tra session Admin, connect DB...)
    // if(session.getAttribute("admin") == null) { response.sendRedirect("login.jsp"); return; }
%>
            <%
    if(session.getAttribute("admin") == null){
        response.sendRedirect("dangnhap.jsp");
        return;
    }
%>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Admin Dashboard — OmniStay</title>
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
                        
                        .stat-card {
                            background: #fff;
                            border-radius: 16px;
                            padding: 1.5rem;
                            border: 1px solid rgba(0,0,0,0.05);
                            box-shadow: 0 4px 15px rgba(0,0,0,0.02);
                            display: flex;
                            align-items: center;
                            gap: 1rem;
                        }
                        
                        .stat-icon {
                            width: 54px;
                            height: 54px;
                            border-radius: 12px;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 1.5rem;
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
                            width: 32px;
                            height: 32px;
                            display: inline-flex;
                            align-items: center;
                            justify-content: center;
                            border-radius: 8px;
                            transition: 0.2s;
                        }
                        .action-btn:hover {
                            background: var(--bg-light);
                        }
                    </style>
                </head>

                <body>

                    <%@ include file="../layouts/sidebar-admin.jsp" %>

                    <main class="main-content">
                        <div class="d-flex justify-content-between align-items-center mb-5">
                            <div>
                                <h2 class="font-display fw-normal mb-1">Tổng quan hệ thống</h2>
                                <p class="text-muted mb-0" style="font-size: 0.9rem;">Chào mừng trở lại, Khang. Chúc bạn một ngày làm việc hiệu quả.</p>
                            </div>
                            <div class="d-flex align-items-center gap-3">
                                <div class="position-relative">
                                    <i class="bi bi-bell fs-5 text-muted"></i>
                                    <span class="position-absolute top-0 start-100 translate-middle p-1 bg-danger border border-light rounded-circle"></span>
                                </div>
                                <div class="d-flex align-items-center gap-2 ms-3 pl-3" style="border-left: 1px solid var(--border);">
                                    <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 32px; height: 32px; font-weight: 600;">
                                        <%= (adminEmail != null && !adminEmail.isEmpty()) ? adminEmail.substring(0, 1).toUpperCase() : "A" %>
                                    </div>
                                    <span class="fw-500" style="font-size: 0.9rem;"><%= adminEmail %></span>
                                </div>
                            </div>
                        </div>

                        <div class="row g-4 mb-5">
                            <div class="col-md-3">
                                <div class="stat-card">
                                    <div class="stat-icon" style="background: rgba(26, 107, 90, 0.1); color: var(--primary);">
                                        <i class="bi bi-door-open-fill"></i>
                                    </div>
                                    <div>
                                        <div class="text-muted" style="font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; font-weight: 500;">Phòng đang trống</div>
                                        <div class="font-display fs-3" style="color: var(--primary); line-height: 1.2;">
                                            24
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stat-card">
                                    <div class="stat-icon" style="background: rgba(212, 168, 71, 0.15); color: #a07820;">
                                        <i class="bi bi-calendar2-check-fill"></i>
                                    </div>
                                    <div>
                                        <div class="text-muted" style="font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; font-weight: 500;">Đơn đặt hôm nay</div>
                                        <div class="font-display fs-3" style="color: var(--primary); line-height: 1.2;">
                                            12
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stat-card">
                                    <div class="stat-icon" style="background: rgba(13, 110, 253, 0.1); color: #0d6efd;">
                                        <i class="bi bi-people-fill"></i>
                                    </div>
                                    <div>
                                        <div class="text-muted" style="font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; font-weight: 500;">Khách đang lưu trú</div>
                                        <div class="font-display fs-3" style="color: var(--primary); line-height: 1.2;">
                                            86
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stat-card">
                                    <div class="stat-icon" style="background: rgba(25, 135, 84, 0.1); color: #198754;">
                                        <i class="bi bi-wallet2"></i>
                                    </div>
                                    <div>
                                        <div class="text-muted" style="font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; font-weight: 500;">Doanh thu tháng</div>
                                        <div class="font-display fs-4" style="color: var(--primary); line-height: 1.2;">
                                            125.5M
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="d-flex justify-content-between align-items-end mb-3">
                            <h4 class="font-display fw-normal mb-0">Đơn đặt phòng gần đây</h4>
                            <a href="admin-bookings.jsp" class="btn btn-sm btn-outline-secondary rounded-pill px-3" style="font-size: 0.8rem;">Xem tất cả</a>
                        </div>

                        <div class="table-custom">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead>
                                        <tr>
                                            <th style="width: 80px;">Mã Đơn</th>
                                            <th>Khách hàng</th>
                                            <th>Hạng phòng</th>
                                            <th>Check-in / Check-out</th>
                                            <th>Tổng tiền</th>
                                            <th>Trạng thái</th>
                                            <th class="text-end">Hành động</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                            // NƠI BẠN VIẾT CODE BACKEND:
                            // String sql = "SELECT * FROM bookings ORDER BY created_at DESC LIMIT 5";
                            // PreparedStatement ps = conn.prepareStatement(sql);
                            // ResultSet rs = ps.executeQuery();
                            // while(rs.next()) { ... }
                        %>

                                            <tr>
                                                <td class="fw-500">#BK001</td>
                                                <td>
                                                    <div class="fw-500">Nguyễn Văn A</div>
                                                    <div class="text-muted" style="font-size: 0.75rem;">0901234567</div>
                                                </td>
                                                <td>
                                                    <div>Premium Deluxe</div>
                                                    <div class="text-muted" style="font-size: 0.75rem;">Phòng 301</div>
                                                </td>
                                                <td>
                                                    <div>01/04/2026</div>
                                                    <div class="text-muted" style="font-size: 0.75rem;"><i class="bi bi-arrow-right"></i> 03/04/2026</div>
                                                </td>
                                                <td class="font-display fw-600" style="color: var(--primary);">4.500.000₫</td>
                                                <td>
                                                    <span class="badge rounded-pill bg-success bg-opacity-10 text-success" style="font-weight: 500;">Đã nhận phòng</span>
                                                </td>
                                                <td class="text-end">
                                                    <a href="#" class="action-btn text-primary" title="Chỉnh sửa"><i class="bi bi-pencil-square"></i></a>
                                                    <a href="#" class="action-btn text-danger" title="Xóa"><i class="bi bi-trash3"></i></a>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td class="fw-500">#BK002</td>
                                                <td>
                                                    <div class="fw-500">Trần Thị B</div>
                                                    <div class="text-muted" style="font-size: 0.75rem;">0987654321</div>
                                                </td>
                                                <td>
                                                    <div>Executive Suite</div>
                                                    <div class="text-muted" style="font-size: 0.75rem;">Chưa xếp phòng</div>
                                                </td>
                                                <td>
                                                    <div>05/04/2026</div>
                                                    <div class="text-muted" style="font-size: 0.75rem;"><i class="bi bi-arrow-right"></i> 07/04/2026</div>
                                                </td>
                                                <td class="font-display fw-600" style="color: var(--primary);">6.400.000₫</td>
                                                <td>
                                                    <span class="badge rounded-pill bg-warning bg-opacity-10 text-warning" style="font-weight: 500; color: #b08112 !important;">Chờ thanh toán</span>
                                                </td>
                                                <td class="text-end">
                                                    <a href="#" class="action-btn text-primary"><i class="bi bi-pencil-square"></i></a>
                                                    <a href="#" class="action-btn text-danger"><i class="bi bi-trash3"></i></a>
                                                </td>
                                            </tr>

                                            <% // Đóng vòng lặp backend ở đây %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </main>

                    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
                </body>

                </html>