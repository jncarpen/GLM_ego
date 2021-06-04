function [speed_grid,speedVec,speed] = speed_map(posx,posy,nbins)

%compute velocity
sampleRate = 50; % in Hz
velx = diff([posx(1); posx]); vely = diff([posy(1); posy]); % add the extra just to make the vectors the same size
speed = sqrt(velx.^2+vely.^2)*sampleRate; 
maxSpeed = 70; speed(speed>maxSpeed) = maxSpeed; %send everything over 70 cm/s to 70 cm/s

speedVec = maxSpeed/nbins/2:maxSpeed/nbins:maxSpeed-maxSpeed/nbins/2;
speed_grid = zeros(numel(posx),numel(speedVec));

for i = 1:numel(posx)

    % figure out the speed index
    [~, idx] = min(abs(speed(i)-speedVec));
    speed_grid(i,idx) = 1;
    

end

return