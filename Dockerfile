# Use an official Python runtime as a parent image.
# We're using a smaller image variant for a more efficient build.
FROM python:3.10-slim

# Set the working directory in the container to /app.
WORKDIR /app

# Copy the requirements file into the container at /app.
COPY requirements.txt .

# Install any dependencies specified in requirements.txt.
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application's source code into the container.
COPY . .

# Expose the port on which the Flask app will run.
EXPOSE 5000

# Run the app.py script when the container launches.
# We use 'python' to directly execute the file, which is more reliable than 'flask run'.
CMD ["python", "app.py"]
