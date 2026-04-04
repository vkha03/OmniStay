<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
    <%@ page import="java.sql.*, java.util.*, java.text.NumberFormat" %>
        <%
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
                <title>Đăng nhập Admin - OmniStay</title>

                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
                <link href="https://fonts.googleapis.com/css2?family=Playfair+Display&family=Outfit:wght@300;400;500&display=swap" rel="stylesheet" />

                <style>
                     :root {
                        --primary: #1a6b5a;
                        --primary-dark: #134f43;
                        --accent: #d4a847;
                        --border: #e8e2d9;
                    }
                    
                    body {
                        font-family: "Outfit", sans-serif;
                        background: linear-gradient(160deg, #0f3d33, #1a6b5a, #2d8c72);
                        height: 100vh;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                    }
                    
                    .login-box {
                        width: 400px;
                        background: #fff;
                        padding: 2rem;
                        border-radius: 20px;
                        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
                    }
                    
                    .font-display {
                        font-family: "Playfair Display", serif;
                    }
                    
                    .booking-input {
                        border: 1.5px solid var(--border);
                        border-radius: 10px;
                        padding: 0.6rem;
                        width: 100%;
                    }
                    
                    .booking-input:focus {
                        border-color: var(--primary);
                        box-shadow: 0 0 0 3px rgba(26, 107, 90, 0.1);
                        outline: none;
                    }
                    
                    .btn-login {
                        background: var(--primary);
                        color: #fff;
                        border-radius: 12px;
                        padding: 10px;
                        border: none;
                        width: 100%;
                    }
                    
                    .btn-login:hover {
                        background: var(--primary-dark);
                    }
                </style>
            </head>

            <body>

                <div class="login-box">
                    <h3 class="text-center font-display mb-4">
                        Omni<span style="color: var(--accent)">Stay</span>
                    </h3>

                    <form method="post">

                        <div class="mb-3">
                            <label class="small">Email</label>
                            <input type="text" name="username" class="booking-input" required>
                        </div>

                        <div class="mb-3">
                            <label class="small">Mật khẩu</label>
                            <input type="password" name="password" class="booking-input" required>
                        </div>

                        <button type="submit" class="btn-login mt-2">
            Đăng nhập
        </button>

                        <% if(request.getAttribute("error") != null){ %>
                            <p class="text-danger mt-3 text-center">Sai tài khoản hoặc mật khẩu!</p>
                            <% } %>

                    </form>
                </div>

            </body>

            </html>