/* Save the current document as Web with '-Web' appended to filename
 * TIFF, LZW compression, 8bit/channel
 * Author: Tuan T. Pham <tuan at vt dot edu>
 */

var doc = app.activeDocument;
doc.bitsPerChannel = BitsPerChannelType.EIGHT;
var docName = doc.name;
docName = docName.match(/(.*)(\.[^\.]+)/) ? docName = docName.match(/(.*)(\.[^\.]+)/):docName = [docName, docName];
var suffix = '-Web';
var saveName = new File(decodeURI(doc.path)+'/'+docName[1]+suffix+'.tif');
var tifOptions = new TiffSaveOptions();
tifOptions.embedColorProfile = true;
tifOptions.imageCompression = TIFFEncoding.TIFFLZW;
doc.saveAs(saveName, tifOptions, true, Extension.LOWERCASE);
doc.close(SaveOptions.DONOTSAVECHANGES);
