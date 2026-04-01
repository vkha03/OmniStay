<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.NumberFormat" %>
<%
    // Khởi tạo kết nối Backend của bạn ở đây (Kiểm tra session Admin, connect DB...)
    // if(session.getAttribute("admin") == null) { response.sendRedirect("login.jsp"); return; }
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
            --primary-dark: #134f43;
            --accent: #d4a847;
            --light-bg: #f8f6f2;
            --border: #e8e2d9;
            --sidebar-width: 260px;
        }
        body {
            font-family: "Outfit", sans-serif;
            font-weight: 300;
            color: #2c2c2c;
            background: var(--light-bg);
            overflow-x: hidden;
        }
        .font-display {
            font-family: "Playfair Display", serif;
        }

        /* ─── SIDEBAR ─── */
        .sidebar {
            width: var(--sidebar-width);
            height: 100vh;
            position: fixed;
            top: 0; left: 0;
            background: linear-gradient(180deg, var(--primary-dark) 0%, var(--primary) 100%);
            color: white;
            z-index: 1000;
            padding-top: 2rem;
            box-shadow: 4px 0 24px rgba(0,0,0,0.1);
        }
        .sidebar .brand {
            font-size: 1.8rem;
            text-align: center;
            margin-bottom: 2.5rem;
        }
        .sidebar .brand span {
            color: var(--accent);
            font-weight: 600;
        }
        .nav-sidebar .nav-link {
            color: rgba(255,255,255,0.7);
            padding: 0.8rem 1.5rem;
            font-weight: 400;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 12px;
            border-left: 4px solid transparent;
        }
        .nav-sidebar .nav-link:hover, .nav-sidebar .nav-link.active {
            color: #fff;
            background: rgba(255,255,255,0.08);
            border-left-color: var(--accent);
        }
        .nav-sidebar .nav-link i {
            font-size: 1.2rem;
            color: var(--accent);
        }

        /* ─── MAIN CONTENT ─── */
        .main-content {
            margin-left: var(--sidebar-width);
            padding: 2rem 3rem;
            min-height: 100vh;
        }
        .stat-card {
            background: #fff;
            border-radius: 16px;
            padding: 1.5rem;
            border: 1px solid var(--border);
            box-shadow: 0 4px 20px rgba(0,0,0,0.03);
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
            box-shadow: 0 4px 20px rgba(0,0,0,0.03);
            border: 1px solid var(--border);
            overflow: hidden;
        }
        .table-custom th {
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.1em;
            color: var(--primary);
            font-weight: 600;
            padding: 1.2rem 1.5rem;
            background: rgba(26, 107, 90, 0.03);
            border-bottom: 1px solid var(--border);
        }
        .table-custom td {
            padding: 1.2rem 1.5rem;
            vertical-align: middle;
            font-size: 0.9rem;
            border-bottom: 1px solid var(--border);
        }
        .table-custom tr:last-child td { border-bottom: none; }
        .action-btn {
            width: 32px; height: 32px;
            display: inline-flex;
            align-items: center; justify-content: center;
            border-radius: 8px;
            transition: 0.2s;
        }
        .action-btn:hover { background: var(--light-bg); }
    </style>
</head>
<body>
    <%@ include file="layouts/sidebar-admin.jsp" %>
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
                    <img src="https://ui-avatars.com/api/?name=Admin+Khang&background=1a6b5a&color=fff" class="rounded-circle" width="40" alt="Admin">
                    <span class="fw-500" style="font-size: 0.9rem;">Admin Khang</span>
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