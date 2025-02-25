# SDA-bootcamp-project

## Stage 3 - Chatbot with Chat History

### Stage Introduction 

A basic chatbot using Streamlit and FastAPI. At this stage, we enhance the functionality by storing chat history locally and tracking each session in a database. 

![stage3](https://weclouddata.s3.us-east-1.amazonaws.com/cloud/project-stages/stage-3.png)

Specifically, we record the chat ID, chat name, and the file path of the history in PostgreSQL. This way, whenever you open the chatbot, it automatically retrieves your previous conversations, providing a seamless experience.

By separating responsibilities—Streamlit for the user interface, FastAPI for the core logic, and PostgreSQL for data storage—you create a flexible, maintainable system. Each layer can be updated or replaced independently, making it simpler to add new features or swap out technologies without disrupting the rest of the application. This structure also lays the groundwork for easily migrating the application to the cloud in the future.


### How to Get Started

In this stage I create a table called `chats` in the database using the following schema:
```
CREATE TABLE IF NOT EXISTS chats (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    file_path TEXT NOT null,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

Please store your `OPENAI_API_KEY` and **Database Credentials** in `.env` file.

Now the `.env` file should look like:
```
OPENAI_API_KEY=YOUR-OPENAI-API-KEY
DB_NAME = YOUR-DB-NAME
DB_USER = YOUR-DB-USER
DB_PASSWORD = YOUR-DB-PASSWORD
DB_HOST = YOUR-DB-HOST
DB_PORT = YOUR-DB-PORT
```

Start the backend app first using:

```
uvicorn backend:app --reload
```

And then use 
```
streamlit run chatbot.py
```
to run the Streamlit app. Make sure that you always start the backend first!
