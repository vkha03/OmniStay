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
    
    // 1. KHAI BÁO CÁC BIẾN (Tên phải khớp với bên dưới HTML)
    String type_name = "";
    double price = 0;
    int maxOccupancy = 0;
    String typeId = request.getParameter("id");
    // GẮN LINK HÌNH CỨNG (Không cần lấy từ DB)
    String imgURL = "https://pix8.agoda.net/hotelImages/902/-1/9e98e4e28acb9561e2d69f0f7dd2c706.jpg?ce=0&s=1024x";

    // 2. CHẠY SQL LẤY THÔNG TIN LOẠI PHÒNG
    if(conn != null) {
        try {
            // Chỉ cần gọi bảng room_types là đủ thông tin cho Banner
            String sql1 = "SELECT * FROM room_types WHERE id = ?";
            PreparedStatement ps1 = conn.prepareStatement(sql1);
            ps1.setString(1, typeId);
            ResultSet rs1 = ps1.executeQuery();
            
            if(rs1.next()) {
                type_name = rs1.getString("type_name");
                price = rs1.getDouble("base_price");
                maxOccupancy = rs1.getInt("max_occupancy");
            }
            
            rs1.close();
            ps1.close();
        } catch(Exception e) {
            dbError = e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Chọn phòng <%= type_name %> — OmniStay</title>
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
        }
        body { font-family: "Outfit", sans-serif; font-weight: 300; color: #2c2c2c; background: var(--light-bg); overflow-x: hidden; }
        .font-display { font-family: "Playfair Display", serif; }

        /* ===================================================
           1. THÊM CSS CHO BANNER HÌNH ẢNH Ở TRÊN CÙNG
        ==================================================== */
        .page-header {
            background: linear-gradient(rgba(10, 40, 33, 0.75), rgba(10, 40, 33, 0.9)), url('<%= imgURL %>') center/cover no-repeat;
            padding: 10rem 0 4rem;
            border-bottom: 5px solid var(--accent);
        }

        /* 2. CỘT THÔNG TIN CỐ ĐỊNH BÊN TRÁI */
        .type-summary-card {
            background: #fff;
            border-radius: 20px;
            overflow: hidden;
            border: 1px solid var(--border);
            box-shadow: 0 15px 35px rgba(0,0,0,0.05);
            position: sticky;
            top: 100px; /* Đứng im khi cuộn chuột */
        }
        .type-summary-img { width: 100%; height: 220px; object-fit: cover; }

        /* 3. DANH SÁCH PHÒNG (DẢI NGANG) */
            .room-row-card {
            background: #fff;
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 1.2rem 1.5rem;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .room-row-card:hover {
            transform: translateX(8px);
            border-color: var(--accent);
            box-shadow: -5px 10px 25px rgba(0,0,0,0.05);
        }

        /* 4. TRẠNG THÁI VÀ NÚT BẤM */
        .status-dot { width: 10px; height: 10px; border-radius: 50%; display: inline-block; margin-right: 8px; }
        .dot-available { background-color: #198754; box-shadow: 0 0 8px rgba(25, 135, 84, 0.5); }
        .dot-occupied { background-color: #dc3545; }
        .dot-maintenance { background-color: #ffc107; }

        .btn-book { background: var(--primary); color: white; border-radius: 8px; font-weight: 500; padding: 0.6rem 1.5rem; transition: 0.3s; }
        .btn-book:hover { background: var(--primary-dark); color: white; transform: translateY(-2px); box-shadow: 0 5px 15px rgba(26,107,90,0.3); }
    </style>
</head>
<body>
    <%@ include file="../layouts/navbar.jsp" %>

    <header class="page-header text-center">
        <div class="container position-relative z-1">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb justify-content-center mb-3 small text-uppercase" style="letter-spacing: 2px;">
                    <li class="breadcrumb-item"><a href="rooms.jsp" class="text-white-50 text-decoration-none">Danh mục phòng</a></li>
                    <li class="breadcrumb-item active" style="color: var(--accent);"><%= type_name %></li>
                </ol>
            </nav>
            <h1 class="font-display text-white mb-2" style="font-size: 3.5rem;"><%= type_name %></h1>
            <p class="text-white-50 mb-0">Hạng phòng tuyển chọn dành cho bạn</p>
        </div>
    </header>

    <section class="py-5">
        <div class="container">
            <div class="row g-5">
                
                <div class="col-lg-4">
                    <div class="type-summary-card">
                        <img src="<%= imgURL %>" alt="<%= type_name %>" class="type-summary-img">
                        <div class="p-4">
                            <span class="badge bg-light text-dark border mb-3">Thông tin hạng phòng</span>
                            <h3 class="font-display fw-normal" style="color: var(--primary);"><%= type_name %></h3>
                            <div class="d-flex align-items-center gap-3 text-muted mb-4 pb-3 border-bottom">
                                <span><i class="bi bi-people me-1"></i> Tối đa <%= maxOccupancy %> khách</span>
                                <span><i class="bi bi-aspect-ratio me-1"></i> 55 m²</span>
                            </div>
                            <div class="text-muted small text-uppercase mb-1" style="letter-spacing: 1px;">Giá niêm yết từ</div>
                            <h2 class="font-display mb-0" style="color: var(--accent);">
                                <%= nf.format(price).replace("VNĐ", "₫") %> <span class="text-muted fs-6">/ đêm</span>
                            </h2>
                        </div>
                    </div>
                </div>

                <div class="col-lg-8">
                    <div class="d-flex justify-content-between align-items-end mb-4">
                        <div>
                            <h4 class="font-display mb-1" style="color: var(--primary);">Danh sách phòng trống</h4>
                            <p class="text-muted small mb-0">Vui lòng chọn một số phòng cụ thể để tiếp tục đặt phòng.</p>
                        </div>
                        <div class="bg-white px-3 py-2 border rounded-pill small text-muted shadow-sm">
                            <span class="me-3"><span class="status-dot dot-available"></span>Sẵn sàng</span>
                            <span class="me-3"><span class="status-dot dot-occupied"></span>Đang có khách</span>
                            <span><span class="status-dot dot-maintenance"></span>Bảo trì</span>
                        </div>
                    </div>

                    <div class="d-flex flex-column gap-3">
                        <%
                            String sql2 = "SELECT * FROM rooms WHERE room_type_id = ? ORDER BY room_number ASC ";
                         	PreparedStatement ps2 = conn.prepareStatement(sql2);
                         	ps2.setString(1,typeId);
                         	ResultSet rs2 = ps2.executeQuery();
                         	while(rs2.next()){
                         	   int roomNB = rs2.getInt("room_number");
                         	   String status = rs2.getString("status");
                        %>
                        
                        <div class="room-row-card <%= !status.equals("AVAILABLE") ? "bg-light opacity-75" : "" %>">
                            
                            <div class="d-flex align-items-center gap-4">
                                <div class="text-center rounded-3 p-3" style="background-color: <%= status.equals("AVAILABLE") ? "rgba(212, 168, 71, 0.1)" : "#e9ecef" %>; min-width: 90px;">
                                    <i class="bi bi-key-fill d-block mb-1" style="font-size: 1.2rem; color: <%= status.equals("AVAILABLE") ? "var(--accent)" : "#adb5bd" %>;"></i>
                                    <h4 class="font-display mb-0" style="color: var(--primary);"><%= roomNB %></h4>
                                </div>
                                
                                <div>
                                    <div class="fw-500 mb-1 fs-5">Phòng số <%= roomNB %></div>
                                    <% if(status.equals("AVAILABLE")) { %>
                                        <div class="text-success small fw-500"><span class="status-dot dot-available"></span> Sẵn sàng</div>
                                    <% } else if(status.equals("OCCUPIED")) { %>
                                        <div class="text-danger small fw-500"><span class="status-dot dot-occupied"></span> Đang có khách</div>
                                    <% } else { %>
                                        <div class="text-warning small fw-500"><span class="status-dot dot-maintenance"></span> Bảo trì</div>
                                    <% } %>
                                </div>
                            </div>
                            
                            <div>
                                <% if(status.equals("AVAILABLE")) { %>
                                    <a href="booking.jsp?room_id=<%= roomNB %>" class="btn btn-book">
                                        Chọn phòng <i class="bi bi-arrow-right ms-1"></i>
                                    </a>
                                <% } else { %>
                                    <button class="btn btn-secondary border-0" style="background: #e9ecef; color: #adb5bd; cursor: not-allowed;" disabled>
                                        Không khả dụng
                                    </button>
                                <% } %>
                            </div>

                        </div>
                        
                        <%  
                        }
                         ps2.close();
                         rs2.close();
                         conn.close();
                        %>
                    </div>

                </div>
            </div>
        </div>
    </section>

    <%@ include file="../layouts/chatbot.jsp" %>
    <%@ include file="../layouts/footer.jsp" %>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>