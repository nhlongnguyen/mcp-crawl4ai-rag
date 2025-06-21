# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an MCP (Model Context Protocol) server that integrates Crawl4AI web crawling with RAG (Retrieval Augmented Generation) capabilities. It serves as a knowledge engine for AI agents, providing intelligent web content crawling, vector storage, and semantic search capabilities with optional AI hallucination detection through knowledge graphs.

## Development Commands

### Setup and Installation
```bash
# Python setup
uv venv && source .venv/bin/activate
uv pip install -e .
crawl4ai-setup

# Docker setup
docker build -t mcp/crawl4ai-rag --build-arg PORT=8051 .
docker run --env-file .env -p 8051:8051 mcp/crawl4ai-rag
```

### Running the Server
```bash
# SSE transport (default)
python src/crawl4ai_mcp.py

# Stdio transport
python src/crawl4ai_mcp.py --transport stdio

# With specific port
python src/crawl4ai_mcp.py --port 8051
```

### Testing
```bash
# Test MCP server locally
npx @modelcontextprotocol/inspector src/crawl4ai_mcp.py

# Test with Claude Desktop (add to config)
# SSE: http://localhost:8000/sse
# Stdio: python src/crawl4ai_mcp.py --transport stdio
```

## Core Architecture

### Main Components

**Entry Point:** `src/crawl4ai_mcp.py`
- FastMCP server with dual transport support (SSE/stdio)
- Async lifespan management for crawler and database connections
- Environment-driven configuration with toggleable RAG strategies

**Utilities:** `src/utils.py`
- Supabase vector database integration
- OpenAI embeddings with batch processing
- Smart content chunking with markdown-aware breaking
- Code example extraction and summarization

**Knowledge Graph System:** `knowledge_graphs/`
- Neo4j integration for repository analysis
- AI hallucination detection by validating code against real repositories
- AST-based script validation for imports, methods, and classes

### Database Schema (Supabase)

Three main tables defined in `crawled_pages.sql`:
- `sources`: Domain-level summaries and metadata
- `crawled_pages`: Document chunks with vector embeddings
- `code_examples`: Extracted code blocks with summaries

Uses pgvector extension for cosine similarity search.

### RAG Strategy Configuration

Control advanced features via environment variables:
- `USE_CONTEXTUAL_EMBEDDINGS=true` - LLM-enhanced chunk context
- `USE_HYBRID_SEARCH=true` - Vector + keyword combined search
- `USE_AGENTIC_RAG=true` - Enables code example tools
- `USE_RERANKING=true` - Cross-encoder result reordering
- `USE_KNOWLEDGE_GRAPH=true` - Enables hallucination detection tools

## Key Architectural Patterns

### Smart Crawling Engine
The system automatically detects URL types:
- **Sitemaps**: Extracts and crawls all URLs in parallel
- **Text files**: Direct content retrieval
- **Regular pages**: Recursive internal link following

### Modular RAG Design
Each RAG strategy is independently toggleable, allowing progressive enhancement of capabilities based on requirements and computational resources.

### Async Context Management
Proper lifecycle handling ensures crawlers and database connections are cleanly managed through server startup/shutdown.

### Batch Processing
Parallel embedding creation and database operations with configurable batch sizes for memory efficiency.

## Environment Configuration

Copy `.env.example` to `.env` and configure:
- **Database**: Supabase credentials and connection details
- **AI Services**: OpenAI API key for embeddings
- **Optional**: Neo4j credentials for knowledge graph features
- **Transport**: Choose between SSE or stdio for MCP communication
- **RAG Strategies**: Enable/disable advanced features

## MCP Tools Available

### Core Tools (Always Available)
- `crawl_single_page` - Quick single-page content retrieval
- `smart_crawl_url` - Intelligent multi-page crawling with depth control
- `get_available_sources` - List all indexed domains
- `perform_rag_query` - Semantic search with optional source filtering

### Conditional Tools
- `search_code_examples` - Code-specific search (requires `USE_AGENTIC_RAG=true`)
- `parse_github_repository` - Index repositories for validation (requires `USE_KNOWLEDGE_GRAPH=true`)
- `check_ai_script_hallucinations` - Validate Python scripts against knowledge graph
- `query_knowledge_graph` - Interactive Neo4j exploration with Cypher queries

## Development Notes

### Memory Management
The system includes adaptive dispatching that monitors memory usage and adjusts concurrent operations accordingly. Batch sizes are configurable per environment.

### Error Handling
Comprehensive retry logic with exponential backoff is implemented throughout, particularly for embedding generation and database operations.

### Performance Optimization
Vector indexing is automatically created for optimal query performance. The system supports both exact and approximate vector searches based on query requirements.