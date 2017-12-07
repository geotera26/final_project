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
		
