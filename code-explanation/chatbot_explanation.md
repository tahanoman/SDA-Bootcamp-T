
# Chatbot Frontend Explanation

This document provides a detailed explanation of the `chatbot.py` script, which serves as the frontend for the chatbot application using **Streamlit** and communicates with a FastAPI backend.

---

## 1. Import Required Libraries

The script starts by importing the necessary libraries:

- **`streamlit`**: A Python library to build interactive web applications.
- **`requests`**: A library used to send HTTP requests to the backend API.

```python
import streamlit as st
import requests
```

---

## 2. Set Page Title

The `st.title()` function sets the title of the Streamlit app, providing a simple and user-friendly interface.

```python
st.title("Chatbot basic")
```

---

## 3. Define Backend API URL

The script specifies the FastAPI backend endpoint, which handles chat requests.

```python
chat_url = "http://127.0.0.1:8000/chat/"
```

---

## 4. Initialize Session State

Streamlit provides a session state to maintain stateful data across reruns of the app.

- **`openai_model`**: Stores the default OpenAI model (`gpt-3.5-turbo`).
- **`messages`**: Holds the chat history, including both user and assistant messages.

```python
if "openai_model" not in st.session_state:
    st.session_state["openai_model"] = "gpt-3.5-turbo"

if "messages" not in st.session_state:
    st.session_state.messages = []
```

---

## 5. Display Chat History

The chat history stored in `session_state.messages` is displayed using `st.chat_message()` to keep track of previous interactions.

```python
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])
```

---

## 6. Handle User Input

When the user enters text, it is added to the session state and displayed on the interface.

```python
if prompt := st.chat_input("What is up?"):
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)
```

---

## 7. Sending Chat Request to Backend

The input message, along with the chat history, is sent to the FastAPI backend for processing. The script provides both a streamed and non-streamed approach.

### Non-Stream Approach (commented out)

```python
# stream = requests.post(chat_url, json=payload, headers=headers)
# response = stream.json()["reply"]
# st.markdown(response)
```

### Stream Approach (used in script)

A streaming response is received and displayed in real-time.

```python
def get_stream_response():
    with requests.post(chat_url, json=payload, headers=headers, stream=True) as r:
        for chunk in r:
            yield chunk.decode('utf-8')

response = st.write_stream(get_stream_response)
```

---

## 8. Store Assistant Response

The chatbot's response is stored in session state to maintain conversation continuity.

```python
st.session_state.messages.append({"role": "assistant", "content": response})
```

---

## 9. Running the Application

To run the chatbot, use the following command:

```bash
streamlit run chatbot.py
```

---

