# SDA-bootcamp-project

Stage 3 - Chatbot with Chat history

A basic chatbot using streamlit and FastAPI. At this stage we will store the chat history at local path, and also log the coresponding chat id, chat name and chat history file path in a database. In this case, every time we open our chatbot, it will automatically load the previous chat history.

In thie stage I create a table called `chats` in the database using following schema:
```
CREATE TABLE IF NOT EXISTS chats (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    file_path TEXT NOT null,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

Please store your `OPENAI_API_KEY` and **Database Credentials** in `.env` file.

Start the backend app first using:

```
uvicorn backend:app --reload
```

And then use 
```
streamlit run chatbot.py
```
to run the streamlit app. Make sure that always start the backend first!