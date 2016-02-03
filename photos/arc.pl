#!/usr/bin/perl
#---------------------oOo-------------------------
# Filename: arc.pl
# Usage: ./arc.pl filename2.tif ....
# the output will be filename2.png
# Coder: Tuan Trung Pham
# Last update: 10/22/02

# Requirement:
# 1) convert ( from ImageMagick Studio package)
# 2) perl
# 3) decent OS (*ix)
# 4) a lot of image files (tif, jpg, png....)

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
	while ($NextFile=shift(@ARGV))
	{
		if ( -e $NextFile )	# resize one file
		{
			$CurrentFile=$NextFile;
			$OutFile=$CurrentFile;
			$OutFile=~s/\.[^\.]+/\.png/;
			# I wonder if this is faster than using system()
			print "Processing \"$CurrentFile\"... ";
			`convert -quality 95 $CurrentFile $OutFile`;
			print "done.\n";
		}
	}
}
