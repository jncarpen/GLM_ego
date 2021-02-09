function [distgrid,distVec,dist] = dist_map(posx_c,posy_c,ref,nbins)
%DIST_MAP: EGOCENTRIC DISTANCE CALCULATION

% unpack reference point
refx = ref(1);
refy = ref(2);

% compute distance at each time (euclidean)
dist = sqrt((refx-posx_c).^2 + (refy-posy_c).^2);
maxDist = nanmax(dist);

% bin centers for distance 
distVec = maxDist/nbins/2:maxDist/nbins:maxDist-maxDist/nbins/2;
distgrid = zeros(numel(posx_c),numel(distVec));

for i = 1:numel(posx_c)
    % figure out the speed index
    [~, idx] = min(abs(dist(i)-distVec));
    distgrid(i,idx) = 1;
end

end

