function [theta_grid,phaseVec,phase_time] = theta_map(filt_eeg,timeVec,sampleRate,nbins)

%compute instantaneous phase
hilb_eeg = hilbert(filt_eeg); % compute hilbert transform
phase = atan2(imag(hilb_eeg),real(hilb_eeg)); %inverse tangent (-pi to pi)
ind = phase < 0; phase(ind) = phase(ind)+2*pi; % map from 0 to 2*pi

%give index in egf (downsample the lfp)
% same size as timeVec at this stage
% phase_ind = round(timeVec*sampleRate);
phase_ind = round(linspace(1,numel(filt_eeg)-1, numel(timeVec)))'; % not sure if this is kosher


%if spikes happened after eeg stopped recording, remove
phase_ind(phase_ind + 1 > numel(filt_eeg)) = [];
phase_time = phase(phase_ind+1); % gives phase of lfp at every time point

theta_grid = zeros(length(timeVec),nbins);
phaseVec = 2*pi/nbins/2:2*pi/nbins:2*pi-2*pi/nbins/2; % 0 to 2pi

for i = 1:numel(timeVec)
    
    % figure out the theta index at each time point
    % by finding which bin has the smallest difference
    % from the actual eeg
    [~, idx] = min(abs(phase_time(i)-phaseVec));
    theta_grid(i,idx) = 1;
    
end

return