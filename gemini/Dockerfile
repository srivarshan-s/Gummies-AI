# Load base image
FROM debian:12-slim

# Update base image and install python3
RUN apt update && apt upgrade -y && apt install python3 python3-venv -y

# Create and activate virtual environment, and install python packages
COPY requirements.txt .
RUN python3 -m venv /venv && \
    . /venv/bin/activate && \
    pip install --upgrade pip && \
    pip install -r requirements.txt

# Copy secrets file (environment variables)
COPY .env .

# Create app directory
RUN mkdir /app
WORKDIR /app

# Copy over the code
COPY gemini_functions.py app.py

# Set entrypoint to use the virtual environment
ENTRYPOINT ["/venv/bin/python3"]

# Command to run api
CMD ["app.py"]