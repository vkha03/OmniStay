<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- ==========================================================================
     TRANG TRA CỨU HÓA ĐƠN VÀ ĐƠN ĐẶT PHÒNG (INVOICE & BOOKING LOOKUP)
     Cung cấp biểu mẫu bảo mật cho phép khách hàng tra cứu trạng thái đơn hàng,
     tổng chi phí và tùy chọn gửi nhận xét dựa trên Mã đặt phòng (Booking Code)
     và Số điện thoại đăng ký nhằm bảo vệ tối đa dữ liệu cá nhân.
     ========================================================================== --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tra cứu hóa đơn — OmniStay Hotel</title>
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

        /* ── HERO HEADER (Đồng bộ chuẩn Rooms/Contact) ── */
        .page-header {
            background: linear-gradient(
                160deg,
                rgba(10, 40, 33, 0.90) 0%,
                rgba(20, 85, 70, 0.78) 50%,
                rgba(30, 110, 90, 0.68) 100%
            ), url('<%=request.getContextPath()%>/images/hero/hotel-exterior.jpg') center/cover no-repeat;
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
            -webkit-backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.12);
            border-radius: 50px;
            padding: 0.5rem 1.5rem;
            display: inline-block;
        }

        /* ── LOOKUP CARD (Đồng bộ chuẩn Form Contact) ── */
        .form-card {
            background: #fff;
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 3.5rem;
            box-shadow: 0 15px 35px rgba(0,0,0,0.05);
            margin-top: -60px;
            position: relative;
            z-index: 10;
        }

        .form-floating > .form-control {
            border: 1px solid var(--border);
            border-radius: 10px;
        }
        .form-floating > .form-control:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 0.25rem rgba(212, 168, 71, 0.15);
        }

        .btn-submit {
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            color: #fff;
            border-radius: 12px;
            padding: 15px 30px;
            font-weight: 500;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            text-transform: uppercase;
            letter-spacing: 1px;
            border: none;
            width: 100%;
        }
        .btn-submit:hover {
            background: linear-gradient(135deg, var(--accent), #c49a3a);
            transform: translateY(-3px);
            box-shadow: 0 12px 30px rgba(212, 168, 71, 0.3);
            color: #111;
        }

        .info-box {
            background: rgba(26, 107, 90, 0.03);
            border: 1px dashed var(--primary);
            border-radius: 15px;
            padding: 1.5rem;
            margin-top: 2rem;
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
    </style>
</head>
<body>

    <%@ include file="../layouts/navbar.jsp" %>

    <section class="page-header text-center">
        <div class="container position-relative z-1">
            <nav aria-label="breadcrumb">
                <div class="hero-breadcrumb mb-4">
                    <ol class="breadcrumb justify-content-center mb-0 small text-uppercase" style="letter-spacing: 2px;">
                        <li class="breadcrumb-item"><a href="../index.jsp" class="text-white text-decoration-none">Trang chủ</a></li>
                        <li class="breadcrumb-item active" style="color: var(--accent);" aria-current="page">Tra cứu hóa đơn</li>
                    </ol>
                </div>
            </nav>
            <p class="text-uppercase fw-500 mb-3" style="font-size: 0.75rem; letter-spacing: 0.2em; color: var(--accent);">
                ✦ OmniStay Cần Thơ ✦
            </p>
            <h1 class="font-display fw-normal text-white mb-3" style="font-size: clamp(2rem, 4vw, 3.5rem)">
                Quản lý <em style="color: var(--accent)">Hành trình</em>
            </h1>
            <p class="mx-auto" style="font-size: 0.95rem; max-width: 520px; color: rgba(255,255,255,0.85);">
                Truy cập thông tin đặt phòng, hóa đơn điện tử và các dịch vụ đi kèm của bạn tại OmniStay.
            </p>
        </div>
    </section>

    <main class="container pb-5">
        <div class="row justify-content-center">
            <div class="col-lg-7 animate-fade-in" id="lookupSection">
                <div class="form-card">
                    <div class="text-center mb-5">
                        <h3 class="font-display fw-normal mb-2" style="color: var(--primary);">Thông tin tra cứu</h3>
                        <p class="text-muted small">Vui lòng cung cấp mã đặt phòng và số điện thoại đăng ký.</p>
                    </div>

                    <form action="invoice-detail.jsp" method="GET">
                        <div class="row g-4">
                            <div class="col-12">
                                <div class="form-floating">
                                    <input type="text" class="form-control" id="code" name="code" placeholder="Mã đặt phòng" required>
                                    <label for="code">Mã đặt phòng (Booking Code) <span class="text-danger">*</span></label>
                                </div>
                            </div>
                            <div class="col-12">
                                <div class="form-floating">
                                    <input type="tel" class="form-control" id="phone" name="phone" placeholder="Số điện thoại" required>
                                    <label for="phone">Số điện thoại liên hệ <span class="text-danger">*</span></label>
                                </div>
                            </div>
                            <div class="col-12 mt-5">
                                <button type="submit" class="btn btn-submit">
                                    <i class="bi bi-search me-2"></i> Truy xuất hóa đơn
                                </button>
                            </div>
                        </div>
                    </form>

                    <div class="info-box d-flex align-items-center gap-3">
                        <i class="bi bi-shield-lock fs-3 text-primary"></i>
                        <div class="small text-muted" style="line-height: 1.5;">
                            Để bảo vệ quyền riêng tư, hệ thống chỉ hiển thị hóa đơn khi Mã đặt phòng và Số điện thoại khớp hoàn toàn với dữ liệu lưu trữ.
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <%@ include file="../layouts/footer.jsp" %>
    <%@ include file="../layouts/chatbot.jsp" %>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Animation trigger
        document.addEventListener("DOMContentLoaded", () => {
            const section = document.getElementById('lookupSection');
            setTimeout(() => section.classList.add('visible'), 100);
        });
    </script>
</body>
</html>
