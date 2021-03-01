%% SET UP DATA: EGOCENTRIC GLM
% This script is segmented into several parts. First, the data (an
% example cell) is loaded. Then, 15 LN models are fit to the
% cell's spike train. Each model uses information about 
% position, head direction, running speed, theta phase,
% or some combination thereof, to predict a section of the
% spike train. Model fitting and model performance is computed through
% 10-fold cross-validation, and the minimization procedure is carried out
% through fminunc. Next, a forward-search procedure is
% implemented to find the simplest 'best' model describing this spike
% train. Following this, the firing rate tuning curves are computed, and
% these - along with the model-derived response profiles and the model
% performance and results of the selection procedure are plotted.

% description of variables included --
% boxSize = length (in cm) of one side of the square box
% post = vector of time (seconds) at every 20 ms time bin
% spiketrain = vector of the # of spikes in each 20 ms time bin
% posx = x-position of left LED every 20 ms
% posx2 = x-position of right LED every 20 ms
% posx_c = x-position in middle of LEDs
% posy = y-position of left LED every 20 ms
% posy2 = y-posiiton of right LED every 20 ms
% posy_c = y-position in middle of LEDs
% ref = reference point for egocentric bearing calculations; 
% formatted as [x y].

% Modified from code implemented in Hardcastle, Maheswaranthan, Ganguli, Giocomo,
% Neuron 2017; V1: Kiah Hardcastle, March 16, 2017
% Current V: Jordan Carpenter, February 8, 2021.


%% load data and format variables
warning('off', 'all');
clear all; close all; clc

% load dataset from animal 24116
fprintf('(1/5) Loading data...')
% load('C:\Users\17145\OneDrive - NTNU\Documents\github_local\GLM\GLM_sample_data\egodistcell.mat');

% format variables:
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
spiketrain = histcounts(ST, linspace(post(1),post(end),numel(post)+1))';
% (9) boxSize: length (in cm) of one side of the square box
boxSize = nanmean([nanmax(posx_c) nanmax(posy_c)]);
% (10) ref: reference point for bearing calculations (added by me)
ref = [75, 75];


%% fit the model
fprintf('(2/5) Fitting all linear-nonlinear (LN) models\n')
fit_all_ln_models

%% find the simplest model that best describes the spike train
fprintf('(3/5) Performing forward model selection\n')
select_best_model

%% Compute the firing-rate tuning curves
fprintf('(4/5) Computing tuning curves\n')
compute_all_tuning_curves

%% plot the results
fprintf('(5/5) Plotting performance and parameters\n') 
plot_performance_and_parameters



















