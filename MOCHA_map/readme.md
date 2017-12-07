Contents of MOCHA_map/
	
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
								this by uncommenting the specified section, but I prefer
								the inset not to have topography)
				
		Notes:
			Execute this code in GMT

	
	II. make_mocha_map_succinct.bash
		Description: This script is nearly identical to make_mocha_map.bash . The 
			difference is that it contains a for-loop to color code the receivers 
		
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
