<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.NumberFormat" %>
<%@ include file="../env-secrets.jsp" %>
<%
    String bookingCode = request.getParameter("code");
    String guestPhone = request.getParameter("phone");
    
    boolean found = false;
    String error = null;
    
    String fullName = "", email = "", phone = "", roomName = "", roomType = "", status = "", createdAt = "", checkIn = "", checkOut = "";
    String customerIdCard = "", paymentMethod = "", paymentStatus = "";
    int numAdults = 1, numChildren = 0;
    double totalAmount = 0, paidAmount = 0;
    
    if (bookingCode == null || guestPhone == null || bookingCode.isEmpty() || guestPhone.isEmpty()) {
        response.sendRedirect("invoice-lookup.jsp");
        return;
    }

    Connection conn = null;
    int roomId = 0;
    int guestId = 0;
    int bookingId = 0;
    boolean hasReviewed = false;
    String bookingNotes = "";
    double totalServices = 0;
    boolean hasServices = false;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(SECRET_DB_URL, SECRET_DB_USER, SECRET_DB_PASS);
        
        String sql = "SELECT b.*, r.id as r_id, r.room_number, rt.type_name " +
                     "FROM bookings b " +
                     "JOIN booking_rooms br ON b.id = br.booking_id " +
                     "JOIN rooms r ON br.room_id = r.id " +
                     "JOIN room_types rt ON r.room_type_id = rt.id " +
                     "WHERE b.booking_code = ? AND b.customer_phone = ?";
        
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, bookingCode);
        ps.setString(2, guestPhone);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            found = true;
            bookingId = rs.getInt("id");
            guestId = rs.getInt("guest_id");
            roomId = rs.getInt("r_id");
            fullName = rs.getString("customer_full_name");
            email = rs.getString("customer_email");
            phone = rs.getString("customer_phone");
            roomName = rs.getString("room_number");
            roomType = rs.getString("type_name");
            status = rs.getString("status");
            totalAmount = rs.getDouble("total_amount");
            createdAt = rs.getString("created_at");
            checkIn = rs.getString("check_in_date");
            checkOut = rs.getString("check_out_date");
            bookingNotes = rs.getString("notes");
            customerIdCard = rs.getString("customer_id_card");
            paymentMethod = rs.getString("payment_method");
            paymentStatus = rs.getString("payment_status");
            numAdults = rs.getInt("num_adults");
            numChildren = rs.getInt("num_children");
            paidAmount = rs.getDouble("paid_amount");
            totalAmount = rs.getDouble("total_amount");
            
            // Tính toán dịch vụ
            PreparedStatement psSvcCount = conn.prepareStatement("SELECT SUM(quantity * historical_price) as total_svc FROM booking_services WHERE booking_id = ?");
            psSvcCount.setInt(1, bookingId);
            ResultSet rsSvcCount = psSvcCount.executeQuery();
            if(rsSvcCount.next()){
                totalServices = rsSvcCount.getDouble("total_svc");
                if(totalServices > 0) hasServices = true;
            }
            rsSvcCount.close();
            psSvcCount.close();

            // Kiểm tra xem đã đánh giá chưa
            PreparedStatement psCheck = conn.prepareStatement("SELECT id FROM reviews WHERE booking_id = ?");
            psCheck.setInt(1, bookingId);
            ResultSet rsCheck = psCheck.executeQuery();
            if(rsCheck.next()) hasReviewed = true;
            rsCheck.close();
            psCheck.close();
        } else {
            error = "Không tìm thấy dữ liệu phù hợp với thông tin bạn cung cấp.";
        }
        rs.close();
        ps.close();
        conn.close();
    } catch (Exception e) {
        error = "Lỗi kết nối: " + e.getMessage();
    }
    
    NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết hóa đơn — <%= bookingCode %> — OmniStay</title>
    <link rel="icon" type="image/png" href="<%=request.getContextPath()%>/images/logo.png">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;1,400&family=Outfit:wght@300;400;500&display=swap" rel="stylesheet" />
    <style>
        :root {
            --primary: #1a6b5a;
            --primary-dark: #134f43;
            --accent: #d4a847;
            --light-bg: #f8f6f2;
            --border: #e8e2d9;
        }
        body {
            font-family: "Outfit", sans-serif;
            font-weight: 300;
            color: #2c2c2c;
            background: var(--light-bg);
            overflow-x: hidden;
        }
        .font-display { font-family: "Playfair Display", serif; }

        /* ── HERO HEADER ── */
        .page-header {
            background: linear-gradient(
                160deg,
                rgba(10, 40, 33, 0.90) 0%,
                rgba(20, 85, 70, 0.78) 50%,
                rgba(30, 110, 90, 0.68) 100%
            ), url('<%=request.getContextPath()%>/images/hero/hotel-aerial.jpg') center/cover no-repeat;
            background-attachment: fixed;
            padding: 10rem 0 5rem;
            position: relative;
            border-bottom: 5px solid var(--accent);
        }
        .page-header::after {
            content: '';
            position: absolute;
            bottom: 0; left: 0; right: 0;
            height: 60px;
            background: linear-gradient(transparent, var(--light-bg));
            pointer-events: none;
        }
        .hero-breadcrumb {
            background: rgba(255, 255, 255, 0.08);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.12);
            border-radius: 50px;
            padding: 0.5rem 1.5rem;
            display: inline-block;
        }

        /* ── INVOICE CARD ── */
        .invoice-card {
            background: #fff;
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 4rem;
            box-shadow: 0 15px 45px rgba(0,0,0,0.05);
            margin-top: -60px;
            position: relative;
            z-index: 10;
        }

        .status-pill {
            padding: 0.4rem 1.2rem;
            border-radius: 50px;
            font-weight: 500;
            font-size: 0.8rem;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .info-group {
            margin-bottom: 2rem;
        }
        .info-label {
            color: #999;
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 0.5rem;
        }
        .info-value {
            font-weight: 500;
            color: #111;
            font-size: 1.1rem;
        }

        .table-invoice th {
            background: #fdfdfd;
            border-bottom: 2px solid var(--primary);
            color: var(--primary);
            font-weight: 500;
            padding: 1rem;
            font-family: "Playfair Display", serif;
        }
        .table-invoice td {
            padding: 1.5rem 1rem;
            border-bottom: 1px solid #f1f1f1;
        }

        .total-box {
            background: rgba(26, 107, 90, 0.03);
            border-radius: 12px;
            padding: 2rem;
            border: 1px solid rgba(26, 107, 90, 0.1);
        }

        .btn-print {
            border: 1.5px solid var(--primary);
            color: var(--primary);
            background: transparent;
            border-radius: 10px;
            padding: 0.8rem 1.5rem;
            font-weight: 500;
            transition: 0.3s;
        }
        .btn-print:hover {
            background: var(--primary);
            color: white;
        }

        /* ── FEEDBACK MODAL STYLES ── */
        .star-rating {
            display: flex;
            flex-direction: row-reverse;
            justify-content: center;
            gap: 10px;
        }
        .star-rating input { display: none; }
        .star-rating label {
            font-size: 2.5rem;
            color: #ddd;
            cursor: pointer;
            transition: color 0.2s;
        }
        .star-rating label:hover,
        .star-rating label:hover ~ label,
        .star-rating input:checked ~ label {
            color: var(--accent);
        }

        /* ── ANIMATIONS ── */
        .animate-fade-in {
            opacity: 0;
            transform: translateY(40px);
            transition: all 0.8s cubic-bezier(0.16, 1, 0.3, 1);
        }
        .animate-fade-in.visible {
            opacity: 1;
            transform: translateY(0);
        }

        @media print {
            .no-print { display: none !important; }
            .invoice-card { margin: 0; padding: 2rem; box-shadow: none; border: none; width: 100%; }
            body { background: white; }
        }
    </style>
</head>
<body>

    <div class="no-print">
        <%@ include file="../layouts/navbar.jsp" %>
    </div>

    <section class="page-header text-center">
        <div class="container position-relative z-1">
            <nav aria-label="breadcrumb">
                <div class="hero-breadcrumb mb-4 no-print">
                    <ol class="breadcrumb justify-content-center mb-0 small text-uppercase" style="letter-spacing: 2px;">
                        <li class="breadcrumb-item"><a href="../index.jsp" class="text-white text-decoration-none">Trang chủ</a></li>
                        <li class="breadcrumb-item"><a href="invoice-lookup.jsp" class="text-white text-decoration-none">Tra cứu</a></li>
                        <li class="breadcrumb-item active" style="color: var(--accent);" aria-current="page">Hóa đơn</li>
                    </ol>
                </div>
            </nav>
            <p class="text-uppercase fw-500 mb-3" style="font-size: 0.75rem; letter-spacing: 0.2em; color: var(--accent);">
                ✦ Thông tin lưu trú ✦
            </p>
            <h1 class="font-display fw-normal text-white mb-3" style="font-size: clamp(2rem, 4vw, 3.5rem)">
                Chi tiết <em style="color: var(--accent)">Hóa đơn</em>
            </h1>
            <p class="mx-auto" style="font-size: 0.95rem; max-width: 520px; color: rgba(255,255,255,0.85);">
                Trân trọng cảm ơn quý khách đã tin tưởng lựa chọn OmniStay cho kỳ nghỉ của mình.
            </p>
        </div>
    </section>

    <main class="container pb-5 mb-5">
        <div class="row justify-content-center">
            <div class="col-lg-10 animate-fade-in" id="invoiceSection">
                
                <% if (!found) { %>
                    <div class="invoice-card text-center py-5">
                        <i class="bi bi-exclamation-circle text-danger display-1 mb-4"></i>
                        <h2 class="font-display fw-normal mb-3">Lỗi truy xuất</h2>
                        <p class="text-muted"><%= error %></p>
                        <a href="invoice-lookup.jsp" class="btn btn-outline-dark rounded-pill px-4 mt-3">Quay lại tra cứu</a>
                    </div>
                <% } else { %>
                    
                    <% if (request.getParameter("feedback") != null) { %>
                        <div class="alert alert-success alert-dismissible fade show mb-4 no-print border-0 shadow-sm" role="alert" style="background: var(--primary); color: #fff; border-radius: 12px;">
                            <i class="bi bi-check-circle-fill me-2"></i>
                            Cảm ơn quý khách đã gửi đánh giá! Ý kiến của bạn đã được ghi nhận.
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    <% } %>

                    <div class="d-flex justify-content-between align-items-center mb-4 no-print">
                        <a href="invoice-lookup.jsp" class="text-decoration-none text-muted">
                            <i class="bi bi-arrow-left me-2"></i>Quay lại
                        </a>
                        <div class="d-flex gap-2">
                            <button onclick="window.print()" class="btn-print">
                                <i class="bi bi-printer me-2"></i>In hóa đơn
                            </button>
                        </div>
                    </div>

                    <div class="invoice-card">
                        <div class="row align-items-start mb-5 pb-4 border-bottom">
                            <div class="col-md-6">
                                <h1 class="font-display fw-normal text-primary mb-1">OMNI<span style="color: var(--accent)">STAY</span></h1>
                                <p class="text-muted small mb-0">Hệ thống khách sạn & nghỉ dưỡng 5 sao</p>
                                <p class="text-muted small">Hotline: 1900 1234 | Email: support@omnistay.vn</p>
                            </div>
                            <div class="col-md-6 text-md-end">
                                <h4 class="font-display fw-normal mb-2">HÓA ĐƠN DỊCH VỤ</h4>
                                <p class="mb-1 text-muted">Mã đơn: <span class="fw-bold text-dark"><%= bookingCode %></span></p>
                                <% 
                                    String statusClass = "bg-light text-muted";
                                    String statusText = status;
                                    if("CONFIRMED".equals(status)) { statusClass = "bg-success-subtle text-success"; statusText = "Đã xác nhận"; }
                                    else if("PENDING".equals(status)) { statusClass = "bg-warning-subtle text-warning"; statusText = "Đang chờ"; }
                                    else if("COMPLETED".equals(status)) { statusClass = "bg-primary-subtle text-primary"; statusText = "Hoàn tất"; }
                                    else if("CANCELLED".equals(status)) { statusClass = "bg-danger-subtle text-danger"; statusText = "Đã hủy"; }
                                %>
                                <span class="status-pill <%= statusClass %>"><%= statusText %></span>
                            </div>
                        </div>

                        <div class="row mb-5">
                            <div class="col-md-4 info-group">
                                <div class="info-label">Khách hàng</div>
                                <div class="info-value"><%= fullName %></div>
                                <div class="text-muted small">CCCD: <%= customerIdCard %></div>
                                <div class="text-muted small">SĐT: <%= phone %></div>
                            </div>
                            <div class="col-md-4 info-group">
                                <div class="info-label">Thời gian lưu trú</div>
                                <div class="info-value"><%= checkIn %> <i class="bi bi-arrow-right mx-2 text-muted" style="font-size: 0.8rem;"></i> <%= checkOut %></div>
                                <div class="text-muted small">Số khách: <%= numAdults %> NL, <%= numChildren %> TE</div>
                            </div>
                            <div class="col-md-4 text-md-end info-group">
                                <div class="info-label">Thanh toán</div>
                                <div class="info-value"><%= "VNPAY".equals(paymentMethod) ? "Chuyển khoản VNPAY" : "Tiền mặt / Tại quầy" %></div>
                                <div class="badge <%= "PAID".equals(paymentStatus) ? "bg-success" : "bg-danger" %>">
                                    <%= "PAID".equals(paymentStatus) ? "Đã thanh toán" : "Chưa thanh toán" %>
                                </div>
                            </div>
                        </div>

                        <% if (bookingNotes != null && !bookingNotes.isEmpty()) { %>
                        <div class="mb-5 p-3 rounded-3" style="background: #fdfaf3; border-left: 4px solid var(--accent);">
                            <div class="info-label mb-1">Ghi chú của khách hàng</div>
                            <div class="text-muted small"><%= bookingNotes %></div>
                        </div>
                        <% } %>

                        <div class="table-responsive">
                            <table class="table table-invoice">
                                <thead>
                                    <tr>
                                        <th>Mô tả chi tiết</th>
                                        <th class="text-center">Số lượng</th>
                                        <th class="text-end">Đơn giá</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>
                                            <div class="fw-bold">Dịch vụ lưu trú - Phòng <%= roomName %></div>
                                            <div class="text-muted small"><%= roomType %></div>
                                        </td>
                                        <td class="text-center">01</td>
                                        <td class="text-end fw-bold"><%= nf.format(totalAmount - totalServices).replace("VNĐ","₫") %></td>
                                    </tr>
                                    <%
                                        // Hiển thị danh sách dịch vụ nếu có
                                        if (hasServices) {
                                            Connection connSvc = null;
                                            try {
                                                connSvc = DriverManager.getConnection(SECRET_DB_URL, SECRET_DB_USER, SECRET_DB_PASS);
                                                String sqlSvc = "SELECT bs.*, s.service_name FROM booking_services bs JOIN services s ON bs.service_id = s.id WHERE bs.booking_id = ?";
                                                PreparedStatement psSvc = connSvc.prepareStatement(sqlSvc);
                                                psSvc.setInt(1, bookingId);
                                                ResultSet rsSvc = psSvc.executeQuery();
                                                while(rsSvc.next()){
                                                    String sName = rsSvc.getString("service_name");
                                                    int sQty = rsSvc.getInt("quantity");
                                                    double sPrice = rsSvc.getDouble("historical_price");
                                    %>
                                    <tr>
                                        <td>
                                            <div class="fw-bold"><%= sName %></div>
                                            <div class="text-muted small">Dịch vụ bổ sung</div>
                                        </td>
                                        <td class="text-center"><%= sQty %></td>
                                        <td class="text-end fw-bold"><%= nf.format(sPrice * sQty).replace("VNĐ","₫") %></td>
                                    </tr>
                                    <%
                                                }
                                                rsSvc.close();
                                                psSvc.close();
                                            } catch(Exception e) { e.printStackTrace(); } finally { if(connSvc != null) connSvc.close(); }
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>

                        <div class="row justify-content-end mt-5">
                            <div class="col-md-5">
                                <div class="total-box">
                                    <div class="d-flex justify-content-between mb-2">
                                    <span class="text-muted">Tổng cộng hóa đơn</span>
                                    <span class="fw-bold"><%= nf.format(totalAmount).replace("VNĐ", "₫") %></span>
                                </div>
                                <div class="d-flex justify-content-between mb-2">
                                    <span class="text-muted">Đã thanh toán (VNPAY/Cọc)</span>
                                    <span class="text-success fw-bold">- <%= nf.format(paidAmount).replace("VNĐ", "₫") %></span>
                                </div>
                                <hr>
                                <div class="d-flex justify-content-between">
                                    <span class="h5 mb-0">Còn lại phải trả (Balance)</span>
                                    <span class="h5 mb-0 text-danger fw-bold"><%= nf.format(totalAmount - paidAmount).replace("VNĐ", "₫") %></span>
                                </div>
                                    <div class="d-flex justify-content-between mb-3 pb-3 border-bottom">
                                        <span class="text-muted small">Thuế VAT (0%):</span>
                                        <span class="fw-500">0₫</span>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center">
                                        <h5 class="font-display mb-0">TỔNG CỘNG:</h5>
                                        <h4 class="font-display fw-bold text-primary mb-0"><%= nf.format(totalAmount).replace("VNĐ","₫") %></h4>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="mt-5 pt-4 text-center border-top">
                            <p class="text-muted small mb-0">
                                <i class="bi bi-patch-check-fill text-success me-1"></i> Đây là hóa đơn điện tử được xác thực bởi OmniStay Hotel & Resort.<br>
                                Trân trọng cảm ơn sự lựa chọn của quý khách.
                            </p>
                        </div>
                    </div>

                    <div class="mt-4 no-print">
                        <% if ("COMPLETED".equals(status)) { %>
                            <% if (hasReviewed) { %>
                                <div class="alert alert-info border-0 p-4 d-flex align-items-center justify-content-center" style="background: rgba(26, 107, 90, 0.05); color: var(--primary); border-radius: 15px;">
                                    <i class="bi bi-check-all fs-3 me-2"></i>
                                    <span class="fw-500">Bạn đã gửi đánh giá cho kỳ nghỉ này. Trân trọng cảm ơn!</span>
                                </div>
                            <% } else { %>
                                <div class="alert border-0 p-4 d-flex align-items-center justify-content-between" style="background: var(--accent); color: #fff; border-radius: 15px;">
                                    <div>
                                        <h5 class="font-display mb-1">Chia sẻ trải nghiệm của bạn</h5>
                                        <p class="mb-0 small opacity-75">Sự góp ý của bạn là động lực để chúng tôi hoàn thiện hơn.</p>
                                    </div>
                                    <button type="button" class="btn btn-light rounded-pill px-4 fw-bold text-primary-dark" data-bs-toggle="modal" data-bs-target="#feedbackModal">
                                        Đánh giá ngay <i class="bi bi-star-fill ms-1"></i>
                                    </button>
                                </div>
                            <% } %>
                        <% } else { %>
                            <div class="alert border-0 p-4 d-flex align-items-center justify-content-center" style="background: rgba(0,0,0,0.05); color: #888; border-radius: 15px;">
                                <i class="bi bi-clock-history fs-3 me-3"></i>
                                <span class="fw-500 text-uppercase small" style="letter-spacing: 1px;">Chờ trải nghiệm để đánh giá</span>
                            </div>
                        <% } %>
                    </div>

                <% } %>
            </div>
        </div>
    </main>

    <!-- Feedback Modal -->
    <div class="modal fade" id="feedbackModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg" style="border-radius: 20px;">
                <div class="modal-header border-0 pb-0">
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="process-feedback.jsp" method="POST">
                    <input type="hidden" name="booking_id" value="<%= bookingId %>">
                    <input type="hidden" name="guest_id" value="<%= guestId %>">
                    <input type="hidden" name="room_id" value="<%= roomId %>">
                    <input type="hidden" name="code" value="<%= bookingCode %>">
                    <input type="hidden" name="phone" value="<%= guestPhone %>">

                    <div class="modal-body p-4 text-center">
                        <h3 class="font-display text-primary mb-3">Đánh giá kỳ nghỉ</h3>
                        <p class="text-muted small mb-4">Bạn cảm thấy thế nào về dịch vụ tại OmniStay?</p>
                        
                        <div class="star-rating mb-4">
                            <input type="radio" id="star5" name="rating" value="5" required /><label for="star5" title="5 sao"><i class="bi bi-star-fill"></i></label>
                            <input type="radio" id="star4" name="rating" value="4" /><label for="star4" title="4 sao"><i class="bi bi-star-fill"></i></label>
                            <input type="radio" id="star3" name="rating" value="3" /><label for="star3" title="3 sao"><i class="bi bi-star-fill"></i></label>
                            <input type="radio" id="star2" name="rating" value="2" /><label for="star2" title="2 sao"><i class="bi bi-star-fill"></i></label>
                            <input type="radio" id="star1" name="rating" value="1" /><label for="star1" title="1 sao"><i class="bi bi-star-fill"></i></label>
                        </div>

                        <div class="form-floating mb-3">
                            <textarea class="form-control" name="comment" placeholder="Lời nhắn" id="comment" style="height: 120px; border-radius: 12px;"></textarea>
                            <label for="comment">Chia sẻ chi tiết trải nghiệm...</label>
                        </div>
                    </div>
                    <div class="modal-footer border-0 p-4 pt-0">
                        <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-primary rounded-pill px-4 bg-primary border-0" style="background: var(--primary) !important;">Gửi đánh giá</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="no-print">
        <%@ include file="../layouts/footer.jsp" %>
        <%@ include file="../layouts/chatbot.jsp" %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener("DOMContentLoaded", () => {
            const section = document.getElementById('invoiceSection');
            if(section) setTimeout(() => section.classList.add('visible'), 150);
        });
    </script>
</body>
</html>
