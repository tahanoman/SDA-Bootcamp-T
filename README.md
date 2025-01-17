# SDA-bootcamp-project

The project is divided into multiple stages, aligned with the teaching progress of the bootcamp. Each stage builds upon the previous one, gradually incorporating new technologies and concepts. Below is a detailed breakdown:


| Stage    | Name                                | Teaching Progress                                             | description                                                                         |
| ---------|-------------------------------------|---------------------------------------------------------------|-------------------------------------------------------------------------------------|
| Stage-1  | Basic Chatbot                       | After learning Streamlit and Pyhon fast-track in **Week 1**   | Students needs to create a very simple chatbot using Streamlit                      |
| Stage-2  | Chatbot with Frontend/Backend split | After learning the FastAPI in **Week 2**                      | At this stage we just move the function that call the OpenAI API to the backend     |
| Stage-3  | Chatbot with Chathistory            | After learning the SQL and FastAPI in **Week 2**              | At this stage the app will save the chathistory in the local path and use database to track the location of the chat history |
| Stage-4  | RAG chatbot                         | After learning the SQL and FastAPI in **Week 2**              | Here we add some functions to upload pdf and do the RAG chat, this part may be diffcult for students since RAG is something they need to do some rearch |
| Stage-5  | Move to Cloud                       | After learning the intro to Azure and Azure VM in **Week 3**  | There is no branch for this stage since the **codes are same as stage-4**, what students can do is that, after learning the Azure VM, they need to do is move the codes to the VM and setup the database on the VM |
| Stage-6  | Chatbot with CloudStorage           | After learning Azure Blob and Azure PostgreSQL  in **Week 3** | After learning the Azure Blob Storage, students can save the chat history and pdf files to the Blob Storage. And after learning the Azure PostgreSQL, they can move the database from VM to Azure PostgreSQL |
| Stage-7  | Serverless                          | Ater learning the Function APPs in **Week 6**                 | At this stage, they can move the backend functions to the Azure Function App       |
| Stage-8  | Serverless cont.                    | Ater learning the CosmosDB in **Week 6**                      | After learning the CosmosDB, we no longer need to save the chat history in the Blob Storage, in stead, we can save it to the CosmosDB. In the sample codes, we only store the chat history in the CosmosDB, but students can try to save other metadata as well to replace the Azure PostgreSQL database |
| Stage-9  | Azure Function with Binding         | Ater learning the Function APPs and CosmosDB in **Week 6**    | In this stage, we just change the connect to the CosmosDB from using client to using Binding when saving data to CosmosDB. This is the showcase for the Azure Function Binding |
| Stage-10 **(WIP)**| Containerazation           | After learning Docker and Container Apps in **Week 7**        | This is also another option to deploy the App, instead of deploy the backend to the Azure Function App, we can also deploy it to the Container App. The codes at this stage is *NOT* build on top of the stage-9, instead, it is build on top of the stage-6 |

## Notes
- The provided code offers only basic functionality. Students are expected to optimize the code and add advanced features to make the chatbot more robust and functional.
- The progression aligns with the topics covered each week, allowing students to apply new skills incrementally.