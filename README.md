# SDA-bootcamp-project

Stage 3 - RAG Chatbot with Chat history

A RAG chatbot using streamlit and FastAPI. At this stage we will add the RAG function to the bot.
Other than creating normal chat, user can upload `pdf` file to the chatbot and ask questions specific to this document 

In thie stage we will create a **new** table called `advanced_chats` in the database using following schema:
```
CREATE TABLE IF NOT EXISTS chats (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    file_path TEXT NOT null,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    pdf_path TEXT,
    pdf_name TEXT,
    pdf_uuid TEXT
)
```
or if you want, you can just add the extra columns in the `chats` database created in stage 3.

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