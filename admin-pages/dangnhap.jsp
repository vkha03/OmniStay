<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
    <%@ page import="java.sql.*, java.util.*, java.text.NumberFormat" %>
        <%
    // ===== KIỂM TRA ĐÃ ĐĂNG NHẬP =====
    if (session.getAttribute("admin") != null && request.getParameter("action") == null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    // ===== XỬ LÝ LOGOUT =====
    if(request.getParameter("action") != null && request.getParameter("action").equals("logout")){
        session.invalidate();
        response.sendRedirect("dangnhap.jsp");
        return;
    }

    // ===== XỬ LÝ LOGIN =====

       if(request.getMethod().equalsIgnoreCase("POST")){
        String user = request.getParameter("username"); // email
        String pass = request.getParameter("password");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/omnistay",
                "root",
                "" // mật khẩu MySQL nếu có
            );

            String sql = "SELECT * FROM staff WHERE email=? AND password=?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, user);
            ps.setString(2, pass);

            rs = ps.executeQuery();

            if(rs.next()){
                session.setAttribute("admin", rs.getString("email"));
                session.setAttribute("role", rs.getString("role"));

                response.sendRedirect("dashboard.jsp"); // sửa đúng tên file
                return;
            } else {
                request.setAttribute("error", "Sai tài khoản hoặc mật khẩu!");
            }

        } catch(Exception e){
            out.println("Lỗi: " + e.getMessage());
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cổng Quản Trị — OmniStay Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;1,400&family=Outfit:wght@300;400;500;600&display=swap" rel="stylesheet" />
    <style>
        :root {
            --primary: #1a6b5a;
            --primary-dark: #124a3e;
            --accent: #d4a847;
            --border: #e8e2d9;
        }

        body {
            font-family: "Outfit", sans-serif;
            background: linear-gradient(rgba(0, 0, 0, 0.65), rgba(0, 0, 0, 0.65)), 
                        url('https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1600&q=80') center/cover no-repeat;
            background-attachment: fixed;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0;
            overflow: hidden;
        }

        .login-container {
            width: 100%;
            max-width: 440px;
            padding: 20px;
            animation: fadeIn 0.8s ease-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .login-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            border-radius: 24px;
            padding: 3rem 2.5rem;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3);
            border: 1px solid rgba(255, 255, 255, 0.3);
            position: relative;
        }

        .login-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 6px;
            background: linear-gradient(90deg, var(--primary), var(--accent));
            border-radius: 24px 24px 0 0;
        }

        .font-display { font-family: "Playfair Display", serif; }

        .brand-title {
            font-size: 2.2rem;
            letter-spacing: 1px;
            color: var(--primary);
            margin-bottom: 0.5rem;
        }

        .brand-subtitle {
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 4px;
            color: #888;
            font-weight: 500;
            margin-bottom: 2.5rem;
        }

        .input-group-custom {
            margin-bottom: 1.5rem;
            position: relative;
        }

        .input-group-custom label {
            display: block;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: #555;
            margin-bottom: 0.6rem;
            margin-left: 0.5rem;
        }

        .input-wrapper {
            position: relative;
            display: flex;
            align-items: center;
        }

        .input-wrapper i {
            position: absolute;
            left: 1.2rem;
            color: #aaa;
            transition: color 0.3s;
        }

        .booking-input {
            width: 100%;
            border: 1.5px solid #eee;
            border-radius: 12px;
            padding: 0.8rem 1rem 0.8rem 3rem;
            font-size: 0.95rem;
            transition: all 0.3s;
            background: #fdfdfd;
        }

        .booking-input:focus {
            border-color: var(--primary);
            background: #fff;
            box-shadow: 0 0 0 4px rgba(26, 107, 90, 0.1);
            outline: none;
        }

        .booking-input:focus + i {
            color: var(--primary);
        }

        .btn-login {
            background: var(--primary);
            color: #fff;
            border-radius: 12px;
            padding: 1rem;
            border: none;
            width: 100%;
            font-weight: 500;
            font-size: 1rem;
            letter-spacing: 1px;
            transition: all 0.3s;
            margin-top: 1rem;
            box-shadow: 0 10px 20px rgba(26, 107, 90, 0.2);
        }

        .btn-login:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
            box-shadow: 0 15px 30px rgba(26, 107, 90, 0.3);
        }

        .btn-login:active {
            transform: translateY(0);
        }

        .error-msg {
            background: rgba(220, 53, 69, 0.08);
            color: #dc3545;
            padding: 0.8rem;
            border-radius: 10px;
            font-size: 0.85rem;
            text-align: center;
            margin-top: 1.5rem;
            border: 1px solid rgba(220, 53, 69, 0.1);
        }

        .footer-note {
            text-align: center;
            margin-top: 2rem;
            color: rgba(255, 255, 255, 0.6);
            font-size: 0.75rem;
        }
        
        .security-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            color: var(--primary);
            font-size: 0.7rem;
            background: rgba(26, 107, 90, 0.05);
            padding: 4px 12px;
            border-radius: 50px;
            margin-bottom: 2rem;
        }
    </style>
</head>
<body>

    <div class="login-container">
        <div class="login-card">
            <div class="text-center">
                <h1 class="brand-title font-display">
                    Omni<span style="color: var(--accent)">Stay</span>
                </h1>
                <div class="brand-subtitle">Cổng Quản Trị Hệ Thống</div>
                
                <div class="security-badge">
                    <i class="bi bi-shield-lock-fill"></i>
                    Chỉ dành cho nhân viên có thẩm quyền
                </div>
            </div>

            <form method="POST">
                <div class="input-group-custom">
                    <label>Địa chỉ Email</label>
                    <div class="input-wrapper">
                        <input type="email" name="username" class="booking-input" placeholder="admin@omnistay.vn" required>
                        <i class="bi bi-envelope"></i>
                    </div>
                </div>

                <div class="input-group-custom">
                    <label>Mật khẩu Truy cập</label>
                    <div class="input-wrapper">
                        <input type="password" name="password" class="booking-input" placeholder="••••••••" required>
                        <i class="bi bi-key"></i>
                    </div>
                </div>

                <button type="submit" class="btn-login">
                    Đăng Nhập Hệ Thống <i class="bi bi-arrow-right-short ms-1"></i>
                </button>

                <% if(request.getAttribute("error") != null){ %>
                    <div class="error-msg">
                        <i class="bi bi-exclamation-circle me-1"></i> Sai tài khoản hoặc mật khẩu!
                    </div>
                <% } %>
            </form>
        </div>
        
        <div class="footer-note">
            &copy; 2026 Tập đoàn Khách sạn Cao cấp OmniStay.<br>
            Mọi hoạt động truy cập đều được ghi lại và giám sát bởi hệ thống.
        </div>
    </div>

</body>
</html>