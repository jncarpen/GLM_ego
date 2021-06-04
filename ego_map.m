function [egogrid,dirVec,ego] = ego_map(posx,posx2,posy,posy2,ref,nbins)

% unpack reference point
refx = ref(1);
refy = ref(2);

%compute head direction
direction = atan2(posy2-posy,posx2-posx) + pi/2;
direction(direction < 0) = direction(direction<0)+2*pi; % go from 0 to 2*pi, without any negative numbers

% compute allocentric bearing on the reference point
allo = atan2(refy-posy, refx-posx) + pi/2; % add 90 deg
allo(allo<0) = allo(allo<0)+2*pi;

% compute egocentric bearing on the reference point
ego = allo - direction;
ego(ego < 0) = ego(ego < 0) + 2*pi;

% sets up a grid of zeros
egogrid = zeros(length(posx),nbins);

% creates n linearly spaced bins from 0 to 2pi
dirVec = 2*pi/nbins/2:2*pi/nbins:2*pi-2*pi/nbins/2;

for i = 1:numel(posx)
    
    % figure out the egocentric bearing index
    [~, idx] = min(abs(ego(i)-dirVec));
    egogrid(i,idx) = 1;
  
end

return