# Use the official Python image as a base
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the FastAPI app files to the container
COPY backend.py /app/
COPY requirements.txt /app/

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the FastAPI port
EXPOSE 8000

# Set environment variables (ensure these are configured in the environment or passed at runtime)
ENV DB_NAME=your_db_name
ENV DB_USER=your_db_user
ENV DB_PASSWORD=your_db_password
ENV DB_HOST=your_db_host
ENV DB_PORT=your_db_port
ENV OPENAI_API_KEY=your_openai_api_key
ENV AZURE_STORAGE_SAS_URL=your_azure_storage_sas_url
ENV AZURE_STORAGE_CONTAINER=your_azure_storage_container
ENV COSMOSDB_ENDPOINT=your_cosmosdb_endpoint
ENV COSMOSDB_KEY=your_cosmosdb_key
ENV COSMOSDB_DATABASE=your_cosmosdb_database
ENV COSMOSDB_CONTAINER=your_cosmosdb_container

# Command to run FastAPI using uvicorn
CMD ["uvicorn", "backend:app", "--host", "0.0.0.0", "--port", "8000"]
