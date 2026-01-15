# Frida Scripts Collection

> Ready-to-use Frida scripts for mobile reverse engineering.
> Based on patterns from: MobSF, frida-codeshare, Brida, noobpk/frida-ios-hook

## Quick Reference

| Task | Script |
|------|--------|
| SSL Pinning Bypass (Android) | `ssl_pinning_bypass_android.js` |
| SSL Pinning Bypass (iOS) | `ssl_pinning_bypass_ios.js` |
| Jailbreak/Root Detection Bypass | `jailbreak_bypass.js` |
| Crypto Interception | `intercept_crypto.js` |
| API Call Logging | `api_logger.js` |
| Class/Method Enumeration | `enumerate_classes.js` |

---

## Android Scripts

### Universal SSL Pinning Bypass
```javascript
// Source: frida-codeshare, MobSF
Java.perform(function() {

    // 1. TrustManager bypass
    var X509TrustManager = Java.use('javax.net.ssl.X509TrustManager');
    var SSLContext = Java.use('javax.net.ssl.SSLContext');

    var TrustManager = Java.registerClass({
        name: 'com.custom.TrustManager',
        implements: [X509TrustManager],
        methods: {
            checkClientTrusted: function(chain, authType) {},
            checkServerTrusted: function(chain, authType) {},
            getAcceptedIssuers: function() { return []; }
        }
    });

    // 2. Replace default SSLContext
    var TrustManagers = [TrustManager.$new()];
    var SSLContextInit = SSLContext.init.overload(
        '[Ljavax.net.ssl.KeyManager;',
        '[Ljavax.net.ssl.TrustManager;',
        'java.security.SecureRandom'
    );
    SSLContextInit.implementation = function(keyManager, trustManager, secureRandom) {
        console.log('[+] SSLContext.init() intercepted - bypassing');
        SSLContextInit.call(this, keyManager, TrustManagers, secureRandom);
    };

    // 3. HostnameVerifier bypass
    var HostnameVerifier = Java.use('javax.net.ssl.HostnameVerifier');
    var HttpsURLConnection = Java.use('javax.net.ssl.HttpsURLConnection');

    HttpsURLConnection.setDefaultHostnameVerifier.implementation = function(verifier) {
        console.log('[+] setDefaultHostnameVerifier bypassed');
    };

    HttpsURLConnection.setSSLSocketFactory.implementation = function(factory) {
        console.log('[+] setSSLSocketFactory bypassed');
    };

    // 4. OkHttp Certificate Pinner bypass
    try {
        var CertificatePinner = Java.use('okhttp3.CertificatePinner');
        CertificatePinner.check.overload('java.lang.String', 'java.util.List').implementation = function(hostname, peerCertificates) {
            console.log('[+] OkHttp CertificatePinner.check() bypassed for: ' + hostname);
        };
        CertificatePinner.check.overload('java.lang.String', '[Ljava.security.cert.Certificate;').implementation = function(hostname, certs) {
            console.log('[+] OkHttp CertificatePinner.check() bypassed for: ' + hostname);
        };
    } catch(e) {
        console.log('[-] OkHttp not found');
    }

    // 5. TrustManagerImpl (Android 7+)
    try {
        var TrustManagerImpl = Java.use('com.android.org.conscrypt.TrustManagerImpl');
        TrustManagerImpl.verifyChain.implementation = function(untrustedChain, trustAnchorChain, host, clientAuth, ocspData, tlsSctData) {
            console.log('[+] TrustManagerImpl.verifyChain() bypassed for: ' + host);
            return untrustedChain;
        };
    } catch(e) {
        console.log('[-] TrustManagerImpl not found');
    }

    console.log('[*] SSL Pinning bypass loaded');
});
```

### Root Detection Bypass
```javascript
// Source: MobSF, frida-codeshare
Java.perform(function() {

    // 1. File existence checks
    var File = Java.use('java.io.File');
    var originalExists = File.exists;
    File.exists.implementation = function() {
        var path = this.getAbsolutePath();
        var rootPaths = [
            '/system/app/Superuser.apk',
            '/system/xbin/su',
            '/system/bin/su',
            '/sbin/su',
            '/data/local/xbin/su',
            '/data/local/bin/su',
            '/data/local/su',
            '/su/bin/su',
            '/magisk'
        ];

        for (var i = 0; i < rootPaths.length; i++) {
            if (path.indexOf(rootPaths[i]) !== -1) {
                console.log('[+] Root check bypassed: ' + path);
                return false;
            }
        }
        return originalExists.call(this);
    };

    // 2. Runtime.exec checks
    var Runtime = Java.use('java.lang.Runtime');
    var originalExec = Runtime.exec.overload('java.lang.String');
    originalExec.implementation = function(cmd) {
        if (cmd.indexOf('su') !== -1 || cmd.indexOf('which') !== -1) {
            console.log('[+] Runtime.exec() blocked: ' + cmd);
            throw new Error('Command not found');
        }
        return originalExec.call(this, cmd);
    };

    // 3. System property checks
    var SystemProperties = Java.use('android.os.SystemProperties');
    var originalGet = SystemProperties.get.overload('java.lang.String');
    originalGet.implementation = function(key) {
        var result = originalGet.call(this, key);
        if (key.indexOf('ro.build.tags') !== -1 && result.indexOf('test-keys') !== -1) {
            console.log('[+] SystemProperties test-keys bypassed');
            return 'release-keys';
        }
        return result;
    };

    // 4. Build.TAGS check
    var Build = Java.use('android.os.Build');
    Build.TAGS.value = 'release-keys';

    console.log('[*] Root detection bypass loaded');
});
```

### Debugger Detection Bypass
```javascript
// Source: MobSF
Java.perform(function() {

    // 1. isDebuggerConnected
    var Debug = Java.use('android.os.Debug');
    Debug.isDebuggerConnected.implementation = function() {
        console.log('[+] isDebuggerConnected() bypassed');
        return false;
    };

    // 2. Debuggable flag
    var ApplicationInfo = Java.use('android.content.pm.ApplicationInfo');
    ApplicationInfo.flags.value = 0;

    // 3. TracerPid check
    try {
        var BufferedReader = Java.use('java.io.BufferedReader');
        var FileReader = Java.use('java.io.FileReader');
        var originalReadLine = BufferedReader.readLine;
        originalReadLine.implementation = function() {
            var line = originalReadLine.call(this);
            if (line && line.indexOf('TracerPid') !== -1) {
                console.log('[+] TracerPid check bypassed');
                return 'TracerPid:\t0';
            }
            return line;
        };
    } catch(e) {}

    console.log('[*] Debugger detection bypass loaded');
});
```

### Enumerate All Classes
```javascript
// Source: RMS-Runtime-Mobile-Security
Java.perform(function() {
    var classes = [];
    Java.enumerateLoadedClasses({
        onMatch: function(className) {
            // Filter out generic Android/Java classes
            if (!className.startsWith('android.') &&
                !className.startsWith('java.') &&
                !className.startsWith('kotlin.') &&
                !className.startsWith('com.google.') &&
                !className.startsWith('androidx.')) {
                classes.push(className);
            }
        },
        onComplete: function() {
            console.log('[*] Found ' + classes.length + ' app classes:');
            classes.forEach(function(c) {
                console.log('  ' + c);
            });
        }
    });
});
```

### Hook HTTP Requests
```javascript
// Log all OkHttp requests
Java.perform(function() {
    try {
        var OkHttpClient = Java.use('okhttp3.OkHttpClient');
        var Request = Java.use('okhttp3.Request');
        var RequestBody = Java.use('okhttp3.RequestBody');
        var Buffer = Java.use('okio.Buffer');

        var RealCall = Java.use('okhttp3.RealCall');
        RealCall.execute.implementation = function() {
            var request = this.request();
            console.log('\n[HTTP Request]');
            console.log('  URL: ' + request.url().toString());
            console.log('  Method: ' + request.method());
            console.log('  Headers: ' + request.headers().toString());

            var body = request.body();
            if (body !== null) {
                var buffer = Buffer.$new();
                body.writeTo(buffer);
                console.log('  Body: ' + buffer.readUtf8());
            }

            var response = this.execute();
            console.log('[HTTP Response]');
            console.log('  Code: ' + response.code());
            return response;
        };
    } catch(e) {
        console.log('[-] OkHttp not found: ' + e);
    }
});
```

---

## iOS Scripts

### iOS SSL Pinning Bypass
```javascript
// Source: Brida, frida-ios-hook
if (ObjC.available) {

    // 1. NSURLSession bypass
    var NSURLSessionConfiguration = ObjC.classes.NSURLSessionConfiguration;

    Interceptor.attach(NSURLSessionConfiguration['- setTLSMinimumSupportedProtocol:'].implementation, {
        onEnter: function(args) {
            console.log('[+] setTLSMinimumSupportedProtocol bypassed');
        }
    });

    // 2. SecTrustEvaluate bypass
    var SecTrustEvaluate = Module.findExportByName('Security', 'SecTrustEvaluate');
    if (SecTrustEvaluate) {
        Interceptor.attach(SecTrustEvaluate, {
            onLeave: function(retval) {
                console.log('[+] SecTrustEvaluate bypassed');
                retval.replace(0); // errSecSuccess
            }
        });
    }

    // 3. SecTrustEvaluateWithError bypass (iOS 12+)
    var SecTrustEvaluateWithError = Module.findExportByName('Security', 'SecTrustEvaluateWithError');
    if (SecTrustEvaluateWithError) {
        Interceptor.attach(SecTrustEvaluateWithError, {
            onLeave: function(retval) {
                console.log('[+] SecTrustEvaluateWithError bypassed');
                retval.replace(1); // true
            }
        });
    }

    // 4. AFNetworking bypass
    try {
        var AFSecurityPolicy = ObjC.classes.AFSecurityPolicy;
        AFSecurityPolicy['- setSSLPinningMode:'].implementation = ObjC.implement(
            AFSecurityPolicy['- setSSLPinningMode:'],
            function(handle, selector, mode) {
                console.log('[+] AFSecurityPolicy.setSSLPinningMode bypassed');
            }
        );
    } catch(e) {}

    console.log('[*] iOS SSL Pinning bypass loaded');
}
```

### iOS Jailbreak Detection Bypass
```javascript
// Source: Brida, frida-ios-hook
if (ObjC.available) {

    var jailbreakPaths = [
        '/Applications/Cydia.app',
        '/Library/MobileSubstrate/MobileSubstrate.dylib',
        '/bin/bash',
        '/usr/sbin/sshd',
        '/etc/apt',
        '/private/var/lib/apt/',
        '/usr/bin/ssh',
        '/private/var/stash',
        '/.installed_unc0ver',
        '/.bootstrapped_electra',
        '/usr/lib/libjailbreak.dylib'
    ];

    // 1. NSFileManager bypass
    var NSFileManager = ObjC.classes.NSFileManager;
    var originalFileExists = NSFileManager['- fileExistsAtPath:'];

    Interceptor.attach(originalFileExists.implementation, {
        onEnter: function(args) {
            this.path = ObjC.Object(args[2]).toString();
        },
        onLeave: function(retval) {
            for (var i = 0; i < jailbreakPaths.length; i++) {
                if (this.path.indexOf(jailbreakPaths[i]) !== -1) {
                    console.log('[+] fileExistsAtPath bypassed: ' + this.path);
                    retval.replace(0);
                    return;
                }
            }
        }
    });

    // 2. stat/access bypass
    var statHandler = {
        onEnter: function(args) {
            this.path = args[0].readUtf8String();
        },
        onLeave: function(retval) {
            for (var i = 0; i < jailbreakPaths.length; i++) {
                if (this.path && this.path.indexOf(jailbreakPaths[i]) !== -1) {
                    console.log('[+] stat bypassed: ' + this.path);
                    retval.replace(-1);
                    return;
                }
            }
        }
    };

    Interceptor.attach(Module.findExportByName(null, 'stat'), statHandler);
    Interceptor.attach(Module.findExportByName(null, 'stat64'), statHandler);
    Interceptor.attach(Module.findExportByName(null, 'access'), statHandler);

    // 3. fork() bypass
    Interceptor.attach(Module.findExportByName(null, 'fork'), {
        onLeave: function(retval) {
            console.log('[+] fork() bypassed');
            retval.replace(-1);
        }
    });

    console.log('[*] iOS Jailbreak detection bypass loaded');
}
```

### iOS Crypto Interception (CCCrypt)
```javascript
// Source: frida-ios-hook, Brida
if (ObjC.available) {

    var CCCrypt = Module.findExportByName('libSystem.B.dylib', 'CCCrypt');

    Interceptor.attach(CCCrypt, {
        onEnter: function(args) {
            this.operation = args[0].toInt32(); // 0=encrypt, 1=decrypt
            this.algorithm = args[1].toInt32(); // 0=AES128, 1=DES, 2=3DES
            this.options = args[2].toInt32();
            this.keyLength = args[4].toInt32();
            this.dataInLength = args[6].toInt32();

            this.key = args[3].readByteArray(this.keyLength);
            this.dataIn = args[5].readByteArray(this.dataInLength);
            this.dataOut = args[7];
            this.dataOutLength = args[8].toInt32();

            var opName = this.operation === 0 ? 'ENCRYPT' : 'DECRYPT';
            var algName = ['AES128', 'DES', '3DES', 'CAST', 'RC4', 'RC2', 'Blowfish'][this.algorithm] || 'Unknown';

            console.log('\n[CCCrypt] ' + opName + ' (' + algName + ')');
            console.log('  Key (' + this.keyLength + ' bytes): ' + bytesToHex(this.key));
            console.log('  Input (' + this.dataInLength + ' bytes): ' + bytesToHex(this.dataIn));
        },
        onLeave: function(retval) {
            if (retval.toInt32() === 0) { // kCCSuccess
                var output = this.dataOut.readByteArray(this.dataOutLength);
                console.log('  Output: ' + bytesToHex(output));
            }
        }
    });

    function bytesToHex(bytes) {
        var hex = '';
        var view = new Uint8Array(bytes);
        for (var i = 0; i < view.length && i < 64; i++) {
            hex += ('0' + view[i].toString(16)).slice(-2);
        }
        return hex + (view.length > 64 ? '...' : '');
    }

    console.log('[*] CCCrypt interception loaded');
}
```

---

## Native Hooks

### Hook Native Functions
```javascript
// Hook any native function by name
function hookNative(moduleName, functionName, onEnterCallback, onLeaveCallback) {
    var addr = Module.findExportByName(moduleName, functionName);
    if (addr) {
        Interceptor.attach(addr, {
            onEnter: onEnterCallback || function(args) {
                console.log('[' + functionName + '] called');
            },
            onLeave: onLeaveCallback || function(retval) {}
        });
        console.log('[+] Hooked ' + functionName + ' at ' + addr);
    } else {
        console.log('[-] ' + functionName + ' not found');
    }
}

// Example: Hook open() to log file access
hookNative(null, 'open', function(args) {
    var path = args[0].readUtf8String();
    console.log('[open] ' + path);
});

// Example: Hook SSL_read to dump decrypted traffic
hookNative('libssl.so', 'SSL_read', function(args) {
    this.ssl = args[0];
    this.buf = args[1];
    this.num = args[2].toInt32();
}, function(retval) {
    var bytesRead = retval.toInt32();
    if (bytesRead > 0) {
        console.log('[SSL_read] ' + bytesRead + ' bytes:');
        console.log(hexdump(this.buf, { length: Math.min(bytesRead, 256) }));
    }
});
```

### Memory Search and Patch
```javascript
// Find and patch bytes in memory
function findAndPatch(moduleName, searchPattern, patchBytes) {
    var module = Process.findModuleByName(moduleName);
    if (!module) {
        console.log('[-] Module not found: ' + moduleName);
        return;
    }

    Memory.scan(module.base, module.size, searchPattern, {
        onMatch: function(address, size) {
            console.log('[+] Found pattern at: ' + address);
            Memory.protect(address, patchBytes.length, 'rwx');
            address.writeByteArray(patchBytes);
            console.log('[+] Patched!');
        },
        onComplete: function() {
            console.log('[*] Scan complete');
        }
    });
}

// Example: NOP out a function call
// findAndPatch('libapp.so', 'E8 ?? ?? ?? ??', [0x90, 0x90, 0x90, 0x90, 0x90]);
```

---

## Utility Functions

### Hex Dump Helper
```javascript
function hexdump(buffer, options) {
    options = options || {};
    var length = options.length || buffer.byteLength;
    var offset = options.offset || 0;
    var result = '';

    for (var i = 0; i < length; i += 16) {
        var hex = '';
        var ascii = '';

        for (var j = 0; j < 16 && i + j < length; j++) {
            var byte = buffer.add(offset + i + j).readU8();
            hex += ('0' + byte.toString(16)).slice(-2) + ' ';
            ascii += (byte >= 32 && byte <= 126) ? String.fromCharCode(byte) : '.';
        }

        result += ('00000000' + (offset + i).toString(16)).slice(-8) + '  ';
        result += hex.padEnd(48, ' ') + ' |' + ascii + '|\n';
    }

    return result;
}
```

### Stack Trace Helper
```javascript
function getStackTrace() {
    if (Java.available) {
        return Java.use('android.util.Log').getStackTraceString(
            Java.use('java.lang.Exception').$new()
        );
    } else if (ObjC.available) {
        return Thread.backtrace(this.context, Backtracer.ACCURATE)
            .map(DebugSymbol.fromAddress)
            .join('\n');
    }
    return 'Stack trace not available';
}
```

---

## Usage

### Android
```bash
# Spawn app with script
frida -U -f com.target.app -l ssl_bypass.js --no-pause

# Attach to running app
frida -U -n "App Name" -l ssl_bypass.js

# Multiple scripts
frida -U -f com.target.app -l ssl_bypass.js -l root_bypass.js --no-pause
```

### iOS
```bash
# Spawn app
frida -U -f com.target.app -l ios_ssl_bypass.js --no-pause

# Attach to running app
frida -U -n "App Name" -l ios_jailbreak_bypass.js
```

### With Objection
```bash
# One-liner SSL bypass
objection -g "com.target.app" explore --startup-command "android sslpinning disable"

# iOS SSL bypass
objection -g "com.target.app" explore --startup-command "ios sslpinning disable"
```

---

## Advanced Patterns (from GitHub Code Search)

### iOS Access/Stat Bypass (Jailbreak Detection)
```javascript
// Source: grep MCP - common jailbreak bypass pattern
// Bypasses file existence checks used by jailbreak detection
Interceptor.attach(Module.findExportByName(null, "access"), {
    onEnter: function(args) {
        this.path = args[0].readUtf8String();
    },
    onLeave: function(retval) {
        var jbPaths = ["/Applications/Cydia.app", "/bin/bash", "/usr/sbin/sshd",
                       "/etc/apt", "/private/var/lib/apt", "/.installed_unc0ver"];
        for (var i = 0; i < jbPaths.length; i++) {
            if (this.path && this.path.indexOf(jbPaths[i]) !== -1) {
                console.log('[+] access() bypassed: ' + this.path);
                retval.replace(-1);
                return;
            }
        }
    }
});

Interceptor.attach(Module.findExportByName(null, "stat64"), {
    onEnter: function(args) {
        this.path = args[0].readUtf8String();
    },
    onLeave: function(retval) {
        // Same jailbreak path check as above
    }
});
```

### Android Crypto Key Interception
```javascript
// Source: grep MCP - intercept crypto operations to capture keys
Java.perform(function() {
    var SecretKeySpec = Java.use('javax.crypto.spec.SecretKeySpec');
    SecretKeySpec.$init.overload('[B', 'java.lang.String').implementation = function(keyBytes, algorithm) {
        console.log('[+] SecretKeySpec created');
        console.log('    Algorithm: ' + algorithm);
        console.log('    Key: ' + bytesToHex(keyBytes));
        return this.$init(keyBytes, algorithm);
    };

    var Cipher = Java.use('javax.crypto.Cipher');
    Cipher.doFinal.overload('[B').implementation = function(input) {
        console.log('[+] Cipher.doFinal()');
        console.log('    Input: ' + bytesToHex(input));
        var result = this.doFinal(input);
        console.log('    Output: ' + bytesToHex(result));
        return result;
    };

    function bytesToHex(bytes) {
        var hex = '';
        for (var i = 0; i < bytes.length && i < 64; i++) {
            hex += ('0' + (bytes[i] & 0xff).toString(16)).slice(-2);
        }
        return hex + (bytes.length > 64 ? '...' : '');
    }
});
```

### iOS Keychain Interception
```javascript
// Source: grep MCP - intercept keychain operations
if (ObjC.available) {
    var SecItemCopyMatching = Module.findExportByName('Security', 'SecItemCopyMatching');
    Interceptor.attach(SecItemCopyMatching, {
        onEnter: function(args) {
            console.log('[+] SecItemCopyMatching called');
            var query = new ObjC.Object(args[0]);
            console.log('    Query: ' + query.toString());
        },
        onLeave: function(retval) {
            console.log('    Return: ' + retval);
        }
    });

    var SecItemAdd = Module.findExportByName('Security', 'SecItemAdd');
    Interceptor.attach(SecItemAdd, {
        onEnter: function(args) {
            console.log('[+] SecItemAdd called');
            var attributes = new ObjC.Object(args[0]);
            console.log('    Attributes: ' + attributes.toString());
        }
    });
}
```

### Dynamic Library Loading Bypass
```javascript
// Source: grep MCP - bypass detection of Frida/Substrate libraries
Interceptor.attach(Module.findExportByName(null, "dlopen"), {
    onEnter: function(args) {
        this.path = args[0].readUtf8String();
    },
    onLeave: function(retval) {
        var blockedLibs = ["frida", "substrate", "inject", "hook"];
        if (this.path) {
            for (var i = 0; i < blockedLibs.length; i++) {
                if (this.path.toLowerCase().indexOf(blockedLibs[i]) !== -1) {
                    console.log('[+] dlopen blocked: ' + this.path);
                    retval.replace(ptr(0));
                    return;
                }
            }
        }
    }
});

// Also hook dlsym for symbol resolution bypass
Interceptor.attach(Module.findExportByName(null, "dlsym"), {
    onEnter: function(args) {
        this.symbol = args[1].readUtf8String();
    },
    onLeave: function(retval) {
        var blockedSymbols = ["frida", "gum_", "g_object"];
        if (this.symbol) {
            for (var i = 0; i < blockedSymbols.length; i++) {
                if (this.symbol.toLowerCase().indexOf(blockedSymbols[i]) !== -1) {
                    console.log('[+] dlsym blocked: ' + this.symbol);
                    retval.replace(ptr(0));
                    return;
                }
            }
        }
    }
});
```
