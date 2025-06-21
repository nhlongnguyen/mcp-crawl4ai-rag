FROM python:3.12-slim

ARG PORT=8051

WORKDIR /app

# Install system dependencies and uv
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/* && \
    pip install uv

# Copy the MCP server files
COPY . .

# Install packages directly to the system (no virtual environment)
# Combining commands to reduce Docker layers
RUN uv pip install --system -e . && \
    crawl4ai-setup

EXPOSE ${PORT}

# Command to run the MCP server
CMD ["python", "src/crawl4ai_mcp.py"]
