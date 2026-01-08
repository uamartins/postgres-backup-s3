# API Documentation

This project now includes a REST API to trigger backup and restore operations on demand.

## Overview

The API listens on port `80` by default. It allows you to trigger backups and restores programmatically without waiting for the schedule.

## Endpoints

### 1. Trigger Backup
Triggers the `backup.sh` script immediately.

- **URL**: `/backup`
- **Method**: `POST`
- **Success Response**:
  - **Code**: 200 OK
  - **Content**:
    ```json
    {
      "status": "success",
      "message": "Backup completed successfully",
      "output": "..."
    }
    ```
- **Error Response**:
  - **Code**: 500 Internal Server Error
  - **Content**:
    ```json
    {
      "status": "error",
      "message": "Backup failed",
      "error": "..."
    }
    ```

**Example:**
```bash
curl -X POST http://localhost:80/backup
```

### 2. Trigger Restore
Triggers the `restore.sh` script.

- **URL**: `/restore`
- **Method**: `POST`
- **Body** (optional):
  ```json
  {
    "timestamp": "2023-10-27T10:00:00"
  }
  ```
  If `timestamp` is provided, it restores that specific version. If omitted, it restores the latest available backup.

- **Success Response**:
  - **Code**: 200 OK
  - **Content**:
    ```json
    {
      "status": "success",
      "message": "Restore completed successfully"
    }
    ```

**Example (Latest):**
```bash
curl -X POST http://localhost:80/restore
```

**Example (Specific Timestamp):**
```bash
curl -X POST -H "Content-Type: application/json" \
     -d '{"timestamp": "2023-10-27T10:00:00"}' \
     http://localhost:80/restore
```

### 3. Health Check
Simple health check endpoint.

- **URL**: `/health`
- **Method**: `GET`
- **Response**: `{"status": "healthy"}`

## Configuration

The API server runs automatically when the container starts.
- **Port**: 80 (configurable via `API_PORT` env var, default 80)
