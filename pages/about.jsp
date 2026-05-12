<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="../env-secrets.jsp" %>
<%-- ==========================================================================
     TRANG GIỚI THIỆU KHÁCH SẠN (ABOUT US PAGE)
     Cung cấp cái nhìn toàn diện về lịch sử hình thành, di sản kiến trúc,
     tiện ích đỉnh cao và giá trị cốt lõi của thương hiệu OmniStay.
     Tích hợp logic đếm tổng số phòng thực tế từ CSDL để minh họa trực quan.
     ========================================================================== --%>
<%
    // 1. KHỞI TẠO VÀ TRUY VẤN THỐNG KÊ (DYNAMIC STATS INITIALIZATION)
    Connection conn = null;
    // Đặt giá trị dự phòng mặc định (fallback) trong trường hợp mất kết nối CSDL ngầm
    int totalRooms = 38; 
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        // Gọi chuỗi kết nối an toàn bảo mật từ tệp cấu hình tập trung env-secrets.jsp
        conn = DriverManager.getConnection(SECRET_DB_URL, SECRET_DB_USER, SECRET_DB_PASS);
        
        // Truy vấn hàm tổng hợp COUNT(*) để đếm tự động tổng số phòng đang quản lý
        PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM rooms");
        ResultSet rs = ps.executeQuery();
        if(rs.next()) {
            totalRooms = rs.getInt(1);
        }
        // Đóng ngay ResultSet và PreparedStatement để tiết kiệm bộ nhớ đệm
        rs.close(); ps.close();
    } catch(Exception e) {
        // Bỏ qua lỗi ngầm định để đảm bảo trang About luôn hiển thị mượt mà với số liệu fallback
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Về chúng tôi — OmniStay Hotel</title>
    <link rel="icon" type="image/png" href="<%=request.getContextPath()%>/images/logo.png">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,500;0,600;1,400&family=Outfit:wght@300;400;500;600&display=swap" rel="stylesheet" />
    <style>
        :root {
            --primary: #1a6b5a;
            --primary-dark: #124a3e;
            --accent: #d4a847;
            --bg-light: #faf9f6;
            --border-color: #e8e2d9;
        }
        body {
            font-family: "Outfit", sans-serif;
            background-color: var(--bg-light);
            color: #333;
            overflow-x: hidden;
            font-weight: 300;
        }
        .font-display { font-family: "Playfair Display", serif; }
        .text-primary-theme { color: var(--primary) !important; }
        .text-accent { color: var(--accent) !important; }
        .bg-primary-theme { background-color: var(--primary) !important; }

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

        /* ── HERO HEADER (Đồng bộ với dịch vụ, liên hệ) ── */
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
            background: linear-gradient(transparent, var(--bg-light));
            pointer-events: none;
        }
        .page-header h1 {
            text-shadow: 0 4px 20px rgba(0, 0, 0, 0.4), 0 1px 3px rgba(0, 0, 0, 0.3);
        }
        .page-header p {
            text-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
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

        /* Section Titles */
        .section-subtitle {
            font-size: 0.75rem;
            font-weight: 600;
            letter-spacing: 0.2em;
            text-transform: uppercase;
            color: var(--accent);
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 1rem;
        }
        .section-subtitle::before, .section-subtitle::after {
            content: '';
            height: 1px;
            width: 40px;
            background: var(--accent);
            opacity: 0.5;
        }

        /* Image Blocks */
        .img-block {
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            position: relative;
        }
        .img-block img {
            transition: transform 0.8s ease;
        }
        .img-block:hover img {
            transform: scale(1.05);
        }
        .img-badge {
            position: absolute;
            bottom: -30px;
            right: -30px;
            background: var(--primary);
            color: var(--accent);
            width: 140px;
            height: 140px;
            border-radius: 50%;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            border: 8px solid var(--bg-light);
            z-index: 2;
            box-shadow: 0 10px 20px rgba(0,0,0,0.15);
        }

        /* Feature Row */
        .feature-row {
            padding: 5rem 0;
        }
        .feature-row:nth-child(even) {
            background-color: #fff;
            border-top: 1px solid var(--border-color);
            border-bottom: 1px solid var(--border-color);
        }

        /* Value Cards */
        .value-card {
            background: #fff;
            padding: 3rem 2rem;
            border-radius: 16px;
            border: 1px solid var(--border-color);
            height: 100%;
            transition: all 0.4s ease;
            position: relative;
            overflow: hidden;
        }
        .value-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; width: 4px; height: 100%;
            background: linear-gradient(to bottom, var(--primary), var(--accent));
            transform: scaleY(0);
            transform-origin: top;
            transition: transform 0.4s ease;
        }
        .value-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 40px rgba(26, 107, 90, 0.08);
        }
        .value-card:hover::before { transform: scaleY(1); }
        
        .value-icon {
            width: 60px; height: 60px;
            background: rgba(212, 168, 71, 0.1);
            color: var(--accent);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.5rem; margin-bottom: 1.5rem;
            transition: all 0.4s ease;
        }
        .value-card:hover .value-icon {
            background: var(--primary);
            color: #fff;
            transform: rotate(10deg);
        }

        /* Quote Section */
        .quote-section {
            background: var(--primary);
            color: #fff;
            position: relative;
            padding: 6rem 0;
            overflow: hidden;
        }
        .quote-icon {
            position: absolute;
            top: 20px; left: 50%;
            transform: translateX(-50%);
            font-size: 8rem;
            opacity: 0.05;
            color: var(--accent);
        }
        
        /* Stats Box */
        .stats-box {
            background: white;
            border-radius: 16px;
            padding: 2rem;
            box-shadow: 0 10px 30px rgba(0,0,0,0.05);
            text-align: center;
            border: 1px solid var(--border-color);
            height: 100%;
        }
        .stats-number {
            font-family: "Playfair Display", serif;
            font-size: 2.5rem;
            color: var(--primary);
            margin-bottom: 0.5rem;
            line-height: 1;
        }
    </style>
</head>
<body>

    <%@ include file="../layouts/navbar.jsp" %>

    <!-- HERO SECTION -->
    <section class="page-header text-center">
        <div class="container position-relative z-1">
            <nav aria-label="breadcrumb">
                <div class="hero-breadcrumb mb-4">
                    <ol class="breadcrumb justify-content-center mb-0 small text-uppercase" style="letter-spacing: 2px;">
                        <li class="breadcrumb-item"><a href="<%=request.getContextPath()%>/index.jsp" class="text-white text-decoration-none" style="color: rgba(255,255,255,0.85) !important;">Trang chủ</a></li>
                        <li class="breadcrumb-item active" style="color: var(--accent);" aria-current="page">Về chúng tôi</li>
                    </ol>
                </div>
            </nav>
            <p class="text-uppercase fw-500 mb-3" style="font-size: 0.75rem; letter-spacing: 0.2em; color: var(--accent);">
                ✦ Di sản & Tầm nhìn ✦
            </p>
            <h1 class="font-display fw-normal text-white mb-3" style="font-size: clamp(2rem, 4vw, 3.5rem)">
                Hành trình Kiến tạo <em style="color: var(--accent)">Đẳng cấp</em>
            </h1>
            <p class="mx-auto" style="font-size: 0.95rem; max-width: 600px; color: rgba(255,255,255,0.85);">
                Khám phá câu chuyện đằng sau biểu tượng thịnh vượng vùng Tây Đô, nơi nghệ thuật hiếu khách chạm đến sự hoàn mỹ và mọi chuẩn mực đều được định nghĩa lại.
            </p>
        </div>
    </section>

    <!-- SECTION 1: OUR HERITAGE -->
    <section class="feature-row">
        <div class="container">
            <div class="row align-items-center g-5">
                <div class="col-lg-6 animate-fade-in">
                    <div class="position-relative p-3">
                        <div class="img-block">
                            <!-- Sử dụng ảnh tin cậy từ unsplash -->
                            <img src="<%=request.getContextPath()%>/images/hero/hotel-exterior.jpg" alt="OmniStay Heritage" class="w-100" style="height: 550px; object-fit: cover;">
                        </div>
                        <div class="img-badge d-none d-md-flex">
                            <span class="font-display" style="font-size: 2.2rem; line-height: 1;">2009</span>
                            <span style="font-size: 0.65rem; text-transform: uppercase; letter-spacing: 2px;">Thành Lập</span>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6 ps-lg-5 animate-fade-in" style="transition-delay: 0.2s;">
                    <div class="section-subtitle">Dấu ấn thời gian</div>
                    <h2 class="font-display text-primary-theme mb-4" style="font-size: 2.5rem;">Biểu tượng của sự <br><em class="text-accent">Thịnh vượng</em> Miền Tây</h2>
                    <p class="text-muted mb-4" style="line-height: 1.8; font-size: 1.05rem;">
                        Được thành lập từ năm 2009, OmniStay tọa lạc ngay tại trái tim của thành phố Cần Thơ, soi bóng xuống dòng sông Hậu êm đềm và Bến Ninh Kiều lịch sử. Chúng tôi khởi nguồn từ một khát vọng duy nhất: nâng tầm dịch vụ lưu trú miền Tây Nam Bộ lên chuẩn mực quốc tế 5 sao.
                    </p>
                    <p class="text-muted mb-4" style="line-height: 1.8; font-size: 1.05rem;">
                        Suốt hơn một thập kỷ, OmniStay không ngừng đổi mới để mang đến trải nghiệm nghỉ dưỡng cá nhân hóa cao cấp nhất. Vượt qua những giai đoạn thăng trầm của thị trường, chúng tôi đã phục vụ hơn 200.000 lượt khách toàn cầu và tự hào trở thành điểm đến lý tưởng cho giới tinh hoa, doanh nhân và du khách quốc tế khi đặt chân đến Đồng bằng sông Cửu Long.
                    </p>
                    <div class="row mt-4">
                        <div class="col-sm-6 mb-3">
                            <div class="d-flex align-items-center gap-3">
                                <i class="bi bi-check-circle-fill fs-4 text-accent"></i>
                                <span class="fw-500">15+ Năm Lịch Sử</span>
                            </div>
                        </div>
                        <div class="col-sm-6 mb-3">
                            <div class="d-flex align-items-center gap-3">
                                <i class="bi bi-check-circle-fill fs-4 text-accent"></i>
                                <span class="fw-500">Tiên Phong Dịch Vụ</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- SECTION 2: ARCHITECTURE & DESIGN -->
    <section class="feature-row" style="background-color: #fff;">
        <div class="container">
            <div class="row align-items-center flex-lg-row-reverse g-5">
                <div class="col-lg-6 animate-fade-in">
                    <div class="img-block">
                        <!-- Ảnh tin cậy -->
                        <img src="<%=request.getContextPath()%>/images/rooms/room-suite.jpg" alt="OmniStay Architecture" class="w-100" style="height: 600px; object-fit: cover;">
                    </div>
                </div>
                <div class="col-lg-6 pe-lg-5 animate-fade-in" style="transition-delay: 0.2s;">
                    <div class="section-subtitle">Kiến trúc & Nghệ thuật</div>
                    <h2 class="font-display text-primary-theme mb-4" style="font-size: 2.5rem;">Ngôn ngữ <em class="text-accent">Tối giản</em> <br>Đương đại</h2>
                    <p class="text-muted mb-4" style="line-height: 1.8; font-size: 1.05rem;">
                        Kiến trúc của OmniStay là bản giao hưởng tuyệt mỹ giữa nét phóng khoáng của thiên nhiên sông nước và sự tinh tế, góc cạnh của phong cách Minimalist (Tối giản). Mọi chi tiết, từ đường nét mặt tiền đến việc bố trí nội thất, đều tuân thủ nguyên tắc "Less is More" nhưng không kém phần xa hoa.
                    </p>
                    <p class="text-muted mb-4" style="line-height: 1.8; font-size: 1.05rem;">
                        Với hệ thống <strong><%= totalRooms %> phòng nghỉ</strong> siêu sang, mỗi không gian lưu trú đều được tối ưu hóa ánh sáng tự nhiên qua hệ thống kính chạm trần (floor-to-ceiling windows). Từ sảnh đón khách ngập tràn ánh hào quang của những chùm đèn pha lê chế tác thủ công, đến khu vực hồ bơi vô cực trên tầng thượng ôm trọn vẻ đẹp lộng lẫy của cầu Cần Thơ về đêm, OmniStay không chỉ là khách sạn, mà là một tác phẩm nghệ thuật.
                    </p>
                    <a href="<%=request.getContextPath()%>/pages/rooms.jsp" class="btn text-white px-4 py-2 mt-2" style="background: var(--primary); border-radius: 50px;">Xem Các Hạng Phòng <i class="bi bi-arrow-right ms-2"></i></a>
                </div>
            </div>
        </div>
    </section>

    <!-- SECTION 3: GASTRONOMY & WELLNESS -->
    <section class="feature-row">
        <div class="container">
            <div class="row align-items-center g-5">
                <div class="col-lg-6 animate-fade-in">
                    <div class="row g-3">
                        <div class="col-6 mt-4">
                            <div class="img-block h-100">
                                <img src="<%=request.getContextPath()%>/images/services/service-restaurant.jpg" alt="Fine Dining" class="w-100 h-100" style="object-fit: cover;">
                            </div>
                        </div>
                        <div class="col-6 mb-4">
                            <div class="img-block h-100">
                                <img src="<%=request.getContextPath()%>/images/hero/hotel-entrance.jpg" alt="Spa Wellness" class="w-100 h-100" style="object-fit: cover;">
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6 ps-lg-5 animate-fade-in" style="transition-delay: 0.2s;">
                    <div class="section-subtitle">Tiện ích Đỉnh cao</div>
                    <h2 class="font-display text-primary-theme mb-4" style="font-size: 2.5rem;">Đánh thức <em class="text-accent">Mọi giác quan</em></h2>
                    <p class="text-muted mb-4" style="line-height: 1.8; font-size: 1.05rem;">
                        <strong>Tinh hoa ẩm thực:</strong> Chuỗi nhà hàng Signature tại OmniStay quy tụ những bếp trưởng hàng đầu, mang đến sự kết hợp hoàn hảo giữa ẩm thực địa phương tinh túy và các nền văn hóa ẩm thực thế giới. Bữa tối của bạn sẽ không chỉ là một bữa ăn, mà là một hành trình khám phá vị giác đầy cảm xúc.
                    </p>
                    <p class="text-muted mb-4" style="line-height: 1.8; font-size: 1.05rem;">
                        <strong>Ốc đảo bình yên:</strong> Trốn khỏi sự ồn ào của phố thị, khu vực Spa & Wellness của chúng tôi mang đến những liệu pháp thư giãn chuyên sâu, kết hợp các dược liệu quý từ thiên nhiên. Mọi căng thẳng sẽ tan biến khi bạn đắm mình trong làn nước ấm của hồ bơi vô cực, thưởng thức ly cocktail và ngắm hoàng hôn buông xuống dòng sông Hậu.
                    </p>
                </div>
            </div>
        </div>
    </section>

    <!-- QUOTE SECTION -->
    <section class="quote-section text-center animate-fade-in">
        <i class="bi bi-quote quote-icon"></i>
        <div class="container position-relative z-1">
            <h3 class="font-display fw-normal mx-auto mb-4" style="max-width: 800px; font-size: 2.2rem; line-height: 1.5; color: var(--bg-light);">
                "Chúng tôi không chỉ cung cấp một nơi lưu trú. Chúng tôi thiết kế một <em class="text-accent">Phong cách sống</em>, nơi mỗi giây phút đều là một kiệt tác của nghệ thuật phục vụ."
            </h3>
            <p class="text-uppercase mb-0" style="letter-spacing: 2px; font-size: 0.8rem; color: var(--accent); font-weight: 500;">— Ban Giám Đốc OmniStay</p>
        </div>
    </section>

    <!-- CORE VALUES -->
    <section class="py-5" style="background-color: #fff;">
        <div class="container py-5">
            <div class="text-center mb-5 animate-fade-in">
                <div class="section-subtitle justify-content-center mx-auto">Tôn chỉ hoạt động</div>
                <h2 class="font-display text-primary-theme" style="font-size: 2.5rem;">Giá trị <em class="text-accent">Cốt lõi</em></h2>
                <p class="text-muted mt-3 mx-auto" style="max-width: 600px;">Bốn cột trụ định hình phong cách và văn hóa phục vụ của toàn bộ hệ thống OmniStay.</p>
            </div>
            
            <div class="row g-4">
                <div class="col-md-6 col-lg-3 animate-fade-in" style="transition-delay: 0.1s;">
                    <div class="value-card text-center text-md-start">
                        <div class="value-icon mx-auto mx-md-0"><i class="bi bi-gem"></i></div>
                        <h4 class="font-display text-primary-theme fw-bold mb-3">Sự Xuất Sắc</h4>
                        <p class="text-muted small mb-0" style="line-height: 1.6;">Cam kết vượt qua mọi kỳ vọng của khách hàng trong từng chi tiết nhỏ nhất, từ lúc chạm ngõ đến khi vẫy chào tạm biệt.</p>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3 animate-fade-in" style="transition-delay: 0.2s;">
                    <div class="value-card text-center text-md-start">
                        <div class="value-icon mx-auto mx-md-0"><i class="bi bi-flower1"></i></div>
                        <h4 class="font-display text-primary-theme fw-bold mb-3">Bản Sắc</h4>
                        <p class="text-muted small mb-0" style="line-height: 1.6;">Tôn vinh và lồng ghép khéo léo văn hóa, tinh thần thân thiện của con người Miền Tây Nam Bộ vào trải nghiệm lưu trú.</p>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3 animate-fade-in" style="transition-delay: 0.3s;">
                    <div class="value-card text-center text-md-start">
                        <div class="value-icon mx-auto mx-md-0"><i class="bi bi-person-hearts"></i></div>
                        <h4 class="font-display text-primary-theme fw-bold mb-3">Cá Nhân Hóa</h4>
                        <p class="text-muted small mb-0" style="line-height: 1.6;">Thấu hiểu từng thói quen, sở thích để thiết kế một kỳ nghỉ "đo ni đóng giày" cho từng vị khách thượng lưu đến với OmniStay.</p>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3 animate-fade-in" style="transition-delay: 0.4s;">
                    <div class="value-card text-center text-md-start">
                        <div class="value-icon mx-auto mx-md-0"><i class="bi bi-tree"></i></div>
                        <h4 class="font-display text-primary-theme fw-bold mb-3">Bền Vững</h4>
                        <p class="text-muted small mb-0" style="line-height: 1.6;">Vận hành xanh, ưu tiên sử dụng năng lượng tái tạo và chung tay bảo vệ môi trường sinh thái đa dạng của dòng sông Mekong.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- SUSTAINABILITY & CSR -->
    <section class="feature-row">
        <div class="container">
            <div class="row align-items-center flex-lg-row-reverse g-5">
                <div class="col-lg-6 animate-fade-in">
                    <div class="img-block">
                        <img src="<%=request.getContextPath()%>/images/about/about-sustainability.jpg" alt="Sustainability" class="w-100" style="height: 450px; object-fit: cover;">
                    </div>
                </div>
                <div class="col-lg-6 pe-lg-5 animate-fade-in" style="transition-delay: 0.2s;">
                    <div class="section-subtitle">Trách nhiệm Xã hội</div>
                    <h2 class="font-display text-primary-theme mb-4" style="font-size: 2.5rem;">Kiến tạo tương lai <br><em class="text-accent">Xanh & Bền Vững</em></h2>
                    <p class="text-muted mb-4" style="line-height: 1.8; font-size: 1.05rem;">
                        Là một thương hiệu có trách nhiệm, OmniStay đi tiên phong trong các sáng kiến bảo vệ môi trường tại khu vực Đồng bằng sông Cửu Long. Chúng tôi tự hào:
                    </p>
                    <ul class="list-unstyled text-muted" style="line-height: 1.8; font-size: 1.05rem;">
                        <li class="mb-3"><i class="bi bi-droplet-fill text-accent me-2"></i> Hệ thống xử lý nước thông minh tuần hoàn, tiết kiệm 30% tài nguyên.</li>
                        <li class="mb-3"><i class="bi bi-sun-fill text-accent me-2"></i> Sử dụng 100% năng lượng mặt trời cho các tiện ích sưởi ấm hồ bơi và nước sinh hoạt.</li>
                        <li class="mb-3"><i class="bi bi-bag-x-fill text-accent me-2"></i> Loại bỏ hoàn toàn đồ nhựa dùng một lần trong mọi dịch vụ buồng phòng.</li>
                        <li><i class="bi bi-people-fill text-accent me-2"></i> Ưu tiên sử dụng nguyên liệu và sản phẩm từ các hộ nông dân địa phương, góp phần thúc đẩy kinh tế vùng.</li>
                    </ul>
                </div>
            </div>
        </div>
    </section>

    <!-- STATS / TEAM BRIEF -->
    <section class="py-5" style="background-color: var(--primary); padding-top: 5rem !important; padding-bottom: 5rem !important;">
        <div class="container animate-fade-in">
            <div class="row g-4 justify-content-center">
                <div class="col-md-4 col-sm-6">
                    <div class="stats-box">
                        <div class="stats-number"><%= totalRooms %></div>
                        <div class="text-uppercase fw-bold text-secondary" style="font-size: 0.8rem; letter-spacing: 1px;">Phòng & Suite</div>
                    </div>
                </div>
                <div class="col-md-4 col-sm-6">
                    <div class="stats-box">
                        <div class="stats-number">50+</div>
                        <div class="text-uppercase fw-bold text-secondary" style="font-size: 0.8rem; letter-spacing: 1px;">Nhân sự Tận tâm</div>
                    </div>
                </div>
                <div class="col-md-4 col-sm-6">
                    <div class="stats-box">
                        <div class="stats-number">200K+</div>
                        <div class="text-uppercase fw-bold text-secondary" style="font-size: 0.8rem; letter-spacing: 1px;">Khách hàng Hài lòng</div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <%@ include file="../layouts/footer.jsp" %>
    <%@ include file="../layouts/chatbot.jsp" %>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
      // Navbar scroll effect
      window.addEventListener("scroll", function () {
        const navbar = document.querySelector(".navbar");
        if (navbar) {
          navbar.classList.toggle("navbar-scrolled", window.scrollY > 50);
        }
      });

      // Intersection Observer for scroll animations
      const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            entry.target.classList.add('visible');
          }
        });
      }, { threshold: 0.1, rootMargin: '0px 0px -50px 0px' });

      document.querySelectorAll('.animate-fade-in').forEach(el => {
        observer.observe(el);
      });
    </script>
    <% 
        // 2. GIẢI PHÓNG TÀI NGUYÊN (CONNECTION CLEANUP)
        // Hoàn trả tài nguyên kết nối về cho Server nhằm tránh rò rỉ bộ nhớ
        if(conn != null) try { conn.close(); } catch(Exception e) {} 
    %>
</body>
</html>
