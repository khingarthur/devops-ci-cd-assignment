from flask import Flask

# Create a Flask web server instance.
app = Flask(__name__)

# Define a route for the root URL ('/').
@app.route('/')
def hello_world():
    # Return the "Hello, World!" string when the root URL is accessed.
    return "Hello, World! I'm Arthur!"

# The entry point of the application.
if __name__ == '__main__':
    # Run the application on all available network interfaces on port 5000.
    app.run(host='0.0.0.0', port=5000) #nosec B104


