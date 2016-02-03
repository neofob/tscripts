#!/usr/bin/perl

################################################################################
# make html files to display jpg file(s)
# coder: tuan pham
# developed: some time during summer 2002 when my roommate was russie
# last updated:  06/25/02 (added a table for title and name)
#    08/31/02 (changed the textcolor of title to FAFAFA)
#    12/31/02 (added -t for title and changed script name to mkphoto.pl)
#    01/04/03 (added -c=yyyy)
#    01/05/03 (fixed parsing the title w/ html tags)
#    04/06/03 fixed invalid html tags
#    06/13/06 add website url and parents link
#    03/28/08 add Previous and Next link
#    12/23/11 added click-on feature to viewing picture as requested by Ruel
#    12/28/11 replaced tabs with spaces
# usage: mkphoto.pl -t="photo title" a.jpg (make html for one file)
# the output will be *.html

# requirements:
# os: anything that dont crash on you
# perl: any version that can interpret this code
# others: ImageMagick package that has `identify` and A LOT of photos in jpg or png format

#----------------------------------------oOo----------------------------------------
# global vars
$Title="";
$Name="Tuan T. Pham";
$CurrentFile="";
$Site="http://photo.neofob.org";

$Header=""; $Body=""; $Tail="";

$Width;
$Year=`date +%Y`;  # get the current year
chomp $Year;;
#----------------------------------------oOo----------------------------------------
#print "@ARGV[0]  @ARGV[1]\n";
$PrevFile="./index.html";
$NextFile="./index.html";
main();


#----------------------------------------oOo----------------------------------------
sub main
{
  makeHtml();        # generate the html header and tail
  my $temp,$bYear="";
  my $t=0,$i=0;

  my @A_PARA;
  my @array;

  while ($i<2)  # parse two parameters
  {
    @A_PARA=split("=",@ARGV[0]);  # parse the first argument
    for (@A_PARA[0])
    {
      /-t/ and do
      {
        $Title=@ARGV[0];
        $Title=~s/-t=//;
        $t=1;
        shift(@ARGV);
      };

      /-c/ and do
      {
        $bYear=@A_PARA[1];
        shift(@ARGV);
      };
    } # for loop
    $i++;
  } # while loop
  
#  while ( $AFile=shift(@ARGV) )
  if ( $AFile=shift(@ARGV) )
  {
    if ( @ARGV[0] )
    {
      $PrevFile=@ARGV[0];
    }

    if ( @ARGV[1] )
    {
      $NextFile=@ARGV[1];
    }

    if ( open (TEMP,$AFile) )  # check whether this file exist
    {

      $FileName=$AFile;                 # get filename of this one
      $CurrentFile=$AFile;
      $FileName=~s/\.([^\.]+)/\.html/;  # replace the extension w/ html

      $temp=`identify $CurrentFile`;
      @array=split(/\s/,$temp);         # parse the output
      $temp=@array[2];                  # grab resolution in WxH
      @array=split(/x/,$temp);          # parse the number
      $Width=@array[0];                 # grab the width, $Width is global variable
      @t=split(/\./,$FileName);
      
      if ($t==0)
      {
        $Title=@t[0];
      }
      
      open(OUTFILE,"> $FileName");      # create html file
      makeHtml();                       # generate the html header and tail
      makeBody();
      print OUTFILE "$Header $Body $Tail\n";

      close(OUTFILE);
      close(TEMP);
    }
  }
}


#-------------------------oOo--------------------------
# generate the actual code that display the jpg file
# information is from $CurrentFile
sub makeBody
{
  $Body="    <a href=\"$NextFile\"><img src=\"./$CurrentFile\" border=\"1\"\n    alt=\"$Title\" \n".
  "    onmouseout=\"self.status='Move the mouse pointer over image to see the title'\"\n".
  "    onmouseover=\"window.status='&quot;$Title&quot;'; return true;\"></a>\n".
  "    <table width=\"$Width\" align=\"center\">\n".
  "    <tr>\n".
  "    <td align=\"left\">\n".
  "      <font size=\"+1\" color=\"#FAFAFA\"><b><i>\n".
  "      &quot;$Title&quot;</i></b>\n".
  "      </font>\n".
  "    </td>\n\n".
  "    <td align=\"right\">\n".
  "      <font size=\"+1\" color=\"#FAFAFA\">\n";
  
  if ("" eq $bYear)
  {
    $Body.="       <b><i>&copy;$Year $Name</i></b>\n";
  }
  else
  {
    $Body.="       <b><i>&copy;$bYear-$Year $Name</i></b>\n";
  }
  
  $Body.="      </font>\n".
  "    </td>\n".
  
  "    </tr>\n".
  "    </table>\n\n".

  "    <table width=\"$Width\" align=\"center\">\n".
  "    <tr>\n".
  "    <td align=\"left\" width=\"25%\"><a href=\"$PrevFile\">Previous</a></td>".
  " <td align=\"right\" width=\"25%\"><a href=\"$Site\">Home</a></td>".
  " <td align=\"left\" width=\"25%\"><a href=\"./index.html\">Up</a></td>".
  " <td align=\"right\" width=\"25%\"><a href=\"$NextFile\">Next</a></td>\n".
  "    </tr>\n".
  "    </table>\n";
}

#-------------------------oOo--------------------------
# adding the html header
sub makeHtml
{
  $DATE=localtime();
  $Header="<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n".
    "<html>\n".
    "<head>\n".
    "<meta http-equiv=\"content-type\" content=\n\"text/html; charset=UTF-8\">\n".
    "<title>$Title</title>"."\n\n".
    "<!-- Htmlized by Tuan Trung Pham on $DATE -->"."\n\n".
    "</head>"."\n\n".
    "<body bgcolor=\"#8F8F8F\" text=\"#00EE00\">\n".
    "<br><br>\n".
    "<table align=\"center\">".
    "<tr><td>".
    "\n\n";

  $Tail=  "</td></tr>\n</table>"."\n".
    "</body>"."\n".
    "</html>";
}
#-------------------------oOo--------------------------
