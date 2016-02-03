#!/usr/bin/perl
#---------------------oOo-------------------------
# Filename: mkweb.pl
# Usage: ./mkweb.pl filename1.jpg filename2.tif
# the output will be filename1.jpg filename2.jpg
# Author: Tuan T. Pham
# Last update:  June 24, 2002
#    Sunday September 1, 2002 (added sharpen)
#    Satursday January 4, 2003 (added unsharp)
#    Tuesday May 18, 2004 (removed profiles from jpeg files)
#    Monday December 17, 2012 (updated scaling)

# Requirement:
# 1) convert ( from ImageMagick Studio package)
# 2) perl
# 3) decent OS (*ix)
# 4) a lot of image files (tif, jpg, png....)
# Wish list:
# 1.recursive directory
# 2.copy right tag (check out JWZ's code)

main();

#--------------------------oOo---------------------------
#
sub main
{
  my $NextFile;
  my $OutFile;
  my $ThumbNail;
  my $CurrentFile="";
  my $i=0;
  my $b=1;    # border is on by default
  my $max_size=1280;  # max size is 1280 pixels by default

  my @A_PARA;
  
  while ($i<2)
  {
    @A_PARA=split("=",@ARGV[0]);

    for (@A_PARA[0])
    {
    /-b/ and do
      {
        $b=0;                   # no border
        shift(@ARGV);
      };
    /-m/ and do
      {
        $max_size=@A_PARA[1];
        shift(@ARGV);
      };
    }
    $i++;
  }

  if ($b==0)
  {
    while ($NextFile=shift(@ARGV))
    {
      if ( -e $NextFile )  # resize one file
      {
        $CurrentFile=$NextFile;
        $OutFile=$CurrentFile;
        $OutFile=~s/\.[^\.]+/\.jpg/;
        #print "\n$OutFile\n"
        # I wonder if this is faster than using system()
        print "Processing \"$CurrentFile\"... ";
        `convert -scale $max_size"x"$max_size -sharpen 1x1 \\
        -quality 95 -strip $CurrentFile $OutFile`;
        print "done.\n";
      }
    }
  }
  else
  {
    while ($NextFile=shift(@ARGV))
    {
      if ( -e $NextFile )  # resize one file
      {
        $CurrentFile=$NextFile;
        $OutFile=$CurrentFile;
        $OutFile=~s/\.[^\.]+/\.jpg/;
        # I wonder if this is faster than using system()
        print "Processing \"$CurrentFile\"... ";
        `convert -size 2048x2048 -scale 2048x2048 \\
        -bordercolor "#FDFDFD" -border 1x1 \\
        -bordercolor "#000000" -border 3x3 \\
        -flip -flop -bordercolor "#F8E5AF" -border 5x5 -raise 5x5 \\
        -flop -flip -bordercolor "#000000" -border 15x15 \\
         -scale $max_size"x"$max_size -sharpen 1x1 -unsharp 0.5x0.5+0.75+0 \\
        -quality 95 -strip \\
        $CurrentFile $OutFile`;
        print "done.\n";
      }
    }
  }
}
