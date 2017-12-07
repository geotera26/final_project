function [xcorr_Hx,xcorr_Hy,xcorr_Ex,xcorr_Ey,nDays,t] = ambnoise(rx1, rx2,stacklength)
% AMBNOISE :    Calculates the cross correlation between the magnetic field
%               components of any 2 MOCHA receivers
%
% Syntax:  [xcorr_Hx,xcorr_Hy,xcorr_Ex,xcorr_Ey,t] = ambnoise(rx1,rx2,stacklength)
%
% Inputs:
%       rx1 - letter and 2 number ID of 1st receiver
%       rx2 - letter and 2 number ID of 2nd receiver   
%       stacklength - number of seconds to use for each stack; default is
%       200 seconds; must be a multiple of 86400
%
% Outputs:
%   xcorr_Hx - stacked cross correlation of Hx components of the receivers 
%   xcorr_Hy - stacked cross correlation of Hy components of the receivers 
%   xcorr_Ex - stacked cross correlation of Ex components of the receivers 
%   xcorr_Ey - stacked cross correlation of Ey components of the receivers
%   nDays - total number of days used for stack 
%   t - vector of seconds for plotting abscissa of cross correlation
%
%   figures - cross correlations of Hx, Hy, Ex, and Ey
%
% Example: 
%   ambnoise(B01,N02,400)
%
% Requirements:
%   directory - You MUST put this function in MOCHA_2014_Receiver_Data !!!
%   other directories - You also MUST have MTprocessing/config/
%   codes - getSP.m, getsio.m, getIGRF.m
%   clear all other variables before running to improve efficiency
%
% See also: getSP.m,  getsio.m, getIGRF.m, makeMTFieldMovie.m
%
% Author: Christine Chesley
% Work address: 305AA Oceanography
% email: chesley@ldeo.columbia.edu
% 28 November 2017; Last revision: 4 December 2017
%
%--------------------------------------------------------------------------

% Check whether stacklength was input; if not, set to default 200s
% If you used too many or too few inputs, exit function
if nargin() == 2
    stacklength = 200;    
elseif nargin() > 3
    error('Error using ambnoise. Too many input arguments')
elseif nargin() < 2
    error('Error using ambnoise. Too few input arguments')
end

% Check that stacklength is a multiple of 86400 (# of seconds in a day)
if (mod(86400,stacklength) ~= 0)
    error('Error using ambnoise. Stacklength must be a multiple of 86400')
end

%--------------------------------------------------------------------------

% Isolate the appropriate receivers
disp('........Looking for receivers: ') % cd into MOCHA_2014_Receiver_Data !!!!
disp([string(rx1) string(rx2)])

file1 = 'empty'; 
file2 = 'empty';

file1 = ls([rx1,'*']); 
file2 = ls([rx2,'*']);

file1 = file1(1:end-1);     % Matlab ls command adds an extra character to the end
file2 = file2(1:end-1); 

% In the event that the receiver you entered does not exist, exit out of
% the function 
% This might not be necessary since ls should return an error anyway
if (strcmp(file1,'empty')~=0 | strcmp(file2,'empty')~=0)
    error('Invalid or nonexistent rx1, rx2 ID. Check current directory.')
end

disp('........Receivers found!........')

%--------------------------------------------------------------------------

% Pull appropriate time window
disp('........Determining appropriate time window, latitudes, and longitudes........')

% Choose the day after the later of the two receiver installations
% and go until the day before the earlier of the two receiver take downs
iFile = {file1,file2};
sSPFolder   = '../MTprocessing/config/';        % from K.Key's makeMTFieldMovie.m

% Isolate info about start and end date-time
% Also pull lat, lon, and azimuth information to be used later for rotation
for m = 1:2
    
    st = [];
    st.filename = char(iFile{m});
    
    [header, errmsg] = getsio('headdir',st,'off');   % from K.Key and D.Myers 
    
	% Read SP file (this is from K.Key and D.Myers):
    [stHead(m) stChan(m).stCh] = getSP(fullfile(sSPFolder,strcat(st.filename(1:end-4),'.sp')));   
    
    if m==1
        header1 = header;
        lat1 = stHead(m).nLat;
        lon1 = stHead(m).nLong;
    elseif m==2
        header2 = header;        
        lat2 = stHead(m).nLat;
        lon2 = stHead(m).nLong;
    end
    
end


% Determine the larger of the two start dates and add 1 day to it (to
% avoid issues with turning on instrument)
tStart = max(floor(header1.datastart),floor(header2.datastart)) + 1;  % Already in datenum format

% Determine the smaller of the two end dates and subtract 1 day from it 
% (again to avoid issues that come with turning off instrument)
tEnd = min(ceil(header1.dataend),ceil(header2.dataend)) - 1;        % Already in datenum format

% Now to figure out the length of the data window to read in
nDays = floor(tEnd - tStart);       % number of days worth of data to use (round down)
tLength  = 60*60*24*nDays; % length of data window to read in seconds

disp('........Time window and receiver locations have been determined!........')

%--------------------------------------------------------------------------

% Pull the data from the binary files and perform rotations
disp('........Loading and rotating data........')
disp('........This will take some time........')
headers = {header1,header2};
lats = [lat1 lat2];
lons = [lon1 lon2];

for m = 1:2
    data_struc = headers{m};
    [st,~]  = getsio('times',data_struc,tStart,'time',tLength);    % from K.Key and D.Myers
    
    % Get station declination (altered from K.Key and D.Myers):
    [Bn Be Bv Decl(m) Incl] = getIGRF(lons(m), lats(m), 0, datenum(2014,5,15,0,0,0));
    
    % Rotate data so that southernmost Hx points towards 
    % northernmost Hx AND both point in same direction; 
    % Similarly, northernmost Ex will point toward southermost Ex
    % y components for H and E will be 90 deg clockwise from alignment
    ang = deg2rad(Decl(m) + stChan(m).stCh(1).nOrient);     % from K.Key and D.Myers; 
                                                            % this will be used to first
                                                            % get Hx's pointing north
    MTrot = MT_rotate(st,lats,lons,ang);    % subfunction below
    
    if m==1
        MT1 = MTrot;    % Store the rotated components
        disp("........Why don't you go fix yourself a spot of tea?........") 
    elseif m==2
        MT2 = MTrot;
    end
    
    clear MTrot st data_struc         % Delete these to save RAM
end

MT = [MT1 MT2];

clear MT1 MT2     % Delete to save RAM

disp('........Alright, we have the data........')

%--------------------------------------------------------------------------

% Detrend the components
disp("........Now let's detrend it........")

len = floor(length(MT(1,:))/2);     % strangely, sometimes one receiver
                                    % will have 1 additional entry

% This will loop through and detrend each component (1. Hx, 2. Hy, 3. Ex, 4. Ey)
% This step takes a long time
    for c=1:4
        MT(c,1:len) = detrend(MT(c,1:len));       % 1st receiver
        MT(c,len+1:end) = detrend(MT(c,len+1:end));       % 2nd receiver
    end
 
%--------------------------------------------------------------------------

% Perform cross correlation (also time consuming)
disp("........Finally, the cross correlation........")
f = 62.5;   %sampling interval for these data
n = stacklength*f;	% Use sections based on stacklength
t = -n+1:n-1;   
t = t/f;    % time in seconds, for plotting purposes

xcorr_all = 0;

% Use a loop since the dataset is so large
for cross=1:4
    slice = MT(cross,:);    % pull each component separately
    for dt=1:nDays*24*60*60/stacklength
        sect1 = slice((dt-1)*n+1:dt*n);     % pull rx1; go 1 stacklength at a time
        sect2 = slice((dt + nDays*24*60*60/stacklength - 1)*n +1:(dt+nDays*24*60*60/stacklength)*n); % pull rx2; go 1 stacklength at a time
        xcorr_all = xcorr_all + xcorr(sect1,sect2); % cross correlate and add each cross correlation section
    end
    
    xcorrs(cross,:) = xcorr_all;    % store the cross correlation for each component
    xcorr_all = 0;      % reset to 0 before moving to next component
end

clear MT xcorr_all sect1 sect2 slice    % clear to save RAM

%--------------------------------------------------------------------------

% Plot the cross correlations (sort of "Pythonic")
comps = ['Hx' 'Hy' 'Ex' 'Ey'];


for f=1:4
    figure(f)
    plot(t,xcorrs(f,:),'k','LineWidth',2)
    xlabel('time (seconds)')
    ylabel('(V/Am^2)^2')
    title([ rx1 ' and ' rx2 ' ' num2str(stacklength) ' s stack, ' comps(2*f-1:2*f) ])
    set(gca,'FontSize',18)       
end

% Output the cross correlations
xcorr_Hx = xcorrs(1,:);
xcorr_Hy = xcorrs(2,:);
xcorr_Ex = xcorrs(3,:);
xcorr_Ey = xcorrs(4,:);

end
%----------------------End of function ambnoise.m-------------------------%





%--------------------------------------------------------------------------
function [MTrot] = MT_rotate(MT,lats,lons,angle)
%--------------------------------------------------------------------------
% H_ROTATE :    Rotates Hx and Ex components for a MOCHA receiver so that
%               they align with another receiver (these receivers are
%               located at lat1,lon1 and lat2,lon2)
%
%               This is a subfunction of ambnoise.m
%
% Syntax:  [MTrot] = MT_rotate(MT,lats,lons,angle)
%
% Inputs:
%       MT - structure with data entries where MT.data(1:2,:) = [Hx Hy]'
%       and MT.data(3:4,:) = [Ex Ey]'
%       lats - vector containing latitudes (DEGREES) of the 2 receivers    
%       lons - vector containing longitudes (DEGREES) of the 2 receivers 
%       angle - azimuth of Hx component of the receiver in RADIANS
%
% Outputs:
%   MTrot - Matrix with rotated components of the receiver; Hx's and Ex's
%   are aligned and Hy and Ey are 90 degrees clockwise from Hx and Ex, respectively
%       MTrot(1:2,:) = rotated H's
%       MTrot(3:4,:) = rotated E's
%
% Requirements:
%   See requirements of ambnoise
%
% Author: Christine Chesley
% Work address: 305AA Oceanography
% email: chesley@ldeo.columbia.edu
% 29 November 2017; Last revision: 4 December 2017
%
%--------------------------------------------------------------------------

% As a convention, we will always take the northernmost receiver to be rx2
% in this calculation
if (lats(1) > lats(2))
    lat1 = lats(2);
    lat2 = lats(1);
    lon1 = lons(2);
    lon2 = lons(1);
    lats = [lat1 lat2];
    lons = [lon1 lon2];
end

H = MT.data(1:2,:);
E = MT.data(3:4,:);

% Calculate the rotation angle necessary to align rx1 and rx2
% I prefer this approximation since all stations are close (approximately
% in same UTM zone)
% We are treating the map as a 2D grid and ignoring curvature
lat2km = 111.141;       % Approximate distance between 2 parallels in this location
lon2km = 111.320*cosd(mean(lats));  % Approximate distance between 2 meridians at average latidude of the two stations

dlat = lat2km*diff(lats);
dlon = lon2km*diff(lons);

if dlat == 0
    azi = pi/2;      % in the case that the receivers are on same line of latitude atan is undefined, but limit is 90 deg
else
    azi = atan(dlon/dlat);
end

% Counterclockwise rotation of Hx to north followed by clockwise rotation to azi
R1 = [cos(angle) -sin(angle);sin(angle) cos(angle)];
R2 = [cos(azi) sin(azi);-sin(azi) cos(azi)];

R = R2*R1;

% This is to align Hx's and Ex's
MTrot(1:2,:) = R*H;
MTrot(3:4,:) = R*E;

end

%---------------------End of subfunction H_rotate.m-----------------------%
 

