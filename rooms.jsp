<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.NumberFormat, java.util.Locale" %> 
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
    <title>Phòng & Suite — OmniStay Hotel</title>
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
      }
      .font-display {
        font-family: "Playfair Display", serif;
      }
      
      .page-header {
        background: linear-gradient(160deg, #0f3d33 0%, #1a6b5a 60%, #2d8c72 100%);
        padding: 8rem 0 4rem;
        position: relative;
      }
      .page-header::after {
        content: '';
        position: absolute;
        bottom: 0; left: 0; right: 0;
        height: 40px;
        background: var(--light-bg);
        border-radius: 40px 40px 0 0;
      }

      .room-img {
        height: 250px;
        object-fit: cover;
        transition: transform 0.6s ease;
      }
      .room-card:hover .room-img {
        transform: scale(1.05);
      }
      .filter-bar {
        background: #fff;
        border-radius: 16px;
        box-shadow: 0 12px 32px rgba(0,0,0,0.05);
        padding: 1.5rem;
        margin-top: -30px;
        position: relative;
        z-index: 10;
        border: 1px solid var(--border);
      }
    </style>
  </head>
  <body>
    <%@ include file="layouts/navbar.jsp" %>

    <section class="page-header text-center">
      <div class="container position-relative z-1">
        <p class="text-white-50 text-uppercase fw-500 mb-2" style="font-size: 0.75rem; letter-spacing: 0.2em">
          ✦ OmniStay Cần Thơ ✦
        </p>
        <h1 class="font-display fw-normal text-white mb-3" style="font-size: clamp(2rem, 4vw, 3.5rem)">
          Danh mục <em style="color: var(--accent)">Phòng & Suite</em>
        </h1>
        <p class="text-white-50 mx-auto" style="font-size: 0.95rem; max-width: 500px">
          Khám phá không gian lưu trú mang đậm dấu ấn nghệ thuật đương đại, nơi mọi chi tiết đều được chăm chút để mang đến trải nghiệm thượng lưu.
        </p>
      </div>
    </section>

    <section class="pb-5">
      <div class="container">
        
        <div class="filter-bar mb-5">
          <form class="row g-3 align-items-end" action="rooms.jsp" method="GET">
            <div class="col-md-3">
              <label class="form-label" style="font-size: 0.75rem; color: var(--primary); font-weight: 500; text-transform: uppercase; letter-spacing: 0.1em">Loại phòng</label>
              <select name="type" class="form-select border-0 bg-light">
                <option value="all">Tất cả các loại</option>
                <option value="standard">Standard</option>
                <option value="deluxe">Deluxe</option>
                <option value="suite">Suite cao cấp</option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="form-label" style="font-size: 0.75rem; color: var(--primary); font-weight: 500; text-transform: uppercase; letter-spacing: 0.1em">Sức chứa</label>
              <select name="occupancy" class="form-select border-0 bg-light">
                <option value="">Bất kỳ</option>
                <option value="2">2 Khách</option>
                <option value="4">Gia đình (4 Khách)</option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="form-label" style="font-size: 0.75rem; color: var(--primary); font-weight: 500; text-transform: uppercase; letter-spacing: 0.1em">Sắp xếp theo</label>
              <select name="sort" class="form-select border-0 bg-light">
                <option value="price_asc">Giá: Thấp đến Cao</option>
                <option value="price_desc">Giá: Cao đến Thấp</option>
                <option value="popular">Phổ biến nhất</option>
              </select>
            </div>
            <div class="col-md-2">
              <button type="submit" class="btn w-100 text-white" style="background: var(--primary); border-radius: 8px;">Lọc <i class="bi bi-funnel ms-1"></i></button>
            </div>
          </form>
        </div>

        <div class="row g-4">
          <%
            if(conn != null){
                try{
                    String SQL = "SELECT * FROM room_types";
                    PreparedStatement ps = conn.prepareStatement(SQL);
                    
                    ResultSet rs = ps.executeQuery();
                    
                    //Chạy vòng lặp in từng phòng
                    while(rs.next()){
                        int id = rs.getInt("id");
                        String typeName = rs.getString("type_name");
                        double price = rs.getDouble("base_price");
                        int people = rs.getInt("max_occupancy");
                        String des = rs.getString("description");
                        String imgURL = rs.getString("image_url");
                        
                        // Nếu DB chưa có hình -> Gán hình mặc định để không bị bể web
                        if(imgURL == null || imgURL.isEmpty()){
                            imgURL = "https://images.unsplash.com/photo-1590490360182-c33d57733427?w=600&q=80";
                        }
          %>
          
          <div class="col-md-6 col-lg-4">
            <div class="room-card card h-100 border-0 shadow-sm rounded-4 overflow-hidden bg-white">
              <div class="overflow-hidden position-relative">
                <img src="<%= imgURL %>" class="room-img w-100" alt="Room Image" />
                <div class="position-absolute top-0 end-0 p-3">
                    <span class="badge rounded-pill bg-white text-dark shadow-sm"><i class="bi bi-star-fill text-warning me-1"></i>4.9</span>
                </div>
              </div>
              
              <div class="card-body p-4 d-flex flex-column">
                <div>
                    <span class="badge rounded-pill mb-2" style="background: rgba(26, 107, 90, 0.1); color: var(--primary); font-size: 0.65rem; letter-spacing: 0.1em;">
                     <%= people >= 3 ? "LUXURY" : "EXCLUSIVE" %>
                    </span>
                    <h4 class="font-display fw-normal mb-2">
                      <%= typeName %>
                    </h4>
                    <p class="text-muted mb-3" style="font-size: 0.82rem; line-height: 1.6">
                      <%= des %>
                    </p>
                </div>
                
                <div class="mt-auto">
                    <div class="d-flex flex-wrap gap-2 mb-4">
                      <span class="badge rounded-pill bg-light text-secondary border fw-normal" style="font-size: 0.7rem"><i class="bi bi-people me-1"></i><%= people %> Khách</span>
                      <span class="badge rounded-pill bg-light text-secondary border fw-normal" style="font-size: 0.7rem"><i class="bi bi-aspect-ratio me-1"></i>45m²</span>
                      <span class="badge rounded-pill bg-light text-secondary border fw-normal" style="font-size: 0.7rem"><i class="bi bi-cup-hot me-1"></i>Bữa sáng</span>
                    </div>
                    
                    <div class="d-flex justify-content-between align-items-center pt-3 border-top" style="border-color: var(--border) !important;">
                      <div>
                        <span class="font-display" style="font-size: 1.25rem; color: var(--primary)"><%= nf.format(price).replace("VNĐ", "₫") %></span>
                        <span class="text-muted" style="font-size: 0.75rem">/đêm</span>
                      </div>
                      <a href="room-detail.jsp?id=<%= id %>" class="btn rounded-pill px-4 text-white" style="background: var(--primary); font-size: 0.8rem; font-weight: 500;">Xem Phòng</a>
                    </div>
                </div>
              </div>
            </div>
          </div>
          
          <%
                    } // Đóng vòng lặp while
                    rs.close();
                    ps.close();
                } catch(Exception e) { 
                    out.println("<div class='col-12'><p class='alert alert-danger'>Lỗi lấy dữ liệu: " + e.getMessage() + "</p></div>");
                }
            } else {
                out.println("<div class='col-12'><p class='alert alert-danger'>LỖI KẾT NỐI DATABASE: " + dbError + "</p></div>");
            }
          %>
        </div>

        <div class="d-flex justify-content-center mt-5 pt-3">
            <ul class="pagination">
                <li class="page-item disabled"><a class="page-link rounded-circle mx-1 border-0 text-muted" href="#" style="width: 40px; height: 40px; display: flex; align-items: center; justify-content: center;"><i class="bi bi-chevron-left"></i></a></li>
                <li class="page-item active"><a class="page-link rounded-circle mx-1 border-0 shadow-sm" href="#" style="width: 40px; height: 40px; display: flex; align-items: center; justify-content: center; background: var(--primary); color: white;">1</a></li>
                <li class="page-item"><a class="page-link rounded-circle mx-1 border-0 text-dark bg-white shadow-sm" href="#" style="width: 40px; height: 40px; display: flex; align-items: center; justify-content: center;">2</a></li>
                <li class="page-item"><a class="page-link rounded-circle mx-1 border-0 text-dark bg-white shadow-sm" href="#" style="width: 40px; height: 40px; display: flex; align-items: center; justify-content: center;"><i class="bi bi-chevron-right"></i></a></li>
            </ul>
        </div>
      </div>
    </section>

    <%@ include file="layouts/chatbot.jsp" %>
    <%@ include file="layouts/footer.jsp" %>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
      // Kế thừa Navbar scroll từ index.jsp
      window.addEventListener("scroll", function () {
        const navbar = document.querySelector(".navbar");
        if (navbar) {
          navbar.classList.toggle("navbar-scrolled", window.scrollY > 50);
        }
      });
    </script>
    <% 
        //Đóng connection ở đây
        if(conn != null) try { conn.close(); } catch(Exception e) {} 
    %>
  </body>
</html>