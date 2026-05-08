<%@ page language="java" contentType="text/event-stream; charset=UTF-8" pageEncoding="UTF-8" buffer="none" %>
<%@ page import="java.io.*, java.net.*" %>
<%@ include file="../env-secrets.jsp" %>
<%! 
    public static final String GEMINI_API_KEY = SECRET_GEMINI_KEY; 
    public static final String GEMINI_MODEL = SECRET_GEMINI_MODEL; 
%>
<%
    response.setHeader("Cache-Control", "no-cache");
    response.setHeader("Connection", "keep-alive");
    request.setCharacterEncoding("UTF-8");

    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        out.print("data: {\"error\":\"Method not allowed\"}\n\n");
        return;
    }

    BufferedReader br = request.getReader();
    StringBuilder reqBody = new StringBuilder();
    String l;
    while ((l = br.readLine()) != null) reqBody.append(l);
    
    int start = reqBody.indexOf("[");
    int end = reqBody.lastIndexOf("]");
    if (start == -1) return;
    String contents = reqBody.substring(start, end + 1);

    String systemPrompt = "Bạn là OmniAI, trợ lý khách sạn 5 sao OmniStay Luxury Hotel & Resort tại Cần Thơ. Trả lời trực tiếp, nhẹ nhàng, chuyên nghiệp và ngắn gọn. "
        + "THÔNG TIN KHÁCH SẠN:\n"
        + "- Địa chỉ: ✦ OmniStay Cần Thơ ✦, gần Bến Ninh Kiều.\n"
        + "- Hotline: 1900 1234 | Email: support@omnistay.vn\n"
        + "- Giờ nhận phòng (Check-in): 14:00 | Giờ trả phòng (Check-out): 12:00\n"
        + "- Hạng phòng:\n"
        + "  1. Ninh Kieu Standard: 950.000₫/đêm, 2 người. Sàn gỗ sồi, view thành phố.\n"
        + "  2. Hau River Deluxe: 1.600.000₫/đêm, 2 người. Ban công hướng sông Hậu, bồn tắm sứ.\n"
        + "  3. Mekong Heritage Suite: 3.200.000₫/đêm, 3 người. Nội thất khảm trai, miễn phí trà chiều & đưa đón sân bay.\n"
        + "- Dịch vụ đi kèm:\n"
        + "  1. Tour Chợ Nổi Cái Răng VIP: 500.000₫/người.\n"
        + "  2. Sen Spa & Massage (90 phút): 850.000₫/lượt.\n"
        + "  3. Xe Limousine sân bay: 350.000₫/chuyến.\n"
        + "  4. Trà chiều Jade Lounge: 450.000₫/set 2 người.\n"
        + "  5. Giặt ủi: 100.000₫/bộ.\n"
        + "CRITICAL INSTRUCTION: ONLY OUTPUT THE FINAL DIRECT RESPONSE. DO NOT WRITE ANY THOUGHTS. DO NOT WRITE '* User says:' OR 'Draft:' OR 'Persona:'. "
        + "DO NOT OUTPUT REASONING EVER. YOU MUST JUST GIVE THE FINAL ANSWER EXACTLY AS YOU WOULD SPEAK IT TO THE USER. NO PREAMBLES, NO BULLETED RULES.";
    String apiBody = "{\"system_instruction\":{\"parts\":[{\"text\":\"" + systemPrompt + "\"}]},\"contents\":" + contents + "}";

    try {
        URL url = new URL("https://generativelanguage.googleapis.com/v1beta/models/" + GEMINI_MODEL + ":streamGenerateContent?alt=sse&key=" + GEMINI_API_KEY);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setDoOutput(true);
        conn.setConnectTimeout(10000);
        conn.setReadTimeout(30000);

        try(OutputStream os = conn.getOutputStream()) {
            os.write(apiBody.getBytes("UTF-8"));
        }
        
        int code = conn.getResponseCode();
        if (code != 200) {
            out.print("data: {\"error\":\"Lỗi kết nối API: " + code + "\"}\n\n");
            return;
        }

        BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
        String line;
        while ((line = reader.readLine()) != null) {
            if (line.startsWith("data: ")) {
                out.print(line + "\n\n");
                out.flush();
            }
        }
    } catch(Exception e) {
        String err = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Unknown Error";
        out.print("data: {\"error\":\"" + err + "\"}\n\n");
    }
%>
