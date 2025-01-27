# Backend Code Explanation

This document provides a detailed explanation of the `backend.py` script, following a structured format with explanations and code blocks.

---

## 1. Import Required Libraries

The script imports necessary libraries to facilitate API creation, database connectivity, and environment variable handling.

### Function Breakdown

```python
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from openai import OpenAI
from fastapi.responses import StreamingResponse
from dotenv import load_dotenv
import json
import psycopg2
import os
from psycopg2.extras import RealDictCursor
from typing import List
```

- **`FastAPI`**: Provides an easy-to-use framework for API development.
- **`HTTPException`**: Handles error responses.
- **`Depends`**: Manages dependencies in API endpoints.
- **`Pydantic`**: For request data validation.
- **`OpenAI`**: To interact with the OpenAI API.
- **`StreamingResponse`**: Handles streamed responses.
- **`dotenv`**: Loads environment variables securely.
- **`psycopg2`**: Establishes connection with PostgreSQL.
- **`os`**: Provides access to environment variables.
- **`json`**: Handles JSON data processing.

---

## 2. Load Environment Variables

Loads sensitive credentials from an environment file.

```python
load_dotenv()
```

- `load_dotenv()`: Reads key-value pairs from the `.env` file into environment variables.

---

## 3. Database Configuration

Defines database connection parameters using environment variables.

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

Initializes the OpenAI client using an API key.

```python
client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))
model = "gpt-3.5-turbo"
```

- `OpenAI(api_key=...)`: Initializes OpenAI's client.
- `model = "gpt-3.5-turbo"`: Specifies the model to be used.

---

## 5. FastAPI Application Initialization

Creates an instance of FastAPI for defining API routes.

```python
app = FastAPI()
```

---

## 6. Request Models

Defines models for API request payload validation.

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
```

- Validates saving chat requests including chat ID, name, and message content.

```python
class DeleteChatRequest(BaseModel):
    chat_id: str
```

- Ensures deletion requests contain a chat ID.

---

## 7. Database Connection Dependency

Manages PostgreSQL database connections using dependency injection.

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

## 8. Chat Endpoint

Handles chat requests by interacting with the OpenAI API.

### Function Breakdown

```python
@app.post("/chat/")
async def chat(request: ChatRequest):
```

- Defines an asynchronous endpoint for processing chat requests.

```python
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

---


## 9. Load Chat Endpoint

Retrieves saved chats from the database and returns them to the client.

### Function Breakdown

```python
@app.get("/load_chat/")
async def load_chat(db: psycopg2.extensions.connection = Depends(get_db)):
```

- Defines an asynchronous GET endpoint to retrieve chat data.
- Uses FastAPI's dependency injection to get a database connection.

```python
    try:
        with db.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute("SELECT id, name, file_path FROM chats ORDER BY last_update DESC")
            rows = cursor.fetchall()
```

- Establishes a database cursor to execute SQL queries.
- Retrieves all chat records ordered by the latest update date.
- Fetches all rows as dictionary objects.

```python
        records = []
        for row in rows:
            chat_id, name, file_path = row["id"], row["name"], row["file_path"]
            if os.path.exists(file_path):
                with open(file_path, "r", encoding="utf-8") as f:
                    messages = json.load(f)
                records.append({"id": chat_id, "chat_name": name, "messages": messages})
```

- Initializes an empty list to store chat records.
- Iterates through each retrieved row to extract chat ID, name, and file path.
- Checks if the corresponding file exists on the server.
- Reads and loads the JSON file content if it exists.
- Appends the loaded chat data to the `records` list.

```python
        return records
```

- Returns the retrieved chat records to the client as a JSON response.

```python
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")
```

- Handles any errors that occur during execution by raising an HTTP 500 exception.

---


## 10. Save Chat Endpoint

Saves chat conversations into a file and stores metadata in the database.

### Function Breakdown

```python
@app.post("/save_chat/")
async def save_chat(request: SaveChatRequest, db: psycopg2.extensions.connection = Depends(get_db)):
```

- Defines an asynchronous endpoint to handle chat saving requests.
- Takes `SaveChatRequest` model input and a database connection dependency.

```python
    try:
        file_path = f"chat_logs/{request.chat_id}.json"
        os.makedirs("chat_logs", exist_ok=True)
```

- Constructs a file path using the chat ID.
- Ensures the directory exists to store chat logs.

```python
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(request.messages, f, ensure_ascii=False, indent=4)
```

- Writes chat messages to a JSON file with proper formatting.

```python
        with db.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO chats (id, name, file_path, last_update)
                VALUES (%s, %s, %s, CURRENT_TIMESTAMP)
                ON CONFLICT (id)
                DO UPDATE SET name = EXCLUDED.name, file_path = EXCLUDED.file_path, last_update = CURRENT_TIMESTAMP
                """,
                (request.chat_id, request.chat_name, file_path),
            )
        db.commit()
        return {"message": "Chat saved successfully"}
```

- Inserts or updates the chat metadata in the database.
- Ensures chat records are stored without duplication.

```python
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")
```

- Handles errors by rolling back the transaction and raising an HTTP exception.

---

## 11. Delete Chat Endpoint

Deletes chat records and associated files.

### Function Breakdown

```python
@app.post("/delete_chat/")
async def delete_chat(request: DeleteChatRequest, db: psycopg2.extensions.connection = Depends(get_db)):
```

- Defines an endpoint to delete a chat by ID.
- Accepts a `DeleteChatRequest` model input.

```python
    try:
        file_path = None
        with db.cursor() as cursor:
            cursor.execute("SELECT file_path FROM chats WHERE id = %s", (request.chat_id,))
            result = cursor.fetchone()
            if result:
                file_path = result[0]
            else:
                raise HTTPException(status_code=404, detail="Chat not found")
```

- Queries the database to fetch the chat file path.
- Raises a 404 error if the chat does not exist.

```python
        with db.cursor() as cursor:
            cursor.execute("DELETE FROM chats WHERE id = %s", (request.chat_id,))
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

- Rolls back the transaction and raises an error if something goes wrong.

---

