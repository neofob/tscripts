/* Save the current document as Final with '-Final' appended to the filename
 * TIFF, LZW compression
 * Author: Tuan T. Pham <tuan at vt dot edu>
 */
var doc = app.activeDocument;
var docName = doc.name;
docName = docName.match(/(.*)(\.[^\.]+)/) ? docName = docName.match(/(.*)(\.[^\.]+)/):docName = [docName, docName];
var suffix = '-Final';
var saveName = new File(decodeURI(doc.path)+'/'+docName[1]+suffix+'.tif');
var tifOptions = new TiffSaveOptions();
tifOptions.embedColorProfile = true;
tifOptions.imageCompression = TIFFEncoding.TIFFLZW;
doc.saveAs(saveName, tifOptions, true, Extension.LOWERCASE);
// uncomment the below line if you want to close the document
// doc.close(SaveOptions.DONOTSAVECHANGES);
