<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<%@ include file="../env-secrets.jsp" %>
<%
    Connection conn = null;
    String dbError = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(SECRET_DB_URL, SECRET_DB_USER, SECRET_DB_PASS);
    } catch(Exception e) {
        dbError = e.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đánh giá khách hàng — OmniStay Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;1,400&family=Outfit:wght@300;400;500&display=swap" rel="stylesheet">
    
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
      .font-display {
        font-family: "Playfair Display", serif;
      }

      /* ── HERO HEADER ── */
      .page-header {
        background: linear-gradient(
          160deg,
          rgba(10, 40, 33, 0.90) 0%,
          rgba(20, 85, 70, 0.78) 50%,
          rgba(30, 110, 90, 0.68) 100%
        ), url('https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&q=80&w=2070') center/cover no-repeat;
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
      .page-header h1 {
        text-shadow: 0 4px 20px rgba(0, 0, 0, 0.4), 0 1px 3px rgba(0, 0, 0, 0.3);
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

      /* ── REVIEW CARDS ── */
      .review-card {
        background: white;
        border: none;
        border-radius: 20px;
        padding: 2.5rem;
        box-shadow: 0 10px 30px rgba(0,0,0,0.03);
        transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        height: 100%;
        position: relative;
        overflow: hidden;
      }
      .review-card::before {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0;
        height: 4px;
        background: linear-gradient(90deg, var(--primary), var(--accent));
        transform: scaleX(0);
        transition: transform 0.4s ease;
        transform-origin: left;
      }
      .review-card:hover {
        transform: translateY(-10px);
        box-shadow: 0 24px 48px rgba(26, 107, 90, 0.12) !important;
      }
      .review-card:hover::before {
        transform: scaleX(1);
      }
      .quote-icon {
        position: absolute;
        top: 2rem;
        right: 2rem;
        font-size: 3rem;
        color: rgba(26, 107, 90, 0.05);
      }
      .rating-stars { color: var(--accent); font-size: 0.9rem; margin-bottom: 1rem; }
      .review-text { font-style: italic; line-height: 1.8; color: #5d6d7e; margin-bottom: 1.5rem; font-size: 1.05rem; }
      .reviewer-info { display: flex; align-items: center; gap: 1rem; }
      .reviewer-avatar {
        width: 50px; height: 50px;
        background: var(--primary);
        color: white;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 600;
        font-size: 1.2rem;
      }
      .reviewer-name { font-weight: 600; color: var(--primary); margin-bottom: 0; }
      .review-date { font-size: 0.8rem; color: #abb2b9; }

      .btn-primary-custom {
        background: var(--primary);
        border: none;
        padding: 1rem 2.5rem;
        border-radius: 50px;
        font-weight: 500;
        transition: 0.3s;
        color: white;
        text-decoration: none;
        display: inline-block;
      }
      .btn-primary-custom:hover { background: var(--primary-dark); transform: scale(1.05); color: white; }
    </style>
</head>
<body>
    <%@ include file="../layouts/navbar.jsp" %>

    <section class="page-header text-center">
      <div class="container position-relative z-1">
        <nav aria-label="breadcrumb">
          <div class="hero-breadcrumb mb-4">
            <ol class="breadcrumb justify-content-center mb-0 small text-uppercase" style="letter-spacing: 2px;">
              <li class="breadcrumb-item"><a href="<%=request.getContextPath()%>/index.jsp" class="text-white text-decoration-none" style="color: rgba(255,255,255,0.85) !important;">Trang chủ</a></li>
              <li class="breadcrumb-item active" style="color: var(--accent);" aria-current="page">Đánh giá</li>
            </ol>
          </div>
        </nav>
        <p class="text-uppercase fw-500 mb-3" style="font-size: 0.75rem; letter-spacing: 0.2em; color: var(--accent);">
          ✦ OmniStay Experience ✦
        </p>
        <h1 class="font-display fw-normal text-white mb-3" style="font-size: clamp(2rem, 4vw, 3.5rem)">
          Trải nghiệm <em style="color: var(--accent)">Khách hàng</em>
        </h1>
        <p class="mx-auto" style="font-size: 0.95rem; max-width: 520px; color: rgba(255,255,255,0.85);">
          Những chia sẻ chân thực từ những vị khách đã ghé thăm và trải nghiệm dịch vụ tại OmniStay Cần Thơ.
        </p>
      </div>
    </section>

    <section class="py-5">
        <div class="container py-4">
            <div class="row g-4">
                <%
                    if(conn != null){
                        try {
                            String sql = "SELECT r.*, g.full_name FROM reviews r JOIN guests g ON r.guest_id = g.id WHERE r.status = 1 ORDER BY r.created_at DESC";
                            Statement st = conn.createStatement();
                            ResultSet rs = st.executeQuery(sql);
                            
                            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
                            boolean hasReviews = false;
                            
                            while(rs.next()) {
                                hasReviews = true;
                                String name = rs.getString("full_name");
                                int rating = rs.getInt("rating");
                                String comment = rs.getString("comment");
                                Timestamp date = rs.getTimestamp("created_at");
                                String initial = name.substring(0, 1).toUpperCase();
                %>
                <div class="col-lg-4 col-md-6">
                    <div class="review-card shadow-sm">
                        <i class="bi bi-quote quote-icon"></i>
                        <div class="rating-stars">
                            <% for(int i=0; i<5; i++) { %>
                                <i class="bi <%= (i < rating) ? "bi-star-fill" : "bi-star" %>"></i>
                            <% } %>
                        </div>
                        <p class="review-text">"<%= comment %>"</p>
                        <div class="reviewer-info">
                            <div class="reviewer-avatar"><%= initial %></div>
                            <div>
                                <h6 class="reviewer-name"><%= name %></h6>
                                <span class="review-date"><%= sdf.format(date) %></span>
                            </div>
                        </div>
                    </div>
                </div>
                <% 
                            }
                            if (!hasReviews) {
                                out.println("<div class='col-12 text-center py-5'><p class='text-muted'>Chưa có đánh giá nào được hiển thị. Hãy là người đầu tiên chia sẻ trải nghiệm!</p></div>");
                            }
                            rs.close(); st.close();
                        } catch(Exception e) {
                            out.println("<div class='col-12 alert alert-danger'>Lỗi kết nối: " + e.getMessage() + "</div>");
                        }
                    } else {
                        out.println("<div class='col-12 alert alert-danger'>Lỗi kết nối database: " + dbError + "</div>");
                    }
                %>
            </div>

            <div class="text-center mt-5 pt-4">
                <h4 class="font-display mb-4">Bạn đã từng ở OmniStay?</h4>
                <p class="text-muted mb-4">Mọi phản hồi của bạn đều giúp chúng tôi hoàn thiện dịch vụ tốt hơn mỗi ngày.</p>
                <a href="contact.jsp" class="btn btn-primary-custom shadow-lg">Gửi đánh giá của bạn</a>
            </div>
        </div>
    </section>

    <%@ include file="../layouts/chatbot.jsp" %>
    <%@ include file="../layouts/footer.jsp" %>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <% if(conn != null) try { conn.close(); } catch(Exception e) {} %>
</body>
</html>
