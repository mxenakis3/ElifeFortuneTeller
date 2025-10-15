# 1. Base image with Python installed
# Uses the official Python 3.11 slim image (a lightweight version)
# This provides Python runtime without unnecessary packages, reducing image size

# ie. start FROM this image
FROM python:3.11-slim

# 2. Set working directory inside the container
# Creates /app directory if it doesn't exist and sets it as the current working directory
# All subsequent commands (COPY, RUN, CMD) will execute from this directory
WORKDIR /app

# 3. Copy dependencies list into container
# Copies requirements.txt from your local machine to /app in the container
# This is done separately from the app code to leverage Docker's layer caching:
# If requirements.txt doesn't change, Docker can reuse the cached dependency layer
COPY requirements.txt .

# 4. Install dependencies
# pip install: Installs Python packages listed in requirements.txt
# --no-cache-dir: Prevents pip from storing cache files, reducing image size
# -r requirements.txt: Reads package list from the requirements file
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copy the app code into container
# Copies your application code (app.py) from local machine to /app in the container
# This is done after installing dependencies so code changes don't trigger dependency reinstall
COPY app.py .

# 6. Expose the port your app runs on
# Documents that the container listens on port 5000 at runtime
# Note: This doesn't actually publish the port - you need to use -p flag when running the container
# (e.g., docker run -p 5000:5000 <image-name>)
EXPOSE 5000

# 7. Command to run the app
# Specifies the default command to execute when the container starts
# Uses exec form (JSON array) which is preferred over shell form
# This runs "python app.py" to start your application
CMD ["python", "app.py"]