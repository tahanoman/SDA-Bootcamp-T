# SDA-bootcamp-project

Stage 6.5 - **RAG** Chatbot with Chat history **(Cloud Storage+KeyVault)**

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
**At this stage, since we learned the Azure KeyVault, we can store all the environment variables(***Except `KEY_VAULT_NAME`***) in the Azure KeyVault and load from there. To do this we need to enable the *System Assigned Identity* for the VM and add it to the Key Vault Access Control as a `Key Vault Secrets User`. For the Detailed steps you can check [this toturial](GrantKeyVaultAccessToVM.md)**

All the requirements are in the `requirements.txt`

To use RAG, we need to start the chromaDB fisrt, using the follow command to start the Chroma server:
```
chroma run --path /db_path
```
change `/db_path` to the path you want to store the data, for example: `chromadb`.

Then, start the backend app using:

```
uvicorn backend:app --reload --port 5000
```

And then use 
```
streamlit run chatbot.py
```
to run the streamlit app.
