# Stage 1: The Optimized Build Stage
FROM python:3.9-slim as builder

# Install system dependencies needed for runtime
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0

# Set the working directory
WORKDIR /app

# Copy ONLY the requirements file to leverage caching
COPY requirements.txt .

# Install the CPU-only PyTorch FIRST
RUN pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu

# Install the rest of the dependencies from requirements.txt
RUN pip install --no-cache-dir -r requirements.txt


# Stage 2: The Final Application Stage
FROM python:3.9-slim

# Install the same system dependencies for runtime
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0

# Set the working directory
WORKDIR /app

# Copy the installed Python packages from the builder stage
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
# --- THIS IS THE NEW, FIXED LINE ---
# Copy the executables (like 'streamlit' and 'yolo') as well
COPY --from=builder /usr/local/bin /usr/local/bin
# --- END OF FIX ---

# Copy your application code
COPY . .

# Expose the port Streamlit runs on
EXPOSE 8501

# The command to run your app
CMD ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]
