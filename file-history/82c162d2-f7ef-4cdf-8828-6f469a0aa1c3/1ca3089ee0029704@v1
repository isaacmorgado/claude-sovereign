#!/usr/bin/env node
/**
 * Multi-Provider Proxy Server for Claude Code (with Google OAuth)
 * Enables GLM, Featherless.ai, Google Gemini (with OAuth), and Anthropic models
 *
 * Features:
 * - Tool calling emulation for models without native support (abliterated models)
 * - Google OAuth 2.0 authentication (browser-based login)
 * - Multiple provider support with automatic format translation
 * - Seamless integration with Claude Code's MCP tools
 *
 * Usage:
 *   node model-proxy-server.js [port]          # Start proxy server
 *   node model-proxy-server.js --gemini-login  # Login to Google via OAuth
 *
 * Then start Claude Code with:
 *   ANTHROPIC_BASE_URL=http://localhost:PORT claude
 *
 * Model Prefixes:
 *   glm/glm-4           -> GLM (ZhipuAI)
 *   featherless/...     -> Featherless.ai (with tool emulation)
 *   google/gemini-pro   -> Google Gemini (OAuth or API key)
 *   anthropic/...       -> Native Anthropic (passthrough)
 *   (no prefix)         -> Native Anthropic (passthrough)
 */

const http = require('http');
const https = require('https');
const { URL } = require('url');

// Check for CLI flags
const args = process.argv.slice(2);
const isLoginCommand = args.includes('--gemini-login') || args.includes('--google-login');
const isLogoutCommand = args.includes('--gemini-logout') || args.includes('--google-logout');

// Handle OAuth commands
if (isLoginCommand || isLogoutCommand) {
  (async () => {
    const { startOAuthLogin, clearTokens } = await import('./lib/gemini-oauth.js');

    if (isLoginCommand) {
      console.log('');
      console.log('🔐 Starting Google OAuth login...');
      console.log('');
      try {
        await startOAuthLogin();
        console.log('');
        console.log('✅ Google authentication successful!');
        console.log('');
        console.log('You can now use Google Gemini models without GOOGLE_API_KEY');
        console.log('Example: /model google/gemini-2.0-flash');
        console.log('');
      } catch (error) {
        console.error('');
        console.error('❌ OAuth login failed:', error.message);
        console.error('');
        process.exit(1);
      }
    } else if (isLogoutCommand) {
      console.log('');
      console.log('🔓 Clearing Google OAuth tokens...');
      const cleared = await clearTokens();
      if (cleared) {
        console.log('✓ Logged out successfully');
      } else {
        console.log('ℹ No tokens found');
      }
      console.log('');
    }

    process.exit(0);
  })();

  // Don't start server for login/logout commands
  return;
}

// Configuration
const PORT = process.env.CLAUDISH_PORT || args.find(a => !a.startsWith('--')) || 3000;
const GLM_API_KEY = process.env.GLM_API_KEY || '9a58c7331504f3cbaef3f2f95cb375b.BrfNpV8TbeF5tCaK';
const GLM_BASE_URL = 'https://open.bigmodel.cn/api/paas/v4';
const FEATHERLESS_API_KEY = process.env.FEATHERLESS_API_KEY || '';
const FEATHERLESS_BASE_URL = 'https://api.featherless.ai/v1';
const GOOGLE_API_KEY = process.env.GOOGLE_API_KEY || '';
const GOOGLE_BASE_URL = 'https://generativelanguage.googleapis.com/v1beta';
const ANTHROPIC_API_KEY = process.env.ANTHROPIC_API_KEY || '';
const ANTHROPIC_BASE_URL = 'https://api.anthropic.com';

// Models that support native tool calling
const NATIVE_TOOL_CALLING_MODELS = [
  'glm-4',
  'glm-4-plus',
  'gemini-pro',
  'gemini-1.5-pro',
  'gemini-2.0-flash',
];

// Color codes for logging
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  dim: '\x1b[2m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
  matrixGreen: '\x1b[38;5;46m', // Matrix green color
};

function log(message, color = 'reset') {
  const timestamp = new Date().toISOString().split('T')[1].split('.')[0];
  console.error(`${colors.dim}[${timestamp}]${colors.reset} ${colors[color]}${message}${colors.reset}`);
}

// OAuth module (loaded dynamically when needed)
let oauthModule = null;
async function getOAuthModule() {
  if (!oauthModule) {
    oauthModule = await import('./lib/gemini-oauth.js');
  }
  return oauthModule;
}

/**
 * Get Google API authentication (OAuth token or API key)
 * Returns { type: 'oauth' | 'apikey', token: string } or null
 */
async function getGoogleAuth() {
  // Try OAuth first
  try {
    const oauth = await getOAuthModule();
    const accessToken = await oauth.getAccessToken();
    if (accessToken) {
      return { type: 'oauth', token: accessToken };
    }
  } catch (error) {
    log(`OAuth token unavailable: ${error.message}`, 'dim');
  }

  // Fall back to API key
  if (GOOGLE_API_KEY) {
    return { type: 'apikey', token: GOOGLE_API_KEY };
  }

  return null;
}
