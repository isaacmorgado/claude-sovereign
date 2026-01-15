/**
 * Full Website Reverse Engineering Capture
 *
 * Captures: API calls, JS source files, localStorage, sessionStorage,
 * cookies, and monitors function calls.
 *
 * Usage: Paste in console, browse site, then run capture.exportAll()
 */

(function() {
  'use strict';

  const capture = {
    apiLogs: [],
    jsSources: [],
    storageSnapshot: {},
    cookies: {},
    isCapturing: true,
    startTime: Date.now(),

    originalFetch: window.fetch.bind(window),
    originalXHROpen: XMLHttpRequest.prototype.open,
    originalXHRSend: XMLHttpRequest.prototype.send,

    // ============ API CAPTURE ============
    interceptFetch() {
      const self = this;
      window.fetch = async function(input, init = {}) {
        const url = typeof input === 'string' ? input : input.url;
        const method = (init.method || 'GET').toUpperCase();

        let requestBody = null;
        let requestHeaders = {};

        if (init.headers) {
          if (init.headers instanceof Headers) {
            init.headers.forEach((v, k) => requestHeaders[k] = v);
          } else {
            requestHeaders = { ...init.headers };
          }
        }

        if (init.body) {
          try {
            if (typeof init.body === 'string') {
              try { requestBody = JSON.parse(init.body); }
              catch { requestBody = init.body; }
            } else if (init.body instanceof FormData) {
              requestBody = {};
              init.body.forEach((v, k) => requestBody[k] = v);
            } else {
              requestBody = String(init.body);
            }
          } catch {
            requestBody = '[Binary Data]';
          }
        }

        const entry = {
          id: self.apiLogs.length + 1,
          timestamp: new Date().toISOString(),
          type: 'fetch',
          method,
          url,
          requestHeaders,
          requestBody,
          response: null
        };
        self.apiLogs.push(entry);

        console.log(`%c→ ${method}%c ${url}`,
          'background: #61affe; color: white; padding: 2px 6px; border-radius: 3px;', '');

        try {
          const response = await self.originalFetch(input, init);
          const cloned = response.clone();

          let responseBody = null;
          try {
            const ct = response.headers.get('content-type') || '';
            if (ct.includes('json')) {
              responseBody = await cloned.json();
            } else if (ct.includes('text') || ct.includes('javascript')) {
              responseBody = await cloned.text();
            } else {
              responseBody = '[Binary/Unknown Content]';
            }
          } catch { responseBody = '[Could not parse]'; }

          const responseHeaders = {};
          response.headers.forEach((v, k) => responseHeaders[k] = v);

          entry.response = {
            status: response.status,
            statusText: response.statusText,
            headers: responseHeaders,
            body: responseBody
          };

          const statusColor = response.status >= 400 ? '#f93e3e' : '#49cc90';
          console.log(`%c← ${response.status}%c ${url}`,
            `background: ${statusColor}; color: white; padding: 2px 6px; border-radius: 3px;`, '');

          return response;
        } catch (err) {
          entry.response = { error: err.message };
          throw err;
        }
      };
    },

    interceptXHR() {
      const self = this;

      XMLHttpRequest.prototype.open = function(method, url, ...args) {
        this._capture = { method: method.toUpperCase(), url, headers: {} };
        return self.originalXHROpen.apply(this, [method, url, ...args]);
      };

      const origSetHeader = XMLHttpRequest.prototype.setRequestHeader;
      XMLHttpRequest.prototype.setRequestHeader = function(name, value) {
        if (this._capture) this._capture.headers[name] = value;
        return origSetHeader.apply(this, [name, value]);
      };

      XMLHttpRequest.prototype.send = function(body) {
        if (this._capture) {
          const entry = {
            id: self.apiLogs.length + 1,
            timestamp: new Date().toISOString(),
            type: 'xhr',
            method: this._capture.method,
            url: this._capture.url,
            requestHeaders: this._capture.headers,
            requestBody: body,
            response: null
          };
          self.apiLogs.push(entry);
          this._captureEntry = entry;

          console.log(`%c→ XHR ${this._capture.method}%c ${this._capture.url}`,
            'background: #fca130; color: white; padding: 2px 6px; border-radius: 3px;', '');

          this.addEventListener('load', function() {
            let responseBody;
            try { responseBody = JSON.parse(this.responseText); }
            catch { responseBody = this.responseText; }

            this._captureEntry.response = {
              status: this.status,
              body: responseBody
            };
          });
        }
        return self.originalXHRSend.apply(this, [body]);
      };
    },

    // ============ JS SOURCE CAPTURE ============
    captureJSSources() {
      const self = this;

      // Get all script tags
      document.querySelectorAll('script').forEach(script => {
        if (script.src) {
          self.jsSources.push({
            type: 'external',
            src: script.src,
            content: null // Will fetch later
          });
        } else if (script.textContent) {
          self.jsSources.push({
            type: 'inline',
            content: script.textContent
          });
        }
      });

      console.log(`%c📜 Found ${this.jsSources.length} script tags`, 'color: #9b59b6;');
    },

    async fetchJSSources() {
      console.log('%c⏳ Fetching JS source files...', 'color: #f39c12;');

      for (const source of this.jsSources) {
        if (source.type === 'external' && source.src) {
          try {
            const resp = await this.originalFetch(source.src);
            source.content = await resp.text();
            console.log(`%c✓%c ${source.src}`, 'color: #49cc90;', 'color: #666;');
          } catch (err) {
            source.content = `[Error fetching: ${err.message}]`;
            console.log(`%c✗%c ${source.src}`, 'color: #f93e3e;', 'color: #666;');
          }
        }
      }

      // Also try to get source maps
      for (const source of this.jsSources) {
        if (source.content && source.content.includes('//# sourceMappingURL=')) {
          const match = source.content.match(/\/\/# sourceMappingURL=(.+)/);
          if (match) {
            try {
              const mapUrl = new URL(match[1], source.src).href;
              const mapResp = await this.originalFetch(mapUrl);
              source.sourceMap = await mapResp.json();
              console.log(`%c✓ SourceMap%c ${mapUrl}`, 'color: #49cc90;', 'color: #666;');
            } catch {}
          }
        }
      }

      console.log('%c✅ JS sources fetched', 'color: #49cc90;');
    },

    // ============ STORAGE & COOKIES ============
    captureStorage() {
      this.storageSnapshot = {
        localStorage: { ...localStorage },
        sessionStorage: { ...sessionStorage },
        timestamp: new Date().toISOString()
      };

      // Parse JSON values where possible
      for (const store of ['localStorage', 'sessionStorage']) {
        for (const key in this.storageSnapshot[store]) {
          try {
            this.storageSnapshot[store][key] = JSON.parse(this.storageSnapshot[store][key]);
          } catch {}
        }
      }

      console.log('%c💾 Storage captured', 'color: #3498db;');
    },

    captureCookies() {
      this.cookies = {};
      document.cookie.split(';').forEach(cookie => {
        const [name, ...rest] = cookie.trim().split('=');
        if (name) {
          this.cookies[name] = decodeURIComponent(rest.join('='));
        }
      });
      console.log('%c🍪 Cookies captured', 'color: #e67e22;');
    },

    // ============ FIND MATH/CALCULATION FUNCTIONS ============
    findCalculations() {
      const mathPatterns = [
        /function\s+\w*(?:calc|compute|score|ratio|measure|analyze|evaluate)\w*\s*\([^)]*\)\s*\{[^}]+\}/gi,
        /(?:const|let|var)\s+\w*(?:calc|compute|score|ratio|measure|formula)\w*\s*=\s*(?:function|\([^)]*\)\s*=>)[^;]+/gi,
        /Math\.\w+\([^)]+\)/g,
        /(?:\+|\-|\*|\/)\s*(?:\d+\.?\d*|\w+)\s*(?:\+|\-|\*|\/)/g,
      ];

      const calculations = [];

      this.jsSources.forEach(source => {
        if (!source.content) return;

        // Find function definitions with math-related names
        const funcMatches = source.content.match(
          /(?:function\s+(\w+)|(?:const|let|var)\s+(\w+)\s*=\s*(?:function|\([^)]*\)\s*=>))[^]*?(?:\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}|[^;]+;)/g
        );

        if (funcMatches) {
          funcMatches.forEach(match => {
            const hasCalculation =
              match.includes('Math.') ||
              /[\+\-\*\/]\s*[\d\w]+\s*[\+\-\*\/]/.test(match) ||
              /(?:ratio|score|calc|compute|measure|distance|angle)/i.test(match);

            if (hasCalculation) {
              calculations.push({
                source: source.src || 'inline',
                code: match.substring(0, 2000) // Limit size
              });
            }
          });
        }
      });

      console.log(`%c🔢 Found ${calculations.length} potential calculation functions`, 'color: #9b59b6;');
      return calculations;
    },

    // ============ SEARCH WITHIN CAPTURED CODE ============
    search(pattern, options = {}) {
      const regex = new RegExp(pattern, options.flags || 'gi');
      const results = [];

      this.jsSources.forEach(source => {
        if (!source.content) return;

        const lines = source.content.split('\n');
        lines.forEach((line, idx) => {
          if (regex.test(line)) {
            results.push({
              file: source.src || 'inline',
              line: idx + 1,
              content: line.trim().substring(0, 200),
              context: lines.slice(Math.max(0, idx - 2), idx + 3).join('\n')
            });
          }
        });
      });

      console.log(`%c🔍 Found ${results.length} matches for "${pattern}"`, 'color: #3498db;');
      console.table(results.map(r => ({ file: r.file, line: r.line, content: r.content })));
      return results;
    },

    // ============ EXPORT ============
    async exportAll() {
      console.log('%c📦 Preparing full export...', 'color: #f39c12; font-weight: bold;');

      // Fetch JS sources if not already done
      const hasContent = this.jsSources.some(s => s.content);
      if (!hasContent) {
        await this.fetchJSSources();
      }

      this.captureStorage();
      this.captureCookies();

      const exportData = {
        metadata: {
          url: window.location.href,
          title: document.title,
          timestamp: new Date().toISOString(),
          userAgent: navigator.userAgent
        },
        apiCalls: this.apiLogs,
        jsSources: this.jsSources,
        storage: this.storageSnapshot,
        cookies: this.cookies,
        calculations: this.findCalculations()
      };

      const blob = new Blob([JSON.stringify(exportData, null, 2)], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `site-capture-${window.location.hostname}-${Date.now()}.json`;
      a.click();
      URL.revokeObjectURL(url);

      console.log('%c✅ Export complete!', 'color: #49cc90; font-weight: bold;');
      console.log(`   ${this.apiLogs.length} API calls`);
      console.log(`   ${this.jsSources.length} JS files`);
      console.log(`   ${Object.keys(this.storageSnapshot.localStorage || {}).length} localStorage items`);

      return exportData;
    },

    exportAPIOnly() {
      const blob = new Blob([JSON.stringify(this.apiLogs, null, 2)], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `api-calls-${Date.now()}.json`;
      a.click();
      URL.revokeObjectURL(url);
      console.log(`%c📁 Exported ${this.apiLogs.length} API calls`, 'color: #49cc90;');
    },

    // ============ UTILITIES ============
    getLogs() {
      console.table(this.apiLogs.map(l => ({
        id: l.id,
        method: l.method,
        url: l.url.substring(0, 60),
        status: l.response?.status || 'pending',
        hasBody: !!l.requestBody
      })));
      return this.apiLogs;
    },

    clear() {
      this.apiLogs = [];
      this.jsSources = [];
      console.clear();
      console.log('%c🗑️ Cleared', 'color: #666;');
    },

    // ============ INIT ============
    init() {
      this.interceptFetch();
      this.interceptXHR();
      this.captureJSSources();

      console.log('%c🔬 Full Capture Active', 'font-size: 18px; font-weight: bold; color: #e74c3c;');
      console.log('');
      console.log('%cBrowse the site, then run:', 'font-weight: bold;');
      console.log('');
      console.log('  capture.exportAll()        → Download everything (API + JS + storage)');
      console.log('  capture.exportAPIOnly()    → Download API calls only');
      console.log('  capture.fetchJSSources()   → Fetch all JS file contents');
      console.log('  capture.findCalculations() → Find math/scoring functions');
      console.log('  capture.search("pattern")  → Search in captured JS');
      console.log('  capture.getLogs()          → View API calls table');
      console.log('');
      console.log('%cTip: Run capture.search("score") or capture.search("ratio") to find formulas', 'color: #666; font-style: italic;');
    }
  };

  capture.init();
  window.capture = capture;
})();
