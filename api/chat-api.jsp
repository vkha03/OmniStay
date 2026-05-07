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

    String systemPrompt = "Bạn là OmniAI, trợ lý khách sạn 5 sao OmniStay. Trả lời trực tiếp, nhẹ nhàng, ngắn gọn. Tuyệt đối không dùng markdown block, bullet points quá nhiều. "
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
