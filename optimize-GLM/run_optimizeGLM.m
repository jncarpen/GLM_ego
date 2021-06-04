% Run OptimizeGLM algorithm

%% load data and format variables
warning('off', 'all');
clear all; close all; clc
fprintf('(1/5) Loading data...')
load('D:\Data\Project Data\Simulation-EX\single-units\ego0.mat');
% 
% % format variables:
% (1)  x-position of left LED every 20 ms (t x 1):
posx = P(:,2);
% (2)  y-position of left LED every 20 ms (t x 1):
posy = P(:,3);
% (3)  x-position of right LED every 20 ms (t x 1):
posx2 = P(:,4);
% (4)  y-position of right LED every 20 ms (t x 1):
posy2 = P(:,5);
% (5)  x-position in middle of LEDs
posx_c = (posx + posx2)./2;
% (6)  y-position in middle of LEDs
posy_c = (posy + posy2)./2;
% (7) vector of time (seconds) at every 20 ms time bin
post = P(:,1);
% (8) spiketrain: vector of the # of spikes in each 20 ms time bin
ST = ST(ST < post(end) & ST > post(1));
spiketrain_original = histcounts(ST, linspace(post(1),post(end),numel(post)+1))';
% (9) boxSize: length (in cm) of one side of the square box
boxSize = 150; %nanmean([nanmax(posx_c) nanmax(posy_c)]);


% initialize number of reference points to test
num_xy_bins = 10; % inside of box
[xref_matrix, yref_matrix] = meshgrid(linspace(nanmin(posx_c),nanmax(posx_c),num_xy_bins),...
    linspace(nanmin(posy_c),nanmax(posy_c),num_xy_bins));
% linearize the meshgrid
xref_vector = reshape(xref_matrix,num_xy_bins^2,1);
yref_vector = reshape(yref_matrix,num_xy_bins^2,1);
numRuns = length(xref_vector);

%% Iterate through each reference point sample
for refPointIter = 1:numRuns
    
    % reference point now
    fprintf('Testing reference point %d of %d\n', refPointIter, length(xref_vector));
    ref = [xref_vector(refPointIter), yref_vector(refPointIter)];
    
    %% compute the egocentric bearing state matrix
    n_ego_bins = 12;
    [egogrid,dirVec,ego] = ego_map(posx,posx2,posy,posy2,ref,n_ego_bins);

    % compute speed matrix (for thresholding)
    n_speed_bins = 10;
    [~,~,speed] = speed_map(posx_c,posy_c,n_speed_bins);

    % remove times when the animal ran > 70 cm/s
    maxSpeed = 70;
    too_fast = find(speed >= maxSpeed);
    egogrid(too_fast,:) = [];
    spiketrain = spiketrain_original; % re-initialize for each run
    spiketrain(too_fast) = [];

    %% Fit the LN model
    numModels = 1;
    testFit = cell(numModels,1);
    trainFit = cell(numModels,1);
    param = cell(numModels,1);
    paramMat = cell(numModels,1);
    A = cell(numModels,1);
    modelType = cell(numModels,1);
    A{1} = [egogrid]; modelType{1} = [0 0 0 1 0];

    % compute a filter, which will be used to smooth the firing rate
    filter = gaussmf(-4:4,[2 0]); filter = filter/sum(filter); 
    dt = post(3)-post(2); fr = spiketrain/dt;
    smooth_fr = conv(fr,filter,'same');

    % compute the number of folds we would like to do
    numFolds = 8;
    for n = 1 %:numModels
        fprintf('\t- Fitting model %d of %d\n', n, numModels);
        [testFit{n},trainFit{n},param{n}, paramMat{n}] = fit_model(A{n},dt,spiketrain,filter,modelType{n},numFolds);
    end
    
    % package output for each iteration
    lnOut(refPointIter).testFit = testFit;
    lnOut(refPointIter).trainFit = trainFit;
    lnOut(refPointIter).param = param;
    lnOut(refPointIter).paramMat = paramMat;
    
end

% concatenate results from each run
clear testFit trainFit param paramMat
for rr = 1:length(xref_vector)
    testFit{rr,1} = lnOut(rr).testFit{:};
    trainFit{rr,1} = lnOut(rr).trainFit{:};
    param{rr,1} = lnOut(rr).param{:};
    paramMat{rr,1} = lnOut(rr).paramMat{:};
end

% matrix of LLH values
testFit_mat = cell2mat(testFit);
LLH_values = reshape(testFit_mat(:,3),numFolds,numRuns);

% find model with highest LLH
mean_LLH = nanmean(LLH_values);
mean_LLH_matrix = reshape(mean_LLH',sqrt(numRuns),sqrt(numRuns));
% sort from high to low LLH
[~,top_LLH_idx] = sort(mean_LLH, 'descend');
best_model_idx = top_LLH_idx(1);

%% calculate and plot tuning curves for best model
% compute true tuning curve (given the data)
ego(too_fast) = [];
[ego_curve] = compute_1d_tuning_curve(ego,smooth_fr,n_ego_bins,0,2*pi);
% compute model-derived response profiles
ego_param = param{best_model_idx};
scale_factor_ego = mean(ego_param);
ego_response = scale_factor_ego*exp(ego_param);

% create x-axis vectors
figure; set(gcf,'color','w'); hold on;
ego_vector = 2*pi/n_ego_bins/2:2*pi/n_ego_bins:2*pi - 2*pi/n_ego_bins/2;
lw = 1; % linewidth
plot(ego_vector,ego_curve,'k','linewidth', lw); 
plot(ego_vector,ego_response,'b','linewidth', lw); 
xlabel('angle (rad)');
axis([0 2*pi -inf inf])
box off;
title('egocentric bearing'); hold off;

%% plot results
% initialize colormap
figure; set(gcf,'color','w');
my_colormap = hot; my_colormap = my_colormap(1:end-10,:);
% scatter(xref_vector, yref_vector, [200], mean_LLH', 'filled');
surf(mean_LLH_matrix); 
colormap(my_colormap); cb=colorbar; cb.FontSize = 12;













