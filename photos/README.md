Photography Scripts
===================

####Adobe Photoshop Scripts
  * `Actions`: Actions for Photoshop
  * `*.js`: Scripts


####Shell Scripts
  * `arc.pl`: save photos as `PNG` file with compression for archive
  * `mkindex.pl`: generate `index.html` with input `*.{jpg, png}`
  * `mkphoto.pl`: generate `.html` file to display an image
  * `mkweb2.py`: fork two processes executing `mkweb.pl`; _deprecated_, use `mkweb_n.py`
  * `mkweb_n.py`: fork `n` processes executing `mkweb.pl`, only support `-b` for now
  * `mkweb.pl`: resize your image to _web-friendly_ size; maximum dimension is `1080`by default

**Note:** to resize pictures in many directories, pip install [`tfoto`][0]

[0]: https://github.com/neofob/tfoto
