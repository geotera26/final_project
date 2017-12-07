#! /bin/bash

# Christine Chesley
# 4 November 2017

# The general idea of the layout is adapted from make_NJ_MV_Map.bash,
# a script by K. Key

# Set up the desired GMT defaults:
gmtset FONT_ANNOT_PRIMARY = 10
gmtset FONT_LABEL = 10
gmtset FONT_TITLE = 24p,Helvetica-Bold
gmtset MAP_FRAME_TYPE fancy   # I prefer this style of frame
gmtset PS_PAGE_ORIENTATION=portrait
gmtset PS_MEDIA=letter
gmtset PROJ_ELLIPSOID WGS-84

# Name of figure:
filename=MOCHA_site


# Topography files from GeoMapApp:
GRD=MOCHA_med.grd
GRD_inset=us.grd


# Region of interest (lonW/lonE/latS/latN):
region=-R-129/-123/43.5/47.5
regionInset=-R-155/-64/20/60


# Map proj.:
scale=-JM6i
scaleInset=-JM1.75i


# Basemap offsets for page:
offX=-X1.5i
offY=-Y2.5i

offXInset=-X0.01i
offYInset=-Y4.641i

# Basemap frames:
frame=-Ba2f60m    # label every 2˚ and tick every 60 mins
frameInset=-B300  # so as not to show tick marks, make this outside range


# Map Title (this won't work for more than one word, so enter it in
# psbasemap command directly):
# title=-B+t"MOCHA Survey"

# Position of color scale:
cScalePos=-Dx2i/-1i+w2.45i/0.18i+h


# gradient filename and azimuth for gradient:
grad=gradient.grd
gradInset=gradientInset.grd

gradA=-A100   # after several trials, this was determined as the most suitable
gradAInset=-A15

norm=-N4e0.8  # standard normalization to use


# MOCHA station squares, labels, and font settings:
stats=-Ss0.3c
statFont=-F+f30p,Helvetica-Bold,black
labelloc=-D0c/0c


# Color palette:
CPT=my_relief.cpt
# Run the following 3 lines when making a new cpt file:
echo " creating color palette..."
rm $CPT
makecpt -Crelief -T-5000/5000/500 -Z > my_relief.cpt


# Remove some previous files b/4 creating new ones:
rm $filename.ps
rm $filename.pdf
rm $grad
rm $gradInset


echo " creating gradient file for shading..."
grdgradient $gradA $norm $GRD -G$grad
grdgradient $gradAInset $norm $GRD_inset -G$gradInset

echo " making basemap..."
psbasemap $scale $region $frame -B+t"MOCHA Survey" $offX $offY -K > $filename.ps

echo " adding topography from GeoMapApp..."
grdimage $region $GRD -I$grad -C$CPT $scale -O -K >> $filename.ps

# Adding MOCHA sites:
echo " adding MOCHA station locations..."
# # To add all stations in black
# psxy -R -J Mocha_stations.txt -W0.5,black -G255/255/255 $stats -O -K >> $filename.ps
# pstext MOCHA_sitelab.txt -F+f8.5p,Helvetica,red -D0/0.12i $scale -R -V -O  -K >> $filename.ps


# Color each station based on the line letter

# # Autumn cpt
# Bcol=150/26/51
# Dcol=230/49/61
# Fcol=232/102/120
# Hcol=212/80/39
# Jcol=208/150/42
# Lcol=61/94/44
# Ncol=155/159/75
# Pcol=47/127/124

# # Autumn cpt 2
# Bcol=194/55/69
# Dcol=203/89/91
# Hcol=230/135/108
# Fcol=235/172/126
# Jcol=217/170/194
# Pcol=82/195/192
# Ncol=206/189/166
# Lcol=165/85/124

# Vibrant cpt 1
Bcol=230/49/61
Dcol=150/26/51
Hcol=2/48/72
Fcol=29/230/181
Jcol=91/71/156
Lcol=52/235/74
Ncol=251/174/32
Pcol=212/80/39

# Parameters for station labels
outline=0.4p,black
stat_pen=-W0.5,black
stat_font=-F+f8p,Helvetica-Bold,
stat_font_s=-F+f7p,Helvetica-Bold,
stat_font_offset=-D0/0.12i
col_select=-i0,1

# Define arrays in bash syntax
# This is, again, an homage to Pythonic tricks
letters=('B' 'D' 'F' 'H' 'J' 'L' 'N' 'P')
colors=($Bcol $Dcol $Fcol $Hcol $Jcol $Lcol $Ncol $Pcol)

for rxline in {0..7}
  do
    letter=${letters[$rxline]}    #bash syntax for indexing into an array
    color=${colors[$rxline]}

    cat MOCHA_sitelab.txt | grep -e $letter | psxy -R -J $col_select $stat_pen -G$color $stats -O -K >> $filename.ps
    cat MOCHA_sitelab.txt | grep -e $letter | pstext ${stat_font}${color},-=$outline $stat_font_offset $scale -R -O -K >> $filename.ps
  done


echo " appending color scale... "
psscale -C$CPT $cScalePos -B5000 -Bx+l"Elevation (m)" -O -K >> $filename.ps

# Now for inset of entire USA
echo " making inset basemap..."
gmtset MAP_FRAME_TYPE plain
psbasemap $scaleInset $regionInset $frameInset $offXInset $offYInset -K -O >> $filename.ps

echo " adding coastlines &/or topo to inset..."
# Option 1: Full grid
# grdimage $regionInset $GRD_inset -I$gradAInset -C$CPT $scaleInset -O -K >> $filename.ps

# Option 2: No grid, just outline of US
pscoast $regionInset $scaleInset -Swhite -Ggrey -K -O >> $filename.ps

# Option 3: Grid on dry area only
# grdimage $regionInset $GRD_inset -I$gradInset -C$CPT $scaleInset -O -K >> $filename.ps
# pscoast $regionInset $scaleInset -Swhite -K -O >> $filename.ps


echo " drawing bounding box on inset..."
psxy inset_bnds.txt $regionInset $scaleInset -W2,black -L -O >> $filename.ps

echo " converting ps to pdf..."
ps2pdf $filename.ps  $filename.pdf

echo " opening figure..."
open $filename.pdf
