/* Save the current document as Web with '-Web' appended to the filename
 * TIFF, LZW compression, 8bit/channel
 * The string "-Final" is replaced by "-Web"
 * Author: Tuan T. Pham <tuan at vt dot edu>
 */

var doc = app.activeDocument;
doc.bitsPerChannel = BitsPerChannelType.EIGHT;
var docName = doc.name;
docName = docName.match(/(.*)(\.[^\.]+)/) ? docName = docName.match(/(.*)(\.[^\.]+)/):docName = [docName, docName];
docName[1] = docName[1].replace("-Final","");
var suffix = '-Web';
var saveName = new File(decodeURI(doc.path)+'/'+docName[1]+suffix+'.tif');
var tifOptions = new TiffSaveOptions();
tifOptions.embedColorProfile = false;
tifOptions.imageCompression = TIFFEncoding.TIFFLZW;
doc.saveAs(saveName, tifOptions, true, Extension.LOWERCASE);
doc.close(SaveOptions.DONOTSAVECHANGES);
