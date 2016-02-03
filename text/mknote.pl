#!/usr/bin/perl
#---------------------oOo-------------------------
# Filename: mknote.pl
# Usage: ./mknote.pl filename1.txt filename2.html
# the output will be filename1.html filename2.html and so on
# Coder: Tuan Trung Pham
# Last update: April 12, 2003  1st release

# Requirements:
# 1) perl
# 2) decent OS (*ix) with date and awk tools

$NAME="Tuan Pham";            # put your darn name here
$IndexFile="";
@FILENAME,@TITLE, $inputFile; # filename and title array

main();

#--------------------------oOo---------------------------
# the job is done mainly by this subroutine => main()
sub main
{
  my $Body,$NextFile,$OutFile,$ThumbNail,$CurrentFile;
  my $i;

  my @A_PARA;

  my $bYear="";
  my $Year=`date | awk '{print \$6}'`;  # get the current year

#  $Body="<table cellpadding=\"0\" cellspacing=\"5\" border=\"0\" align=\"center\" bgcolor=\"#8F8F8F\">"."\n";
  while ($NextFile=shift(@ARGV))
  {
    if ( -e $NextFile )
    {
      $CurrentFile=$NextFile;
      $OutFile=$CurrentFile;
      $OutFile=~s/\.[^\.]+/\.html/;
      print "Processing \"$CurrentFile\"...\n";

      # open this file
      # parse the title
      open (INPUT_FILE,"< $CurrentFile")  # default is open(INPUT_FILE,"< $inputFile") readonly
      || die "Jebus! Can't read $CurrentFile\n fsck?";
      
      open (OUTPUT_FILE,"> $OutFile")    #
      || die "Jebus! Can't read $OutFile\n fsck?";

      $Title=<INPUT_FILE>;    # read the first line as the title for the index.html
      chomp $Title;      # clean it
      makeHeader();      # make the header
      
      $Body="";
      # parse all terms and definitions
      local($/)="\n\n";
      while ($line=<INPUT_FILE>)  # parse the terms and definition
      {
        chomp $line;    # clean it!
        @temp_list=split("  ",$line);    # split it into term and definition
        # now make a row with one cell for term and another cell for definition
        $Body=$Body."  <tr>\n  <td width=\"25%\" valign=\"top\"><tt><b>@temp_list[0]</b></tt></td>\n\n".
          "  <td>@temp_list[1]</td>\n".
          "  </tr>\n\n";
      }
      
      $IndexFile=$IndexFile.$Body."\n\n".
      "</table>\n".

      "<!-- Make a horizontal line -->\n".  # make a horizontal line
      "<br>".
      "<table width=\"80%\" bgcolor=\"#5A1A0E\" border=\"0\" cellspacing=\"0\" align=\"center\">\n".
      "  <tr>\n".
      "  <td width=\"100%\" bgcolor=\"#5A1A0E\">\n".
      "  </td>\n".
      "  </tr>\n".
      "</table>\n".
      "<br>\n".
    
      # (c)
      "<!-- Copy right note -->\n".
      "<table width=\"80%\" bgcolor=\"#F8E5AF\" border=\"0\" cellpadding=\"0\"\n".
      "cellspacing=\"0\" align=\"center\">\n".
      "  <tr>\n".
      "  <td align=\"left\">\n".
      "    <font size=\"-1\" color=\"#5A1A0E\">\n";
      $IndexFile.="    &copy;$Year $NAME<br>\n".
    "    </font>\n".
    "</td></tr>".
    "</table>".
    "</body>\n".
    "</html>";
    local($/)="\n";
    print OUTPUT_FILE $IndexFile;
    close(INPUT_FILE);
    close(OUTPUT_FILE);
    }
    else
    {
      print STDERR "Broken arrow! Broken arrow! \"$NextFile\" doesnt exist!\n";
    }
  } # while loop
}

#-------------------------oOo--------------------------
# makeHeader()
# generate the the header for index.html
sub makeHeader
{
  $MyDate=localtime();
  $IndexFile="<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n".
    "<html>\n".
    "<head>\n".
    "<meta http-equiv=\"content-type\" content=\n\"text/html; charset=UTF-8\">\n".
    "<title>$Title</title>\n".
    "</head>\n\n".
    "<body BGCOLOR=\"#F8E5AF\" TEXT=\"#5A1A0E\">\n".
    "<!-- End of Header -->\n".
    "<!-- Generated on $MyDate by Tuan Pham -->\n\n".
    "<br>\n\n".
    "<table width=\"80%\" cellspacing=\"5\" align=\"center\">\n";
}
