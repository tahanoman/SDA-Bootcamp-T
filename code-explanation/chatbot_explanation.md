# Chatbot Code Explanation

This document provides a detailed explanation of the `chatbot.py` script, following a structured format with explanations and code blocks.

---

## 1. Import Required Libraries

The script begins by importing the necessary libraries:

```python
import streamlit as st
import uuid
import requests
```

- **`streamlit`**: Used to create the web UI and manage state across user interactions.
- **`uuid`**: Generates unique identifiers to ensure chat sessions have unique IDs.
- **`requests`**: Handles HTTP requests to the backend API endpoints.

---

## 2. Initialize Session State

Session state is used to persist chat data across reruns of the Streamlit app.

```python
if "history_chats" not in st.session_state:
    st.session_state["history_chats"] = []
if "current_chat" not in st.session_state:
    st.session_state["current_chat"] = None
if "chat_names" not in st.session_state:
    st.session_state["chat_names"] = {}
```

### Explanation:
- `history_chats`: Stores all past chats.
- `current_chat`: Tracks the currently selected chat.
- `chat_names`: Maps chat IDs to their respective names for easy access.
- Ensuring the variables exist prevents `KeyError` during interactions.

---

## 3. Load Chats from Database

Retrieves stored chat data from the backend.

```python
def load_chats_from_db():
    response = requests.get("http://127.0.0.1:8000/load_chat/")
```

- Sends a `GET` request to the backend to fetch saved chats.

```python
    if response.status_code == 200:
        records = response.json()
        for record in records:
            chat_id = record['id']
            messages = record['messages']
            name = record['chat_name']
```

- Parses the response JSON and extracts:
  - `chat_id`: Unique ID of the chat.
  - `messages`: List of messages exchanged in the chat.
  - `chat_name`: Friendly name assigned to the chat.

```python
            st.session_state["history_chats"].append({"id": chat_id, "messages": messages})
            st.session_state["chat_names"][chat_id] = name
```

- Stores chat data in the session state.
- Maps the chat ID to its name for UI reference.

---

## 4. Save Chat to Database

Stores chat data to the backend database for future retrieval.

```python
def save_chat_to_db(chat_id, chat_name, messages):
    payload = {
        "chat_id": chat_id,
        "chat_name": chat_name,
        "messages": messages
    }
    headers = {"Content-Type": "application/json"}
```

- Prepares the chat data payload.
- Specifies JSON content type for the request.

```python
    response = requests.post("http://127.0.0.1:8000/save_chat/", json=payload, headers=headers)
```

- Sends a `POST` request to save chat data.

### Error Handling:

```python
    if response.status_code != 200:
        print(f"Failed to save data. Status code: {response.status_code}")
```

- Prints an error message if the response status is not successful.

---

## 5. Create New Chat

Generates a new chat session.

```python
def create_chat(chat_name):
    new_chat_id = str(uuid.uuid4())
```

- Generates a unique chat ID using the `uuid` library.

```python
    new_chat = {"id": new_chat_id, "messages": []}
    st.session_state["history_chats"].insert(0, new_chat)
    st.session_state["chat_names"][new_chat_id] = chat_name
    st.session_state["current_chat"] = new_chat_id
```

- Adds the new chat to the session state.
- Sets the new chat as the current active chat.

```python
    save_chat_to_db(new_chat_id, chat_name, [])
```

- Calls the save function to store the new chat.

---

## 6. Delete Chat

Deletes a selected chat session.

```python
def delete_chat():
    if st.session_state["current_chat"]:
        chat_id = st.session_state["current_chat"]
        payload = {"chat_id": chat_id}
        headers = {"Content-Type": "application/json"}
```

- Checks if a chat is selected.
- Prepares the payload for deletion.

```python
        response = requests.post("http://127.0.0.1:8000/delete_chat/", json=payload, headers=headers)
```

- Sends the request to delete the chat from the backend.

---

## 7. Select Chat Function

Handles chat selection when a user picks a chat from the sidebar.

```python
def select_chat(chat_id):
    st.session_state["current_chat"] = chat_id
```

- Updates the session state to set the selected chat ID as the active chat.
- Ensures that future interactions refer to the chosen chat.

---

## 8. Sidebar Navigation

The sidebar section allows users to create and manage chat sessions.

```python
with st.sidebar:
    st.title("Chat Management")
    chat_name = st.text_input("Enter Chat Name:", key="new_chat_name")
    if st.button("Create New Chat"):
        if chat_name.strip():
            create_chat(chat_name.strip())
        else:
            st.warning("Chat name cannot be empty.")
```

- Provides a sidebar for managing chats.
- Takes user input for new chat name.
- Calls `create_chat` function if a valid name is entered.

```python
    if st.session_state["history_chats"]:
        chat_options = {
            chat["id"]: st.session_state["chat_names"][chat["id"]]
            for chat in st.session_state["history_chats"]
        }
```

- Retrieves stored chat history to populate chat selection.

```python
        selected_chat = st.radio(
            "Select Chat",
            options=list(chat_options.keys()),
            format_func=lambda x: chat_options[x],
            key="chat_selector",
            on_change=lambda: select_chat(st.session_state.chat_selector),
        )
```

- Allows the user to select an existing chat via a radio button.
- Updates the `current_chat` when a new selection is made.

```python
        st.button("Delete Chat", on_click=delete_chat)
```

- Provides a button to delete the selected chat.

---


## 9. Display and Handle Chat Messages

The chat interface displays previous messages and processes new user inputs.

```python
if st.session_state["current_chat"]:
    chat_id = st.session_state["current_chat"]
    chat_name = st.session_state["chat_names"][chat_id]
    st.subheader(f"Current Chat: {chat_name}")
```

- Checks if a chat is currently selected.
- Retrieves the chat ID and name from session state.
- Displays the chat name as a subheader in the UI.

```python
    current_chat = next(
        (chat for chat in st.session_state["history_chats"] if chat["id"] == chat_id),
        None,
    )
```

- Searches the stored chat history for the selected chat ID.
- Assigns the found chat to `current_chat` or `None` if not found.

```python
    if current_chat:
        for message in current_chat["messages"]:
            with st.chat_message(message["role"]):
                st.markdown(message["content"])
```

- Iterates through chat messages and displays them.
- Messages are displayed with their role (e.g., `user` or `assistant`).

```python
        if prompt := st.chat_input("Your Message:"):
            current_chat["messages"].append({"role": "user", "content": prompt})
```

- Captures user input via the chat input box.
- Appends the user's message to the chat history.

```python
            with st.chat_message("user"):
                st.markdown(prompt)
```

- Displays the user's message in the chat interface.

```python
            with st.chat_message("assistant"):
                payload = {
                    "messages": [
                        {"role": m["role"], "content": m["content"]}
                        for m in current_chat["messages"]
                    ]
                }
                headers = {"Content-Type": "application/json"}
```

- Prepares the payload for the backend request by structuring the chat messages.
- Specifies the request headers.

```python
                def get_stream_response():
                    with requests.post("http://127.0.0.1:8000/chat/", json=payload, headers=headers, stream=True) as r:
                        for chunk in r:
                            yield chunk.decode("utf-8")
```

- Sends the chat data to the backend API with streaming enabled.
- Decodes and yields each chunk of the response in real-time.

```python
                response = st.write_stream(get_stream_response)
                current_chat["messages"].append({"role": "assistant", "content": response})
```

- Displays the assistant's response as it streams.
- Appends the assistant's message to the chat history.

---

## 10. Running the Application

To run the chatbot application, execute the following command:

```bash
streamlit run chatbot.py
```



