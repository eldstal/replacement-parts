# replacement-parts
Open CAD library of replacement parts for game consoles

The purpose of this project is to measure, model and archive the plastic and
metal parts that make up old game consoles. These drawings can then be used to
manufacture replacement parts (by CNC milling, 3D printing, molding, ...).

In some cases, models of electronic parts (circuit boards, displays, ...) are also provided, as a tool
for people designing custom cases. For these components, the focus is to locate mounting points (screw holes, etc)
and other external features (button contacts, display frames, protruding components, ...) rather than a 100%
accurate model of the part.


# Guidelines

## Directory structure
The directory structure of the repository has a depth of 3:
1. Friendly system name, such as "psx"
2. Friendly device name, such as "console" or "dual-shock"
3. Part name (see *Naming* below)

Each part's directory contains at least the `metadata.json` file and a `src/` directory
with the CAD drawings in some portable format (Recommended: FreeCAD .fcstd).

Don't include the model exported to any non-editable format such as STL, there will eventually be automatic export
from submitted drawing sources.

## Classes
Any part found in this repository falls into one of these three classes:
* Faithful reproduction of the original
* Adaptation (for example, changed to be 3D-printable)
* Custom (For example, an alternate styling of a power button)

Please keep in mind that there are many ways to manufacture the part, and that a faithful representation
of the original is the best starting point. If a part does not exist in the library, please add the original
first and then adapt it for specific users (e.g. molding).

## Naming
The directory containing a part should be named in a descriptive and (if possible) short manner.
If official manufacturer parts numbers are known (for example, from a service manual), these should
be added as a prefix. If multiple revisions of the same part exist (for different releases of the same console, for example),
they should be given a suffix on the form "-rev05" with an order that makes sense (for example the order in which the devices were released).

Example of a good name with a part number prefix:
`gbc/console/38884-button.A`

If you adapt an existing original part, for example by making it suitable for 3D printing, use the same name and add a suffix that
describes your adaptation.

Example of a good adaptation name:
`gbc/console/38884-button.A-3dp`

## Licensing
Any parts you submit must either be your own work or work
that you have permission to submit. Parts must be released
under an Open-source license of your choice (Recommended: [CC by-sa 4.0](https://creativecommons.org/licenses/by-sa/4.0/))

## Trademarks and logos
If the part you are designing is an external part (an outer case for example),
the original may carry trademarked logos which we are not allowed to use.
Please remove these logos in your CAD drawing, leaving a suitable blank space.

Each CAD drawing should represent only the size and shape of the part itself, and optionally its proper color.
If the original part has logos or decals on it, please consider including the **location and size** of these
decals in a separate "decals" layer in the CAD drawing. *FIXME: Provide an example of how to do this*

## Modelling
When adding constraints to your CAD drawing, use the ones you have measured (and which can be most easily measured by a user).
For example, if you have measured the outer diameter and the inner diameter of a round part, don't add the wall thickness to
the drawing. This allows others to easily compare their parts to your drawing by measuring the same lengths to determine
whether to use the drawing or not.

Try to use whichever units (inches or mm) make sense **for the part**. If the part appears to have been designed using inches,
use that in your drawing as well. If done carefully, this reduces approximation errors.

## Metadata
Every part is accompanied by a metadata.json file, which contains
information about the part. The following fields are mandatory:

| Field  | Description | Example |
|-------:|:------------|:---------|
| author | A name or alias for the person who contributed the original drawing. | `"author" : "jimmy_p"` |
| system | The game system this part applies to | `"system" : "psx"` |
| fits   | A list of specific model numbers of devices where this exact part is used. This could be a console main unit, a controller, an accessory, ... | `"fits" : [ "scph-1002", "scph-5000" ]` |
| license | The license of the part, which specifies how it may be reused. | `"license" : "cc-by-sa-4.0"` |
| class  | The class (see above) of the part. This is either `"original"`, `"adaptation"` or `"custom"`. | `"class" : "adaptation"` |
| description | A free-text description of the part. If it is an adaptation, explain here. If there are any caveats, explain here. | `"description" : "Power button adapted for 3D-printing by hollowing out and adding struts."` |

Example of a working `metadata.json`:
```json
{
  "author" : "Nicki E. Santana",
  "system" : "nes",
  "fits" : [ "nes-001" ],
  "license" : "wtfpl",
  "class" : "original",
  "description" : "Reset button"
}
```
