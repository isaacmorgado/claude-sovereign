/**
 * API Call Capture Script for Black-Box Analysis
 *
 * Usage: Copy and paste this entire script into the browser console,
 * then browse the website. All API calls will be logged.
 *
 * Commands:
 *   apiCapture.getLogs()     - Get all captured requests
 *   apiCapture.clear()       - Clear captured logs
 *   apiCapture.export()      - Export logs as JSON file
 *   apiCapture.summary()     - Show summary of endpoints
 *   apiCapture.stop()        - Stop capturing
 *   apiCapture.start()       - Resume capturing
 */

(function() {
  'use strict';

  const apiCapture = {
    logs: [],
    isCapturing: true,
    startTime: Date.now(),

    // Store original functions
    originalFetch: window.fetch.bind(window),
    originalXHROpen: XMLHttpRequest.prototype.open,
    originalXHRSend: XMLHttpRequest.prototype.send,

    log(entry) {
      if (!this.isCapturing) return;

      const logEntry = {
        id: this.logs.length + 1,
        timestamp: new Date().toISOString(),
        relativeTime: Date.now() - this.startTime,
        ...entry
      };

      this.logs.push(logEntry);

      // Console output with styling
      const methodColors = {
        GET: '#61affe',
        POST: '#49cc90',
        PUT: '#fca130',
        PATCH: '#50e3c2',
        DELETE: '#f93e3e'
      };

      const color = methodColors[entry.method] || '#999';

      console.groupCollapsed(
        `%c${entry.method}%c ${entry.url}`,
        `background: ${color}; color: white; padding: 2px 6px; border-radius: 3px; font-weight: bold;`,
        'color: inherit;'
      );
      console.log('📋 Request:', entry);
      if (entry.requestBody) {
        console.log('📤 Body:', entry.requestBody);
      }
      if (entry.requestHeaders) {
        console.log('📨 Headers:', entry.requestHeaders);
      }
      console.groupEnd();
    },

    logResponse(id, response) {
      const entry = this.logs.find(l => l.id === id);
      if (entry) {
        entry.response = response;
        entry.duration = Date.now() - this.startTime - entry.relativeTime;

        const statusColor = response.status >= 400 ? '#f93e3e' :
                           response.status >= 300 ? '#fca130' : '#49cc90';

        console.log(
          `%c${response.status}%c ${entry.method} ${entry.url} (${entry.duration}ms)`,
          `background: ${statusColor}; color: white; padding: 2px 6px; border-radius: 3px;`,
          'color: #666;'
        );

        if (response.body) {
          console.log('📥 Response:', response.body);
        }
      }
    },

    // Intercept Fetch API
    interceptFetch() {
      const self = this;

      window.fetch = async function(input, init = {}) {
        const url = typeof input === 'string' ? input : input.url;
        const method = init.method || (input.method) || 'GET';

        let requestBody = null;
        let requestHeaders = {};

        // Capture headers
        if (init.headers) {
          if (init.headers instanceof Headers) {
            init.headers.forEach((v, k) => requestHeaders[k] = v);
          } else {
            requestHeaders = { ...init.headers };
          }
        }

        // Capture body
        if (init.body) {
          try {
            if (typeof init.body === 'string') {
              requestBody = JSON.parse(init.body);
            } else if (init.body instanceof FormData) {
              requestBody = {};
              init.body.forEach((v, k) => requestBody[k] = v);
            } else {
              requestBody = init.body;
            }
          } catch {
            requestBody = init.body;
          }
        }

        const entryId = self.logs.length + 1;

        self.log({
          type: 'fetch',
          method: method.toUpperCase(),
          url,
          requestHeaders,
          requestBody
        });

        try {
          const response = await self.originalFetch(input, init);
          const clonedResponse = response.clone();

          let responseBody = null;
          try {
            const contentType = response.headers.get('content-type');
            if (contentType && contentType.includes('application/json')) {
              responseBody = await clonedResponse.json();
            } else {
              responseBody = await clonedResponse.text();
              if (responseBody.length > 1000) {
                responseBody = responseBody.substring(0, 1000) + '... (truncated)';
              }
            }
          } catch {}

          const responseHeaders = {};
          response.headers.forEach((v, k) => responseHeaders[k] = v);

          self.logResponse(entryId, {
            status: response.status,
            statusText: response.statusText,
            headers: responseHeaders,
            body: responseBody
          });

          return response;
        } catch (error) {
          self.logResponse(entryId, {
            status: 0,
            error: error.message
          });
          throw error;
        }
      };
    },

    // Intercept XMLHttpRequest
    interceptXHR() {
      const self = this;

      XMLHttpRequest.prototype.open = function(method, url, ...args) {
        this._captureData = {
          method: method.toUpperCase(),
          url,
          requestHeaders: {}
        };
        return self.originalXHROpen.apply(this, [method, url, ...args]);
      };

      const originalSetRequestHeader = XMLHttpRequest.prototype.setRequestHeader;
      XMLHttpRequest.prototype.setRequestHeader = function(name, value) {
        if (this._captureData) {
          this._captureData.requestHeaders[name] = value;
        }
        return originalSetRequestHeader.apply(this, [name, value]);
      };

      XMLHttpRequest.prototype.send = function(body) {
        if (this._captureData) {
          let requestBody = null;
          if (body) {
            try {
              requestBody = JSON.parse(body);
            } catch {
              requestBody = body;
            }
          }

          const entryId = self.logs.length + 1;
          this._captureData.entryId = entryId;

          self.log({
            type: 'xhr',
            ...this._captureData,
            requestBody
          });

          this.addEventListener('load', function() {
            let responseBody = null;
            try {
              responseBody = JSON.parse(this.responseText);
            } catch {
              responseBody = this.responseText;
              if (responseBody && responseBody.length > 1000) {
                responseBody = responseBody.substring(0, 1000) + '... (truncated)';
              }
            }

            self.logResponse(this._captureData.entryId, {
              status: this.status,
              statusText: this.statusText,
              body: responseBody
            });
          });

          this.addEventListener('error', function() {
            self.logResponse(this._captureData.entryId, {
              status: 0,
              error: 'Network Error'
            });
          });
        }

        return self.originalXHRSend.apply(this, [body]);
      };
    },

    // Intercept WebSocket (optional)
    interceptWebSocket() {
      const self = this;
      const OriginalWebSocket = window.WebSocket;

      window.WebSocket = function(url, protocols) {
        const ws = new OriginalWebSocket(url, protocols);

        self.log({
          type: 'websocket',
          method: 'CONNECT',
          url
        });

        const originalSend = ws.send.bind(ws);
        ws.send = function(data) {
          console.log('%c⬆️ WS Send%c', 'background: #9b59b6; color: white; padding: 2px 6px; border-radius: 3px;', '', data);
          return originalSend(data);
        };

        ws.addEventListener('message', function(event) {
          console.log('%c⬇️ WS Receive%c', 'background: #3498db; color: white; padding: 2px 6px; border-radius: 3px;', '', event.data);
        });

        return ws;
      };
      window.WebSocket.prototype = OriginalWebSocket.prototype;
    },

    // Public methods
    getLogs() {
      console.table(this.logs.map(l => ({
        id: l.id,
        method: l.method,
        url: l.url,
        status: l.response?.status,
        duration: l.duration ? `${l.duration}ms` : 'pending'
      })));
      return this.logs;
    },

    clear() {
      this.logs = [];
      this.startTime = Date.now();
      console.clear();
      console.log('%c🗑️ API Capture logs cleared', 'color: #666;');
    },

    export() {
      const data = JSON.stringify(this.logs, null, 2);
      const blob = new Blob([data], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `api-capture-${new Date().toISOString().split('T')[0]}.json`;
      a.click();
      URL.revokeObjectURL(url);
      console.log(`%c📁 Exported ${this.logs.length} requests`, 'color: #49cc90;');
    },

    summary() {
      const endpoints = {};

      this.logs.forEach(log => {
        const key = `${log.method} ${new URL(log.url, window.location.origin).pathname}`;
        if (!endpoints[key]) {
          endpoints[key] = { count: 0, statuses: [], avgDuration: 0, durations: [] };
        }
        endpoints[key].count++;
        if (log.response?.status) {
          endpoints[key].statuses.push(log.response.status);
        }
        if (log.duration) {
          endpoints[key].durations.push(log.duration);
        }
      });

      Object.keys(endpoints).forEach(key => {
        const e = endpoints[key];
        e.avgDuration = e.durations.length
          ? Math.round(e.durations.reduce((a, b) => a + b, 0) / e.durations.length)
          : 0;
        e.statuses = [...new Set(e.statuses)].join(', ');
        delete e.durations;
      });

      console.log('%c📊 API Endpoint Summary', 'font-size: 14px; font-weight: bold;');
      console.table(endpoints);
      return endpoints;
    },

    stop() {
      this.isCapturing = false;
      console.log('%c⏸️ API Capture paused', 'color: #fca130;');
    },

    start() {
      this.isCapturing = true;
      console.log('%c▶️ API Capture resumed', 'color: #49cc90;');
    },

    init() {
      this.interceptFetch();
      this.interceptXHR();
      this.interceptWebSocket();

      console.log('%c🔍 API Capture Active', 'font-size: 16px; font-weight: bold; color: #49cc90;');
      console.log('%cCommands:', 'font-weight: bold;');
      console.log('  apiCapture.getLogs()   - View all captured requests');
      console.log('  apiCapture.summary()   - Endpoint summary');
      console.log('  apiCapture.export()    - Download as JSON');
      console.log('  apiCapture.clear()     - Clear logs');
      console.log('  apiCapture.stop()      - Pause capturing');
      console.log('  apiCapture.start()     - Resume capturing');
      console.log('%cBrowse the site and watch API calls appear here...', 'color: #666; font-style: italic;');
    }
  };

  // Initialize and expose globally
  apiCapture.init();
  window.apiCapture = apiCapture;
})();
