# SDA-bootcamp-project

## Stage 2 - Basic Chatbot with FastAPI

### Stage Introduction 
A basic chatbot using Streamlit and OpenAI API. At this stage we move the call to OpenAI to the backend using FastAPI.

![stage2](https://weclouddata.s3.us-east-1.amazonaws.com/cloud/project-stages/stage-2.png)

In this setup, when a user interacts with the Streamlit frontend, the request is sent to the FastAPI backend. The backend then calls the OpenAI API and returns the results to the frontend. 

By splitting responsibilities in this way, the frontend focuses on user interaction and session management, while the backend handles all business logic. As a result, as long as the backend endpoints remain active, you can replace the Streamlit interface with any other frontend technology without losing the core functionality of the application.

### How to Get Started

Store your `OPENAI_API_KEY` in `.env` file.

Start the backend app first using:

```
uvicorn backend:app --reload
```

And then use 
```
streamlit run chatbot.py
```
to run the streamlit app. Make sure that always start the backend first!