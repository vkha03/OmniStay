<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.NumberFormat" %>
<%@ include file="../env-secrets.jsp" %>
<%-- ==========================================================================
     TRANG BỘ LỌC VÀ DANH SÁCH PHÒNG (ROOMS CATALOG & FILTERING)
     Cung cấp giao diện trực quan cho phép khách hàng tra cứu, lọc và sắp xếp
     các loại phòng theo nhiều tiêu chí (Loại phòng, Sức chứa, Giá cả).
     Hỗ trợ truy vấn SQL động an toàn để tối ưu hóa kết quả trả về.
     ========================================================================== --%>
<%
    // 1. KHỞI TẠO KẾT NỐI VÀ XỬ LÝ LỖI (CONNECTION SETUP)
    Connection conn = null;
    String dbError = null;
    try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(SECRET_DB_URL, SECRET_DB_USER, SECRET_DB_PASS);
    }catch(Exception e){
        dbError = e.getMessage();
    }
    
    // 2. NHẬN CÁC THAM SỐ LỌC TỪ QUERY STRING (EXTRACT FILTER PARAMETERS)
    // Lấy tiêu chí loại phòng (VD: Standard, Deluxe, Premium)
    String filterType = request.getParameter("type");
    if(filterType == null) filterType = "all"; // Mặc định là hiển thị tất cả
    
    // Lấy tiêu chí số lượng khách tối thiểu
    String filterOccupancy = request.getParameter("occupancy");
    if(filterOccupancy == null) filterOccupancy = "";
    
    // Lấy tiêu chí sắp xếp (Giá tăng dần, giảm dần, độ phổ biến)
    String filterSort = request.getParameter("sort");
    if(filterSort == null) filterSort = "price_asc";
    
    // Bộ định dạng số tiền bản địa hóa (Việt Nam Đồng)
    NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
%>
<%!
    // 3. HÀM CHUYỂN ĐỔI NGÔN NGỮ LOẠI PHÒNG (ROOM TYPE TRANSLATION HELPER)
    // Thay thế cách viết Lambda (tránh lỗi tương thích trình biên dịch cũ trên Tomcat)
    // Chuyển đổi mã loại phòng sang tên tiếng Việt tường minh cho khách hàng dễ đọc
    private String translateType(String type) {
        if(type == null) return "Chưa xác định";
        // Chuẩn hóa chuỗi (xóa khoảng trắng thừa và viết hoa toàn bộ để so sánh chính xác)
        String t = type.trim().toUpperCase();
        if("STANDARD".equals(t)) return "Tiêu chuẩn (Standard)";
        if("DELUXE".equals(t)) return "Sang trọng (Deluxe)";
        if("PREMIUM".equals(t)) return "Cao cấp (Premium)";
        // Trả về chuỗi gốc nếu không khớp các mẫu định sẵn
        return type;
    }
%>
<!DOCTYPE html>
<html lang="vi">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Phòng & Suite — OmniStay Hotel</title>
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
      .font-display {
        font-family: "Playfair Display", serif;
      }

      /* ── ANIMATIONS ── */
      @keyframes fadeInUp {
        from { opacity: 0; transform: translateY(40px); }
        to { opacity: 1; transform: translateY(0); }
      }
      .animate-fade-in {
        opacity: 0;
        transform: translateY(40px);
        transition: all 0.8s cubic-bezier(0.16, 1, 0.3, 1);
      }
      .animate-fade-in.visible {
        opacity: 1;
        transform: translateY(0);
      }

      /* ── HERO HEADER ── */
      .page-header {
        background: linear-gradient(
          160deg,
          rgba(10, 40, 33, 0.90) 0%,
          rgba(20, 85, 70, 0.78) 50%,
          rgba(30, 110, 90, 0.68) 100%
        ), url('<%=request.getContextPath()%>/images/hero/hotel-room-hero.jpg') center/cover no-repeat;
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

      /* ── ROOM CARDS ── */
      .room-img {
        height: 250px;
        object-fit: cover;
        transition: transform 0.6s cubic-bezier(0.4, 0, 0.2, 1);
      }
      .room-card {
        transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        position: relative;
        overflow: hidden;
      }
      .room-card::before {
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
      .room-card:hover {
        transform: translateY(-10px);
        box-shadow: 0 24px 48px rgba(26, 107, 90, 0.15) !important;
      }
      .room-card:hover::before {
        transform: scaleX(1);
      }
      .room-card:hover .room-img {
        transform: scale(1.08);
      }
      .room-card .btn {
        transition: all 0.3s ease;
      }
      .room-card:hover .btn {
        background: var(--accent) !important;
        color: #111 !important;
        box-shadow: 0 4px 15px rgba(212, 168, 71, 0.35);
      }

      /* ── FILTER BAR ── */
      .filter-bar {
        background: rgba(255, 255, 255, 0.9);
        backdrop-filter: blur(16px);
        -webkit-backdrop-filter: blur(16px);
        border-radius: 20px;
        box-shadow: 0 16px 48px rgba(0,0,0,0.08);
        padding: 2rem;
        margin-top: -40px;
        position: relative;
        z-index: 10;
        border: 1px solid rgba(255, 255, 255, 0.6);
      }
      .filter-bar .form-select {
        border: 1.5px solid var(--border) !important;
        border-radius: 10px !important;
        padding: 0.6rem 0.9rem;
        background-color: #fff !important;
        transition: border-color 0.3s;
      }
      .filter-bar .form-select:focus {
        border-color: var(--accent) !important;
        box-shadow: 0 0 0 3px rgba(212, 168, 71, 0.15) !important;
      }
      .filter-bar .btn {
        border-radius: 12px !important;
        padding: 0.65rem 1.2rem;
        font-weight: 500;
        transition: all 0.3s;
      }
      .filter-bar .btn:hover {
        background: var(--primary-dark) !important;
        transform: translateY(-2px);
        box-shadow: 0 6px 18px rgba(26, 107, 90, 0.3);
      }

      /* ── PAGINATION ── */
      .pagination .page-link {
        transition: all 0.3s ease;
      }
      .pagination .page-item:not(.active):not(.disabled) .page-link:hover {
        background: var(--primary) !important;
        color: white !important;
        transform: scale(1.1);
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
              <li class="breadcrumb-item active" style="color: var(--accent);" aria-current="page">Phòng & Suite</li>
            </ol>
          </div>
        </nav>
        <p class="text-uppercase fw-500 mb-3" style="font-size: 0.75rem; letter-spacing: 0.2em; color: var(--accent);">
          ✦ OmniStay Cần Thơ ✦
        </p>
        <h1 class="font-display fw-normal text-white mb-3" style="font-size: clamp(2rem, 4vw, 3.5rem)">
          Danh mục <em style="color: var(--accent)">Phòng & Suite</em>
        </h1>
        <p class="mx-auto" style="font-size: 0.95rem; max-width: 520px; color: rgba(255,255,255,0.85);">
          Khám phá không gian lưu trú mang đậm dấu ấn nghệ thuật đương đại, nơi mọi chi tiết đều được chăm chút để mang đến trải nghiệm thượng lưu.
        </p>
      </div>
    </section>

    <section class="pb-5">
      <div class="container">
        
        <div class="filter-bar mb-5">
          <form class="row g-3 align-items-end" action="rooms.jsp" method="GET">
            <div class="col-md-3">
              <label class="form-label" style="font-size: 0.72rem; color: var(--accent); font-weight: 600; text-transform: uppercase; letter-spacing: 0.15em">Loại phòng</label>
              <select name="type" class="form-select">
                <option value="all" <%= filterType.equals("all") ? "selected" : "" %>>Tất cả các loại</option>
                <%
                    // 4. TRUY VẤN NẠP BỘ LỌC LOẠI PHÒNG (POPULATE FILTER OPTIONS)
                    // Tự động lấy danh sách tên loại phòng từ cơ sở dữ liệu
                    if(conn != null) {
                        try {
                            PreparedStatement pst = conn.prepareStatement("SELECT type_name FROM room_types ORDER BY id ASC");
                            ResultSet rst = pst.executeQuery();
                            while(rst.next()) {
                                String tName = rst.getString("type_name");
                                // So sánh không phân biệt hoa thường để giữ trạng thái đã chọn (selected)
                                String selected = filterType.equalsIgnoreCase(tName) ? "selected" : "";
                                out.print("<option value='" + tName + "' " + selected + ">" + tName + "</option>");
                            }
                            rst.close(); pst.close();
                        } catch(Exception e) {
                            // Bỏ qua lỗi ngầm định để không làm gián đoạn form lọc
                        }
                    }
                %>
              </select>
            </div>
            <div class="col-md-3">
              <label class="form-label" style="font-size: 0.72rem; color: var(--accent); font-weight: 600; text-transform: uppercase; letter-spacing: 0.15em">Sức chứa</label>
              <select name="occupancy" class="form-select">
                <option value="" <%= filterOccupancy.equals("") ? "selected" : "" %>>Bất kỳ</option>
                <option value="2" <%= filterOccupancy.equals("2") ? "selected" : "" %>>2 Khách</option>
                <option value="4" <%= filterOccupancy.equals("4") ? "selected" : "" %>>Gia đình (4 Khách)</option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="form-label" style="font-size: 0.72rem; color: var(--accent); font-weight: 600; text-transform: uppercase; letter-spacing: 0.15em">Sắp xếp theo</label>
              <select name="sort" class="form-select">
                <option value="price_asc" <%= filterSort.equals("price_asc") ? "selected" : "" %>>Giá: Thấp đến Cao</option>
                <option value="price_desc" <%= filterSort.equals("price_desc") ? "selected" : "" %>>Giá: Cao đến Thấp</option>
                <option value="popular" <%= filterSort.equals("popular") ? "selected" : "" %>>Phổ biến nhất</option>
              </select>
            </div>
            <div class="col-md-2">
              <button type="submit" class="btn w-100 text-white" style="background: var(--primary);">Lọc <i class="bi bi-funnel ms-1"></i></button>
            </div>
          </form>
        </div>

        <div class="row g-4">
          <%
            // 5. TRUY VẤN VÀ RENDER DANH SÁCH LOẠI PHÒNG KÈM BỘ LỌC (RENDER DYNAMIC CATALOG)
            if(conn != null){
                try{
                    // Sử dụng StringBuilder để cộng chuỗi SQL động tối ưu bộ nhớ
                    // Mệnh đề WHERE 1=1 giúp việc append các điều kiện AND phía sau dễ dàng hơn
                    StringBuilder sqlBuilder = new StringBuilder("SELECT * FROM room_types WHERE 1=1");
                    List<Object> params = new ArrayList<>();
                    
                    // Nạp điều kiện lọc theo Tên loại phòng nếu người dùng chọn cụ thể
                    if(!filterType.equals("all")) {
                        sqlBuilder.append(" AND type_name LIKE ?");
                        params.add("%" + filterType + "%");
                    }
                    
                    // Nạp điều kiện lọc theo sức chứa tối thiểu
                    if(!filterOccupancy.isEmpty()) {
                        sqlBuilder.append(" AND max_occupancy >= ?");
                        params.add(Integer.parseInt(filterOccupancy));
                    }
                    
                    // Áp dụng tiêu chí sắp xếp (ORDER BY) theo yêu cầu
                    if(filterSort.equals("price_asc")) {
                        sqlBuilder.append(" ORDER BY base_price ASC");
                    } else if(filterSort.equals("price_desc")) {
                        sqlBuilder.append(" ORDER BY base_price DESC");
                    } else {
                        sqlBuilder.append(" ORDER BY id DESC");
                    }
                    
                    // Khởi tạo PreparedStatement để tránh hoàn toàn rủi ro SQL Injection
                    PreparedStatement ps = conn.prepareStatement(sqlBuilder.toString());
                    for(int i=0; i<params.size(); i++) {
                        ps.setObject(i+1, params.get(i));
                    }
                    
                    ResultSet rs = ps.executeQuery();
                    // Cờ theo dõi xem bộ lọc có trả về kết quả nào hay không
                    boolean hasResults = false;
                    
                    // Duyệt tuần tự qua các hạng phòng khớp điều kiện
                    while(rs.next()){
                        hasResults = true;
                        int id = rs.getInt("id");
                        String typeName = rs.getString("type_name");
                        double price = rs.getDouble("base_price");
                        int people = rs.getInt("max_occupancy");
                        String des = rs.getString("description");
                        String imgURL = rs.getString("image_url");
                        
                        // Sử dụng ảnh mặc định sang trọng nếu CSDL thiếu đường dẫn ảnh
                        if(imgURL == null || imgURL.isEmpty()){
                            imgURL = request.getContextPath() + "/images/hero/hotel-room-hero.jpg";
                        }
          %>
          
          <div class="col-md-6 col-lg-3">
            <div class="room-card card h-100 border-0 shadow-sm rounded-4 overflow-hidden bg-white">
              <div class="overflow-hidden position-relative">
                <img src="<%= imgURL %>" class="room-img w-100" alt="Room Image" />
                <div class="position-absolute top-0 end-0 p-3">
                    <span class="badge rounded-pill bg-white text-dark shadow-sm" style="backdrop-filter: blur(8px); background: rgba(255,255,255,0.9) !important;"><i class="bi bi-star-fill text-warning me-1"></i>4.9</span>
                </div>
              </div>
              
              <div class="card-body p-4 d-flex flex-column">
                <div>
                    <h5 class="font-display fw-normal mb-2"><%= translateType(typeName) %></h5>

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
                        <span class="font-display" style="font-size: 1.35rem; color: var(--primary); line-height: 1">
                            <%= nf.format(price).replace("VNĐ", "₫") %>
                        </span>
                        <span class="text-muted" style="font-size: 0.75rem">/đêm</span>
                      </div>
                      <a href="room-detail.jsp?id=<%= id %>" class="btn rounded-pill px-4 text-white" style="background: var(--primary); font-size: 0.8rem; font-weight: 500;">Xem Phòng</a>
                    </div>
                </div>
              </div>
            </div>
          </div>
          
          <%
                    } // Kết thúc lặp thẻ phòng
                    
                    // Nếu bộ lọc quá khắt khe khiến tập kết quả trống, hiển thị trạng thái Empty State
                    if(!hasResults) {
                        out.println("<div class='col-12 text-center py-5'><div class='p-5 bg-white rounded-4 shadow-sm'><i class='bi bi-search mb-3' style='font-size: 3rem; color: var(--border)'></i><h4 class='font-display'>Không tìm thấy phòng phù hợp</h4><p class='text-muted'>Vui lòng thử lại với các tiêu chí lọc khác.</p><a href='rooms.jsp' class='btn btn-outline-primary rounded-pill mt-3'>Xem tất cả phòng</a></div></div>");
                    }
                    rs.close();
                    ps.close();
                } catch(Exception e) { 
                    // Ghi nhận lỗi thực thi câu truy vấn
                    out.println("<div class='col-12'><p class='alert alert-danger'>Lỗi lấy dữ liệu: " + e.getMessage() + "</p></div>");
                }
            } else {
                // Hiển thị cảnh báo mất kết nối nếu conn == null
                out.println("<div class='col-12'><p class='alert alert-danger'>LỖI KẾT NỐI DATABASE: " + dbError + "</p></div>");
            }
          %>
        </div>
      </div>
    </section>

    <%@ include file="../layouts/chatbot.jsp" %>
    <%@ include file="../layouts/footer.jsp" %>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <% 
        // 6. GIẢI PHÓNG TÀI NGUYÊN (RESOURCE CLEANUP)
        // Đóng Connection để hoàn trả lại cho hệ thống quản lý, tránh tràn bộ nhớ
        if(conn != null) try { conn.close(); } catch(Exception e) {} 
    %>
  </body>
</html>
