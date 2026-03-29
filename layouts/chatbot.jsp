<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<!-- ═══ AI CHATBOT ═══ -->
<style>
  /* ── CHATBOT STYLES ── */
  :root {
    --chat-shadow: 0 12px 48px rgba(0, 0, 0, 0.15);
  }
  #chat-fab {
    position: fixed;
    bottom: 30px;
    right: 30px;
    width: 68px;
    height: 68px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--primary), var(--primary-dark));
    color: var(--accent);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 2rem;
    cursor: pointer;
    box-shadow: 0 12px 32px rgba(26, 107, 90, 0.35);
    z-index: 1050;
    transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    border: 3px solid rgba(212, 168, 71, 0.2);
  }
  #chat-fab:hover {
    transform: scale(1.1) rotate(15deg);
    box-shadow: 0 16px 40px rgba(26, 107, 90, 0.45);
    border-color: var(--accent);
  }
  #chat-window {
    position: fixed;
    bottom: 110px;
    right: 30px;
    width: 380px;
    height: 520px;
    background: #fff;
    border-radius: 24px;
    box-shadow: var(--chat-shadow);
    display: none;
    flex-direction: column;
    overflow: hidden;
    z-index: 1050;
    animation: chatOpen 0.4s cubic-bezier(0.18, 0.89, 0.32, 1.28);
    border: 1px solid var(--border);
  }
  @keyframes chatOpen {
    0% {
      opacity: 0;
      transform: translateY(20px) scale(0.95);
    }
    100% {
      opacity: 1;
      transform: translateY(0) scale(1);
    }
  }
  .chat-header {
    background: linear-gradient(90deg, var(--primary-dark), var(--primary));
    padding: 1.2rem;
    color: white;
  }
  .chat-body {
    flex-grow: 1;
    overflow-y: auto;
    padding: 1.2rem;
    background: #fdfdfb;
    scroll-behavior: smooth;
  }
  .msg {
    max-width: 80%;
    margin-bottom: 1rem;
    padding: 0.8rem 1rem;
    border-radius: 18px;
    font-size: 0.88rem;
    line-height: 1.5;
    position: relative;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
  }
  .msg-ai {
    background: #fff;
    color: #444;
    align-self: flex-start;
    border-bottom-left-radius: 4px;
    border: 1px solid var(--border);
  }
  .msg-user {
    background: var(--primary);
    color: white;
    align-self: flex-end;
    border-bottom-right-radius: 4px;
  }
  .chat-footer {
    padding: 1rem;
    background: #fff;
    border-top: 1px solid var(--border);
  }
  .status-dot {
    width: 8px;
    height: 8px;
    background: #2ecc71;
    border-radius: 50%;
    display: inline-block;
    margin-right: 6px;
    box-shadow: 0 0 8px #2ecc71;
  }
</style>

<div id="chat-fab" onclick="toggleChat()">
  <i class="bi bi-robot"></i>
</div>

<div id="chat-window">
  <!-- Header -->
  <div
    class="chat-header d-flex align-items-center justify-content-between"
    style="border-bottom: 2px solid rgba(212, 168, 71, 0.3)"
  >
    <div class="d-flex align-items-center gap-3">
      <div
        class="rounded-circle overflow-hidden bg-white d-flex align-items-center justify-content-center shadow-sm"
        style="width: 44px; height: 44px; border: 2px solid var(--accent)"
      >
        <i class="bi bi-robot fs-4" style="color: var(--primary)"></i>
      </div>
      <div>
        <div
          class="fw-500 text-white"
          style="font-size: 1rem; letter-spacing: 0.02em"
        >
          OmniAI Concierge
        </div>
        <div style="font-size: 0.68rem; color: var(--accent); font-weight: 500">
          <span class="status-dot"></span>Hệ thống AI đang trực tuyến
        </div>
      </div>
    </div>
    <button
      class="btn btn-link text-white opacity-75 hover-opacity-100 p-0 transition"
      onclick="toggleChat()"
    >
      <i class="bi bi-x-lg fs-5"></i>
    </button>
  </div>

  <!-- Messages -->
  <div class="chat-body d-flex flex-column" id="chatBody">
    <div class="msg msg-ai shadow-sm">
      <div
        class="fw-500 mb-1"
        style="
          font-size: 0.65rem;
          color: var(--primary);
          letter-spacing: 0.1em;
          text-transform: uppercase;
        "
      >
        OmniAI Elite
      </div>
      Kính chào Quý khách! Tôi là OmniAI Concierge — chuyên gia phong cách sống
      cá nhân của bạn. Tôi có thể hỗ trợ gì cho trải nghiệm thượng lưu của bạn
      tại Tây Đô?
    </div>
    <div class="msg msg-ai shadow-sm">
      Bạn có muốn tôi sắp xếp một <strong>Du thuyền riêng</strong> ngắm hoàng
      hôn hay đặt bàn <strong>Fine Dining</strong> tại Sky 15 Bar không?
    </div>
  </div>

  <!-- Footer -->
  <div class="chat-footer">
    <div class="input-group">
      <input
        type="text"
        id="chatInput"
        class="form-control border-end-0 rounded-start-pill ps-4 shadow-none border"
        placeholder="Trò chuyện cùng chuyên gia phong cách sống..."
        style="font-size: 0.88rem; height: 48px; background: #fdfdfd"
      />
      <button
        class="btn btn-primary rounded-end-pill px-4 border-start-0 d-flex align-items-center justify-content-center"
        type="button"
        onclick="sendMessage()"
        style="background: var(--primary); border: none"
      >
        <i
          class="bi bi-send-fill"
          style="color: var(--accent); font-size: 1.1rem"
        ></i>
      </button>
    </div>
    <div
      class="text-center mt-3"
      style="font-size: 0.68rem; color: #999; letter-spacing: 0.05em"
    >
      Trải nghiệm công nghệ bởi
      <strong style="color: var(--primary)">OmniStay Elite AI</strong>
    </div>
  </div>
</div>

<script>
  function toggleChat() {
    const win = document.getElementById("chat-window");
    win.style.display = win.style.display === "flex" ? "none" : "flex";
    if (win.style.display === "flex") {
      const body = document.getElementById("chatBody");
      body.scrollTop = body.scrollHeight;
    }
  }

  function sendMessage() {
    const input = document.getElementById("chatInput");
    const body = document.getElementById("chatBody");
    if (input.value.trim() === "") return;

    // User msg
    const uMsg = document.createElement("div");
    uMsg.className = "msg msg-user shadow-sm";
    uMsg.textContent = input.value;
    body.appendChild(uMsg);

    const val = input.value;
    input.value = "";
    body.scrollTop = body.scrollHeight;

    // Fake AI typing
    setTimeout(() => {
      const aMsg = document.createElement("div");
      aMsg.className = "msg msg-ai shadow-sm";
      aMsg.textContent =
        'Đang xử lý yêu cầu "' +
        val +
        '"... Đội ngũ OmniStay sẽ phản hồi bạn sớm nhất!';
      body.appendChild(aMsg);
      body.scrollTop = body.scrollHeight;
    }, 800);
  }

  // Allow enter key
  document
    .getElementById("chatInput")
    .addEventListener("keypress", function (e) {
      if (e.key === "Enter") {
        sendMessage();
      }
    });
</script>
