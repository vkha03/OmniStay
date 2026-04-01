<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
        <meta charset="UTF-8">
        <title>Đăng nhập quản lý khách sạn</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <!-- Font -->
        <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600&family=Playfair+Display:wght@500;700&display=swap" rel="stylesheet">

        <style>
             :root {
                --primary: #1a6b5a;
                --primary-dark: #134f43;
                --accent: #d4a847;
                --border: #e8e2d9;
            }
            
            * {
                box-sizing: border-box;
            }
            
            body {
                margin: 0;
                font-family: "Outfit", sans-serif;
                background: linear-gradient(160deg, #0f3d33, #1a6b5a, #2d8c72);
                height: 100vh;
                display: flex;
                justify-content: center;
                align-items: center;
            }
            
            .login-container {
                width: 380px;
                background: #fff;
                border-radius: 16px;
                box-shadow: 0 24px 64px rgba(0, 0, 0, 0.2);
                overflow: hidden;
            }
            
            .login-header {
                background: linear-gradient(90deg, var(--primary-dark), var(--primary));
                color: #fff;
                padding: 1.5rem;
                text-align: center;
            }
            
            .login-header h2 {
                margin: 0;
                font-family: "Playfair Display", serif;
            }
            
            .login-body {
                padding: 1.5rem 2rem;
            }
            
            .login-label {
                font-size: 0.7rem;
                text-transform: uppercase;
                color: var(--primary);
                margin-bottom: 5px;
                display: block;
            }
            
            .login-input {
                width: 100%;
                padding: 10px;
                margin-bottom: 15px;
                border-radius: 10px;
                border: 1.5px solid var(--border);
            }
            
            .login-input:focus {
                border-color: var(--primary);
                outline: none;
            }
            
            .btn-login {
                width: 100%;
                padding: 10px;
                border: none;
                border-radius: 12px;
                background: var(--primary);
                color: #fff;
                font-weight: 500;
                cursor: pointer;
            }
            
            .btn-login:hover {
                background: var(--primary-dark);
            }
            
            .login-footer {
                text-align: center;
                font-size: 0.8rem;
                padding: 10px;
                color: #777;
            }
            
            .error {
                color: red;
                font-size: 0.85rem;
                margin-bottom: 10px;
                text-align: center;
            }
        </style>
    </head>

    <body>

        <div class="login-container">
            <div class="login-header">
                <h2>Hotel OmniStay</h2>
                <p>Đăng nhập quản lý</p>
            </div>

            <div class="login-body">

                <!-- HIỂN THỊ LỖI -->
                <p class="error">${error}</p>

                <form action="LoginServlet" method="post">
                    <label class="login-label">Email</label>
                    <input type="email" name="email" class="login-input" required>

                    <label class="login-label">Mật khẩu</label>
                    <input type="password" name="password" class="login-input" required>

                    <button type="submit" class="btn-login">Đăng nhập</button>
                </form>
            </div>

            <div class="login-footer">
                © 2026 Hotel OmniStay
            </div>
        </div>

    </body>

    </html>