from flask import Flask

app = Flask(__name__) # Initializes "web application"
"""
__name__ is a special Python variable that contains the name of the current module.

Flask uses it to figure out:
- Where your app is located on disk
- Where to look for templates, static files, and other resources
Basically, it helps Flask know your projects root location.”

The instance is responsible for:
Routing: mapping URLs to Python functions (@app.route('/'))
Request handling: receiving HTTP requests and returning responses
Configuration: storing settings like debug mode, secret keys, database URIs
Extensions: managing additional functionality (like database connections, authentication, etc.)
"""

@app.route('/') # maps root URL '/' to hello function
def hello():
  return "Hello!"

@app.route('/bye/')
def bye():
   return "Bye!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
    # host 0.0.0.0: 
