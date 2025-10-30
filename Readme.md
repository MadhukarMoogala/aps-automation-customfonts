# APS Automation: Custom Fonts Sample

This project demonstrates how to use custom SHX fonts in AutoCAD automation workflows, specifically for Autodesk Platform Services (APS) Design Automation. It provides sample DWG files, LISP routines, and a font bundle for testing and integration.

This stackoverlow question motivated the creation of this sample:
https://stackoverflow.com/questions/79802419/lisp-and-appbundle-not-working-on-aps-automation-api

Some parts of LISP code are adapted from same stackoverflow question.

## Project Structure

```text

| korean-DBCS-legacy-hangul.dwg
| Bundle/
|   CustomFonts.bundle/
|     PackageContents.xml
|     Contents/
|       CallPlot.lsp
|       fontStyle.lsp
|       Fonts/
|         GHD.SHX
|         GHS.SHX
```

### Key Components

- **CustomFonts.bundle**: APS-compatible bundle containing custom SHX fonts and LISP routines.
- **Fonts**: `GHD.SHX`, `GHS.SHX` — sample SHX font files for use in DWG automation.
- **LISP routines**: `CallPlot.lsp` and `fontStyle.lsp` — demonstrate font usage and automation scripting.
- **Sample DWG files**: Provided for validating font rendering and automation.

## How to Use

### In APS Design Automation

1. Upload the `CustomFonts.bundle` to your APS storage location.
2. Reference the bundle in your Design Automation workitem or activity.
3. Ensure your automation script or LISP routine loads the fonts from the bundle path (see `CallPlot.lsp` and `fontStyle.lsp` for examples).

### In Local AutoCAD

1. Copy the SHX font files from `Bundle/CustomFonts.bundle/Contents/Fonts/` to your AutoCAD Fonts directory.
2. Load the LISP routines in AutoCAD to test font usage in your drawings.

## APS Design Automation Sample Activity and Workitem

Below are example definitions for an APS Design Automation Activity and Workitem that use this custom fonts sample.

### Sample Activity (Activity.json)

````json
{
	"commandLine": [
		"$(engine.path)\\accoreconsole.exe /i \"$(args[Input].path)\" /al \"$(appbundles[CustomFonts].path)\" /s \"$(settings[script].path)\""
	],
	"parameters": {
		"Input": {
			"localName": "input.dwg",
			"verb": "get"
		},
		"Output": {
			"localName": "input.pdf",
			"verb": "put"
		}
	},
	"id": "{{ _.activityId }}",
	"engine": "Autodesk.AutoCAD+25_1",
	"appbundles": [
		"apsapps.CustomFonts+dev"
	],
	"settings": {
		"script": {
			"value": "(load \"fontStyle.lsp\")\nSUBST\n(load \"CallPlot.lsp\")\nCallPlot\n"
		}
	},
	"description": "Plot Custom fonts"
}
````

### Sample Workitem (workitem.json)

````json
{
	"activityId": "{{ _.nickname }}.{{ _.activityId }}+{{ _.alias }}",
	"arguments": {
		"Input": {
			"url": "https://cdn.us.oss.api.autodesk.com/oss/v2/signedresources/5ea86631-8596-4d83-93ef-ead5fc39dc04?region=US"
		},
		"Output": {
			"url": "https://cdn.us.oss.api.autodesk.com/oss/v2/signedresources/2fa01bb7-8437-455c-9036-9d458d95bddf?region=US"
		}
	},
	"limitProcessingTimeSec": 3600
}
````

These samples show how to configure an activity to load the custom font bundle and LISP routines, and how to submit a workitem with input and output URLs.
The input DWG should reference the custom SHX fonts to see them rendered correctly in the [output](input.pdf) PDF.
APS Automation will process the drawing and apply the custom fonts as specified in PackageContents.xml.

### Input DWG

![input-dwg](input-dwg.png)

### Output PDF

![output-pdf](output-pdf.png)

## Notes

- The included SHX fonts are for demonstration and testing only.
- Ensure you have the appropriate license for any fonts used in production.
- This project does **not** include or require the GHSPack component.

## License

This project is provided as-is for demonstration and educational purposes only.
  
---

## Technical Note: Understanding SHX BigFonts and Unicode Behavior in AutoCAD

When working with Asian-language text in AutoCAD—particularly Korean—it’s common to encounter differences in how BigFont SHX files handle characters compared to modern Unicode text.

A typical case is when the combination `romans.shx` + `GHS.shx` fails to display Hangul (Korean) text correctly, while `romans.shx` + `whtmtxt.shx` renders the same Unicode text without issue. This difference stems from how SHX fonts have evolved over time.

### 1. Legacy BigFonts and DBCS Encoding

The file `GHS.shx` behaves as a legacy BigFont, designed during the pre-Unicode era to support double-byte character sets (DBCS), specifically CP949 / KS X 1001 for Korean.

In this system, each Hangul character is represented by one or two bytes, not by a Unicode codepoint. AutoCAD passes these byte values directly to the BigFont, which uses them as glyph indices—essentially, look-up numbers into its internal vector glyph table.

Because of this design, a legacy BigFont like `GHS.shx` cannot interpret or render true Unicode characters. If the text object contains Unicode Hangul (e.g., 안녕하세요), AutoCAD has no matching glyph indices and substitutes question marks (?????).

To render correctly with `GHS.shx`, the Unicode text must first be re-encoded into its legacy byte sequence (CP949). Those bytes are then stored as raw characters in the DWG text entity. When the BigFont interprets these bytes, it retrieves the intended Hangul glyphs and displays them properly.

### 2. Modern SHX Fonts and Unicode Support

In contrast, newer SHX fonts—sometimes referred to as “SHX Unifonts” or Unicode-capable SHX fonts—are built with an extended internal mapping that associates glyphs directly with Unicode codepoints.

Such fonts can render non-ASCII text, including Hangul, directly from Unicode strings without any manual re-encoding. That’s why combinations like `romans.shx` + `whtmtxt.shx` display real Unicode Korean text correctly: `whtmtxt.shx` was authored or compiled with Unicode mappings.

### 3. Evolution of SHX Fonts

In summary, SHX fonts have evolved through three generations:

| Generation            | Mapping Method                  | Unicode-capable | Typical Example           |
|-----------------------|---------------------------------|-----------------|--------------------------|
| Classic SHX           | Single-byte (ASCII only)        | ❌ No           | romans.shx, simplex.shx  |
| Legacy BigFont SHX    | Double-byte (DBCS / CP949 / JIS / GB2312) | ❌ No           | GHS.shx, GHD.shx         |
| Modern SHX Unifont    | Direct Unicode mapping          | ✅ Yes          | whtmtxt.shx, txt.shx (new versions) |

Autodesk’s newer releases note that “All SHX fonts shipped with AutoCAD now support Unicode,” but older, third-party or region-specific BigFonts (like `GHS.shx`) remain DBCS-encoded and require legacy data to render correctly.

### 4. Practical Guidance

If you need legacy compatibility (e.g., reproducing old plotted drawings exactly):
- Use `GHS.shx` and re-encode your Unicode Hangul strings into CP949 byte sequences before writing them into TEXT or MTEXT entities.

If you want modern Unicode correctness (copy/paste, searchable text, interoperability):
- Use a Unicode-capable SHX (e.g., `whtmtxt.shx`) or a TrueType Unicode font such as Malgun Gothic, Gulim, or Arial Unicode MS.

### 5. References

- Autodesk Help — About Using Asian Big Fonts in AutoCAD
- Autodesk Knowledge Network — Working with Unicode and SHX Fonts
- Microsoft Code Page 949 — Korean (Unified Hangul Code)

**In short:**

- `GHS.shx` is a legacy DBCS BigFont that requires CP949-encoded bytes, not Unicode text.
- Modern SHX fonts like `whtmtxt.shx` are Unicode-capable and can render Hangul directly.

---

####  Written by
Madhukar Moogala
APS (Autodesk Platform Services)