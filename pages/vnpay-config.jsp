<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="java.util.*" %>
<%@ page import="javax.crypto.Mac" %>
<%@ page import="javax.crypto.spec.SecretKeySpec" %>
<%@ include file="../env-secrets.jsp" %>
<%-- ==========================================================================
     TỆP CẤU HÌNH THÔNG SỐ CỔNG THANH TOÁN VNPAY (VNPAY GATEWAY CONFIGURATION)
     Chứa các khai báo tham số tĩnh (Terminal Code, Secret Key, API Endpoints)
     và các thuật toán băm mật mã học (HMAC-SHA512) tuân thủ tiêu chuẩn bảo mật
     tuyệt đối theo tài liệu tích hợp chính thức của VNPAY.
     ========================================================================== --%>
<%!
    // ========================================================================
    // 1. CẤU HÌNH THAM SỐ MÔI TRƯỜNG SANDBOX THỬ NGHIỆM (GATEWAY PARAMETERS)
    // Các biến tĩnh được gọi trực tiếp từ tệp bảo mật trung tâm env-secrets.jsp
    // ========================================================================
    
    // Mã website đăng ký tại hệ thống VNPAY (Terminal Code)
    public static String vnp_TmnCode = SECRET_VNP_TMN;
    // Chuỗi bí mật dùng để tạo chữ ký bảo mật toàn vẹn dữ liệu (Secure Hash Secret)
    public static String vnp_HashSecret = SECRET_VNP_HASH;
    // Địa chỉ URL cổng thanh toán VNPAY dành cho môi trường thử nghiệm Sandbox
    public static String vnp_Url = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    // Đường dẫn tuyệt đối xử lý dữ liệu trả về sau khi khách hàng hoàn tất giao dịch
    public static String vnp_Returnurl = "http://localhost:8080/OmniStay/pages/vnpay-return.jsp";
    // Phiên bản giao thức kết nối API chuẩn
    public static String vnp_TmnVersion = "2.1.0";
    // Lệnh thực thi thanh toán tiêu chuẩn
    public static String vnp_Command = "pay";

    // ========================================================================
    // 2. THUẬT TOÁN BĂM HMAC-SHA512 (CRYPTOGRAPHIC SIGNING ALGORITHM)
    // Chuyển đổi dữ liệu chuỗi thô thành chữ ký số an toàn chống chỉnh sửa gói tin
    // ========================================================================
    public static String hmacSHA512(final String key, final String data) {
        try {
            if (key == null || data == null) {
                return null;
            }
            // Khởi tạo thuật toán mã hóa Message Authentication Code chuẩn HmacSHA512
            final Mac hmac512 = Mac.getInstance("HmacSHA512");
            byte[] hmacKeyBytes = key.getBytes(StandardCharsets.UTF_8);
            final SecretKeySpec secretKey = new SecretKeySpec(hmacKeyBytes, "HmacSHA512");
            hmac512.init(secretKey);
            
            // Thực hiện băm mảng byte dữ liệu đầu vào
            byte[] dataBytes = data.getBytes(StandardCharsets.UTF_8);
            byte[] result = hmac512.doFinal(dataBytes);
            
            // Chuyển đổi mảng byte kết quả sang định dạng chuỗi thập lục phân (Hexadecimal)
            StringBuilder sb = new StringBuilder(2 * result.length);
            for (byte b : result) {
                sb.append(String.format("%02x", b & 0xff));
            }
            return sb.toString();
        } catch (Exception ex) {
            return "";
        }
    }

    // ========================================================================
    // 3. HÀM HỖ TRỢ DUYỆT VÀ TẠO CHUỖI BĂM ĐỒNG LOẠT (HASH ALL FIELDS HELPER)
    // Sắp xếp tự động danh sách tham số theo vần Alphabet trước khi ký số
    // ========================================================================
    public static String hashAllFields(Map<String, String> fields) {
        List<String> fieldNames = new ArrayList<>(fields.keySet());
        Collections.sort(fieldNames);
        StringBuilder sb = new StringBuilder();
        Iterator<String> itr = fieldNames.iterator();
        while (itr.hasNext()) {
            String fieldName = itr.next();
            String fieldValue = fields.get(fieldName);
            if ((fieldValue != null) && (fieldValue.length() > 0)) {
                sb.append(fieldName);
                sb.append("=");
                sb.append(fieldValue);
            }
            if (itr.hasNext()) {
                sb.append("&");
            }
        }
        return hmacSHA512(vnp_HashSecret, sb.toString());
    }
%>
