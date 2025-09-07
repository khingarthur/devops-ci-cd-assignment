
# The Build Stage

# # Use an official Python runtime as a parent image. where we will
# build and package our application dependencies.
FROM python:3.10-slim AS builder

# Set the working directory for this stage.
WORKDIR /app

# Copy the requirements file into the container.
COPY requirements.txt .

# Install the dependencies.
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt
    
# Stage 2: The Production Stage

# Use an official Python runtime as a parent image.
FROM python:3.10-slim

# Set the working directory.
WORKDIR /app

# Copy the installed dependencies from the builder stage.
# This ensures we only include the necessary libraries and nothing else.
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages

# Copy the application code from the local directory into the container.
COPY . .

# Expose the port our application will be running on.
EXPOSE 5000

# The command to run the application.
CMD ["flask", "run", "--host=0.0.0.0"]  # nosec B104
