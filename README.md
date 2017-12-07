### Christine Chesley
### Research Computing for Earth Science
### 06 December 2017

#### Project Title: 
_A New Take on Ambient Noise: Cross Correlating MOCHA MT data_


#### Abstract:
Ambient noise cross correlation is a technique gaining prominence in the field of 
seismology for its ability to estimate the Green's function (impulse response) between 
two seismic stations (Roux et al, 2005). The underlying physics of the impulse response
allows for its emergence in the coherent parts of noise as measured from two stations.

Because ground motion from ambient seismic noise can cause slight variations in the 
position of an MT receiver, and thus its location within Earth's geomagnetic field, the 
data collected by these receivers are sensitive to ambient seismic noise. It is 
hypothesized that cross correlating MT data should produce a Green's function similar to 
that observed by cross correlations of seismic data. 

Here, we use MT data from the MOCHA project.

Roux, P., K. G. Sabra, P. Gerstoft, W. A. Kuperman, and M. C. Fehler (2005), P-waves 
from crosscorrelation of seismic noise, Geophys. Res. Lett., 32, L19303,
doi:10.1029/2005GL023803.

#### Contents:
	MOCHA_map/
	
	I. make_mocha_map.bash
		Description: This code creates a map of the MOCHA survey area with topography and 
		bathymetry from GeoMapApp. Receiver locations are color-coded and labeled.
		
		Requirements: 
			-inset_bnds.txt : boundaries for inset map
			-MOCHA_med.grd : topography/bathymetry file for study region
			-MOCHA_sitelab.txt : lon, lat, and label for MOCHA receivers. No comma 
			separation
			-(optional) MochaMarineVersion2.txt : lon, lat, and label for MOCHA receivers.
			comma-separated
			-(optional) us.grd : topography/bathymetry file for inset (you can include 
			this by uncommenting the specified section, but I prefer the inset not to 
			have topography)
				
		Notes:
			Execute this code in GMT

	
	II. make_mocha_map_succinct.bash
		Description: This script is nearly identical to make_mocha_map.bash . The 
		difference is that it contains a for-loop to color the receivers 
		
		Requirements:
			See make_mocha_map.bash
	
	
	III. organize_stats.sh
		Description: This script removes the commas from separating columns of 
		MochaMarineVersion2.txt . As given, MochaMarineVersion2.txt was not
		immediately useable in some of the lines of GMT code
		
		Requirements:
			-MochaMarineVersion2.txt
		
		Output:
			MOCHA_sitelab.txt
	
	IV. MOCHA_site.pdf
		Description: MOCHA survey area map output from running make_mocha_map.bash . 

	--------------------------------------------------------------------------------------
	
	cross_correlation/
	
	I. ambnoise.m
		Description: Matlab function that computes and outputs cross-correlations of each
		horizontal electric and magnetic field component of any 2 MOCHA receivers. This
		function will also output figures for each of the 4 cross-correlations
		
		Outline:
			1. Checks to see whether number of input arguments is correct
			2. Checks to see whether receivers input are in the current directory
			3. Calculates total length of data to read in
			4. Reads in the data from each receiver and rotates the H and E tensors so 
			that Hx (and Ex) components align and Hy (and Ey). This rotation is carried
			out in a subfunction
			5. Detrends each component of each receiver's rotated data
			6. Computes cross-correlations for a given "stacklength" for each component
			7. Stacks the cross-correlations
		
		Tips on using this function:
			-This function needs to be in the same directory as the MOCHA receiver data
			file (it makes this assumption when searching for the receivers).
			
			-MTprocessing/config directory must also be available
			
			-getsio.m , getSP.m, and getIGRF.m must be in directories that have been path set
			in MATLAB
			
			-Code will take ~ 22 minutes to run if you don't have any other programs 
			running on your computer. Clear other variables so as not to crash MATLAB.
		
	II. P04_N02_Hx_200.jpg ; P04_N02_Ey_200.jpg
    	Description: Cross-correlations of the Hx and Ey components of P04 and N02 
    	receivers. These are examples of the figures the ambnoise.m can output.
		
  
