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

## 2. Define Backend URLs

The backend URLs are defined to interact with the API endpoints:

```python
LOAD_CHAT_URL = "http://127.0.0.1:5000/load_chat/"
SAVE_CHAT_URL = "http://127.0.0.1:5000/save_chat/"
DELETE_CHAT_URL = "http://127.0.0.1:5000/delete_chat/"
UPLOAD_PDF_URL = "http://127.0.0.1:5000/upload_pdf/"
CHAT_URL = "http://127.0.0.1:5000/chat/"
RAG_CHAT_URL = "http://127.0.0.1:5000/rag_chat/"
```

- These URLs are used to communicate with the backend for loading chats, saving chats, deleting chats, uploading PDFs, and handling chat interactions.

---

## 3. Initialize Session State

Session state is used to persist chat data across reruns of the Streamlit app:

```python
if "history_chats" not in st.session_state:
    st.session_state["history_chats"] = []
if "current_chat" not in st.session_state:
    st.session_state["current_chat"] = None
if "chat_names" not in st.session_state:
    st.session_state["chat_names"] = {}
```

### Explanation:
- `history_chats`: Stores all past chats, including their messages and associated PDF metadata.
- `current_chat`: Tracks the currently selected chat.
- `chat_names`: Maps chat IDs to their respective names for easy access.
- Ensuring the variables exist prevents `KeyError` during interactions.

---

## 4. Load Chats from Database

Retrieves stored chat data from the backend:

```python
def load_chats_from_db():
    response = requests.get(LOAD_CHAT_URL)
```

- Sends a `GET` request to the backend to fetch saved chats.

```python
    if response.status_code == 200:
        records = response.json()
        for record in records:
            chat_id = record['id']
            messages = record['messages']
            name = record['chat_name']
            pdf_path = record['pdf_path']
            pdf_name = record['pdf_name']
            pdf_uuid = record['pdf_uuid']
```

- Parses the response JSON and extracts:
  - `chat_id`: Unique ID of the chat.
  - `messages`: List of messages exchanged in the chat.
  - `chat_name`: Friendly name assigned to the chat.
  - `pdf_path`: Path to the associated PDF file.
  - `pdf_name`: Name of the associated PDF file.
  - `pdf_uuid`: Unique identifier for the PDF file.

```python
            st.session_state["history_chats"].append({
                "id": chat_id, 
                "messages": messages, 
                "pdf_name": pdf_name, 
                "pdf_path": pdf_path, 
                "pdf_uuid": pdf_uuid
            })
            st.session_state["chat_names"][chat_id] = name
```

- Stores chat data in the session state.
- Maps the chat ID to its name for UI reference.

```python
    else:
        print(f"Failed to retrieve data. Status code: {response.status_code}")
```

- Prints an error message if the response status is not successful.

---

## 5. Save Chat to Database

Stores chat data to the backend database for future retrieval:

```python
def save_chat_to_db(chat_id, chat_name, messages, pdf_name, pdf_path, pdf_uuid):
    payload = {
        "chat_id": chat_id,
        "chat_name": chat_name,
        "messages": messages,
        "pdf_name": pdf_name,
        "pdf_path": pdf_path,
        "pdf_uuid": pdf_uuid
    }
    headers = {"Content-Type": "application/json"}
```

- Prepares the chat data payload, including chat ID, name, messages, and PDF metadata.
- Specifies JSON content type for the request.

```python
    response = requests.post(SAVE_CHAT_URL, json=payload, headers=headers)
```

- Sends a `POST` request to save chat data.

### Error Handling:

```python
    if response.status_code != 200:
        print(f"Failed to save data. Status code: {response.status_code}")
```

- Prints an error message if the response status is not successful.

---

## 6. Create New Chat with PDF

Creates a new chat session with an associated PDF file:

```python
def create_chat_with_pdf(chat_name, uploaded_pdf):
    with st.spinner("Uploading and Processing document, please wait..."):
        files = {"file": (uploaded_pdf.name, uploaded_pdf.getvalue(), "application/pdf")}
```

- Displays a loading spinner while the PDF is being uploaded and processed.
- Prepares the file payload for the upload request.

```python
        response = requests.post(UPLOAD_PDF_URL, files=files)
```

- Sends a `POST` request to upload the PDF file.

```python
        if response.status_code == 200:
            pdf_path = response.json()["pdf_path"]
            pdf_uuid = response.json()["pdf_uuid"]
```

- Extracts the PDF path and UUID from the response.

```python
            new_chat_id = str(uuid.uuid4())
            new_chat = {
                "id": new_chat_id, 
                "messages": [], 
                "pdf_name": uploaded_pdf.name, 
                "pdf_path": pdf_path, 
                "pdf_uuid": pdf_uuid
            }
            st.session_state["history_chats"].insert(0, new_chat)
            st.session_state["chat_names"][new_chat_id] = chat_name
            st.session_state["current_chat"] = new_chat_id
```

- Generates a new chat ID and initializes the chat session.
- Adds the new chat to the session state and sets it as the current chat.

```python
            save_chat_to_db(new_chat_id, chat_name, [], uploaded_pdf.name, pdf_path, pdf_uuid)
            st.success("Successed!")
```

- Saves the new chat to the database and displays a success message.

```python
        else:
            st.error("Failed to upload PDF.")
```

- Displays an error message if the upload fails.

---

## 7. Create New Chat

Creates a new chat session without an associated PDF:

```python
def create_chat(chat_name):
    new_chat_id = str(uuid.uuid4())
    new_chat = {
        "id": new_chat_id, 
        "messages": [], 
        "pdf_name": None, 
        "pdf_path": None, 
        "pdf_uuid": None
    }
    st.session_state["history_chats"].insert(0, new_chat)
    st.session_state["chat_names"][new_chat_id] = chat_name
    st.session_state["current_chat"] = new_chat_id
```

- Generates a new chat ID and initializes the chat session.
- Adds the new chat to the session state and sets it as the current chat.

```python
    save_chat_to_db(new_chat_id, chat_name, [], None, None, None)
```

- Saves the new chat to the database.

---

## 8. Delete Chat

Deletes a selected chat session:

```python
def delete_chat():
    if st.session_state["current_chat"]:
        chat_id = st.session_state["current_chat"]
        st.session_state["history_chats"] = [
            chat for chat in st.session_state["history_chats"] if chat["id"] != chat_id
        ]
        del st.session_state["chat_names"][chat_id]
```

- Removes the chat from the session state.

```python
        payload = {"chat_id": chat_id}
        headers = {"Content-Type": "application/json"}
        response = requests.post(DELETE_CHAT_URL, json=payload, headers=headers)
```

- Sends a `POST` request to delete the chat from the backend.

```python
        if response.status_code != 200:
            print(f"Failed to delete data. Status code: {response.status_code}")
```

- Prints an error message if the deletion fails.

```python
        st.session_state["current_chat"] = (
            st.session_state["history_chats"][0]["id"] if st.session_state["history_chats"] else None
        )
```

- Updates the current chat to the first available chat or `None` if no chats remain.

---

## 9. Select Chat Function

Handles chat selection when a user picks a chat from the sidebar:

```python
def select_chat(chat_id):
    st.session_state["current_chat"] = chat_id
```

- Updates the session state to set the selected chat ID as the active chat.
- Ensures that future interactions refer to the chosen chat.

---

## 10. Sidebar Navigation

The sidebar section allows users to create and manage chat sessions:

```python
with st.sidebar:
    st.title("Chat Management")
    uploaded_pdf = st.file_uploader("Upload PDF", type="pdf", key="pdf_uploader")
    chat_name = st.text_input("Enter Chat Name:", key="new_chat_name")
```

- Provides a sidebar for managing chats.
- Includes a file uploader for PDFs and a text input for chat names.

```python
    if st.button("Create New Chat"):
        if chat_name.strip():
            create_chat(chat_name.strip())
        else:
            st.warning("Chat name cannot be empty.")
```

- Creates a new chat without a PDF if a valid name is entered.

```python
    if st.button("Create New Chat with PDF"):
        if not uploaded_pdf:
            st.warning("Please upload a PDF file before creating the chat.")
        elif chat_name.strip():
            create_chat_with_pdf(chat_name.strip(), uploaded_pdf)
        else:
            st.warning("Chat name cannot be empty.")
```

- Creates a new chat with an associated PDF if a valid name and PDF are provided.

```python
    if st.session_state["history_chats"]:
        chat_options = {
            chat["id"]: st.session_state["chat_names"][chat["id"]]
            for chat in st.session_state["history_chats"]
        }
        selected_chat = st.radio(
            "Select Chat",
            options=list(chat_options.keys()),
            format_func=lambda x: chat_options[x],
            key="chat_selector",
            on_change=lambda: select_chat(st.session_state.chat_selector),
        )
        st.session_state["current_chat"] = selected_chat
```

- Displays a list of existing chats for selection.
- Updates the current chat when a new selection is made.

```python
        st.button("Delete Chat", on_click=delete_chat)
```

- Provides a button to delete the selected chat.

---

## 11. Display and Handle Chat Messages

The chat interface displays previous messages and processes new user inputs:

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
        if current_chat["pdf_name"]:
            pdf_name = current_chat["pdf_name"]
            st.subheader(f"Associate with: {pdf_name}")
```

- Displays the associated PDF name if the chat has one.

```python
        for message in current_chat["messages"]:
            with st.chat_message(message["role"]):
                st.markdown(message["content"])
```

- Iterates through chat messages and displays them.
- Messages are displayed with their role (e.g., `user` or `assistant`).

```python
        if prompt := st.chat_input("Your Message:"):
            current_chat["messages"].append({"role": "user", "content": prompt})
            with st.chat_message("user"):
                st.markdown(prompt)
```

- Captures user input via the chat input box.
- Appends the user's message to the chat history and displays it.

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
                if current_chat["pdf_uuid"]:
                    payload["pdf_uuid"] = current_chat["pdf_uuid"]
                    chat_taret_url = RAG_CHAT_URL
                else:
                    chat_taret_url = CHAT_URL
```

- Determines the target URL based on whether the chat has an associated PDF.

```python
                def get_stream_response():
                    with requests.post(chat_taret_url, json=payload, headers=headers, stream=True) as r:
                        for chunk in r:
                            yield chunk.decode("utf-8")
```

- Sends the chat data to the backend API with streaming enabled.
- Decodes and yields each chunk of the response in real-time.

```python
                response = st.write_stream(get_stream_response)
                current_chat["messages"].append({"role": "assistant", "content": response})
                save_chat_to_db(chat_id, chat_name, current_chat["messages"], current_chat["pdf_name"], current_chat["pdf_path"], current_chat["pdf_uuid"])
```

- Displays the assistant's response as it streams.
- Appends the assistant's message to the chat history and saves the updated chat to the database.

---

## 12. Running the Application

To run the chatbot application, execute the following command:

```bash
streamlit run chatbot.py
```
