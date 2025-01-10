# SDA-bootcamp-project

Stage 3 - RAG Chatbot with Chat history - save file in blob storage

A RAG chatbot using streamlit and FastAPI. At this stage we will add the RAG function to the bot.
Other than creating normal chat, user can upload `pdf` file to the chatbot and ask questions specific to this document.
Since we are moving to the cloud, instead of storing the chat logs and pdf files on the instance, we can store them in the Azure blob storage to save more space for the instance.

In thie stage we still use the `advanced_chats` table with following schema:
```
CREATE TABLE IF NOT EXISTS advanced_chats (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    file_path TEXT NOT null,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    pdf_path TEXT,
    pdf_name TEXT,
    pdf_uuid TEXT
)
```


Besides storing the `OPENAI_API_KEY` and **Database Credentials** in `.env` file, we also need to store `AZURE_STORAGE_SAS_URL` and `AZURE_STORAGE_CONTAINER` in order to connnect to the blob storage.

Start the backend app first using:

```
uvicorn backend:app --reload
```

And then use 
```
streamlit run chatbot.py
```
to run the streamlit app. Make sure that always start the backend first!