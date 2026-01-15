# XML Parsing and Manipulation in JavaScript for UXP Plugin

## Research Summary

This document covers XML parsing options for Adobe UXP plugins, with focus on FCP XML manipulation.

---

## 1. XML Parsing APIs Available in UXP

### Native UXP Limitations

**DOMParser is NOT available in UXP.** This is a confirmed limitation that affects all Adobe UXP plugins (Photoshop, InDesign, Premiere, etc.).

From Adobe Developer Forums:
- "Seems DOMParser is not available to UXP"
- "UXP does not support the DOM Parser for reading XML files"
- The Response API provides no method to parse XML directly

### XMLHttpRequest (Limited Support)

XMLHttpRequest in UXP does return an XML document supporting W3C DOM level 2 specification, but this only works for HTTP requests - not for local file parsing.

---

## 2. Recommended Libraries for UXP

### Option A: fast-xml-parser (RECOMMENDED)

**Why it works for UXP:**
- Pure JavaScript - no native dependencies
- No Node.js APIs required
- Tested up to 100MB files
- Provides both parsing AND building

**Installation:**
```bash
npm install fast-xml-parser
```

**Usage in UXP:**
```javascript
import { XMLParser, XMLBuilder } from "fast-xml-parser";

// Parse XML to JavaScript object
const parser = new XMLParser({
  ignoreAttributes: false,
  attributeNamePrefix: "@_"
});
const jObj = parser.parse(xmlString);

// Modify the object...
jObj.fcpxml.project.sequence.spine["asset-clip"][0]["@_name"] = "New Name";

// Build back to XML
const builder = new XMLBuilder({
  ignoreAttributes: false,
  attributeNamePrefix: "@_"
});
const xmlOutput = builder.build(jObj);
```

**Browser Bundle Sizes:**
| Bundle | Size | Use Case |
|--------|------|----------|
| fxparser.min.js | 20K | Parse only |
| fxbuilder.min.js | 6.5K | Build only |
| fxp.min.js | 26K | Parse + Build |
| fxvalidator.min.js | 5.7K | Validate only |

### Option B: @xmldom/xmldom

**Why it might work:**
- Pure JavaScript W3C DOM implementation
- Provides familiar DOMParser and XMLSerializer APIs
- Zero dependencies

**Caveat:** Primarily tested for Node.js, may require bundling/testing for UXP.

**Usage:**
```javascript
import { DOMParser, XMLSerializer } from '@xmldom/xmldom';

// Parse
const doc = new DOMParser().parseFromString(xmlString, 'text/xml');

// Navigate DOM
const clips = doc.getElementsByTagName('asset-clip');
for (let i = 0; i < clips.length; i++) {
  clips[i].setAttribute('name', 'Modified');
}

// Serialize
const output = new XMLSerializer().serializeToString(doc);
```

### Option C: @rgrove/parse-xml

- Extremely fast and small
- Zero dependencies
- Browser-friendly
- Parse-only (no builder)

---

## 3. Bundling for UXP

UXP requires webpack or rollup to bundle npm packages:

```javascript
// webpack.config.js
module.exports = {
  entry: './src/index.js',
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist'),
  },
  target: 'web', // Important: not 'node'
  resolve: {
    fallback: {
      // Ensure no Node.js polyfills
      fs: false,
      path: false,
      stream: false
    }
  }
};
```

---

## 4. FCP XML Structure

### Root Structure
```xml
<fcpxml version="1.11">
    <resources>
        <!-- Format, Asset, and Media definitions -->
    </resources>
    <project name="Project Name">
        <sequence format="r1" tcStart="0s" duration="..." tcFormat="NDF">
            <spine>
                <!-- Clips, gaps, and nested elements -->
            </spine>
        </sequence>
    </project>
</fcpxml>
```

### Key Elements

| Element | Purpose | Key Attributes |
|---------|---------|----------------|
| `<resources>` | Container for all referenced media | - |
| `<format>` | Video format definition | id, name, frameDuration, width, height |
| `<asset>` | Media file reference | id, src, start, duration, hasVideo, hasAudio |
| `<project>` | Container for sequence | name |
| `<sequence>` | Timeline container | format, tcStart, duration, audioLayout |
| `<spine>` | Primary storyline | - |
| `<asset-clip>` | Clip on timeline | ref, offset, duration, start, name |
| `<gap>` | Empty space | offset, duration |

### Time Format (Rational Numbers)

FCPXML uses rational numbers for precise timing:
- Format: `numerator/denominator s` (e.g., `1001/30000s`)
- Common values:
  - 29.97fps: `1001/30000s` per frame
  - 25fps: `100/2500s` or `1/25s` per frame
  - 24fps: `100/2400s` per frame

### Example: Parsing Asset-Clips
```javascript
import { XMLParser, XMLBuilder } from "fast-xml-parser";

const parserOptions = {
  ignoreAttributes: false,
  attributeNamePrefix: "@_",
  parseAttributeValue: false // Keep as strings for time values
};

const parser = new XMLParser(parserOptions);
const fcpxml = parser.parse(fcpxmlString);

// Access clips
const spine = fcpxml.fcpxml.project.sequence.spine;
const clips = Array.isArray(spine["asset-clip"])
  ? spine["asset-clip"]
  : [spine["asset-clip"]];

clips.forEach(clip => {
  console.log(`Clip: ${clip["@_name"]}`);
  console.log(`  Offset: ${clip["@_offset"]}`);
  console.log(`  Duration: ${clip["@_duration"]}`);
  console.log(`  Asset Ref: ${clip["@_ref"]}`);
});
```

---

## 5. Best Practices for Large XML Files

### For UXP (Browser-like Environment)

**Challenge:** Cannot use Node.js streaming libraries (sax, xml-stream, etc.)

**Approaches:**

1. **Chunked Processing with fast-xml-parser**
   - Parse entire file (handles up to 100MB)
   - Process in batches programmatically

2. **Web Workers (if UXP supports)**
   - Offload parsing to background thread
   - Prevents UI freezing

3. **Incremental Modification**
   ```javascript
   // Parse once, modify, rebuild
   const parser = new XMLParser(options);
   const builder = new XMLBuilder(options);

   const doc = parser.parse(xmlContent);

   // Modify specific sections
   modifyClips(doc.fcpxml.project.sequence.spine);

   // Rebuild
   const output = builder.build(doc);
   ```

### Memory Considerations

- fast-xml-parser is tested to 100MB files
- For larger files, consider:
  - Splitting FCPXML into smaller segments
  - Processing outside UXP and importing results
  - Using native app APIs if available

---

## 6. Code Patterns for UXP FCPXML Manipulation

### Pattern 1: Parse, Modify, Serialize

```javascript
import { XMLParser, XMLBuilder } from "fast-xml-parser";

class FCPXMLEditor {
  constructor() {
    this.parserOptions = {
      ignoreAttributes: false,
      attributeNamePrefix: "@_",
      parseAttributeValue: false,
      trimValues: false,
      processEntities: true
    };

    this.builderOptions = {
      ignoreAttributes: false,
      attributeNamePrefix: "@_",
      format: true,
      indentBy: "    ",
      suppressEmptyNode: false
    };

    this.parser = new XMLParser(this.parserOptions);
    this.builder = new XMLBuilder(this.builderOptions);
  }

  parse(xmlString) {
    this.doc = this.parser.parse(xmlString);
    return this.doc;
  }

  getClips() {
    const spine = this.doc?.fcpxml?.project?.sequence?.spine;
    if (!spine) return [];

    const clips = spine["asset-clip"];
    return Array.isArray(clips) ? clips : clips ? [clips] : [];
  }

  getAssets() {
    const resources = this.doc?.fcpxml?.resources;
    if (!resources) return [];

    const assets = resources.asset;
    return Array.isArray(assets) ? assets : assets ? [assets] : [];
  }

  updateClipName(clipRef, newName) {
    const clips = this.getClips();
    const clip = clips.find(c => c["@_ref"] === clipRef);
    if (clip) {
      clip["@_name"] = newName;
    }
  }

  serialize() {
    return '<?xml version="1.0" encoding="UTF-8"?>\n' +
           '<!DOCTYPE fcpxml>\n' +
           this.builder.build(this.doc);
  }
}
```

### Pattern 2: Time Value Utilities

```javascript
class FCPXMLTime {
  // Parse FCPXML time string to seconds
  static toSeconds(timeStr) {
    if (!timeStr || timeStr === "0s") return 0;

    const match = timeStr.match(/^(\d+)\/(\d+)s$/);
    if (match) {
      return parseInt(match[1]) / parseInt(match[2]);
    }

    const simpleMatch = timeStr.match(/^(\d+(?:\.\d+)?)s$/);
    if (simpleMatch) {
      return parseFloat(simpleMatch[1]);
    }

    return 0;
  }

  // Convert seconds to FCPXML time string
  static fromSeconds(seconds, frameRate = 25) {
    // Common frame rates and their denominators
    const rates = {
      24: { num: 100, den: 2400 },
      25: { num: 100, den: 2500 },
      30: { num: 100, den: 3000 },
      29.97: { num: 1001, den: 30000 },
      23.976: { num: 1001, den: 24000 }
    };

    const rate = rates[frameRate] || rates[25];
    const frames = Math.round(seconds * rate.den / rate.num);
    return `${frames * rate.num}/${rate.den}s`;
  }

  // Add two FCPXML time values
  static add(time1, time2) {
    const s1 = this.toSeconds(time1);
    const s2 = this.toSeconds(time2);
    return this.fromSeconds(s1 + s2);
  }
}
```

### Pattern 3: File I/O in UXP

```javascript
const fs = require('uxp').storage.localFileSystem;

async function loadFCPXML() {
  const file = await fs.getFileForOpening({
    types: ['fcpxml', 'xml']
  });

  if (!file) return null;

  const content = await file.read({ format: 'utf8' });
  return content;
}

async function saveFCPXML(xmlContent) {
  const file = await fs.getFileForSaving('output.fcpxml', {
    types: ['fcpxml']
  });

  if (!file) return false;

  await file.write(xmlContent, { format: 'utf8' });
  return true;
}
```

---

## 7. Potential Issues and Solutions

### Issue: Self-closing tags
**Problem:** Some XML parsers handle `<tag/>` differently than `<tag></tag>`
**Solution:** fast-xml-parser handles both correctly

### Issue: Namespaces
**Problem:** FCPXML doesn't typically use namespaces, but some XML might
**Solution:** Configure parser to handle or ignore namespaces

### Issue: CDATA sections
**Solution:**
```javascript
const parser = new XMLParser({
  cdataPropName: "__cdata"
});
```

### Issue: Preserving original formatting
**Solution:** Use builder with format options matching source

### Issue: Attribute order not preserved
**Note:** XML spec doesn't guarantee attribute order; FCPXML should not depend on it

---

## 8. Sources

- [Adobe Developer Forums - XML Parsing in UXP](https://forums.creativeclouddeveloper.com/t/unable-to-parse-xml-in-adobe-uxp/8877)
- [fast-xml-parser GitHub](https://github.com/NaturalIntelligence/fast-xml-parser)
- [fast-xml-parser npm](https://www.npmjs.com/package/fast-xml-parser)
- [@xmldom/xmldom GitHub](https://github.com/xmldom/xmldom)
- [FCPXML Reference - Apple Developer](https://developer.apple.com/documentation/professional-video-applications/fcpxml-reference)
- [FCP Cafe - FCPXML Documentation](https://fcp.cafe/developers/fcpxml/)
- [FCPXML Structure Gist](https://gist.github.com/allenday/44cafa9d698ae6f94c5d55205f86f5b9)
- [UXP JavaScript Support](https://developer.adobe.com/xd/uxp/develop/plugin-development/javascript-and-xd/javascript-support/)
- [UXP Toolchain Documentation](https://developer.adobe.com/photoshop/uxp/2022/guides/uxp_guide/uxp-misc/uxp-toolchain/)

---

## Recommendation

For a UXP plugin handling FCP XML:

1. **Use `fast-xml-parser`** - proven to work in UXP (confirmed in forums)
2. **Bundle with webpack** targeting 'web' environment
3. **Create utility classes** for FCPXML-specific operations (time parsing, clip navigation)
4. **Test with actual FCPXML files** from Final Cut Pro to ensure compatibility
