The .shp files available in SLIP were converted to KMZ/KML using ArcMap

Selected lines from the KML containing "<coordinates>"
Trimmed the <coordinates> and </coordinates> tags from those lines, leaving only the 3D coordinates.
Removed the ,0 Z coordinate from each item (just replaced each occurrence with an empty string)