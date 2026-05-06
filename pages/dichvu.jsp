<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.NumberFormat" %>
<%
    Connection conn = null;
    String dbError = null;
    try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/omnistay", "root", "");
    }catch(Exception e){
        dbError = e.getMessage();
    }
    NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
%>
<!DOCTYPE html>
<html lang="vi">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Dịch vụ — OmniStay Hotel</title>
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
        ), url('https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=1600&q=80') center/cover no-repeat;
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

      /* ── SERVICE CARDS ── */
      .service-card {
        transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        position: relative;
        overflow: hidden;
        border-radius: 16px;
      }
      .service-card::before {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0;
        height: 4px;
        background: linear-gradient(90deg, var(--primary), var(--accent));
        transform: scaleX(0);
        transition: transform 0.4s ease;
        transform-origin: left;
        z-index: 2;
      }
      .service-card:hover {
        transform: translateY(-10px);
        box-shadow: 0 24px 48px rgba(26, 107, 90, 0.15) !important;
      }
      .service-card:hover::before {
        transform: scaleX(1);
      }
      .icon-wrapper {
        width: 80px;
        height: 80px;
        border-radius: 50%;
        background: rgba(26, 107, 90, 0.05);
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 1.5rem;
        transition: all 0.4s ease;
      }
      .service-card:hover .icon-wrapper {
        background: var(--primary);
        color: white !important;
        transform: scale(1.1);
      }
      .service-card:hover .icon-wrapper i {
        color: white !important;
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
              <li class="breadcrumb-item"><a href="<%=request.getContextPath()%>/index.jsp" class="text-white text-decoration-none" style="color: rgba(255,255,255,0.85) !important;">Trang chủ</a></li>
              <li class="breadcrumb-item active" style="color: var(--accent);" aria-current="page">Dịch vụ</li>
            </ol>
          </div>
        </nav>
        <p class="text-uppercase fw-500 mb-3" style="font-size: 0.75rem; letter-spacing: 0.2em; color: var(--accent);">
          ✦ OmniStay Cần Thơ ✦
        </p>
        <h1 class="font-display fw-normal text-white mb-3" style="font-size: clamp(2rem, 4vw, 3.5rem)">
          Dịch vụ <em style="color: var(--accent)">Khách sạn</em>
        </h1>
        <p class="mx-auto" style="font-size: 0.95rem; max-width: 520px; color: rgba(255,255,255,0.85);">
          Trải nghiệm hệ thống dịch vụ chuẩn mực quốc tế, được kiến tạo dành riêng cho những kỳ nghỉ hoàn hảo tại OmniStay.
        </p>
      </div>
    </section>

    <section class="pb-5 pt-5">
      <div class="container">
        <div class="row g-4">
          <%
            if(conn != null){
                try{
                    String sql = "SELECT * FROM services";
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery();
                    
                    String[] icons = {"bi-stars", "bi-cup-hot", "bi-car-front", "bi-bicycle", "bi-wifi", "bi-tv", "bi-telephone", "bi-magic"};
                    int iconIndex = 0;

                    while(rs.next()){
                        int id = rs.getInt("id");

                        // ⚠️ CHỈNH ĐÚNG TÊN CỘT (tránh lỗi của bạn)
                        String name = rs.getString("service_name");
                        String des  = rs.getString("unit"); 
                        double price = rs.getDouble("price");

                        if(des == null || des.trim().isEmpty()){
                            des = "Trải nghiệm dịch vụ cao cấp tại OmniStay với chất lượng phục vụ 5 sao.";
                        }
                        
                        String icon = icons[iconIndex % icons.length];
                        iconIndex++;
          %>
          
          <div class="col-md-6 col-lg-4">
            <div class="card service-card h-100 border-0 shadow-sm p-4 text-center bg-white">
              <div class="icon-wrapper">
                <i class="bi <%= icon %>" style="font-size: 32px; color: var(--accent);"></i>
              </div>
              
              <h5 class="font-display fw-normal mb-3"><%= name %></h5>
              
              <p class="text-muted mb-4" style="font-size: 0.9rem; line-height: 1.6;">
                <%= des %>
              </p>
              
              <div class="mt-auto pt-4 border-top" style="border-color: var(--border) !important;">
                <span class="font-display" style="font-size: 1.4rem; color: var(--primary); font-weight: 500;">
                  <%= nf.format(price).replace("VNĐ","₫") %>
                </span>
              </div>
            </div>
          </div>
          
          <%
                    }
                    rs.close();
                    ps.close();
                }catch(Exception e){
                    out.println("<div class='col-12'><p class='alert alert-danger'>Lỗi: " + e.getMessage() + "</p></div>");
                }
            }else{
                out.println("<div class='col-12'><p class='alert alert-danger'>Lỗi kết nối DB: " + dbError + "</p></div>");
            }
          %>
        </div>
      </div>
    </section>

    <%@ include file="../layouts/chatbot.jsp" %>
    <%@ include file="../layouts/footer.jsp" %>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <% 
        if(conn != null) try { conn.close(); } catch(Exception e) {} 
    %>
  </body>
</html>