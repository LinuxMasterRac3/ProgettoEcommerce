<!-- filepath: c:\Users\ITIS Volta\Downloads\esercitazione\ProgettoEcommerce\src\views\Contact.vue -->
<template>
  <div>
    <!-- Navbar -->
    <Navbar />

    <!-- Chat Section -->
    <div class="chat-container">
      <aside class="chat-sidebar">
        <div class="chat-header">
          <h2>Chat</h2>
        </div>
        <ul class="chat-list">
          <li
            v-for="(chat, index) in chats"
            :key="index"
            @click="selectChat(index)">
            <div class="chat-item">
              <h3>{{ chat.name }}</h3>
              <p>{{ chat.lastMessage }}</p>
            </div>
          </li>
        </ul>
      </aside>
      <main class="chat-main">
        <div class="chat-header">
          <h2>{{ selectedChat.name }}</h2>
        </div>
        <div class="chat-messages">
          <div
            v-for="(message, index) in selectedChat.messages"
            :key="index"
            :class="['message', message.sent ? 'sent' : 'received']">
            <p>{{ message.text }}</p>
          </div>
        </div>
        <div class="chat-input">
          <input
            type="text"
            v-model="newMessage"
            placeholder="Scrivi un messaggio..."
            @keyup.enter="sendMessage" />
          <button @click="sendMessage">Invia</button>
        </div>
      </main>
    </div>
  </div>
</template>

<script>
import Navbar from "@/components/Navbar.vue";

export default {
  components: {
    Navbar,
  },
  data() {
    return {
      chats: [
        {
          name: "Mario Rossi",
          lastMessage: "Ciao, come stai?",
          messages: [
            { text: "Ciao!", sent: true },
            { text: "Come stai?", sent: false },
          ],
        },
        {
          name: "Luigi Verdi",
          lastMessage: "A domani!",
          messages: [
            { text: "Ci vediamo domani?", sent: false },
            { text: "Sì, a domani!", sent: true },
          ],
        },
      ],
      selectedChat: {
        name: "",
        messages: [],
      },
      newMessage: "",
    };
  },
  methods: {
    selectChat(index) {
      this.selectedChat = this.chats[index];
    },
    sendMessage() {
      if (this.newMessage.trim() !== "") {
        this.selectedChat.messages.push({ text: this.newMessage, sent: true });
        this.selectedChat.lastMessage = this.newMessage;

        // Sposta la chat in cima
        const chatIndex = this.chats.findIndex(
          (chat) => chat.name === this.selectedChat.name
        );
        if (chatIndex !== -1) {
          const [chat] = this.chats.splice(chatIndex, 1);
          this.chats.unshift(chat);
        }

        this.newMessage = "";
      }
    },
    receiveMessage(chatName, message) {
      const chatIndex = this.chats.findIndex((chat) => chat.name === chatName);
      if (chatIndex !== -1) {
        this.chats[chatIndex].messages.push({ text: message, sent: false });
        this.chats[chatIndex].lastMessage = message;

        // Sposta la chat in cima
        const [chat] = this.chats.splice(chatIndex, 1);
        this.chats.unshift(chat);
      }
    },
  },
  mounted() {
    // Apri l'ultima chat al caricamento della pagina
    if (this.chats.length > 0) {
      this.selectChat(this.chats.length - 1);
    }
  },
};
</script>

<style scoped>
/* Navbar Styles */
.navbar {
  background-color: #6a0dad; /* Viola (colore preso dai file Product) */
  padding: 1rem;
  border-bottom: 1px solid #ddd; /* Bordo inferiore */
}

.navbar-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.navbar-title {
  font-size: 1.5rem;
  color: white; /* Testo bianco */
}

.navbar-links {
  list-style: none;
  display: flex;
  gap: 1rem;
  margin: 0;
  padding: 0;
}

.navbar-links li a {
  text-decoration: none;
  color: white; /* Testo bianco */
  font-weight: bold;
}

.navbar-links li a:hover {
  text-decoration: underline;
}

/* Chat Styles */
.chat-container {
  display: flex;
  height: calc(100vh - 70px); /* Altezza meno la navbar */
  background-color: #f9f9f9; /* Sfondo chiaro */
}

.chat-sidebar {
  width: 30%;
  background-color: #f0f0f0; /* Sfondo sidebar */
  color: black; /* Testo nero */
  overflow-y: auto;
}

.chat-header {
  padding: 1rem;
  background-color: #e0e0e0; /* Sfondo header */
  color: black; /* Testo nero */
  text-align: center;
}

.chat-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.chat-item {
  padding: 1rem;
  border-bottom: 1px solid #ddd;
  cursor: pointer;
}

.chat-item:hover {
  background-color: #e0e0e0; /* Sfondo hover */
}

.chat-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  background-color: white;
}

.chat-messages {
  flex: 1;
  padding: 1rem;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 0.5rem; /* Spazio tra i messaggi */
}

.message {
  margin: 0.1rem 0; /* Spazio verticale tra i messaggi */
  padding: 0.5rem 1rem;
  border-radius: 10px;
  max-width: 60%;
  word-wrap: break-word;
}

.message.sent {
  background-color: #6a0dad; /* Viola per i messaggi inviati */
  color: white; /* Testo bianco */
  align-self: flex-end;
  text-align: right;
}

.message.received {
  background-color: #f0f0f0; /* Grigio chiaro per i messaggi ricevuti */
  color: black; /* Testo nero */
  align-self: flex-start;
  text-align: left;
}

.chat-input {
  display: flex;
  padding: 1rem;
  background-color: #f9f9f9; /* Sfondo input */
  border-top: 1px solid #ddd;
}

.chat-input input {
  flex: 1;
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 5px;
}

.chat-input button {
  margin-left: 0.5rem;
  padding: 0.5rem 1rem;
  background-color: #6a0dad; /* Viola (colore preso dai file Product) */
  color: white;
  border: none;
  border-radius: 5px;
  cursor: pointer;
}

.chat-input button:hover {
  background-color: #5a0cae; /* Viola scuro per hover */
}
</style>
