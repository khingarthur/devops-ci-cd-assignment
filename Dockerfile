# Stage 1: The Build Stage
# Use an official Python runtime as a parent image.
FROM python:3.10-slim AS builder

# Set the working directory for this stage.
WORKDIR /app

# Copy the requirements file into the container.
COPY requirements.txt .


RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt
    
# Stage 2: The Production Stage
# Use a minimal base image.
FROM alpine:3.18 as final

# Copy the Python runtime and our installed dependencies from the builder stage.

COPY --from=builder /usr/local /usr/local

# Copy the application code from the local directory into the container.
COPY . .

# Set the working directory for our application.
WORKDIR /app

# Expose the port our application will be running on.
EXPOSE 5000

# The command to run the application.
CMD ["flask", "run", "--host=0.0.0.0"]
