<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.text.*, java.util.Properties" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.mail.*, jakarta.mail.internet.*" %>
<%@ include file="../env-secrets.jsp" %>
<%
    // Xử lý gửi email và lưu Database khi form được submit
    String messageSent = null;
    String errorMessage = null;
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");
        
        String fullname = request.getParameter("fullname");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String subjectSelect = request.getParameter("subjectSelect");
        String message = request.getParameter("message");
        
        if (fullname != null && email != null && message != null && !fullname.trim().isEmpty() && !email.trim().isEmpty() && !message.trim().isEmpty()) {
            Connection conn = null;
            PreparedStatement pstmt = null;
            
            try {
                // 1. LƯU VÀO DATABASE
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(SECRET_DB_URL, SECRET_DB_USER, SECRET_DB_PASS);
                
                String sql = "INSERT INTO contacts (full_name, email, subject, message) VALUES (?, ?, ?, ?)";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, fullname);
                pstmt.setString(2, email);
                pstmt.setString(3, subjectSelect);
                pstmt.setString(4, message);
                pstmt.executeUpdate();

                // 2. GỬI EMAIL THÔNG BÁO BẰNG JAKARTA MAIL
                final String fromEmail = "dvk2341@gmail.com"; 
                final String password = SECRET_MAIL_PASS; 
                
                Properties props = new Properties();
                props.put("mail.smtp.host", "smtp.gmail.com");
                props.put("mail.smtp.port", "587");
                props.put("mail.smtp.auth", "true");
                props.put("mail.smtp.starttls.enable", "true");
                props.put("mail.smtp.ssl.protocols", "TLSv1.2");
                
                Session mailSession = Session.getInstance(props, new Authenticator() {
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(fromEmail, password);
                    }
                });
                
                MimeMessage mimeMessage = new MimeMessage(mailSession);
                mimeMessage.setFrom(new InternetAddress(fromEmail, "OmniStay Hotel"));
                mimeMessage.setRecipient(Message.RecipientType.TO, new InternetAddress("concierge@omnistay.vn"));
                mimeMessage.setRecipient(Message.RecipientType.CC, new InternetAddress(email));
                mimeMessage.setSubject("[OmniStay] Xác nhận liên hệ: " + subjectSelect, "UTF-8");
                
                String emailContent = "<!DOCTYPE html><html><body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'><div style='max-width: 600px; margin: 0 auto; border: 1px solid #e8e2d9; border-radius: 8px; overflow: hidden;'><div style='background: #1a6b5a; padding: 20px; text-align: center;'><h2 style='color: #d4a847; margin: 0;'>OmniStay Hotel</h2><p style='color: white; margin: 0;'>Xác nhận yêu cầu liên hệ</p></div><div style='padding: 20px;'><p>Xin chào <strong>" + fullname + "</strong>,</p><p>Hệ thống của OmniStay đã ghi nhận yêu cầu của quý khách với thông tin chi tiết như sau:</p><table style='width: 100%; border-collapse: collapse; margin-top: 10px;'><tr style='border-bottom: 1px solid #eee;'><td style='padding: 8px 0; width: 100px;'><strong>SĐT:</strong></td><td style='padding: 8px 0;'>" + phone + "</td></tr><tr style='border-bottom: 1px solid #eee;'><td style='padding: 8px 0;'><strong>Chủ đề:</strong></td><td style='padding: 8px 0;'>" + subjectSelect + "</td></tr><tr><td style='padding: 8px 0; vertical-align: top;'><strong>Lời nhắn:</strong></td><td style='padding: 8px 0;'>" + message.replace("\n", "<br>") + "</td></tr></table><p style='margin-top: 20px;'>Đội ngũ Chăm sóc khách hàng sẽ liên hệ lại với quý khách trong vòng 2 giờ làm việc.</p><p>Trân trọng,<br><strong>Đội ngũ OmniStay</strong></p></div></div></body></html>";
                mimeMessage.setContent(emailContent, "text/html; charset=UTF-8");
                Transport.send(mimeMessage);
                
                // 3. GỬI THÔNG BÁO QUA ZALO BOT
                try {
                    String botToken = SECRET_ZALO_TOKEN;
                    String chatId = SECRET_ZALO_CHATID;
                    
                    System.out.println("--- BẮT ĐẦU GỬI ZALO BOT ---");
                    System.out.println("Token: " + botToken);
                    System.out.println("Chat ID: " + chatId);
                    
                    if (botToken != null && !botToken.isEmpty() && chatId != null && !chatId.isEmpty()) {
                        String zaloMessage = "🔔 CÓ LIÊN HỆ MỚI TỪ OMNISTAY\n"
                                + "- Khách hàng: " + fullname + "\n"
                                + "- SĐT: " + phone + "\n"
                                + "- Email: " + email + "\n"
                                + "- Chủ đề: " + subjectSelect + "\n"
                                + "- Lời nhắn: " + message;
                                
                        // Escape chuỗi thành định dạng JSON hợp lệ
                        zaloMessage = zaloMessage.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
                        
                        String jsonPayload = "{\"chat_id\": \"" + chatId + "\", \"text\": \"" + zaloMessage + "\"}";
                        System.out.println("Payload: " + jsonPayload);
                        
                        String apiUrl = "https://bot-api.zaloplatforms.com/bot" + botToken + "/sendMessage";
                        System.out.println("API URL: " + apiUrl);
                        
                        java.net.URL url = new java.net.URL(apiUrl);
                        java.net.HttpURLConnection httpConn = (java.net.HttpURLConnection) url.openConnection();
                        httpConn.setRequestMethod("POST");
                        httpConn.setRequestProperty("Content-Type", "application/json");
                        httpConn.setDoOutput(true);
                        httpConn.setConnectTimeout(5000);
                        httpConn.setReadTimeout(5000);
                        
                        System.out.println("Đang gửi HTTP POST...");
                        try (java.io.OutputStream os = httpConn.getOutputStream()) {
                            byte[] input = jsonPayload.getBytes("utf-8");
                            os.write(input, 0, input.length);
                        }
                        
                        // Gọi HTTP Request để lấy kết quả
                        int responseCode = httpConn.getResponseCode();
                        System.out.println("Mã phản hồi HTTP: " + responseCode);
                        
                        // Đọc chi tiết phản hồi từ Zalo API
                        java.io.InputStream is = (responseCode >= 200 && responseCode < 300) ? httpConn.getInputStream() : httpConn.getErrorStream();
                        if (is != null) {
                            java.util.Scanner s = new java.util.Scanner(is).useDelimiter("\\A");
                            String responseBody = s.hasNext() ? s.next() : "";
                            System.out.println("Zalo Response Body: " + responseBody);
                        }
                        System.out.println("--- KẾT THÚC GỬI ZALO BOT ---");
                    } else {
                        System.out.println("Thiếu Token hoặc Chat ID, huỷ gửi Zalo.");
                    }
                } catch (Exception zaloEx) {
                    System.out.println("Lỗi gửi Zalo Bot (Exception): " + zaloEx.getMessage());
                    zaloEx.printStackTrace();
                }

                messageSent = "success";
            } catch (Exception e) {
                errorMessage = e.getMessage();
                messageSent = "error";
                e.printStackTrace();
            } finally {
                if (pstmt != null) try { pstmt.close(); } catch(SQLException ignore) {}
                if (conn != null) try { conn.close(); } catch(SQLException ignore) {}
            }
        } else {
            errorMessage = "Vui lòng điền đầy đủ thông tin!";
            messageSent = "error";
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Liên Hệ & Hỗ Trợ Khách Hàng — OmniStay</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,500;0,600;1,400&family=Outfit:wght@300;400;500;600&display=swap" rel="stylesheet" />
    <style>
        :root {
            --primary: #1a6b5a;
            --primary-dark: #124a3e;
            --accent: #d4a847;
            --accent-light: #f6ebd4;
            --bg-light: #faf9f6;
            --border-color: #e8e2d9;
        }
        body {
            font-family: "Outfit", sans-serif;
            background-color: var(--bg-light);
            color: #333;
            overflow-x: hidden;
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
        
        /* Hero Section */
        .hero-contact {
            background: linear-gradient(
                160deg,
                rgba(10, 40, 33, 0.90) 0%,
                rgba(20, 85, 70, 0.78) 50%,
                rgba(30, 110, 90, 0.70) 100%
            ), url('https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1600&q=80') center/cover no-repeat;
            background-attachment: fixed;
            padding: 160px 0 120px 0;
            border-bottom: 5px solid var(--accent);
        }
        .hero-contact h1 {
            text-shadow: 0 4px 20px rgba(0, 0, 0, 0.4), 0 1px 3px rgba(0, 0, 0, 0.3);
        }
        .hero-contact p {
            text-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
        }
        .hero-contact .breadcrumb-item a {
            text-shadow: 0 1px 4px rgba(0, 0, 0, 0.4);
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

        /* Department Cards */
        .dept-card {
            background: #fff;
            border: 1px solid var(--border-color);
            border-radius: 16px;
            padding: 2.5rem 2rem;
            height: 100%;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            z-index: 1;
        }
        .dept-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; width: 100%; height: 4px;
            background: linear-gradient(90deg, var(--primary), var(--accent));
            transform: scaleX(0);
            transform-origin: left;
            transition: transform 0.4s ease;
            z-index: 0;
        }
        .dept-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 24px 48px rgba(26, 107, 90, 0.12);
        }
        .dept-card:hover::before { transform: scaleX(1); }
        .dept-icon {
            width: 70px; height: 70px;
            background: linear-gradient(135deg, var(--accent-light), rgba(212, 168, 71, 0.15));
            color: var(--accent);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 2rem; margin-bottom: 1.5rem;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .dept-card:hover .dept-icon {
            background: var(--primary);
            color: #fff;
            transform: scale(1.1) rotate(-5deg);
            box-shadow: 0 8px 20px rgba(26, 107, 90, 0.3);
        }

        /* Floating Form Styles */
        .form-floating > .form-control,
        .form-floating > .form-select {
            border: 1px solid var(--border-color);
            border-radius: 10px;
            background-color: #fff;
        }
        .form-floating > .form-control:focus,
        .form-floating > .form-select:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 0.25rem rgba(212, 168, 71, 0.2);
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
            box-shadow: 0 6px 18px rgba(26, 107, 90, 0.25);
        }
        .btn-submit:hover {
            background: linear-gradient(135deg, var(--accent), #c49a3a);
            transform: translateY(-3px);
            box-shadow: 0 12px 30px rgba(212, 168, 71, 0.4);
            color: #111;
        }

        /* Form Card */
        .form-card {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            transition: all 0.3s ease;
        }
        .form-card:hover {
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.08) !important;
        }

        /* FAQ Accordion */
        .accordion-button:not(.collapsed) {
            color: var(--primary);
            background-color: var(--accent-light);
            box-shadow: none;
            font-weight: 500;
        }
        .accordion-button:focus { box-shadow: none; border-color: var(--border-color); }
        .accordion-item { border: 1px solid var(--border-color); border-radius: 10px !important; margin-bottom: 10px; overflow: hidden; }

        /* Map Card */
        .map-wrapper {
            border-radius: 20px;
            overflow: hidden;
            border: 1px solid var(--border-color);
            box-shadow: 0 15px 40px rgba(0,0,0,0.06);
            transition: all 0.4s ease;
        }
        .map-wrapper:hover {
            transform: translateY(-6px);
            box-shadow: 0 24px 50px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>

    <%@ include file="../layouts/navbar.jsp" %>

    <section class="hero-contact">
        <div class="container text-center text-white position-relative">
            <nav aria-label="breadcrumb">
                <div class="hero-breadcrumb mb-4">
                    <ol class="breadcrumb justify-content-center mb-0 small text-uppercase" style="letter-spacing: 2px;">
                        <li class="breadcrumb-item"><a href="<%=request.getContextPath()%>/index.jsp" class="text-white text-decoration-none" style="color: rgba(255,255,255,0.85) !important;">Trang chủ</a></li>
                        <li class="breadcrumb-item active" style="color: var(--accent);" aria-current="page">Liên hệ</li>
                    </ol>
                </div>
            </nav>
            <p class="text-uppercase fw-500 mb-3" style="font-size: 0.75rem; letter-spacing: 0.2em; color: var(--accent);">✦ Hỗ trợ khách hàng 24/7</p>
            <h1 class="font-display display-3 fw-normal mb-3">Tận Tâm & <em style="color: var(--accent);">Chuyên Nghiệp</em></h1>
            <p class="mx-auto" style="max-width: 700px; font-size: 1.15rem; line-height: 1.8; color: rgba(255,255,255,0.85);">
                Trải nghiệm chuẩn mực dịch vụ 5 sao bắt đầu ngay từ khoảnh khắc bạn liên hệ. Đội ngũ chuyên gia của OmniStay Cần Thơ luôn sẵn sàng thiết kế riêng kỳ nghỉ hoàn hảo cho bạn.
            </p>
        </div>
    </section>

    <section class="container" style="margin-top: -60px; position: relative; z-index: 10;">
        <div class="row g-4">
            <div class="col-lg-4 col-md-6">
                <div class="dept-card shadow-sm text-center text-md-start">
                    <div class="dept-icon mx-auto mx-md-0"><i class="bi bi-calendar2-check"></i></div>
                    <h4 class="font-display fw-bold mb-3 text-primary-theme">Lễ Tân & Đặt Phòng</h4>
                    <p class="text-muted mb-4 small">Tư vấn chọn hạng phòng, kiểm tra tình trạng trống và hỗ trợ các yêu cầu nhận/trả phòng đặc biệt.</p>
                    <ul class="list-unstyled mb-0 text-muted">
                        <li class="mb-2"><i class="bi bi-telephone-fill text-accent me-2"></i> +84 292 3888 999</li>
                        <li><i class="bi bi-envelope-fill text-accent me-2"></i> rsvn@omnistay.vn</li>
                    </ul>
                </div>
            </div>
            <div class="col-lg-4 col-md-6">
                <div class="dept-card shadow-sm text-center text-md-start">
                    <div class="dept-icon mx-auto mx-md-0"><i class="bi bi-balloon-heart"></i></div>
                    <h4 class="font-display fw-bold mb-3 text-primary-theme">Sự Kiện & Tiệc Cưới</h4>
                    <p class="text-muted mb-4 small">Lên kế hoạch tổ chức hội nghị doanh nghiệp, tiệc gala cuối năm hoặc lễ cưới lãng mạn bên sông Hậu.</p>
                    <ul class="list-unstyled mb-0 text-muted">
                        <li class="mb-2"><i class="bi bi-telephone-fill text-accent me-2"></i> +84 292 3888 888</li>
                        <li><i class="bi bi-envelope-fill text-accent me-2"></i> events@omnistay.vn</li>
                    </ul>
                </div>
            </div>
            <div class="col-lg-4 col-md-12">
                <div class="dept-card shadow-sm text-center text-md-start">
                    <div class="dept-icon mx-auto mx-md-0"><i class="bi bi-stars"></i></div>
                    <h4 class="font-display fw-bold mb-3 text-primary-theme">Dịch Vụ Concierge VIP</h4>
                    <p class="text-muted mb-4 small">Hỗ trợ đặt xe Limousine đưa đón sân bay, thiết kế tour tham quan Chợ Nổi Cái Răng và đặt bàn nhà hàng.</p>
                    <ul class="list-unstyled mb-0 text-muted">
                        <li class="mb-2"><i class="bi bi-whatsapp text-accent me-2"></i> 0901 234 567 (Zalo/WA)</li>
                        <li><i class="bi bi-clock-history text-accent me-2"></i> Hỗ trợ 24/7 liên tục</li>
                    </ul>
                </div>
            </div>
        </div>
    </section>

    <section class="py-5 mt-4">
        <div class="container">
            <div class="row g-5">
                
                <div class="col-lg-7">
                    <div class="form-card bg-white p-4 p-md-5 rounded-4 shadow-sm border" style="border-color: var(--border-color) !important;">
                        <h3 class="font-display mb-2 text-primary-theme">Gửi thông điệp cho chúng tôi</h3>
                        <p class="text-muted mb-4 pb-2 border-bottom">Mọi thông tin của quý khách đều được bảo mật tuyệt đối.</p>
                        
                        <% if ("success".equals(messageSent)) { %>
                            <div class="alert alert-success alert-dismissible fade show d-flex align-items-center" role="alert">
                                <i class="bi bi-check-circle-fill fs-4 me-3"></i>
                                <div><strong>Gửi thành công!</strong> Email xác nhận đã được gửi đến quý khách.</div>
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        <% } else if ("error".equals(messageSent)) { %>
                            <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center" role="alert">
                                <i class="bi bi-exclamation-triangle-fill fs-4 me-3"></i>
                                <div><strong>Gặp sự cố:</strong> <%= errorMessage %></div>
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        <% } %>

                        <form action="contact.jsp" method="POST">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <div class="form-floating">
                                        <input type="text" class="form-control" id="fullname" name="fullname" placeholder="Họ và tên" required>
                                        <label for="fullname">Họ và tên quý khách <span class="text-danger">*</span></label>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-floating">
                                        <input type="email" class="form-control" id="email" name="email" placeholder="Email" required>
                                        <label for="email">Địa chỉ Email <span class="text-danger">*</span></label>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-floating">
                                        <input type="tel" class="form-control" id="phone" name="phone" placeholder="SĐT">
                                        <label for="phone">Số điện thoại liên hệ</label>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-floating">
                                        <select class="form-select" id="subjectSelect" name="subjectSelect" required>
                                            <option value="Tư vấn Đặt phòng">Tư vấn Đặt phòng</option>
                                            <option value="Hỏi đáp Dịch vụ/Tiện ích">Hỏi đáp Dịch vụ/Tiện ích</option>
                                            <option value="Tổ chức Tiệc/Hội nghị">Tổ chức Tiệc/Hội nghị</option>
                                            <option value="Góp ý/Khác">Góp ý chất lượng dịch vụ</option>
                                        </select>
                                        <label for="subjectSelect">Chủ đề quan tâm <span class="text-danger">*</span></label>
                                    </div>
                                </div>
                                <div class="col-12">
                                    <div class="form-floating">
                                        <textarea class="form-control" id="message" name="message" placeholder="Nội dung" style="height: 120px" required></textarea>
                                        <label for="message">Nội dung chi tiết yêu cầu <span class="text-danger">*</span></label>
                                    </div>
                                </div>
                                <div class="col-12 mt-4 text-end">
                                    <button type="submit" class="btn btn-submit w-100 w-md-auto d-inline-flex align-items-center justify-content-center gap-2">
                                        <i class="bi bi-send"></i> Gửi Yêu Cầu
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <div class="col-lg-5">
                    <div class="h-100 d-flex flex-column">
                        <div class="mb-4">
                            <span class="badge bg-accent-light text-accent px-3 py-2 rounded-pill mb-2"><i class="bi bi-lightbulb me-1"></i> Thông tin nhanh</span>
                            <h3 class="font-display text-primary-theme">Câu hỏi thường gặp</h3>
                        </div>
                        
                        <div class="accordion" id="faqAccordion">
                            <div class="accordion-item">
                                <h2 class="accordion-header"><button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#faq1">Giờ nhận và trả phòng như thế nào?</button></h2>
                                <div id="faq1" class="accordion-collapse collapse show" data-bs-parent="#faqAccordion">
                                    <div class="accordion-body text-muted small">Giờ nhận phòng (Check-in) tiêu chuẩn là <strong>14:00</strong> và giờ trả phòng (Check-out) là <strong>12:00 trưa</strong>. Quý khách có thể gửi hành lý miễn phí tại lễ tân nếu đến sớm.</div>
                                </div>
                            </div>
                            <div class="accordion-item">
                                <h2 class="accordion-header"><button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq2">Khách sạn có dịch vụ đưa đón sân bay không?</button></h2>
                                <div id="faq2" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                    <div class="accordion-body text-muted small">Dạ có, OmniStay cung cấp xe Limousine cao cấp đưa đón sân bay Cần Thơ (cách 8km). Chi phí là 350.000₫/lượt. Vui lòng liên hệ bộ phận Concierge trước 12 tiếng.</div>
                                </div>
                            </div>
                            <div class="accordion-item">
                                <h2 class="accordion-header"><button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq3">Bãi đỗ xe có tính phí không?</button></h2>
                                <div id="faq3" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                    <div class="accordion-body text-muted small">Chúng tôi có bãi đỗ xe ngầm an ninh 24/7. Phí giữ xe qua đêm là 80.000₫/xe ô tô. Dịch vụ đỗ xe hộ (Valet Parking) được cung cấp hoàn toàn miễn phí tại sảnh chính.</div>
                                </div>
                            </div>
                        </div>

                        <div class="mt-auto pt-4">
                            <div class="p-4 bg-primary-theme text-white rounded-4 text-center">
                                <h5 class="font-display text-accent mb-2">Trợ lý ảo OmniAI</h5>
                                <p class="small opacity-75 mb-3">Trao đổi trực tiếp với AI để nhận câu trả lời ngay lập tức.</p>
                                <button class="btn btn-outline-light rounded-pill btn-sm px-4" onclick="toggleOmniChat()">Bắt đầu Chat <i class="bi bi-chat-dots ms-1"></i></button>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </section>

    <section class="py-5 mb-4" style="background-color: #fff; border-top: 1px solid var(--border-color);">
        <div class="container">
            <div class="row align-items-center g-5">
                <div class="col-lg-5 order-2 order-lg-1">
                    <h3 class="font-display mb-4 text-primary-theme">Hướng dẫn di chuyển</h3>
                    
                    <div class="d-flex mb-4">
                        <div class="me-3 mt-1"><i class="bi bi-airplane-engines fs-3 text-accent"></i></div>
                        <div>
                            <h6 class="fw-bold mb-1">Từ Sân bay Quốc tế Cần Thơ (VCA)</h6>
                            <p class="text-muted small mb-0">Khoảng cách 8 km. Thời gian di chuyển bằng ô tô khoảng 15-20 phút theo tuyến đường Võ Văn Kiệt -> Mậu Thân -> Hai Bà Trưng.</p>
                        </div>
                    </div>
                    
                    <div class="d-flex mb-4">
                        <div class="me-3 mt-1"><i class="bi bi-bus-front fs-3 text-accent"></i></div>
                        <div>
                            <h6 class="fw-bold mb-1">Từ Bến xe trung tâm Cần Thơ</h6>
                            <p class="text-muted small mb-0">Khoảng cách 3.5 km. Có thể di chuyển bằng Taxi (Mai Linh, Vinasun) hoặc xe buýt công cộng (Tuyến 01 dừng cách KS 200m).</p>
                        </div>
                    </div>
                    
                    <div class="d-flex">
                        <div class="me-3 mt-1"><i class="bi bi-water fs-3 text-accent"></i></div>
                        <div>
                            <h6 class="fw-bold mb-1">Đường thủy & Du thuyền</h6>
                            <p class="text-muted small mb-0">Khách sạn nằm ngay đối diện Bến Ninh Kiều. Khách hàng có du thuyền cá nhân có thể cập bến và đi bộ 1 phút tới sảnh chính.</p>
                        </div>
                    </div>
                </div>
                
                <div class="col-lg-7 order-1 order-lg-2">
                    <div class="map-wrapper p-2 bg-white">
                        <iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3928.813162451504!2d105.7882308!3d10.032271499999998!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x31a06298aae43e71%3A0xc6a64bdac582285d!2sNinh%20Kieu%20Wharf!5e0!3m2!1sen!2s!4v1775040122880!5m2!1sen!2s" width="100%" height="450" style="border:0; border-radius: 12px;" allowfullscreen="" loading="lazy"></iframe>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <%@ include file="../layouts/footer.jsp" %>
    <%@ include file="../layouts/chatbot.jsp" %>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
      // Navbar scroll
      window.addEventListener("scroll", function () {
        const navbar = document.querySelector(".navbar");
        if (navbar) {
          navbar.classList.toggle("navbar-scrolled", window.scrollY > 50);
        }
      });

      // Scroll-triggered fade-in animations
      const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            entry.target.classList.add('visible');
          }
        });
      }, { threshold: 0.1, rootMargin: '0px 0px -50px 0px' });

      document.querySelectorAll('.dept-card, .form-card, .accordion-item, .map-wrapper').forEach((el, i) => {
        el.classList.add('animate-fade-in');
        el.style.transitionDelay = (i * 0.08) + 's';
        observer.observe(el);
      });
    </script>
</body>
</html>