# Backend Code Explanation

This document provides a detailed explanation of the `backend.py` script, following a structured format with explanations and code blocks.

---

## 1. Import Required Libraries

The script imports necessary libraries to facilitate API creation, database connectivity, environment variable handling, and integration with OpenAI and LangChain:

```python
from fastapi import FastAPI, File, UploadFile, HTTPException, Depends
from pydantic import BaseModel
from openai import OpenAI
from fastapi.responses import StreamingResponse
from dotenv import load_dotenv
import json
import psycopg2
import os
import uuid
from psycopg2.extras import RealDictCursor
from typing import List, Optional
from langchain_community.document_loaders import PyPDFLoader
from langchain_openai import OpenAIEmbeddings, ChatOpenAI
from langchain_chroma import Chroma
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain.chains import create_history_aware_retriever, create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_core.messages import HumanMessage, AIMessage
import chromadb
```

- **`FastAPI`**: Provides an easy-to-use framework for API development.
- **`File`, `UploadFile`**: Handles file uploads (e.g., PDFs).
- **`HTTPException`**: Handles error responses.
- **`Depends`**: Manages dependencies in API endpoints.
- **`Pydantic`**: For request data validation.
- **`OpenAI`**: To interact with the OpenAI API.
- **`StreamingResponse`**: Handles streamed responses.
- **`dotenv`**: Loads environment variables securely.
- **`psycopg2`**: Establishes connection with PostgreSQL.
- **`os`**: Provides access to environment variables.
- **`uuid`**: Generates unique identifiers.
- **`LangChain`**: Used for document processing, embeddings, and retrieval-augmented generation (RAG).
- **`Chroma`**: A vector database for storing and querying embeddings.

---

## 2. Load Environment Variables

Loads sensitive credentials from an environment file:

```python
load_dotenv()
```

- `load_dotenv()`: Reads key-value pairs from the `.env` file into environment variables.

---

## 3. Database Configuration

Defines database connection parameters using environment variables:

```python
DB_CONFIG = {
    "dbname": os.environ.get("DB_NAME"),
    "user": os.environ.get("DB_USER"),
    "password": os.environ.get("DB_PASSWORD"),
    "host": os.environ.get("DB_HOST"),
    "port": os.environ.get("DB_PORT"),
}
```

- Each key retrieves credentials securely from environment variables.

---

## 4. OpenAI Client Initialization

Initializes the OpenAI client using an API key:

```python
client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))
model = "gpt-3.5-turbo"
```

- `OpenAI(api_key=...)`: Initializes OpenAI's client.
- `model = "gpt-3.5-turbo"`: Specifies the model to be used.

---

## 5. LangChain and Chroma Setup

Configures LangChain and Chroma for document processing and retrieval:

```python
llm = ChatOpenAI(model=model)
embedding_function = OpenAIEmbeddings()
chroma_client = chromadb.HttpClient(host='localhost', port=8000)
collection = chroma_client.get_or_create_collection("langchain")
vectorstore = Chroma(
    client=chroma_client,
    collection_name="langchain",
    embedding_function=embedding_function,
)
```

- **`llm`**: Initializes the LangChain ChatOpenAI model.
- **`embedding_function`**: Uses OpenAI embeddings for text vectorization.
- **`chroma_client`**: Connects to the Chroma vector database.
- **`vectorstore`**: Configures Chroma for storing and querying embeddings.

---

## 6. FastAPI Application Initialization

Creates an instance of FastAPI for defining API routes:

```python
app = FastAPI()
```

---

## 7. Request Models

Defines models for API request payload validation:

```python
class ChatRequest(BaseModel):
    messages: List[dict]
```

- Validates incoming chat requests ensuring they contain a list of message dictionaries.

```python
class SaveChatRequest(BaseModel):
    chat_id: str
    chat_name: str
    messages: List[dict]
    pdf_name: Optional[str] = None
    pdf_path: Optional[str] = None
    pdf_uuid: Optional[str] = None
```

- Validates saving chat requests including chat ID, name, message content, and optional PDF metadata.

```python
class DeleteChatRequest(BaseModel):
    chat_id: str
```

- Ensures deletion requests contain a chat ID.

```python
class RAGChatRequest(BaseModel):
    messages: List[dict]
    pdf_uuid: str
```

- Validates RAG chat requests, including chat messages and the associated PDF UUID.

---

## 8. Database Connection Dependency

Manages PostgreSQL database connections using dependency injection:

```python
def get_db():
    conn = psycopg2.connect(**DB_CONFIG)
    try:
        yield conn
    finally:
        conn.close()
```

- Opens a database connection and ensures it's closed after request processing.

---

## 9. Chat Endpoint

Handles chat requests by interacting with the OpenAI API:

```python
@app.post("/chat/")
async def chat(request: ChatRequest):
    try:
        stream = client.chat.completions.create(
            model=model,
            messages=request.messages,
            stream=True,
        )
```

- Calls OpenAI's API with the given chat messages and enables streaming.

```python
        def stream_response():
            for chunk in stream:
                delta = chunk.choices[0].delta.content
                if delta:
                    yield delta
```

- Yields chunks of response to the client.

```python
        return StreamingResponse(stream_response(), media_type="text/plain")
```

- Returns a streaming response to the client.

```python
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

- Handles errors by raising an HTTP 500 exception.

---

## 10. Load Chat Endpoint

Retrieves saved chats from the database and returns them to the client:

```python
@app.get("/load_chat/")
async def load_chat(db: psycopg2.extensions.connection = Depends(get_db)):
    try:
        with db.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute("SELECT id, name, file_path, pdf_name, pdf_path, pdf_uuid FROM advanced_chats ORDER BY last_update DESC")
            rows = cursor.fetchall()
```

- Queries the database to fetch all chat records, ordered by the latest update date.

```python
        records = []
        for row in rows:
            chat_id, name, file_path, pdf_name, pdf_path, pdf_uuid = row["id"], row["name"], row["file_path"], row["pdf_name"], row["pdf_path"], row["pdf_uuid"]
            if os.path.exists(file_path):
                with open(file_path, "r", encoding="utf-8") as f:
                    messages = json.load(f)
                records.append({
                    "id": chat_id, 
                    "chat_name": name, 
                    "messages": messages, 
                    "pdf_name": pdf_name, 
                    "pdf_path": pdf_path, 
                    "pdf_uuid": pdf_uuid
                })
```

- Loads chat messages from the associated JSON file and appends the data to the `records` list.

```python
        return records
```

- Returns the retrieved chat records to the client.

```python
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")
```

- Handles errors by raising an HTTP 500 exception.

---

## 11. Save Chat Endpoint

Saves chat conversations into a file and stores metadata in the database:

```python
@app.post("/save_chat/")
async def save_chat(request: SaveChatRequest, db: psycopg2.extensions.connection = Depends(get_db)):
    try:
        file_path = f"chat_logs/{request.chat_id}.json"
        os.makedirs("chat_logs", exist_ok=True)
```

- Constructs a file path for the chat log and ensures the directory exists.

```python
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(request.messages, f, ensure_ascii=False, indent=4)
```

- Writes chat messages to a JSON file with proper formatting.

```python
        with db.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO advanced_chats (id, name, file_path, last_update, pdf_path, pdf_name, pdf_uuid)
                VALUES (%s, %s, %s, CURRENT_TIMESTAMP, %s, %s, %s)
                ON CONFLICT (id)
                DO UPDATE SET name = EXCLUDED.name, file_path = EXCLUDED.file_path, last_update = CURRENT_TIMESTAMP, pdf_path = EXCLUDED.pdf_path, pdf_name = EXCLUDED.pdf_name, pdf_uuid = EXCLUDED.pdf_uuid
                """,
                (request.chat_id, request.chat_name, file_path, request.pdf_path, request.pdf_name, request.pdf_uuid),
            )
        db.commit()
        return {"message": "Chat saved successfully"}
```

- Inserts or updates the chat metadata in the database.

```python
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")
```

- Handles errors by rolling back the transaction and raising an HTTP 500 exception.

---

## 12. Delete Chat Endpoint

Deletes chat records and associated files:

```python
@app.post("/delete_chat/")
async def delete_chat(request: DeleteChatRequest, db: psycopg2.extensions.connection = Depends(get_db)):
    try:
        file_path = None
        with db.cursor() as cursor:
            cursor.execute("SELECT file_path FROM advanced_chats WHERE id = %s", (request.chat_id,))
            result = cursor.fetchone()
            if result:
                file_path = result[0]
            else:
                raise HTTPException(status_code=404, detail="Chat not found")
```

- Retrieves the file path of the chat log before deleting the record.

```python
        with db.cursor() as cursor:
            cursor.execute("DELETE FROM advanced_chats WHERE id = %s", (request.chat_id,))
        db.commit()
```

- Deletes the chat record from the database.

```python
        if file_path and os.path.exists(file_path):
            os.remove(file_path)
```

- Deletes the associated chat log file if it exists.

```python
        return {"message": "Chat deleted successfully"}
```

- Returns a success message to the client.

```python
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")
```

- Handles errors by rolling back the transaction and raising an HTTP 500 exception.

---

## 13. Upload PDF Endpoint

Handles PDF file uploads and processes them for RAG:

```python
@app.post("/upload_pdf/")
async def upload_pdf(file: UploadFile = File(...)):
    if file.content_type != "application/pdf":
        raise HTTPException(status_code=400, detail="Only PDF files are allowed.")
```

- Validates that the uploaded file is a PDF.

```python
    try:
        pdf_uuid = str(uuid.uuid4())
        file_path = f"pdf_store/{pdf_uuid}_{file.filename}"
        os.makedirs("pdf_store", exist_ok=True)
```

- Generates a unique UUID for the PDF and constructs the file path.

```python
        with open(file_path, "wb") as f:
            f.write(await file.read())
```

- Saves the uploaded PDF to the server.

```python
        loader = PyPDFLoader(file_path)
        documents = loader.load()
        text_splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=50)
        texts = text_splitter.split_documents(documents)
```

- Loads and splits the PDF into smaller text chunks for processing.

```python
        vectorstore.add_texts(
            [doc.page_content for doc in texts], 
            ids=[str(uuid.uuid4()) for _ in texts],
            metadatas=[{"pdf_uuid": pdf_uuid} for _ in texts]    
        )
```

- Adds the text chunks to the Chroma vector database with metadata.

```python
        return {"message": "File uploaded successfully", "pdf_path": file_path, "pdf_uuid": pdf_uuid}
```

- Returns a success message with the file path and UUID.

```python
    except Exception as e:
        print(e)
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")
```

- Handles errors by raising an HTTP 500 exception.

---

## 14. RAG Chat Endpoint

Handles RAG-based chat interactions:

```python
@app.post("/rag_chat/")
async def rag_chat(request: RAGChatRequest):
    retriever = vectorstore.as_retriever(
        search_kwargs={"k": 5, "filter": {"pdf_uuid": request.pdf_uuid}}
    )
```

- Configures the retriever to fetch relevant text chunks based on the PDF UUID.

```python
    contextualize_q_system_prompt = (
        "Given a chat history and the latest user question, "
        "formulate a standalone question which can be understood "
        "without the chat history. Do NOT answer the question, "
        "just reformulate it if needed and otherwise return it as is."
    )
    contextualize_q_prompt = ChatPromptTemplate.from_messages(
        [
            ("system", contextualize_q_system_prompt),
            MessagesPlaceholder("chat_history"),
            ("human", "{input}"),
        ]
    )
    history_aware_retriever = create_history_aware_retriever(
        llm, retriever, contextualize_q_prompt
    )
```

- Configures the retriever to contextualize the user's question based on chat history.

```python
    system_prompt = (
        "You are an assistant for question-answering tasks. "
        "Use the following pieces of retrieved context to answer "
        "the question. If you don't know the answer, say that you "
        "don't know. Use three sentences maximum and keep the "
        "answer concise."
        "\n\n"
        "{context}"
    )
    qa_prompt = ChatPromptTemplate.from_messages(
        [
            ("system", system_prompt),
            MessagesPlaceholder("chat_history"),
            ("human", "{input}"),
        ]
    )
    question_answer_chain = create_stuff_documents_chain(llm, qa_prompt)
```

- Configures the QA chain to generate concise answers based on retrieved context.

```python
    rag_chain = create_retrieval_chain(history_aware_retriever, question_answer_chain)
```

- Combines the retriever and QA chain into a RAG chain.

```python
    chat_history = []
    user_input = request.messages[-1]
    previous_chat = request.messages[:-1]
```

- Prepares the chat history and user input for processing.

```python
    for message in request.messages:
        if message["role"] == "user":
            chat_history.append(HumanMessage(content=message["content"]))
        if message["role"] == "assistant":
            chat_history.append(AIMessage(content=message["content"]))
```

- Converts chat messages into LangChain message objects.

```python
    chain = rag_chain.pick("answer")
    stream = chain.stream({
        "chat_history": chat_history,
        "input": user_input
    })
```

- Streams the RAG response in real-time.

```python
    def stream_response():
        for chunk in stream:
            yield chunk
```

- Yields chunks of the response to the client.

```python
    return StreamingResponse(stream_response(), media_type="text/plain")
```

- Returns a streaming response to the client.
