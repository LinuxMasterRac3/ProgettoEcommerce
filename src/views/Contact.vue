<template>
  <div class="page-container">
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
      <div class="chat-sidebar">
        <div class="chat-sidebar-header">Chat</div>
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
      </div>
      <div class="chat-main">
        <div class="chat-header">
          {{ selectedChat ? selectedChat.name : "Seleziona una chat" }}
        </div>
        <div class="chat-content">
          <div v-if="selectedChat">
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
            <p>
              Seleziona una conversazione dalla lista o inizia una nuova chat
            </p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal per nuova chat -->
    <Transition name="modal">
      <div
        v-if="showNewChatModal"
        class="modal"
        @click="showNewChatModal = false">
        <div
          class="modal-content"
          @click.stop>
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
              @input="searchUsers"
              autofocus />

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
    </Transition>

    <!-- Add Footer -->
    <Footer />
  </div>
</template>

<script>
import { ref, onMounted, onBeforeUnmount, nextTick } from "vue";
import { useRoute, useRouter } from "vue-router";
import { createClient } from "@supabase/supabase-js";
import Navbar from "@/components/Navbar.vue";
import Footer from "@/components/footer.vue"; // Add this import

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
    Footer, // Add Footer to components
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
.page-container {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

/* Chat container */
.chat-container {
  display: flex;
  height: calc(100vh - 180px);
  margin: 20px;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  background: #ffffff;
}

/* Sidebar */
.chat-sidebar {
  width: 300px;
  background-color: #ffffff;
  border-right: 1px solid #e2e8f0;
  display: flex;
  flex-direction: column;
}

/* Sidebar header */
.chat-sidebar-header {
  background: #6a0dad;
  color: white;
  padding: 16px;
  font-size: 1.3rem;
  font-weight: 500;
  height: 60px;
  display: flex;
  align-items: center;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

/* Main chat area */
.chat-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  height: 100%;
}

/* Chat header (DESTRA) */
.chat-header {
  background: #6a0dad;
  color: white;
  padding: 16px;
  font-size: 1.3rem;
  font-weight: 500;
  height: 60px;
  display: flex;
  align-items: center;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  /* RIMUOVI eventuali margin-top! */
}

/* Chat list */
.chat-list {
  flex: 1;
  overflow-y: auto;
  padding: 10px;
  background: #fff;
}

/* New Chat Button */
.new-chat-btn {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  gap: 6px;
  transition: all 0.2s ease;
  cursor: pointer;
}

.new-chat-btn:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-1px);
}

/* Chat list styles */
.chat-list {
  flex: 1;
  overflow-y: auto;
  padding: 10px;
}

.chat-list li {
  cursor: pointer;
  border-radius: 8px;
  transition: all 0.2s ease;
  margin-bottom: 8px;
}

.chat-list li:hover {
  background: #f8f7ff;
}

.chat-list li.active {
  background: #f0e6ff;
  border-left: 3px solid #6a0dad;
}

.chat-item {
  padding: 12px;
}

.chat-item h3 {
  font-size: 1rem;
  color: #1e293b;
  margin-bottom: 4px;
}

.chat-item p {
  font-size: 0.9rem;
  color: #64748b;
  margin-bottom: 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.chat-item small {
  font-size: 0.8rem;
  color: #94a3b8;
}

/* Main chat area */
.chat-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  height: 100%;
}

.chat-content {
  display: flex;
  flex-direction: column;
  height: 100%;
  position: relative;
  overflow: hidden; /* Impedisce lo scroll del contenitore principale */
}

.chat-messages {
  flex: 1;
  padding: 20px;
  padding-bottom: 100px; /* Spazio per l'input box */
  overflow-y: auto;
  background: #ffffff;
  display: flex;
  flex-direction: column;
  gap: 12px;
  min-height: 0;
  max-height: calc(100% - 80px); /* Limita l'altezza per non sforare */
  scrollbar-width: thin;
  scrollbar-color: #6a0dad transparent;
}

.chat-input {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 16px 24px;
  background: white;
  border-top: 1px solid #e2e8f0;
  display: flex;
  gap: 16px;
  align-items: center;
  height: 80px;
  z-index: 10;
  box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.05);
}

/* Modal Styles */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 12px;
  padding: 24px;
  width: 90%;
  max-width: 500px;
  position: relative;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
}

.modal-close {
  position: absolute;
  top: 16px;
  right: 16px;
  font-size: 24px;
  color: #64748b;
  cursor: pointer;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: all 0.2s ease;
}

.modal-close:hover {
  background: #f1f5f9;
  color: #1e293b;
}

.search-container {
  margin-top: 20px;
}

.search-container input {
  width: 100%;
  padding: 12px 16px;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  font-size: 0.95rem;
  margin-bottom: 16px;
}

.search-container input:focus {
  outline: none;
  border-color: #6a0dad;
  box-shadow: 0 0 0 2px rgba(106, 13, 173, 0.1);
}

.search-results {
  max-height: 300px;
  overflow-y: auto;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
}

.search-result-item {
  padding: 12px 16px;
  border-bottom: 1px solid #e2e8f0;
  cursor: pointer;
  transition: all 0.2s ease;
}

.search-result-item:last-child {
  border-bottom: none;
}

.search-result-item:hover {
  background: #f8f7ff;
}

.search-result-item h4 {
  color: #1e293b;
  margin-bottom: 4px;
}

.search-result-item p {
  color: #64748b;
  font-size: 0.9rem;
}

.no-results,
.searching {
  text-align: center;
  padding: 20px;
  color: #64748b;
}

/* Modal Animation */
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

/* Media Queries */
@media (max-width: 768px) {
  .chat-container {
    margin: 10px;
    height: calc(100vh - 140px);
  }

  .chat-messages {
    padding-bottom: 100px;
  }

  .chat-input {
    height: 70px;
    padding: 12px;
  }
}

/* Messages styling */
.message {
  max-width: 70%;
  padding: 12px 16px;
  border-radius: 16px;
  position: relative;
  margin: 8px 0;
}

.message p {
  margin: 0;
  font-size: 0.95rem;
  line-height: 1.4;
}

.message.sent {
  background: #6a0dad;
  color: white;
  align-self: flex-end;
  border-bottom-right-radius: 4px;
}

.message.received {
  background: #f3f4f6;
  color: #1e293b;
  align-self: flex-start;
  border-bottom-left-radius: 4px;
}

.message-time {
  font-size: 0.75rem;
  opacity: 0.8;
  margin-top: 4px;
  display: block;
}

/* Chat messages scroll area */
.chat-messages {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  background: #ffffff;
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding-bottom: 90px;
}

.chat-messages::-webkit-scrollbar {
  width: 6px;
}

.chat-messages::-webkit-scrollbar-track {
  background: transparent;
}

.chat-messages::-webkit-scrollbar-thumb {
  background-color: #6a0dad;
  border-radius: 20px;
  border: 2px solid #ffffff;
}

/* Input box styling */
.chat-input {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 16px 24px;
  background: white;
  border-top: 1px solid #e2e8f0;
  display: flex;
  gap: 16px;
  align-items: center;
  height: 80px;
  z-index: 10;
  box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.05);
}

.chat-input input {
  flex: 1;
  padding: 12px 20px;
  border: 2px solid #e2e8f0;
  border-radius: 24px;
  font-size: 0.95rem;
  transition: all 0.2s ease;
}

.chat-input input:focus {
  outline: none;
  border-color: #6a0dad;
  box-shadow: 0 0 0 2px rgba(106, 13, 173, 0.1);
}

.chat-input button {
  padding: 12px 24px;
  background: #6a0dad;
  color: white;
  border: none;
  border-radius: 24px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.chat-input button:hover {
  background: #5a0b8d;
  transform: translateY(-1px);
}

.chat-input button:disabled {
  background: #a884d1;
  cursor: not-allowed;
  transform: none;
}
</style>
