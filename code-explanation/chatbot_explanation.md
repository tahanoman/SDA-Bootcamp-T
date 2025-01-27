# Chatbot Frontend Explanation

This document provides a complete explanation of the updated `chatbot.py` script, which serves as the frontend for the chatbot application using **Streamlit**. It includes chat session management, chat creation, deletion, and interaction with a FastAPI backend.

---

## 1. Import Required Libraries

The script starts by importing the necessary libraries:

- **`streamlit`**: A Python library to build interactive web applications.
- **`uuid`**: Used to generate unique chat IDs.
- **`requests`**: A library used to send HTTP requests to the backend API.

```python
import streamlit as st
import uuid
import requests
```

---

## 2. Initialize Session State
Streamlit's session state is used to maintain persistent values across reruns:

- **`history_chats`**: Stores all previously created chats.
- **`current_chat`**: Keeps track of the currently selected chat.
- **`chat_names`**: Maps chat IDs to their respective names.

```
if "history_chats" not in st.session_state:
    st.session_state["history_chats"] = []
if "current_chat" not in st.session_state:
    st.session_state["current_chat"] = None
if "chat_names" not in st.session_state:
    st.session_state["chat_names"] = {}
```

---

## 3. Load Chats from Database
The function `load_chats_from_db()` sends a GET request to the backend to retrieve stored chats from the database and updates session state accordingly.

```
def load_chats_from_db():
    response = requests.get("http://127.0.0.1:8000/load_chat/")

    if response.status_code == 200:
        records = response.json()
        for record in records:
            chat_id = record['id']
            messages = record['messages']
            name = record['chat_name']
            st.session_state["history_chats"].append({"id": chat_id, "messages": messages})
            st.session_state["chat_names"][chat_id] = name
    else:
        print(f"Failed to retrieve data. Status code: {response.status_code}")
```

---

## 4. Save Chats to Database
The function `save_chat_to_db()` sends a POST request to the backend to store chat messages.

```
def save_chat_to_db(chat_id, chat_name, messages):
    payload = {
        "chat_id": chat_id,
        "chat_name": chat_name,
        "messages": messages
    }
    headers = {"Content-Type": "application/json"}

    response = requests.post("http://127.0.0.1:8000/save_chat/", json=payload, headers=headers)

    if response.status_code != 200:
        print(f"Failed to save data. Status code: {response.status_code}")
```
---

## 5. Create a New Chat
The function `create_chat()` generates a unique chat ID and initializes it in session state.

```
def create_chat(chat_name):
    new_chat_id = str(uuid.uuid4())
    new_chat = {"id": new_chat_id, "messages": []}
    st.session_state["history_chats"].insert(0, new_chat)
    st.session_state["chat_names"][new_chat_id] = chat_name
    st.session_state["current_chat"] = new_chat_id
    
    save_chat_to_db(new_chat_id, chat_name, [])
```

---

## 6. Delete a Chat
The function `delete_chat()` removes a chat from session state and sends a request to the backend for deletion.

```
def delete_chat():
    if st.session_state["current_chat"]:
        chat_id = st.session_state["current_chat"]
        st.session_state["history_chats"] = [
            chat for chat in st.session_state["history_chats"] if chat["id"] != chat_id
        ]
        del st.session_state["chat_names"][chat_id]
        payload = {"chat_id": chat_id}
        headers = {"Content-Type": "application/json"}

        response = requests.post("http://127.0.0.1:8000/delete_chat/", json=payload, headers=headers)

        if response.status_code != 200:
            print(f"Failed to delete data. Status code: {response.status_code}")

        st.session_state["current_chat"] = (
            st.session_state["history_chats"][0]["id"] if st.session_state["history_chats"] else None
        )
```

---

## 7. Sidebar for Chat Management
The sidebar provides an interface to create and select chats dynamically.

```
with st.sidebar:
    st.title("Chat Management")
    chat_name = st.text_input("Enter Chat Name:", key="new_chat_name")
    if st.button("Create New Chat"):
        if chat_name.strip():
            create_chat(chat_name.strip())
        else:
            st.warning("Chat name cannot be empty.")
```

---

## 8. Main Chat Interface
The main content section displays chat messages and handles user input.

```
if st.session_state["current_chat"]:
    chat_id = st.session_state["current_chat"]
    chat_name = st.session_state["chat_names"][chat_id]
    st.subheader(f"Current Chat: {chat_name}")

    current_chat = next(
        (chat for chat in st.session_state["history_chats"] if chat["id"] == chat_id),
        None,
    )

    if current_chat:
        for message in current_chat["messages"]:
            with st.chat_message(message["role"]):
                st.markdown(message["content"])
```

---

## 9. Sending Messages
When the user sends a message, it is processed and streamed from the backend.

```
        if prompt := st.chat_input("Your Message:"):
            current_chat["messages"].append({"role": "user", "content": prompt})
            with st.chat_message("user"):
                st.markdown(prompt)

            with st.chat_message("assistant"):
                payload = {
                    "messages": [
                        {"role": m["role"], "content": m["content"]}
                        for m in current_chat["messages"]
                    ]
                }
                headers = {"Content-Type": "application/json"}

                def get_stream_response():
                    with requests.post("http://127.0.0.1:8000/chat/", json=payload, headers=headers, stream=True) as r:
                        for chunk in r:
                            yield chunk.decode("utf-8")

                response = st.write_stream(get_stream_response)
                current_chat["messages"].append({"role": "assistant", "content": response})
                save_chat_to_db(chat_id, chat_name, current_chat["messages"])
```

---

## 10. Running the Application
To run the chatbot, use the following command:

```
streamlit run chatbot.py
```