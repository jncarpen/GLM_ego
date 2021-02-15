%% Description
% The model: r = exp(W*theta), where r is the predicted # of spikes, W is a
% matrix of one-hot vectors describing variable (P, H, S, or T) values, and
% theta is the learned vector of parameters.

%% compute the position, head direction, speed, and theta phase matrices

% initialize the number of bins that position, head direction, speed, and
% theta phase will be divided into
n_pos_bins = 20;
n_dir_bins = 18;
n_ego_bins = 18;
n_speed_bins = 10;
n_dist_bins = 24; % approximatley 5 cm bins

% compute position matrix
[posgrid, posVec] = pos_map([posx_c posy_c], n_pos_bins, boxSize);

% compute head direction matrix
[hdgrid,hdVec,direction] = hd_map(posx,posx2,posy,posy2,n_dir_bins);

% compute speed matrix
[speedgrid,speedVec,speed] = speed_map(posx_c,posy_c,n_speed_bins);

% compute egocentric matrix
[egogrid,dirVec,ego] = ego_map(posx,posx2,posy,posy2,ref,n_ego_bins);

% compute distance matrix
[distgrid,distVec,dist] = dist_map(posx_c,posy_c,ref,n_dist_bins);

% remove times when the animal ran > 50 cm/s (these data points may contain artifacts)
too_fast = find(speed >= 50);
posgrid(too_fast,:) = []; hdgrid(too_fast,:) = []; 
speedgrid(too_fast,:) = []; egogrid(too_fast,:) = [];
distgrid(too_fast,:) = [];
spiketrain(too_fast) = [];



%% Fit all 15 LN models
% compute number of models needed
numModels = 31;
testFit = cell(numModels,1);
trainFit = cell(numModels,1);
param = cell(numModels,1);
A = cell(numModels,1);
modelType = cell(numModels,1);

% nchoosek(['P' 'H' 'S' 'E' 'D'], 3)

% ALL VARIABLES (1) 
A{1} = [ posgrid hdgrid speedgrid egogrid distgrid]; modelType{1} = [1 1 1 1 1];

% FOUR VARIABLES (5)
A{2} = [posgrid hdgrid speedgrid egogrid]; modelType{2} = [1 1 1 1 0];
A{3} = [posgrid hdgrid speedgrid distgrid]; modelType{3} = [1 1 1 0 1];
A{4} = [posgrid hdgrid egogrid distgrid]; modelType{4} = [1 1 0 1 1];
A{5} = [posgrid speedgrid egogrid distgrid]; modelType{5} = [1 0 1 1 1];
A{6} = [hdgrid speedgrid egogrid distgrid]; modelType{6} = [0 1 1 1 1];

% THREE VARIABLES (10)
A{7} = [posgrid hdgrid speedgrid]; modelType{7} = [1 1 1 0 0];
A{8} = [posgrid hdgrid egogrid]; modelType{8} = [1 1 0 1 0];
A{9} = [posgrid hdgrid distgrid]; modelType{9} = [1 1 0 0 1];
A{10} = [posgrid speedgrid egogrid]; modelType{10} = [1 0 1 1 0];
A{11} = [posgrid speedgrid distgrid]; modelType{11} = [1 0 1 0 1];
A{12} = [posgrid egogrid distgrid]; modelType{12} = [1 0 0 1 1];
A{13} = [hdgrid speedgrid egogrid]; modelType{13} = [0 1 1 1 0];
A{14} = [hdgrid speedgrid distgrid]; modelType{14} = [0 1 1 0 1];
A{15} = [hdgrid egogrid distgrid]; modelType{15} = [0 1 0 1 1];
A{16} = [speedgrid egogrid distgrid]; modelType{16} = [0 0 1 1 1];

% TWO VARIABLES (10)
A{17} = [posgrid hdgrid]; modelType{17} = [1 1 0 0 0];
A{18} = [posgrid speedgrid]; modelType{18} = [1 0 1 0 0];
A{19} = [posgrid egogrid]; modelType{19} = [1 0 0 1 0];
A{20} = [posgrid distgrid]; modelType{20} = [1 0 0 0 1];
A{21} = [hdgrid speedgrid]; modelType{21} = [0 1 1 0 0];
A{22} = [hdgrid egogrid]; modelType{22} = [0 1 0 1 0];
A{23} = [hdgrid distgrid]; modelType{23} = [0 1 0 0 1];
A{24} = [speedgrid egogrid]; modelType{24} = [0 0 1 1 0];
A{25} = [speedgrid distgrid]; modelType{25} = [0 0 1 0 1];
A{26} = [egogrid distgrid]; modelType{26} = [0 0 0 1 1];

% ONE VARIABLE (5) 
A{27} = [posgrid]; modelType{27} = [1 0 0 0 0];
A{28} = [hdgrid]; modelType{28} = [0 1 0 0 0];
A{29} = [speedgrid]; modelType{29} = [0 0 1 0 0];
A{30} = [egogrid]; modelType{30} = [0 0 0 1 0];
A{31} = [distgrid]; modelType{31} = [0 0 0 0 1];

% compute a filter, which will be used to smooth the firing rate
filter = gaussmf(-4:4,[2 0]); filter = filter/sum(filter); 
dt = post(3)-post(2); fr = spiketrain/dt;
smooth_fr = conv(fr,filter,'same');

% compute the number of folds we would like to do
numFolds = 2;

for n = 1:numModels
    fprintf('\t- Fitting model %d of %d\n', n, numModels);
    [testFit{n},trainFit{n},param{n}] = fit_model(A{n},dt,spiketrain,filter,modelType{n},numFolds);
end
