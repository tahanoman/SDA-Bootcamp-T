<img src='https://s3.amazonaws.com/weclouddata/images/logos/wcd_logo_new_2.png' width='25%'>

# SDA-bootcamp-project

## Stage 3 - Chatbot with Chat History

### Stage Introduction

In this stage, we enhance our basic chatbot, built with **Streamlit and FastAPI**, by adding **chat history storage**. Now, conversations are saved locally, and session details are logged in a **PostgreSQL database**, allowing users to continue their chats seamlessly.  

![stage3](https://weclouddata.s3.us-east-1.amazonaws.com/cloud/project-stages/stage-3.png)  

Specifically, we store the **chat ID, chat name, and file path** of each conversation in PostgreSQL. Whenever the chatbot is reopened, it automatically retrieves the previous chat history, providing a smoother user experience.  

By **separating responsibilities**—Streamlit for the frontend, FastAPI for backend logic, and PostgreSQL for data storage—we ensure a **flexible and maintainable** architecture. Each component can be updated or replaced independently, making it easier to extend functionality without affecting the overall system. Additionally, this structure lays the foundation for a smooth transition to **cloud deployment** in future stages.  

---

### How to Get Started
In this stage, we create a **new table** called `chats` in PostgreSQL to store chat history. Use the following schema:  

```sql
CREATE TABLE IF NOT EXISTS chats (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### **Step 1: Configure Environment Variables**  
Store your **OpenAI API key** and **database credentials** in a `.env` file.

Your `.env` file should look like this:  

```env
OPENAI_API_KEY=YOUR-OPENAI-API-KEY
DB_NAME=YOUR-DB-NAME
DB_USER=YOUR-DB-USER
DB_PASSWORD=YOUR-DB-PASSWORD
DB_HOST=YOUR-DB-HOST
DB_PORT=YOUR-DB-PORT
```

#### **Step 2: Start the Backend**  
Before running the chatbot, start the FastAPI backend using:

```bash
uvicorn backend:app --reload
```

#### **Step 3: Start the Frontend**  
Once the backend is running, launch the Streamlit app with:

```bash
streamlit run chatbot.py
```

> **Note:** Always start the backend first to ensure proper communication between components.
