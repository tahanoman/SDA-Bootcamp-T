<img src='https://s3.amazonaws.com/weclouddata/images/logos/wcd_logo_new_2.png' width='25%'>

# SDA-bootcamp-project  

## Stage 1 - Basic Chatbot

### Stage Introduction

In this stage, we build a **basic chatbot** using **Streamlit** and the **OpenAI API**. The chatbot provides a simple user interface where users can interact and receive AI-generated responses.  

![stage1](https://weclouddata.s3.us-east-1.amazonaws.com/cloud/project-stages/stage-1.png)  

At this stage, the chatbot runs **entirely on the frontend**, meaning Streamlit directly communicates with the OpenAI API. This setup serves as the foundation for later stages, where we will introduce a backend and enhance functionality.  

---

### How to Get Started

#### **Step 1: Set Up Environment Variables**  
Before running the chatbot, store your **OpenAI API key** in a `.env` file:

```env
OPENAI_API_KEY=YOUR-OPENAI-API-KEY
```

#### **Step 2: Start the Chatbot**  
Run the following command to launch the Streamlit app:

```bash
streamlit run chatbot.py
```

> **Note:** This is a simple frontend-based chatbot. In later stages, we will introduce a backend to handle API calls more efficiently.