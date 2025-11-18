# API Authentication Endpoints Documentation

## 1. LOGIN Endpoint

**URL:** `POST /api/auth/login`

**Request Body:**
```json
{
  "usernameOrEmail": "admin@example.com",
  "password": "password123",
  "device": "Browser",
  "ip": "192.168.1.100"
}
```

**Response:**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiJ9.eyJpZFVzZXIiOjEwLCJ1c2VybmFtZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBleGFtcGxlLmNvbSIsInJvbGUiOiJDdXN0b21lciIsInBlcm1pc3Npb25zIjpbIkxpc3RQcm9kdWN0cyIsIkxpc3RTdG9yZXMiLCJTaG93SW5NYXAiLCJEaXNwbGF5U2hvcHBpbmdDYXIiXSwic2Vzc2lvbklkIjoxMjMsImlhdCI6MTczMTY0MDI1MCwiZXhwIjoxNzMxNjQzODUwfQ.xyz...",
  "refreshToken": "eyJhbGciOiJIUzI1NiJ9.eyJpZFVzZXIiOjEwLCJyb2xlIjoiQ3VzdG9tZXIiLCJwZXJtaXNzaW9ucyI6WyJMaXN0UHJvZHVjdHMiLCJMaXN0U3RvcmVzIiwiU2hvd0luTWFwIiwiRGlzcGxheVNob3BwaW5nQ2FyIl0sInNlc3Npb25JZCI6MTIzLCJ0b2tlblR5cGUiOiJyZWZyZXNoIiwiaWF0IjoxNzMxNjQwMjUwLCJleHAiOjE3MzIyNDUwNTB9.abc..."
}
```

**Device Values:**
- "Browser" - Web browsers
- "iPhone" - iOS applications
- "Android" - Android applications
- "Desktop App" - Desktop applications
- "Mobile Web" - Mobile browsers
- "Tablet" - Tablet devices

## JWT Token Structure

### Access Token Claims:
```json
{
  "idUser": 10,
  "username": "admin",
  "email": "admin@example.com",
  "role": "Customer",
  "permissions": ["ListProducts", "ListStores", "ShowInMap", "DisplayShoppingCar"],
  "sessionId": 123,
  "iat": 1731640250,
  "exp": 1731643850
}
```

### Refresh Token Claims:
```json
{
  "idUser": 10,
  "role": "Customer",
  "permissions": ["ListProducts", "ListStores", "ShowInMap", "DisplayShoppingCar"],
  "sessionId": 123,
  "tokenType": "refresh",
  "iat": 1731640250,
  "exp": 1732245050
}
```

## 2. LOGOUT Endpoint

**URL:** `POST /api/auth/logout`

**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJpZFVzZXIiOjEwLCJ1c2VybmFtZSI6ImFkbWluIi...
Content-Type: application/json
```

**Request Body:** Empty (no body required)

**Response:**
```json
{
  "message": "Sesión cerrada exitosamente."
}
```

**Error Response:**
```json
{
  "message": "Token de autorización requerido en el header Authorization"
}
```

## Session Management

### What happens during LOGIN:
1. Creates a new record in `sessions` table with status "Active"
2. Stores device, IP, and login timestamp
3. Generates JWT tokens with user permissions AND session ID
4. **Previous sessions remain active** (allows multiple concurrent sessions)

### What happens during LOGOUT:
1. Extracts userId and sessionId from JWT token
2. Finds the specific session by sessionId
3. Updates ONLY the specific session to "Inactive" status
4. Sets logout timestamp for that specific session
5. Revokes all refresh tokens for the user

**Note:** 
- Multiple concurrent sessions are allowed per user
- Each session is independent and must be closed individually
- If sessionId is not found in the token (older tokens), it will fall back to closing all active sessions for the user

## cURL Examples

### Login:
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "usernameOrEmail": "admin@example.com",
    "password": "password123",
    "device": "Browser",
    "ip": "192.168.1.100"
  }'
```

### Logout:
```bash
curl -X POST http://localhost:8080/api/auth/logout \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -H "Content-Type: application/json"
```