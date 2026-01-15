# Google OAuth Implementation Guide

Based on claudish PR #28: https://github.com/MadAppGang/claudish/pull/28

## Overview

Instead of requiring users to manually obtain a `GOOGLE_API_KEY` from Google AI Studio, we can implement OAuth 2.0 authentication using Google's OAuth flow. This provides a better user experience with browser-based login.

## Implementation Details

### 1. OAuth Credentials (Public CLI Credentials from gemini-cli)

```javascript
const CLIENT_ID = process.env.OAUTH_CLIENT_ID ||
  '681255809395-oo8ft2oprdrnp9e3aqf6av3hmdib135j.apps.googleusercontent.com';
const CLIENT_SECRET = process.env.OAUTH_CLIENT_SECRET ||
  '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';
```

**Note**: These are public OAuth credentials intended for CLI usage (same as gemini-cli uses).

### 2. Authorization Flow

**Scopes Required**:
- `https://www.googleapis.com/auth/cloud-platform`
- `https://www.googleapis.com/auth/userinfo.email`
- `https://www.googleapis.com/auth/userinfo.profile`

**Authorization URL**:
```
https://accounts.google.com/o/oauth2/v2/auth
```

**Key Parameters**:
- `response_type`: code
- `client_id`: (from above)
- `redirect_uri`: http://127.0.0.1:{random_port}/oauth2callback
- `scope`: (space-separated scopes)
- `access_type`: offline (to get refresh token)
- `code_challenge_method`: S256 (PKCE for security)
- `code_challenge`: (generated from code verifier)
- `state`: (random string for CSRF protection)

### 3. Callback Server Implementation

```javascript
// Pseudo-code based on claudish implementation
const server = http.createServer(async (req, res) => {
  if (req.url?.startsWith('/oauth2callback')) {
    const url = new URL(req.url, `http://127.0.0.1:${port}`);
    const code = url.searchParams.get('code');
    const state = url.searchParams.get('state');

    // Validate state parameter
    if (state !== expectedState) {
      res.end('Error: Invalid state parameter');
      return;
    }

    // Exchange code for tokens
    const tokens = await exchangeCodeForTokens(code, codeVerifier);

    // Store tokens
    await saveTokens(tokens);

    // Show success page
    res.end('Successfully authenticated! You can close this window.');
    server.close();
  }
});

server.listen(0, '127.0.0.1'); // Listen on random port
```

### 4. Token Storage

**Location**: `~/.claude/gemini-oauth.json` (or similar)

**Permissions**: `0o600` (read/write for owner only)

**Format**:
```json
{
  "access_token": "ya29.a0AfB_...",
  "refresh_token": "1//0gXxxx...",
  "scope": "https://www.googleapis.com/auth/cloud-platform ...",
  "token_type": "Bearer",
  "id_token": "eyJhbGc...",
  "expiry_date": 1736712345678
}
```

### 5. Token Refresh Logic

```javascript
async function refreshAccessToken(refreshToken) {
  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      refresh_token: refreshToken,
      grant_type: 'refresh_token'
    })
  });

  const tokens = await response.json();

  // Update expiry date (tokens typically valid for 1 hour)
  tokens.expiry_date = Date.now() + (tokens.expires_in * 1000);

  // Save updated tokens
  await saveTokens(tokens);

  return tokens;
}

// Check if token needs refresh (5 minute buffer)
function needsRefresh(expiryDate) {
  return Date.now() > (expiryDate - 5 * 60 * 1000);
}
```

### 6. Integration with Model Proxy

**Flow**:
1. User runs: `clauded --gemini-login` (or similar command)
2. Browser opens to Google OAuth consent page
3. User authorizes the application
4. Callback server receives authorization code
5. Exchange code for access + refresh tokens
6. Store tokens locally
7. Model proxy uses access token for Gemini API requests

**Fallback**:
- If `GOOGLE_API_KEY` environment variable is set, use it directly
- Otherwise, try to load OAuth tokens from `~/.claude/gemini-oauth.json`
- If neither exists, prompt user to run login command

### 7. Using Code Assist API

**Endpoint**: `https://codeassist.googleapis.com/v1/projects/{PROJECT_ID}/locations/{LOCATION}/codeAssistSessions:run`

**Headers**:
```javascript
{
  'Authorization': `Bearer ${access_token}`,
  'Content-Type': 'application/json'
}
```

**Note**: The PR mentions automatic Code Assist project provisioning if needed.

## Implementation Steps for model-proxy-server.js

1. **Add OAuth module** (`~/.claude/lib/gemini-oauth.js`):
   - Implement authorization flow with PKCE
   - Local callback server on random port
   - Token storage and refresh logic

2. **Add CLI command** to model-proxy-server.js:
   - `--gemini-login` flag to trigger OAuth flow
   - Open browser to authorization URL
   - Wait for callback and token exchange

3. **Update Gemini provider** in proxy server:
   - Check for OAuth tokens before requiring API key
   - Auto-refresh expired tokens
   - Use Code Assist API with OAuth

4. **Graceful fallback**:
   - Try OAuth tokens first
   - Fall back to `GOOGLE_API_KEY` if set
   - Error message if neither available

## Benefits

- ✅ **Better UX**: No need to manually copy API keys from Google AI Studio
- ✅ **More secure**: OAuth flow with PKCE
- ✅ **Auto-refresh**: Tokens automatically renewed
- ✅ **Code Assist**: Access to Google's Code Assist API (if available)
- ✅ **Familiar pattern**: Same as gemini-cli users already know

## Testing

1. Test OAuth flow: `clauded --gemini-login`
2. Verify token storage and permissions
3. Test API calls with OAuth token
4. Test token refresh logic
5. Test fallback to API key if OAuth not configured

---

*Generated from claudish PR #28 analysis*
*Date: 2026-01-12*
