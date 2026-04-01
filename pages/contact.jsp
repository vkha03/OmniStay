<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.text.*, javax.mail.*, javax.mail.internet.*, java.util.Properties" %>
<%
    // Xử lý gửi email khi form được submit
    String messageSent = null;
    String errorMessage = null;
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String fullname = request.getParameter("fullname");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String subjectSelect = request.getParameter("subjectSelect");
        String message = request.getParameter("message");
        
        if (fullname != null && email != null && message != null && !fullname.trim().isEmpty() && !email.trim().isEmpty() && !message.trim().isEmpty()) {
            try {
                // Cấu hình SMTP - Sử dụng Gmail
                final String fromEmail = "your-email@gmail.com"; // Thay bằng email của bạn
                final String password = "your-app-password"; // Thay bằng mật khẩu ứng dụng Gmail
                
                Properties props = new Properties();
                props.put("mail.smtp.host", "smtp.gmail.com");
                props.put("mail.smtp.port", "587");
                props.put("mail.smtp.auth", "true");
                props.put("mail.smtp.starttls.enable", "true");
                props.put("mail.smtp.ssl.protocols", "TLSv1.2");
                
                // Tạo session
                Session mailSession = Session.getInstance(props, new Authenticator() {
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(fromEmail, password);
                    }
                });
                
                // Tạo email
                MimeMessage mimeMessage = new MimeMessage(mailSession);
                mimeMessage.setFrom(new InternetAddress(fromEmail, "OmniStay Hotel"));
                mimeMessage.setRecipient(Message.RecipientType.TO, new InternetAddress("concierge@omnistay.vn"));
                mimeMessage.setRecipient(Message.RecipientType.CC, new InternetAddress(email));
                mimeMessage.setSubject("[OmniStay] Liên hệ từ khách hàng: " + subjectSelect);
                
                // Nội dung email HTML
                String emailContent = "<!DOCTYPE html>" +
                    "<html>" +
                    "<head><meta charset='UTF-8'></head>" +
                    "<body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>" +
                    "<div style='max-width: 600px; margin: 0 auto; background: #f9f9f9; border-radius: 10px; overflow: hidden;'>" +
                    "<div style='background: #1a6b5a; padding: 20px; text-align: center;'>" +
                    "<h1 style='color: #d4a847; margin: 0;'>OmniStay Hotel</h1>" +
                    "<p style='color: white; margin: 5px 0 0;'>Khách sạn 5 sao - Cần Thơ</p>" +
                    "</div>" +
                    "<div style='padding: 30px;'>" +
                    "<h2 style='color: #1a6b5a;'>Thông tin liên hệ mới</h2>" +
                    "<table style='width: 100%; border-collapse: collapse;'>" +
                    "<tr style='border-bottom: 1px solid #ddd;'>" +
                    "<td style='padding: 10px 0; font-weight: bold; width: 120px;'>Họ tên:</td>" +
                    "<td style='padding: 10px 0;'>" + fullname + "</td>" +
                    "</tr>" +
                    "<tr style='border-bottom: 1px solid #ddd;'>" +
                    "<td style='padding: 10px 0; font-weight: bold;'>Email:</td>" +
                    "<td style='padding: 10px 0;'>" + email + "</td>" +
                    "</tr>" +
                    "<tr style='border-bottom: 1px solid #ddd;'>" +
                    "<td style='padding: 10px 0; font-weight: bold;'>Số điện thoại:</td>" +
                    "<td style='padding: 10px 0;'>" + (phone != null && !phone.isEmpty() ? phone : "Không cung cấp") + "</td>" +
                    "</tr>" +
                    "<tr style='border-bottom: 1px solid #ddd;'>" +
                    "<td style='padding: 10px 0; font-weight: bold;'>Chủ đề:</td>" +
                    "<td style='padding: 10px 0;'>" + subjectSelect + "</td>" +
                    "</tr>" +
                    "<tr>" +
                    "<td style='padding: 10px 0; font-weight: bold; vertical-align: top;'>Lời nhắn:</td>" +
                    "<td style='padding: 10px 0;'>" + message.replace("\n", "<br>") + "</td>" +
                    "</tr>" +
                    "</table>" +
                    "<hr style='margin: 20px 0; border: none; border-top: 1px solid #ddd;'>" +
                    "<p style='color: #666; font-size: 12px;'>Email này được gửi tự động từ hệ thống OmniStay. Vui lòng không phản hồi email này.</p>" +
                    "</div>" +
                    "<div style='background: #f0f0f0; padding: 15px; text-align: center; font-size: 12px; color: #666;'>" +
                    "<p>© 2026 OmniStay Hotel - 81-83 Hai Bà Trưng, Ninh Kiều, Cần Thơ</p>" +
                    "<p>Hotline: 0292 345 6789 | Email: concierge@omnistay.vn</p>" +
                    "</div>" +
                    "</div>" +
                    "</body>" +
                    "</html>";
                
                mimeMessage.setContent(emailContent, "text/html; charset=UTF-8");
                
                // Gửi email
                Transport.send(mimeMessage);
                messageSent = "success";
                
            } catch (Exception e) {
                errorMessage = e.getMessage();
                messageSent = "error";
                e.printStackTrace();
            }
        } else {
            errorMessage = "Vui lòng điền đầy đủ thông tin bắt buộc";
            messageSent = "error";
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>OmniStay — Liên hệ & Hỗ trợ</title>
    <link
        href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
        rel="stylesheet"
    />
    <link
        href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
        rel="stylesheet"
    />
    <link
        href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;1,400&family=Outfit:wght@300;400;500;600&display=swap"
        rel="stylesheet"
    />
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
            background: #fff;
        }
        .font-display {
            font-family: "Playfair Display", serif;
        }
        
        /* Main content offset for fixed navbar */
        .main-content {
            padding-top: 100px;
        }
        @media (max-width: 768px) {
            .main-content {
                padding-top: 85px;
            }
        }
        
        /* Section tag styling */
        .section-tag {
            font-size: 0.7rem;
            letter-spacing: 0.2em;
            text-transform: uppercase;
            color: var(--primary);
            font-weight: 500;
        }
        .divider {
            width: 40px;
            height: 2px;
            background: var(--accent);
        }
        
        /* Contact Hero */
        .contact-hero {
            background: linear-gradient(107deg, #f8f6f2 0%, #ffffff 100%);
            border-bottom: 1px solid var(--border);
            padding: 2rem 0 3rem 0;
        }
        
        /* Info Cards */
        .info-card {
            background: #fff;
            border-radius: 24px;
            padding: 2rem 1.5rem;
            height: 100%;
            transition: all 0.4s cubic-bezier(0.2, 0.9, 0.4, 1.1);
            border: 1px solid rgba(212, 168, 71, 0.2);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.03);
        }
        .info-card:hover {
            transform: translateY(-6px);
            border-color: var(--accent);
            box-shadow: 0 20px 35px -12px rgba(26, 107, 90, 0.12);
        }
        .icon-circle {
            width: 64px;
            height: 64px;
            background: rgba(26, 107, 90, 0.08);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 1.5rem;
            transition: all 0.3s;
        }
        .info-card:hover .icon-circle {
            background: var(--primary);
        }
        .icon-circle i {
            font-size: 2rem;
            color: var(--primary);
            transition: color 0.2s;
        }
        .info-card:hover .icon-circle i {
            color: white;
        }
        .info-title {
            font-weight: 600;
            font-size: 1.3rem;
            margin-bottom: 0.75rem;
            color: #1e2a2a;
            font-family: "Playfair Display", serif;
        }
        .info-detail {
            color: #5f6c6c;
            line-height: 1.6;
            font-size: 0.95rem;
        }
        
        /* Contact Form */
        .contact-form-wrapper {
            background: white;
            border-radius: 28px;
            padding: 2rem 2rem;
            box-shadow: 0 12px 28px rgba(0, 0, 0, 0.06);
            border: 1px solid rgba(212, 168, 71, 0.25);
            transition: all 0.3s;
        }
        .form-control, .form-select {
            border: 1.5px solid var(--border);
            border-radius: 14px;
            padding: 0.8rem 1rem;
            font-size: 0.95rem;
            transition: all 0.2s;
            background: #fefefc;
            font-family: "Outfit", sans-serif;
        }
        .form-control:focus, .form-select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(26, 107, 90, 0.1);
            background: white;
        }
        .btn-submit-contact {
            background: var(--primary);
            color: white;
            border: none;
            border-radius: 40px;
            padding: 0.9rem 1.8rem;
            font-weight: 500;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            box-shadow: 0 6px 14px rgba(26, 107, 90, 0.25);
        }
        .btn-submit-contact:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
            box-shadow: 0 12px 22px rgba(26, 107, 90, 0.3);
        }
        
        /* Map Container */
        .map-container {
            border-radius: 28px;
            overflow: hidden;
            box-shadow: 0 12px 28px rgba(0, 0, 0, 0.08);
            border: 1px solid rgba(212, 168, 71, 0.2);
            height: 380px;
        }
        .map-container iframe {
            width: 100%;
            height: 100%;
            border: 0;
        }
        
        /* Quick Info Panel */
        .quick-info-panel {
            background: white;
            border-radius: 24px;
            border-left: 4px solid var(--accent);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.03);
        }
        
        /* Toast Notification */
        .toast-custom {
            position: fixed;
            bottom: 30px;
            left: 30px;
            z-index: 1090;
            background: #1e2a2a;
            color: #f5efdf;
            border-left: 5px solid var(--accent);
            border-radius: 16px;
            box-shadow: 0 12px 28px rgba(0,0,0,0.2);
            min-width: 280px;
        }
        @keyframes slideIn {
            0% { opacity: 0; transform: translateX(-30px); }
            100% { opacity: 1; transform: translateX(0); }
        }
        
        /* Modal thông báo */
        .alert-modal {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 9999;
            min-width: 300px;
            animation: slideInRight 0.3s ease-out;
        }
        @keyframes slideInRight {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .contact-form-wrapper {
                padding: 1.5rem;
            }
            .info-card {
                padding: 1.5rem;
            }
            .map-container {
                height: 280px;
            }
        }
        
        /* Animation for cards */
        .info-card {
            opacity: 0;
            transform: translateY(20px);
            transition: opacity 0.6s ease, transform 0.5s ease;
        }
        .info-card.visible {
            opacity: 1;
            transform: translateY(0);
        }
    </style>
</head>
<body>

    <!-- Include Navbar cố định -->
    <%@ include file="layouts/navbar.jsp" %>

    <!-- Main Content -->
    <div class="main-content">
        <!-- Hero Section -->
        <div class="contact-hero">
            <div class="container">
                <div class="row align-items-center">
                    <div class="col-lg-8 mx-auto text-center">
                        <div class="mb-3">
                            <span class="section-tag">Liên hệ với chúng tôi</span>
                        </div>
                        <h1 class="font-display fw-normal mb-3" style="font-size: clamp(2rem, 4vw, 3rem);">
                            Kết nối <span style="color: var(--accent);">OmniStay</span>
                        </h1>
                        <p class="text-muted mx-auto" style="font-size: 1rem; max-width: 600px; line-height: 1.8;">
                            Đội ngũ chăm sóc khách hàng 5 sao luôn sẵn sàng phục vụ quý khách 24/7. 
                            Hãy để chúng tôi đồng hành cùng trải nghiệm thượng lưu của bạn.
                        </p>
                        <div class="divider mx-auto mt-3"></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Thông tin liên hệ 3 cột -->
        <div class="container py-5">
            <div class="row g-4 mb-5">
                <div class="col-md-4">
                    <div class="info-card text-center text-md-start">
                        <div class="icon-circle mx-auto mx-md-0">
                            <i class="bi bi-geo-alt-fill"></i>
                        </div>
                        <h3 class="info-title">Địa chỉ</h3>
                        <p class="info-detail">81-83 Hai Bà Trưng, Quận Ninh Kiều,<br> TP. Cần Thơ, Việt Nam</p>
                        <small class="text-muted">Trung tâm thành phố – View sông Hậu lộng lẫy</small>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="info-card text-center text-md-start">
                        <div class="icon-circle mx-auto mx-md-0">
                            <i class="bi bi-telephone-fill"></i>
                        </div>
                        <h3 class="info-title">Tổng đài hỗ trợ</h3>
                        <p class="info-detail mb-1"><strong>Hotline:</strong> <a href="tel:+842923456789" class="text-decoration-none" style="color: var(--primary);">+84 292 345 6789</a></p>
                        <p class="info-detail mb-1"><strong>WhatsApp/Zalo:</strong> 0901 234 567</p>
                        <p class="info-detail">Email: concierge@omnistay.vn</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="info-card text-center text-md-start">
                        <div class="icon-circle mx-auto mx-md-0">
                            <i class="bi bi-clock-fill"></i>
                        </div>
                        <h3 class="info-title">Lễ tân 24/7</h3>
                        <p class="info-detail">Phục vụ quanh năm, kể cả ngày lễ. Bộ phận đặt phòng hoạt động 24 giờ để đáp ứng mọi yêu cầu của quý khách.</p>
                        <div class="mt-2">
                            <span class="badge rounded-pill px-3 py-2" style="background: rgba(212, 168, 71, 0.15); color: var(--accent); font-size: 0.7rem;">
                                <i class="bi bi-clock-history me-1"></i>Phản hồi trong 30 phút
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Form + Map Row -->
            <div class="row g-5 mt-2">
                <!-- Contact Form -->
                <div class="col-lg-7">
                    <div class="contact-form-wrapper">
                        <div class="mb-4">
                            <span class="badge rounded-pill px-3 py-2 mb-2" style="background: rgba(26, 107, 90, 0.08); color: var(--primary);">
                                <i class="bi bi-envelope-paper me-1"></i>Gửi yêu cầu
                            </span>
                            <h2 class="font-display fw-normal mb-2" style="font-size: 1.8rem;">Chúng tôi lắng nghe bạn</h2>
                            <p class="text-muted" style="font-size: 0.9rem;">Mọi thông tin góp ý, thắc mắc về đặt phòng, tổ chức sự kiện hoặc dịch vụ cao cấp, đội ngũ chuyên viên sẽ liên hệ lại nhanh nhất.</p>
                        </div>
                        
                        <!-- Hiển thị thông báo kết quả gửi email -->
                        <% if ("success".equals(messageSent)) { %>
                            <div class="alert alert-success alert-dismissible fade show" role="alert">
                                <i class="bi bi-check-circle-fill me-2"></i>
                                <strong>Gửi thành công!</strong> Cảm ơn bạn đã liên hệ. Chúng tôi sẽ phản hồi trong thời gian sớm nhất.
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        <% } else if ("error".equals(messageSent) && errorMessage != null) { %>
                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                <i class="bi bi-exclamation-triangle-fill me-2"></i>
                                <strong>Lỗi gửi!</strong> <%= errorMessage %>
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        <% } %>
                        
                        <form id="contactForm" action="contact.jsp" method="post">
                            <div class="row g-4">
                                <div class="col-md-6">
                                    <label class="form-label fw-500" style="font-size: 0.8rem; color: #666;">Họ và tên <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="fullname" name="fullname" placeholder="Nguyễn Văn A" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-500" style="font-size: 0.8rem; color: #666;">Email <span class="text-danger">*</span></label>
                                    <input type="email" class="form-control" id="email" name="email" placeholder="ten@example.com" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-500" style="font-size: 0.8rem; color: #666;">Số điện thoại</label>
                                    <input type="tel" class="form-control" id="phone" name="phone" placeholder="0901 234 567">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-500" style="font-size: 0.8rem; color: #666;">Chủ đề</label>
                                    <select class="form-select" id="subjectSelect" name="subjectSelect">
                                        <option value="Đặt phòng & Suite">Đặt phòng & Suite</option>
                                        <option value="Tiệc & Hội nghị">Tiệc & Hội nghị</option>
                                        <option value="Dịch vụ Spa & Wellness">Dịch vụ Spa & Wellness</option>
                                        <option value="Ẩm thực & Nhà hàng">Ẩm thực & Nhà hàng</option>
                                        <option value="Góp ý / Khiếu nại">Góp ý / Khiếu nại</option>
                                        <option value="Khác">Khác</option>
                                    </select>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-500" style="font-size: 0.8rem; color: #666;">Lời nhắn <span class="text-danger">*</span></label>
                                    <textarea class="form-control" id="message" name="message" rows="5" placeholder="Xin vui lòng nhập chi tiết yêu cầu của quý khách..." required></textarea>
                                </div>
                                <div class="col-12">
                                    <button type="submit" class="btn btn-submit-contact w-100 w-md-auto px-5">
                                        Gửi liên hệ <i class="bi bi-send ms-2"></i>
                                    </button>
                                </div>
                            </div>
                        </form>
                        <div class="mt-4 text-center small text-muted">
                            <i class="bi bi-shield-check me-1"></i> Cam kết bảo mật thông tin · Phản hồi trong vòng 2 giờ
                            <br>
                            <i class="bi bi-envelope me-1"></i> Hệ thống sẽ gửi email xác nhận đến địa chỉ email của bạn
                        </div>
                    </div>
                </div>
                
                <!-- Map & Quick Info -->
                <div class="col-lg-5">
                    <div class="mb-4">
                        <div class="map-container">
                            <iframe 
                                src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3928.545225670227!2d105.77738541482478!3d10.04523499280771!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x31a0895a51d60793%3A0x9f6b3b8c9b8e5b3d!2s81%20Hai%20B%C3%A0%20Tr%C6%B0ng%2C%20T%C3%A2n%20An%2C%20Ninh%20Ki%E1%BB%81u%2C%20C%E1%BA%A7n%20Th%C6%A1%2C%20Vietnam!5e0!3m2!1sen!2s!4v1712123456789!5m2!1sen!2s" 
                                allowfullscreen="" 
                                loading="lazy"
                                referrerpolicy="no-referrer-when-downgrade">
                            </iframe>
                        </div>
                    </div>
                    
                    <!-- Quick Info Panel -->
                    <div class="quick-info-panel p-4 mt-3">
                        <div class="d-flex align-items-center gap-3 mb-4">
                            <div style="width: 40px; height: 40px; background: rgba(26, 107, 90, 0.08); border-radius: 12px; display: flex; align-items: center; justify-content: center;">
                                <i class="bi bi-star-fill" style="color: var(--accent);"></i>
                            </div>
                            <div>
                                <strong class="fs-6">Dịch vụ đón xe đẳng cấp</strong>
                                <p class="mb-0 small text-muted">Xe limousine sân bay Cần Thơ theo yêu cầu, chỉ cần liên hệ trước 3h.</p>
                            </div>
                        </div>
                        <div class="d-flex align-items-center gap-3 mb-4">
                            <div style="width: 40px; height: 40px; background: rgba(26, 107, 90, 0.08); border-radius: 12px; display: flex; align-items: center; justify-content: center;">
                                <i class="bi bi-chat-heart" style="color: var(--primary);"></i>
                            </div>
                            <div>
                                <strong class="fs-6">Chat trực tiếp với Concierge</strong>
                                <p class="mb-0 small text-muted">Nhấn biểu tượng robot góc phải để trò chuyện cùng AI concierge.</p>
                            </div>
                        </div>
                        <div class="d-flex align-items-center gap-3">
                            <div style="width: 40px; height: 40px; background: rgba(26, 107, 90, 0.08); border-radius: 12px; display: flex; align-items: center; justify-content: center;">
                                <i class="bi bi-whatsapp" style="color: #25D366;"></i>
                            </div>
                            <div>
                                <strong class="fs-6">Hỗ trợ qua Zalo/WhatsApp</strong>
                                <p class="mb-0 small text-muted">Kết nối nhanh với đội ngũ tư vấn qua số <strong>0901 234 567</strong></p>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Working Hours -->
                    <div class="bg-white rounded-4 p-4 mt-3 shadow-sm" style="border: 1px solid var(--border);">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <span class="fw-600" style="font-size: 0.9rem;"><i class="bi bi-calendar3 me-2" style="color: var(--primary);"></i>Giờ làm việc</span>
                            <span class="badge rounded-pill" style="background: rgba(26, 107, 90, 0.1); color: var(--primary);">24/7</span>
                        </div>
                        <div class="d-flex justify-content-between py-2 border-bottom">
                            <span class="text-muted">Lễ tân & Đặt phòng</span>
                            <span class="fw-500">24 giờ / ngày</span>
                        </div>
                        <div class="d-flex justify-content-between py-2 border-bottom">
                            <span class="text-muted">Nhà hàng The Verdant</span>
                            <span class="fw-500">06:00 – 23:00</span>
                        </div>
                        <div class="d-flex justify-content-between py-2 border-bottom">
                            <span class="text-muted">Jade Lounge (Bar)</span>
                            <span class="fw-500">17:00 – 02:00</span>
                        </div>
                        <div class="d-flex justify-content-between py-2">
                            <span class="text-muted">Spa & Wellness</span>
                            <span class="fw-500">09:00 – 22:00</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Map Section Extended (Route) -->
        <section style="padding: 3rem 0 5rem 0; background: var(--light-bg);">
            <div class="container">
                <div class="row align-items-center g-5">
                    <div class="col-lg-6">
                        <span class="section-tag">Phương tiện di chuyển</span>
                        <h2 class="font-display fw-normal mt-2 mb-4" style="font-size: clamp(1.5rem, 3vw, 2.2rem);">
                            Dễ dàng tiếp cận <br><span style="color: var(--accent);">OmniStay</span>
                        </h2>
                        <div class="d-flex gap-3 mb-3 pb-2 border-bottom">
                            <div class="flex-shrink-0" style="width: 40px;">
                                <i class="bi bi-airplane fs-4" style="color: var(--primary);"></i>
                            </div>
                            <div>
                                <strong>Sân bay Quốc tế Cần Thơ (VCA)</strong>
                                <p class="text-muted mb-0 small">8 km · 15 phút lái xe. Dịch vụ xe đưa đón theo yêu cầu: 350.000₫/chuyến.</p>
                            </div>
                        </div>
                        <div class="d-flex gap-3 mb-3 pb-2 border-bottom">
                            <div class="flex-shrink-0" style="width: 40px;">
                                <i class="bi bi-bus-front fs-4" style="color: var(--primary);"></i>
                            </div>
                            <div>
                                <strong>Bến xe khách Cần Thơ</strong>
                                <p class="text-muted mb-0 small">3.5 km · 8 phút taxi. Tuyến xe buýt số 01, 03 dừng trước khách sạn.</p>
                            </div>
                        </div>
                        <div class="d-flex gap-3">
                            <div class="flex-shrink-0" style="width: 40px;">
                                <i class="bi bi-car-front fs-4" style="color: var(--primary);"></i>
                            </div>
                            <div>
                                <strong>Bãi đỗ xe ngầm</strong>
                                <p class="text-muted mb-0 small">Sức chứa 80 xe ô tô, phí 80.000₫/ngày dành cho khách lưu trú. Dịch vụ valet parking miễn phí.</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <div class="rounded-4 overflow-hidden shadow-sm">
                            <img src="https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80" 
                                 class="w-100 object-fit-cover" style="height: 280px; object-fit: cover;"
                                 alt="OmniStay Location">
                        </div>
                        <div class="mt-3 text-center">
                            <a href="https://maps.google.com/?q=81+Hai+Bà+Trưng,+Cần+Thơ" target="_blank" class="text-decoration-none" style="color: var(--primary);">
                                <i class="bi bi-map me-1"></i> Xem chỉ đường trên Google Maps
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </div>

    <!-- Include Footer cố định -->
    <%@ include file="layouts/footer.jsp" %>
    <!-- Include Chatbot -->
    <%@ include file="layouts/chatbot.jsp" %>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Animate info cards on scroll
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('visible');
                }
            });
        }, { threshold: 0.1 });
        
        document.querySelectorAll('.info-card').forEach(card => {
            observer.observe(card);
        });
        
        // Navbar scroll effect
        window.addEventListener("scroll", function () {
            const navbar = document.querySelector(".navbar");
            if (navbar) {
                navbar.classList.toggle("navbar-scrolled", window.scrollY > 50);
            }
        });
        
        // Client-side validation before submit
        document.getElementById('contactForm').addEventListener('submit', function(e) {
            const fullname = document.getElementById('fullname').value.trim();
            const email = document.getElementById('email').value.trim();
            const message = document.getElementById('message').value.trim();
            const emailPattern = /^[^\s@]+@([^\s@]+\.)+[^\s@]+$/;
            
            if (fullname === "") {
                e.preventDefault();
                alert("Vui lòng nhập họ và tên");
                return false;
            }
            if (email === "") {
                e.preventDefault();
                alert("Vui lòng nhập email");
                return false;
            }
            if (!emailPattern.test(email)) {
                e.preventDefault();
                alert("Email không hợp lệ (ví dụ: ten@omnistay.vn)");
                return false;
            }
            if (message === "") {
                e.preventDefault();
                alert("Hãy nhập nội dung lời nhắn");
                return false;
            }
            return true;
        });
    </script>
</body>
</html>