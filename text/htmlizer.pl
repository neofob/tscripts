#!/usr/bin/perl

###############################################################################
# htmlizer for a text file in unicode UTF-8
# coder: tuan pham
# developed: 07/31/01 (hard coded for "In the Jaws of History"
# and "The Chinese Mosaic")
# last updated: 12/28/02 (added -t -a)
#               12/28/11 replaced tabs with spaces
#               02/17/12 removed <p> tag to use css
# usage: htmlizer.pl *.txt
# the output will be *.html
# -t="Put the title here" (in double quotes)
# -a="Put the author's name here" (in double quotes)
# Note: these options are recommended to use by other scripts to match the titles
# and authors for each text file
#-------------------------oOo--------------------------
# global vars
# $input : content of the current input file

$input;
$TITLE="";  # text title
$NAME="";  # author
$CSS_FILE="neofob.css";
local($/)=undef;  # lousy and lazy way to parse text
main();


#-------------------------oOo--------------------------
sub main
{
  my @A_PARA;
  while ( $NextFile=shift(@ARGV) )
  {
    @A_PARA=split("=",$NextFile);
    if ("-t" eq @A_PARA[0])
    {
      @A_PARA[1]=~s/\"//;  # removes "
      $TITLE=@A_PARA[1];
    }
    else
    {
      if ( open (TEMP,$NextFile) )
      {
        $input=<TEMP>;  # get the file's content
        make_paragraph();
        make_html();

        $FileName=$NextFile;
        $FileName=~s/\.([^\.]+)/\.html/;

        open(OUTFILE,"> $FileName");
        print OUTFILE "$input";

        close(OUTFILE);
        close(TEMP);
      }
    }
  }
}


#-------------------------oOo--------------------------
# parse the input text to put <p> tags
# and &nbsp; after .
sub make_paragraph
{
  # add &nbsp;
  # temporarily, this damned line doesn't work!
  $input=~s/\r//g;

  # add <p> tags

  $input=~s/\n+\s+/\n<p class=\"firstLetter\">/;
  $input=~s/\n+\s+/\n\n<p>/g;
}
#-------------------------oOo--------------------------
# adding the html header
sub make_html
{
  $header="<!doctype html system>\n".
    "  <head>\n".
    "     <meta content=\"text/html; charset=UTF-8\" http-equiv=\"Content-Type\">"."\n".
    "     <title>$TITLE</title>"."\n".
    "     <link href=\"$CSS_FILE\" rel=\"stylesheet\" type=\"text/css\">\n".
    "  </head>"."\n\n".
    "<!-- htmlized by neofob -->"."\n\n".
    "<body>\n".
    "<table width=\"90%\" align=\"center\">"."\n".
    "  <tr><td>\n\n";

  $tail=  "  </td></tr>"."\n".
    "</table>"."\n".
    "</body>"."\n".
    "</html>";

  $input=$header.$input.$tail;
}
#-------------------------oOo--------------------------
