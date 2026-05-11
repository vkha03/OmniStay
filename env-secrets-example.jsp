<%! 
    // ========================================================================
    // OMNISTAY - CẤU HÌNH CÁC THAM SỐ HỆ THỐNG & BẢO MẬT (MẪU)
    // HƯỚNG DẪN: Hãy Copy file này thành env-secrets.jsp và điền thông tin thật.
    // ========================================================================

    // 1. DATABASE CONFIGURATION
    public static final String SECRET_DB_URL = "jdbc:mysql://localhost:3306/omnistay?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    public static final String SECRET_DB_USER = "YOUR_DB_USER"; 
    public static final String SECRET_DB_PASS = "YOUR_DB_PASSWORD"; 

    // 2. VNPAY PAYMENT GATEWAY
    public static final String SECRET_VNP_TMN = "YOUR_VNP_TMN_HERE"; 
    public static final String SECRET_VNP_HASH = "YOUR_VNP_HASH_HERE"; 

    // 3. ZALO BOT NOTIFICATION (MANAGER ALERTS)
    public static final String SECRET_ZALO_TOKEN = "YOUR_ZALO_TOKEN_HERE";
    public static final String SECRET_ZALO_CHATID = "YOUR_ZALO_CHATID_HERE"; 

    // 4. EMAIL SMTP SERVICE (FOR CUSTOMER INVOICES)
    public static final String SECRET_MAIL_HOST = "smtp.gmail.com"; 
    public static final String SECRET_MAIL_PORT = "587"; 
    public static final String SECRET_MAIL_USER = "YOUR_EMAIL_HERE"; 
    public static final String SECRET_MAIL_PASS = "YOUR_GMAIL_APP_PASSWORD_HERE"; 

    // 5. GOOGLE GEMINI AI CONFIGURATION
    public static final String SECRET_GEMINI_KEY = "YOUR_GEMINI_API_KEY_HERE"; 
    public static final String SECRET_GEMINI_MODEL = "gemini-2.0-flash"; 
%>
