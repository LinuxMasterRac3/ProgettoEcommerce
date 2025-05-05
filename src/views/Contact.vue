<template>
  <div>
    <!-- Navbar -->
    <Navbar />

    <div
      v-if="isLoading"
      class="loading">
      <p>Caricamento delle conversazioni...</p>
    </div>

    <div
      v-else-if="error"
      class="error-message">
      <p>{{ error }}</p>
    </div>

    <!-- Chat Section -->
    <div
      v-else
      class="chat-container">
      <aside class="chat-sidebar">
        <div class="chat-header">
          <h2>Chat</h2>
          <button
            @click="showNewChatModal = true"
            class="new-chat-btn">
            <span>+</span> Nuova Chat
          </button>
        </div>
        <ul class="chat-list">
          <li
            v-for="chat in chats"
            :key="chat.id"
            @click="selectChat(chat)"
            :class="{ active: selectedChat && selectedChat.id === chat.id }">
            <div class="chat-item">
              <h3>{{ chat.name }}</h3>
              <p>{{ chat.last_message || "Nessun messaggio" }}</p>
              <small>{{ formatDate(chat.updated_at) }}</small>
            </div>
          </li>
          <li
            v-if="chats.length === 0"
            class="no-chats">
            <p>Nessuna conversazione disponibile</p>
          </li>
        </ul>
      </aside>

      <main class="chat-main">
        <div
          v-if="selectedChat"
          class="chat-content">
          <div class="chat-header">
            <h2>{{ selectedChat.name }}</h2>
          </div>

          <div
            class="chat-messages"
            ref="messagesContainer">
            <div
              v-for="message in messages"
              :key="message.id"
              :class="[
                'message',
                message.user_id === user?.id ? 'sent' : 'received',
              ]">
              <p>{{ message.text }}</p>
              <small class="message-time">{{
                formatTime(message.created_at)
              }}</small>
            </div>

            <div
              v-if="messages.length === 0"
              class="no-messages">
              <p>Nessun messaggio. Inizia la conversazione!</p>
            </div>
          </div>

          <div class="chat-input">
            <input
              type="text"
              v-model="newMessage"
              placeholder="Scrivi un messaggio..."
              @keyup.enter="sendMessage" />
            <button
              @click="sendMessage"
              :disabled="isSending">
              Invia
            </button>
          </div>
        </div>

        <div
          v-else
          class="no-chat-selected">
          <p>Seleziona una conversazione dalla lista o inizia una nuova chat</p>
        </div>
      </main>
    </div>

    <!-- Modal per nuova chat -->
    <div
      v-if="showNewChatModal"
      class="modal">
      <div class="modal-content">
        <h3>Nuova Conversazione</h3>
        <div
          class="modal-close"
          @click="showNewChatModal = false">
          &times;
        </div>

        <div class="search-container">
          <input
            type="text"
            v-model="searchTerm"
            placeholder="Cerca un utente..."
            @input="searchUsers" />

          <div
            v-if="searchResults.length > 0"
            class="search-results">
            <div
              v-for="result in searchResults"
              :key="result.id"
              class="search-result-item"
              @click="createChat(result)">
              <h4>{{ result.first_name }} {{ result.last_name }}</h4>
              <p>{{ result.email }}</p>
            </div>
          </div>

          <div
            v-else-if="searchTerm && !isSearching"
            class="no-results">
            <p>Nessun utente trovato</p>
          </div>

          <div
            v-if="isSearching"
            class="searching">
            <p>Ricerca in corso...</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, onBeforeUnmount, nextTick } from "vue";
import { useRoute, useRouter } from "vue-router";
import { createClient } from "@supabase/supabase-js";
import Navbar from "@/components/Navbar.vue";

// Supabase configuration - use just one instance
const supabaseUrl = "https://tiylfyyfitqzwstftzpg.supabase.co";
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpeWxmeXlmaXRxendzdGZ0enBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExNjYyNDcsImV4cCI6MjA1Njc0MjI0N30.CvIx_vI-KGGcFlcZy66-DIC8Itk03Olw3lzEMhnJP_c";
const supabase = createClient(supabaseUrl, supabaseKey, {
  autoRefreshToken: true,
  persistSession: true,
});

export default {
  components: {
    Navbar,
  },
  setup() {
    const router = useRouter();
    const route = useRoute();

    // State
    const user = ref(null);
    const chats = ref([]);
    const messages = ref([]);
    const selectedChat = ref(null);
    const newMessage = ref("");
    const isLoading = ref(true);
    const isSending = ref(false);
    const error = ref(null);
    const messageSubscription = ref(null);
    const chatSubscription = ref(null);
    const showNewChatModal = ref(false);
    const searchTerm = ref("");
    const searchResults = ref([]);
    const isSearching = ref(false);
    const searchTimeout = ref(null);

    // Load chats
    const loadChats = async () => {
      try {
        const { data, error: chatError } = await supabase
          .from("chats")
          .select(
            `
            id,
            name,
            updated_at,
            user_id,
            contact_id
          `
          )
          .or(`user_id.eq.${user.value.id},contact_id.eq.${user.value.id}`)
          .order("updated_at", { ascending: false });

        if (chatError) throw chatError;
        chats.value = data || [];

        // If there are chats, select the first one
        if (chats.value.length > 0) {
          selectChat(chats.value[0]);
        }
      } catch (error) {
        console.error("Errore durante il caricamento delle chat:", error);
        error.value = "Errore durante il caricamento delle chat.";
      }
    };

    // Select a chat and load its messages
    const selectChat = async (chat) => {
      selectedChat.value = chat;

      // Cancel previous subscription
      if (messageSubscription.value) {
        supabase.removeChannel(messageSubscription.value);
      }

      // Load messages
      await loadMessages();

      // Subscribe to new messages
      subscribeToMessages();
    };

    // Load messages for selected chat
    const loadMessages = async () => {
      try {
        const { data, error: messagesError } = await supabase
          .from("messages")
          .select("*")
          .eq("chat_id", selectedChat.value.id)
          .order("created_at", { ascending: true });

        if (messagesError) throw messagesError;
        messages.value = data || [];

        // Scroll to bottom
        nextTick(() => {
          const messagesContainer = document.querySelector(".chat-messages");
          if (messagesContainer) {
            messagesContainer.scrollTop = messagesContainer.scrollHeight;
          }
        });
      } catch (error) {
        console.error("Errore durante il caricamento dei messaggi:", error);
        error.value = "Errore durante il caricamento dei messaggi.";
      }
    };

    // Send message
    const sendMessage = async () => {
      if (!newMessage.value.trim() || !selectedChat.value) return;

      try {
        isSending.value = true;

        // Insert the message
        const { data, error: sendError } = await supabase
          .from("messages")
          .insert({
            chat_id: selectedChat.value.id,
            user_id: user.value.id,
            text: newMessage.value.trim(),
          })
          .select();

        if (sendError) throw sendError;

        // Update the chat's updated_at timestamp
        await supabase
          .from("chats")
          .update({ updated_at: new Date().toISOString() })
          .eq("id", selectedChat.value.id);

        newMessage.value = "";
      } catch (error) {
        console.error("Errore durante l'invio del messaggio:", error);
        error.value = "Errore durante l'invio del messaggio.";
      } finally {
        isSending.value = false;
      }
    };

    // Subscribe to new messages
    const subscribeToMessages = () => {
      messageSubscription.value = supabase
        .channel(`messages:chat_id=eq.${selectedChat.value.id}`)
        .on(
          "postgres_changes",
          {
            event: "INSERT",
            schema: "public",
            table: "messages",
            filter: `chat_id=eq.${selectedChat.value.id}`,
          },
          (payload) => {
            // Add the new message to the list
            messages.value.push(payload.new);

            // Scroll to bottom
            nextTick(() => {
              const messagesContainer =
                document.querySelector(".chat-messages");
              if (messagesContainer) {
                messagesContainer.scrollTop = messagesContainer.scrollHeight;
              }
            });
          }
        )
        .subscribe((status) => {
          if (status === "CHANNEL_ERROR") {
            console.warn(
              "Impossibile sottoscriversi ai messaggi in tempo reale"
            );
          }
        });
    };

    // Subscribe to new chats and updates
    const subscribeToChats = () => {
      chatSubscription.value = supabase
        .channel("public:chats")
        .on(
          "postgres_changes",
          {
            event: "INSERT",
            schema: "public",
            table: "chats",
            filter: `or(user_id=eq.${user.value.id},contact_id=eq.${user.value.id})`,
          },
          (payload) => {
            // Add new chat to the beginning of the list
            chats.value.unshift(payload.new);
          }
        )
        .on(
          "postgres_changes",
          {
            event: "UPDATE",
            schema: "public",
            table: "chats",
            filter: `or(user_id=eq.${user.value.id},contact_id=eq.${user.value.id})`,
          },
          (payload) => {
            // Update existing chat
            const index = chats.value.findIndex((c) => c.id === payload.new.id);
            if (index !== -1) {
              // Update the chat
              chats.value[index] = payload.new;

              // Move the chat to the top if it was updated
              if (index > 0) {
                const [chat] = chats.value.splice(index, 1);
                chats.value.unshift(chat);
              }
            }
          }
        )
        .subscribe((status) => {
          if (status === "CHANNEL_ERROR") {
            console.warn(
              "Impossibile sottoscriversi ai cambiamenti delle chat in tempo reale"
            );
          }
        });
    };

    // Search users
    const searchUsers = () => {
      clearTimeout(searchTimeout.value);

      if (searchTerm.value.trim().length < 3) {
        searchResults.value = [];
        return;
      }

      isSearching.value = true;

      searchTimeout.value = setTimeout(async () => {
        try {
          // Get auth users first
          const { data: authUsers, error: authError } =
            await supabase.auth.admin.listUsers({
              search: searchTerm.value,
              limit: 5,
              filter: {
                id: {
                  neq: user.value.id,
                },
              },
            });

          if (authError) throw authError;

          // Then get their profiles
          if (authUsers && authUsers.users) {
            const userIds = authUsers.users.map((u) => u.id);

            const { data: profiles, error: profilesError } = await supabase
              .from("profiles")
              .select("id, first_name, last_name")
              .in("id", userIds);

            if (profilesError) throw profilesError;

            // Merge auth users and profiles
            searchResults.value = authUsers.users.map((authUser) => {
              const profile = profiles?.find((p) => p.id === authUser.id) || {};
              return {
                id: authUser.id,
                first_name:
                  profile.first_name ||
                  authUser.user_metadata?.name ||
                  "Utente",
                last_name: profile.last_name || "",
                email: authUser.email,
              };
            });
          }
        } catch (error) {
          console.error("Errore durante la ricerca degli utenti:", error);
          searchResults.value = [];
        } finally {
          isSearching.value = false;
        }
      }, 500);
    };

    // Create a new chat with a user
    const createChat = async (contact) => {
      try {
        // Check if a chat with this contact already exists
        const { data: existingChats, error: searchError } = await supabase
          .from("chats")
          .select("*")
          .or(
            `and(user_id.eq.${user.value.id},contact_id.eq.${contact.id}),and(user_id.eq.${contact.id},contact_id.eq.${user.value.id})`
          );

        if (searchError) throw searchError;

        let chatId;

        if (existingChats && existingChats.length > 0) {
          // Use existing chat
          const existingChat = existingChats[0];

          // Update the chats list if the chat is not already there
          const chatExists = chats.value.some((c) => c.id === existingChat.id);

          if (!chatExists) {
            chats.value.unshift(existingChat);
          }

          // Select the chat
          selectChat(existingChat);
          return existingChat.id;
        } else {
          // Create a new chat
          const { data: newChat, error: insertError } = await supabase
            .from("chats")
            .insert({
              user_id: user.value.id,
              contact_id: contact.id,
              name:
                `${contact.first_name} ${contact.last_name}`.trim() ||
                contact.email ||
                "Utente",
              updated_at: new Date().toISOString(),
            })
            .select()
            .single();

          if (insertError) throw insertError;

          // Add to chats list and select it
          chats.value.unshift(newChat);
          selectChat(newChat);
          return newChat.id;
        }
      } catch (error) {
        console.error("Errore durante la creazione della chat:", error);
        error.value =
          "Errore durante la creazione della chat: " + (error.message || error);
        return null;
      } finally {
        // Close modal and clear search
        showNewChatModal.value = false;
        searchTerm.value = "";
        searchResults.value = [];
      }
    };

    // Create a chat with a seller
    const createChatWithSeller = async (sellerId, sellerName) => {
      try {
        console.log("Creating chat with seller:", sellerId, sellerName);

        // Check if a chat with this seller already exists
        const { data: existingChats, error: searchError } = await supabase
          .from("chats")
          .select("*")
          .or(
            `and(user_id.eq.${user.value.id},contact_id.eq.${sellerId}),and(user_id.eq.${sellerId},contact_id.eq.${user.value.id})`
          );

        if (searchError) throw searchError;

        // If chat exists, use it
        if (existingChats && existingChats.length > 0) {
          const existingChat = existingChats[0];

          // Add to chats list if not already there
          const chatExists = chats.value.some((c) => c.id === existingChat.id);

          if (!chatExists) {
            chats.value.unshift(existingChat);
          }

          // Select the chat
          selectChat(existingChat);
          return existingChat.id;
        } else {
          // Create a new chat - removed last_message field
          const { data: newChat, error: insertError } = await supabase
            .from("chats")
            .insert({
              user_id: user.value.id,
              contact_id: sellerId,
              name: sellerName || "Venditore",
              updated_at: new Date().toISOString(),
            })
            .select()
            .single();

          if (insertError) throw insertError;

          // Add to chats list and select it
          chats.value.unshift(newChat);
          selectChat(newChat);
          return newChat.id;
        }
      } catch (error) {
        console.error(
          "Errore durante la creazione della chat con il venditore:",
          error
        );
        error.value =
          "Errore durante la creazione della chat: " + (error.message || error);
        return null;
      }
    };

    // Format date for display
    const formatDate = (dateString) => {
      if (!dateString) return "";

      const date = new Date(dateString);
      const now = new Date();
      const yesterday = new Date(now);
      yesterday.setDate(yesterday.getDate() - 1);

      if (date.toDateString() === now.toDateString()) {
        return (
          "Oggi " +
          date.toLocaleTimeString("it-IT", {
            hour: "2-digit",
            minute: "2-digit",
          })
        );
      } else if (date.toDateString() === yesterday.toDateString()) {
        return (
          "Ieri " +
          date.toLocaleTimeString("it-IT", {
            hour: "2-digit",
            minute: "2-digit",
          })
        );
      } else {
        return date.toLocaleDateString("it-IT", {
          day: "2-digit",
          month: "2-digit",
          year: "numeric",
        });
      }
    };

    // Format time for display
    const formatTime = (dateString) => {
      if (!dateString) return "";
      const date = new Date(dateString);
      return date.toLocaleTimeString("it-IT", {
        hour: "2-digit",
        minute: "2-digit",
      });
    };

    // Initialize component
    onMounted(async () => {
      try {
        isLoading.value = true;

        // Check if user is authenticated
        const {
          data: { session },
          error: authError,
        } = await supabase.auth.getSession();

        if (authError) {
          console.error("Errore di autenticazione:", authError);
          error.value =
            "Errore di autenticazione. Effettua il login per utilizzare la chat.";
          isLoading.value = false;
          return;
        }

        if (!session) {
          error.value = "Devi effettuare il login per utilizzare la chat.";
          isLoading.value = false;
          // Redirect to login after a delay
          setTimeout(() => {
            router.push("/login");
          }, 2000);
          return;
        }

        user.value = session.user;
        console.log("User authenticated:", user.value.id);

        // Load user's chats
        await loadChats();

        // Subscribe to realtime updates if chats loaded successfully
        if (!error.value) {
          try {
            subscribeToChats();
          } catch (subError) {
            console.warn(
              "Impossibile attivare sottoscrizioni realtime:",
              subError
            );
            // Don't block app flow for subscription errors
          }
        }

        // Check if there are query parameters to open a specific chat
        // This happens when "Contatta il venditore" is clicked from a product page
        if (route.query.seller_id && route.query.seller_name) {
          const sellerId = route.query.seller_id;
          const sellerName = route.query.seller_name;

          console.log("Opening chat with seller:", sellerId, sellerName);

          // Create or select chat with this seller
          await createChatWithSeller(sellerId, sellerName);

          // If a product is also specified, prepare an initial message
          if (route.query.product_id && route.query.product_name) {
            newMessage.value = `Ciao, sono interessato al tuo libro "${route.query.product_name}"`;
          }
        }

        isLoading.value = false;
      } catch (error) {
        console.error("Errore durante l'inizializzazione:", error);
        error.value =
          "Si è verificato un errore durante il caricamento della chat.";
        isLoading.value = false;
      }
    });

    // Cleanup subscriptions when component is unmounted
    onBeforeUnmount(() => {
      if (messageSubscription.value) {
        supabase.removeChannel(messageSubscription.value);
      }
      if (chatSubscription.value) {
        supabase.removeChannel(chatSubscription.value);
      }
    });

    return {
      user,
      chats,
      messages,
      selectedChat,
      newMessage,
      isLoading,
      isSending,
      error,
      showNewChatModal,
      searchTerm,
      searchResults,
      isSearching,
      loadChats,
      selectChat,
      loadMessages,
      sendMessage,
      searchUsers,
      createChat,
      createChatWithSeller,
      formatDate,
      formatTime,
    };
  },
};
</script>

<style scoped>
/* Navbar Styles */
.navbar {
  background-color: #6a0dad;
  padding: 1rem;
  border-bottom: 1px solid #ddd;
}

/* Base Layout */
.chat-container {
  display: flex;
  height: calc(100vh - 140px);
  background: linear-gradient(145deg, #ffffff, #f8f9fa);
  margin: 20px;
  border-radius: 24px;
  box-shadow: 0 12px 40px rgba(106, 13, 173, 0.08);
  overflow: hidden;
  border: 1px solid rgba(106, 13, 173, 0.1);
}

/* Enhanced Sidebar */
.chat-sidebar {
  width: 360px;
  background-color: #ffffff;
  border-right: 1px solid rgba(106, 13, 173, 0.1);
  display: flex;
  flex-direction: column;
}

.chat-header {
  padding: 1.8rem;
  background: linear-gradient(135deg, #6a0dad, #8a2be2);
  color: white;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 4px 20px rgba(106, 13, 173, 0.2);
}

.chat-header h2 {
  font-size: 1.5rem;
  font-weight: 600;
  letter-spacing: 0.02em;
  margin: 0;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
  color: #ffffff;
}

.new-chat-btn {
  background: rgba(255, 255, 255, 0.15);
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 14px;
  padding: 0.8rem 1.4rem;
  font-size: 0.95rem;
  font-weight: 500;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  backdrop-filter: blur(8px);
  font-size: 0.95rem;
  font-weight: 500;
  letter-spacing: 0.02em;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.new-chat-btn span {
  font-size: 1.2rem;
  line-height: 1;
}

.new-chat-btn:hover {
  background: rgba(255, 255, 255, 0.25);
  transform: translateY(-2px);
  box-shadow: 0 6px 15px rgba(0, 0, 0, 0.15);
}

/* Improved Chat List */
.chat-list {
  overflow-y: auto;
  flex: 1;
}

.chat-item {
  padding: 1.4rem;
  border-bottom: 1px solid rgba(106, 13, 173, 0.08);
  transition: all 0.3s ease;
  cursor: pointer;
  background: white;
}

.chat-item:hover {
  background: linear-gradient(
    to right,
    rgba(106, 13, 173, 0.03),
    rgba(106, 13, 173, 0.01)
  );
  transform: translateX(4px);
}

.active .chat-item {
  background: linear-gradient(to right, rgba(106, 13, 173, 0.08), transparent);
  border-left: 4px solid #6a0dad;
}

.chat-item h3 {
  font-size: 1.1rem;
  font-weight: 600;
  color: #2d3436;
  margin: 0 0 0.4rem 0;
  line-height: 1.3;
}

.chat-item p {
  color: #64748b;
  font-size: 0.9rem;
  margin: 0 0 0.3rem 0;
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.chat-item small {
  color: #6a0dad;
  font-size: 0.8rem;
  font-weight: 500;
  opacity: 0.8;
}

/* Main Chat Area */
.chat-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  background-color: #ffffff;
}

/* Enhanced Messages Area */
.chat-messages {
  padding: 2rem;
  background: linear-gradient(170deg, #f8f9fa 0%, #ffffff 100%);
  display: flex;
  flex-direction: column;
  gap: 1.2rem;
  overflow-y: auto;
}

.message {
  padding: 1.2rem 1.4rem;
  border-radius: 18px;
  max-width: 60%;
  box-shadow: 0 3px 12px rgba(0, 0, 0, 0.05);
  position: relative;
  transition: all 0.3s ease;
  line-height: 1.5;
  font-size: 0.95rem;
}

.message p {
  margin: 0;
  line-height: 1.5;
}

.message.sent {
  background: linear-gradient(135deg, #6a0dad, #8a2be2);
  color: white;
  align-self: flex-end;
  border-bottom-right-radius: 4px;
  animation: messageSent 0.3s ease;
}

.message.received {
  background: white;
  color: #2d3436;
  align-self: flex-start;
  border-bottom-left-radius: 4px;
  border: 1px solid rgba(106, 13, 173, 0.1);
  animation: messageReceived 0.3s ease;
}

@keyframes messageSent {
  from {
    opacity: 0;
    transform: translateX(20px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes messageReceived {
  from {
    opacity: 0;
    transform: translateX(-20px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.message-time {
  font-size: 0.75rem;
  margin-top: 0.4rem;
  opacity: 0.8;
  display: block;
}

/* Improved Input Area */
.chat-input {
  padding: 1.5rem;
  background: white;
  border-top: 1px solid rgba(106, 13, 173, 0.1);
  display: flex;
  gap: 1rem;
  align-items: center;
  box-shadow: 0 -4px 20px rgba(0, 0, 0, 0.03);
}

.chat-input input {
  flex: 1;
  padding: 1rem 1.4rem;
  border: 2px solid rgba(106, 13, 173, 0.1);
  border-radius: 14px;
  font-size: 1rem;
  transition: all 0.3s ease;
  background: #f8f9fa;
  font-size: 0.95rem;
  color: #1e293b;
}

.chat-input input:focus {
  outline: none;
  border-color: #6a0dad;
  background: white;
  box-shadow: 0 0 0 4px rgba(106, 13, 173, 0.1);
}

.chat-input input::placeholder {
  color: #94a3b8;
  font-weight: 400;
}

.chat-input button {
  padding: 1rem 2rem;
  background: linear-gradient(135deg, #6a0dad, #8a2be2);
  color: white;
  border: none;
  border-radius: 14px;
  font-weight: 500;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 12px rgba(106, 13, 173, 0.2);
  font-size: 0.95rem;
  font-weight: 500;
  letter-spacing: 0.02em;
}

.chat-input button:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(106, 13, 173, 0.3);
}

.chat-input button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* Modal Styles - Fixed */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(8px);
  z-index: 1000;
}

.modal-content {
  position: relative;
  background: white;
  border-radius: 20px;
  padding: 2.5rem;
  width: 95%;
  max-width: 550px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
  animation: modalFadeIn 0.4s cubic-bezier(0.16, 1, 0.3, 1);
}

.modal-content h3 {
  font-size: 1.8rem;
  color: #6a0dad;
  margin-bottom: 1.5rem;
  font-weight: 600;
  font-size: 1.6rem;
  color: #6a0dad;
  margin: 0 0 1.5rem 0;
  font-weight: 600;
  line-height: 1.3;
}

.search-container {
  position: relative;
}

.search-container input {
  width: 100%;
  padding: 1rem 1.2rem;
  font-size: 1.1rem;
  border: 2px solid rgba(106, 13, 173, 0.1);
  border-radius: 12px;
  background-color: #f8f9fa;
  transition: all 0.3s ease;
}

.search-container input:focus {
  outline: none;
  border-color: #6a0dad;
  background-color: #ffffff;
  box-shadow: 0 0 0 4px rgba(106, 13, 173, 0.1);
}

.search-container input::placeholder {
  color: #94a3b8;
  font-weight: 400;
}

.search-results {
  margin-top: 1rem;
  border: 1px solid rgba(106, 13, 173, 0.1);
  border-radius: 12px;
  overflow: hidden;
  max-height: 350px;
  overflow-y: auto;
  background: white;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.search-result-item {
  padding: 1.2rem;
  border-bottom: 1px solid rgba(106, 13, 173, 0.08);
  transition: all 0.3s ease;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  gap: 0.3rem;
}

.search-result-item:last-child {
  border-bottom: none;
}

.search-result-item h4 {
  font-size: 1.1rem;
  color: #2d3436;
  margin: 0;
  font-weight: 500;
  font-size: 1.05rem;
  color: #1e293b;
  margin: 0;
  font-weight: 500;
  line-height: 1.4;
}

.search-result-item p {
  font-size: 0.9rem;
  color: #6c757d;
  margin: 0;
  font-size: 0.9rem;
  color: #64748b;
  margin: 0;
  line-height: 1.4;
}

.search-result-item:hover {
  background-color: rgba(106, 13, 173, 0.05);
  transform: translateX(5px);
}

.modal-close {
  position: absolute;
  top: 1.2rem;
  right: 1.2rem;
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: rgba(106, 13, 173, 0.1);
  color: #6a0dad;
  font-size: 1.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
  border: none;
}

.modal-close:hover {
  background: rgba(106, 13, 173, 0.2);
  transform: rotate(90deg);
}

.no-results,
.searching {
  padding: 2rem;
  text-align: center;
  color: #6c757d;
  font-size: 1.1rem;
  background: #f8f9fa;
  border-radius: 12px;
  margin-top: 1rem;
}

.searching {
  color: #6a0dad;
  background: rgba(106, 13, 173, 0.05);
}

@keyframes modalFadeIn {
  from {
    opacity: 0;
    transform: translateY(-30px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

/* Loading and Error States */
.loading,
.error-message {
  padding: 2rem;
  text-align: center;
  background: linear-gradient(145deg, #ffffff, #f8f9fa);
  border-radius: 16px;
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.08);
  animation: fadeIn 0.3s ease;
  font-size: 1rem;
  font-weight: 500;
  line-height: 1.5;
  text-align: center;
}

.error-message {
  color: #dc3545;
  background: rgba(220, 53, 69, 0.1);
  color: #dc2626;
  font-weight: 500;
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.no-messages,
.no-chat-selected {
  color: #64748b;
  font-size: 1rem;
  text-align: center;
  padding: 2rem;
  font-weight: 500;
  background: rgba(106, 13, 173, 0.03);
  border-radius: 12px;
  line-height: 1.5;
}

.no-chats {
  text-align: center;
  padding: 2rem;
  color: #64748b;
  font-size: 0.95rem;
  font-weight: 500;
  background: rgba(106, 13, 173, 0.03);
  margin: 1rem;
  border-radius: 12px;
}

/* Responsive Design */
@media (max-width: 768px) {
  .chat-container {
    margin: 10px;
    height: calc(100vh - 100px);
  }

  .chat-sidebar {
    width: 100%;
    max-height: 40vh;
  }

  .message {
    max-width: 75%;
  }

  .chat-input {
    padding: 1rem;
  }
}
</style>
