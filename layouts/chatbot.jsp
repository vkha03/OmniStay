<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<style>
  #chat-fab {
    position: fixed;
    bottom: 28px;
    right: 28px;
    width: 60px;
    height: 60px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--primary), var(--primary-dark));
    color: var(--accent);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.5rem;
    cursor: pointer;
    box-shadow: 0 6px 20px rgba(26, 107, 90, 0.4);
    z-index: 9999;
    border: 2px solid rgba(212, 168, 71, 0.25);
    transition: transform 0.3s, box-shadow 0.3s;
  }
  #chat-fab:hover {
    transform: scale(1.1);
    box-shadow: 0 8px 28px rgba(26, 107, 90, 0.5);
  }

  #chat-window {
    position: fixed;
    bottom: 100px;
    right: 28px;
    width: 380px;
    max-width: calc(100vw - 32px);
    height: 520px;
    max-height: calc(100vh - 130px);
    background: #fff;
    border-radius: 18px;
    box-shadow: 0 12px 48px rgba(0, 0, 0, 0.15);
    display: none;
    flex-direction: column;
    overflow: hidden;
    z-index: 9999;
    border: 1px solid rgba(0, 0, 0, 0.08);
  }
  #chat-window.show { display: flex; }

  .chat-header {
    background: linear-gradient(135deg, var(--primary-dark), var(--primary));
    padding: 0.9rem 1.2rem;
    color: white;
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-shrink: 0;
  }
  .chat-header-title {
    font-size: 0.9rem;
    font-weight: 500;
  }
  .chat-header-sub {
    font-size: 0.65rem;
    color: rgba(212, 168, 71, 0.9);
  }
  .chat-close {
    background: none;
    border: none;
    color: rgba(255,255,255,0.7);
    font-size: 1.1rem;
    cursor: pointer;
    padding: 4px;
  }
  .chat-close:hover { color: #fff; }

  .chat-body {
    flex: 1;
    overflow-y: auto;
    padding: 1rem;
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    background: #faf9f7;
  }
  .chat-body::-webkit-scrollbar { width: 4px; }
  .chat-body::-webkit-scrollbar-thumb { background: rgba(0,0,0,0.1); border-radius: 4px; }

  .msg {
    max-width: 80%;
    padding: 0.6rem 0.85rem;
    border-radius: 14px;
    font-size: 0.84rem;
    line-height: 1.6;
    word-wrap: break-word;
  }
  .msg-ai {
    background: #fff;
    color: #333;
    align-self: flex-start;
    border-bottom-left-radius: 4px;
    border: 1px solid rgba(0,0,0,0.06);
  }
  .msg-user {
    background: var(--primary);
    color: #fff;
    align-self: flex-end;
    border-bottom-right-radius: 4px;
  }
  .msg-ai strong { color: var(--primary); }
  .msg-ai ul, .msg-ai ol { margin: 4px 0; padding-left: 1.2em; }
  .msg-ai li { margin-bottom: 2px; }

  .chat-footer {
    padding: 0.7rem;
    background: #fff;
    border-top: 1px solid rgba(0,0,0,0.06);
    flex-shrink: 0;
  }
  .chat-input-row {
    display: flex;
    gap: 6px;
  }
  .chat-input-row input {
    flex: 1;
    border: 1.5px solid #e0e0e0;
    border-radius: 20px;
    padding: 8px 14px;
    font-size: 0.84rem;
    font-family: 'Outfit', sans-serif;
    outline: none;
    transition: border-color 0.2s;
  }
  .chat-input-row input:focus { border-color: var(--primary); }
  .chat-input-row button {
    width: 38px;
    height: 38px;
    border-radius: 50%;
    background: var(--primary);
    color: var(--accent);
    border: none;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 0.9rem;
    flex-shrink: 0;
    transition: background 0.2s;
  }
  .chat-input-row button:hover { background: var(--primary-dark); }
  .chat-input-row button:disabled { opacity: 0.5; cursor: not-allowed; }

  @keyframes typing-bounce {
    0%, 80%, 100% { transform: translateY(0); opacity: 0.4; }
    40% { transform: translateY(-6px); opacity: 1; }
  }
  .typing-indicator {
    display: flex;
    gap: 4px;
    padding: 8px 12px;
    align-items: center;
    min-width: 50px;
  }
  .typing-dot {
    width: 6px;
    height: 6px;
    background: var(--primary);
    border-radius: 50%;
    animation: typing-bounce 1.4s infinite ease-in-out;
  }
  .typing-dot:nth-child(2) { animation-delay: 0.2s; }
  .typing-dot:nth-child(3) { animation-delay: 0.4s; }

  @media (max-width: 480px) {
    #chat-window {
      bottom: 0; right: 0;
      width: 100vw; height: 100vh;
      max-height: 100vh; border-radius: 0;
    }
  }
</style>

<div id="chat-fab" onclick="OmniChat.toggle()">
  <i class="bi bi-robot"></i>
</div>

<div id="chat-window">
  <div class="chat-header">
    <div>
      <div class="chat-header-title">✨ OmniAI Concierge</div>
      <div class="chat-header-sub">Trợ lý AI · OmniStay</div>
    </div>
    <button class="chat-close" onclick="OmniChat.toggle()">
      <i class="bi bi-x-lg"></i>
    </button>
  </div>

  <div class="chat-body" id="chatBody">
    <div class="msg msg-ai">
      Xin chào! ✨ Tôi là <strong>OmniAI</strong> — trợ lý AI của OmniStay. Bạn cần hỗ trợ gì?
    </div>
  </div>

  <div class="chat-footer">
    <div class="chat-input-row">
      <input type="text" id="chatInput" placeholder="Nhập tin nhắn..." autocomplete="off" />
      <button id="chatSendBtn" onclick="OmniChat.send()">
        <i class="bi bi-send-fill"></i>
      </button>
    </div>
  </div>
</div>

<script>
const OmniChat = (() => {
  const API = '<%= request.getContextPath() %>/api/chat-api.jsp';
  let history = [];
  let busy = false;
  let open = false;

  const $ = id => document.getElementById(id);

  function toggle() {
    open = !open;
    $('chat-window').classList.toggle('show', open);
    if (open) $('chatInput').focus();
  }

  function addMsg(role, text) {
    const div = document.createElement('div');
    div.className = 'msg ' + (role === 'user' ? 'msg-user' : 'msg-ai');
    div.innerHTML = role === 'user' ? escapeHtml(text) : md(text);
    $('chatBody').appendChild(div);
    $('chatBody').scrollTop = $('chatBody').scrollHeight;
  }

  function escapeHtml(t) {
    const d = document.createElement('div');
    d.textContent = t;
    return d.innerHTML;
  }

  function md(t) {
    if (!t) return '';
    return t
      .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
      .replace(/\*(.+?)\*/g, '<em>$1</em>')
      .replace(/`(.+?)`/g, '<code>$1</code>')
      .replace(/^[-•]\s+(.+)$/gm, '<li>$1</li>')
      .replace(/(<li>.*<\/li>\n?)+/gs, '<ul>$&</ul>')
      .replace(/\n/g, '<br>');
  }

  async function send() {
    if (busy) return;
    const input = $('chatInput');
    const msg = input.value.trim();
    if (!msg) return;

    input.value = '';
    busy = true;
    $('chatSendBtn').disabled = true;

    addMsg('user', msg);
    history.push({ role: 'user', parts: [{ text: msg }] });

    const aiDiv = document.createElement('div');
    aiDiv.className = 'msg msg-ai';
    aiDiv.innerHTML = '<div class="typing-indicator"><div class="typing-dot"></div><div class="typing-dot"></div><div class="typing-dot"></div></div>';
    $('chatBody').appendChild(aiDiv);
    $('chatBody').scrollTop = $('chatBody').scrollHeight;

    try {
      const res = await fetch(API, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ contents: history })
      });
      
      const reader = res.body.getReader();
      const decoder = new TextDecoder();
      let buffer = '';
      let fullText = '';
      
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        
        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split('\n');
        buffer = lines.pop(); 
        
        for (const line of lines) {
          if (line.startsWith('data: ') && line.length > 6) {
            const dataStr = line.substring(6).trim();
            if (dataStr === '[DONE]' || !dataStr) continue;
            try {
              const data = JSON.parse(dataStr);
              if (data.error) {
                fullText = data.error;
              } else if (data.candidates && data.candidates[0].content) {
                fullText += data.candidates[0].content.parts[0].text;
              }
              
              // Lọc rác: Loại bỏ tất cả luồng suy nghĩ của Gemma
              let cleanText = fullText;
              
              // Nếu có chữ Draft: thì lấy toàn bộ phần nằm sau chữ Draft:
              if (cleanText.includes('Draft:')) {
                  const parts = cleanText.split('Draft:');
                  cleanText = parts[parts.length - 1].trim();
              } else if (cleanText.includes('* Greeting:')) {
                  // Chỉ lấy đoạn cuối cùng sau khi phân tích
                  const lines = cleanText.split('\n');
                  cleanText = lines.filter(l => !l.startsWith('*') && l.trim() !== '').join('\n');
              }
              
              // Nếu text vẫn quá dơ (chứa các gạch đầu dòng phân tích), lọc nốt
              cleanText = cleanText.replace(/\* User says:.*\n/g, '')
                                   .replace(/\* Persona:.*\n/g, '')
                                   .replace(/\* Style:.*\n/g, '')
                                   .replace(/\* Constraints:.*\n/g, '');
                                   
              const processedText = cleanText.trim();
              if (processedText) {
                aiDiv.innerHTML = md(processedText);
                $('chatBody').scrollTop = $('chatBody').scrollHeight;
              }
            } catch(e) {}
          }
        }
      }
      history.push({ role: 'model', parts: [{ text: fullText }] });
      if (history.length > 20) history = history.slice(-20);
    } catch (e) {
      aiDiv.innerHTML = '⚠️ Lỗi kết nối. Vui lòng thử lại.';
    }

    busy = false;
    $('chatSendBtn').disabled = false;
    input.focus();
  }

  document.addEventListener('DOMContentLoaded', () => {
    $('chatInput').addEventListener('keydown', e => {
      if (e.key === 'Enter') { e.preventDefault(); send(); }
    });
  });

  return { toggle, send };
})();
</script>
