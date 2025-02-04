# SDA-bootcamp-project

Stage 9 - RAG Chatbot(Azure Function with Binding)

At this stage, we will use **ouput binding** to connect to the CosmosDB when **saving the chat history**.

For the database we removed the `file_path` column in the `advanced_chats` table:
```
CREATE TABLE IF NOT EXISTS advanced_chats (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    -- file_path TEXT NOT null,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    pdf_path TEXT,
    pdf_name TEXT,
    pdf_uuid TEXT
)
```
Or if you want you can create a new table called `advanced_chats_new` using above query.

> **Note:** The codes in this branch is just the showcase that how to interact with CosmosDB, so we **only** store the chat history to the CosmosDB. Actually students can upload all the metadata to the CosmosDB to replace the PostgreSQL. In that case, we also make the database fully serverless.

Since we need to add the CosmosDB connection in the Azure Function, we also need to store the `PROJ-COSMOSDB-ENDPOINT`, `PROJ-COSMOSDB-KEY`, `PROJ-COSMOSDB-DATABASE`, `PROJ-COSMOSDB-CONTAINER` in the **Azure Key Vault**.

**We also need to store the `COSMOSDB_CONNECTION_STRING`** in the `local.settings.json` under the `azure-function` folder.


When deploy to the Azure function, don't forget to upload the `local.settings.json` to the cloud.

We still need to run the ChromaDB and streamlit in the VM. Using the follow command to start the Chroma server:
```
chroma run --host 0.0.0.0 --path /db_path
```
change `/db_path` to the path you want to store the data, for example: `chromadb`.

And then use
```
streamlit run chatbot.py
```
to run the streamlit app.