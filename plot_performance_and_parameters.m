%% Description
% This will plot the results of all the preceding analyses: the model
% performance, the model-derived tuning curves, and the firing rate tuning
% curves.

%% plot the tuning curves

% create x-axis vectors
hd_vector = 2*pi/n_dir_bins/2:2*pi/n_dir_bins:2*pi - 2*pi/n_dir_bins/2;
ego_vector = hd_vector;
speed_vector = 2.5:50/n_speed_bins:47.5;
maxdist = 120; dist_vector = 0:maxdist/(n_dist_bins-1):maxdist;

% number of rows and colums
nc = 5;
lw = 1;

% plot the tuning curves (real data)
figure(1); set(gcf,'color','w');
subplot(3,nc,1)
imagesc(pos_curve); colorbar
axis off;
title('Position')

subplot(3,nc,2)
plot(hd_vector,hd_curve,'k','linewidth',lw)
box off
axis([0 2*pi -inf inf])
xlabel('angle (rad)')
title('Head direction')

subplot(3,nc,3)
plot(speed_vector,speed_curve,'k','linewidth',lw)
box off
xlabel('Running speed')
axis([0 50 -inf inf])
title('Speed')

subplot(3,nc,4)
plot(hd_vector,ego_curve,'k','linewidth',lw)
xlabel('angle (rad)')
axis([0 2*pi -inf inf])
box off
title('EgoBearing')

subplot(3,nc,5)
plot(dist_vector,dist_curve,'k','linewidth',lw)
xlabel('dist (cm)')
axis([0 maxdist -inf inf])
box off
title('EgoDistance')


%% compute and plot the model-derived response profiles

% show parameters from the full model
param_full_model = param{1};

% pull out the parameter values
pos_param = param_full_model(1:n_pos_bins^2);
hd_param = param_full_model(n_pos_bins^2+1:n_pos_bins^2+n_dir_bins);
speed_param = param_full_model(n_pos_bins^2+n_dir_bins+1:n_pos_bins^2+n_dir_bins+n_speed_bins);
ego_param = param_full_model(n_pos_bins^2+n_dir_bins+n_speed_bins+1:...
    n_pos_bins^2+n_dir_bins+n_speed_bins+n_ego_bins);
dist_param = param_full_model(numel(param_full_model)-n_dist_bins+1:numel(param_full_model));

% compute the scale factors
% NOTE: technically, to compute the precise scale factor, the expectation
% of each parameter should be calculated, not the mean.
scale_factor_pos = mean(exp(speed_param))*mean(exp(hd_param))*mean(exp(ego_param))*mean(exp(dist_param))*50;
scale_factor_hd = mean(exp(speed_param))*mean(exp(pos_param))*mean(exp(ego_param))*mean(exp(dist_param))*50;
scale_factor_spd = mean(exp(pos_param))*mean(exp(hd_param))*mean(exp(ego_param))*mean(exp(dist_param))*50;
scale_factor_ego = mean(exp(speed_param))*mean(exp(hd_param))*mean(exp(pos_param))*mean(exp(dist_param))*50;
scale_factor_dist = mean(exp(pos_param))*mean(exp(hd_param))*mean(exp(speed_param))*mean(exp(ego_param))*50;

% compute the model-derived response profiles
pos_response = scale_factor_pos*exp(pos_param);
hd_response = scale_factor_hd*exp(hd_param);
speed_response = scale_factor_spd*exp(speed_param);
ego_response = scale_factor_ego*exp(ego_param);
dist_response = scale_factor_dist*exp(dist_param);

% plot the model-derived response profiles
subplot(3,nc,6)
imagesc(reshape(pos_response,20,20)); axis off; 
subplot(3,nc,7)
plot(hd_vector,hd_response,'k','linewidth',lw)
xlabel('direction angle')
box off
subplot(3,nc,8)
plot(speed_vector,speed_response,'k','linewidth',lw)
xlabel('Running speed')
box off
subplot(3,nc,9)
plot(ego_vector,ego_response,'k','linewidth',lw)
xlabel('egocentric bearing')
axis([0 2*pi -inf inf])
box off
subplot(3,nc,10)
plot(dist_vector,dist_response,'k','linewidth',lw)
xlabel('distance (cm)')
axis([0 maxdist -inf inf])
box off

% make the axes match
subplot(3,nc,1)
caxis([min(min(pos_response),min(pos_curve(:))) max(max(pos_response),max(pos_curve(:)))])
subplot(3,nc,6)
caxis([min(min(pos_response),min(pos_curve(:))) max(max(pos_response),max(pos_curve(:)))])

subplot(3,nc,2)
axis([0 2*pi min(min(hd_response),min(hd_curve)) max(max(hd_response),max(hd_curve))])
subplot(3,nc,7)
axis([0 2*pi min(min(hd_response),min(hd_curve)) max(max(hd_response),max(hd_curve))])

subplot(3,nc,3)
axis([0 50 min(min(speed_response),min(speed_curve)) max(max(speed_response),max(speed_curve))])
subplot(3,nc,8)
axis([0 50 min(min(speed_response),min(speed_curve)) max(max(speed_response),max(speed_curve))])

subplot(3,nc,4)
axis([0 2*pi min(min(ego_response),min(ego_curve)) max(max(ego_response),max(ego_curve))])
subplot(3,nc,9)
axis([0 2*pi min(min(ego_response),min(ego_curve)) max(max(ego_response),max(ego_curve))])

subplot(3,nc,5)
axis([0 maxdist min(min(dist_response),min(dist_curve)) max(max(dist_response),max(dist_curve))])
subplot(3,nc,10)
axis([0 maxdist min(min(dist_response),min(dist_curve)) max(max(dist_response),max(dist_curve))])

%% compute and plot the model performances

% ordering:
% pos&hd&spd&theta / pos&hd&spd / pos&hd&th / pos&spd&th / hd&spd&th / pos&hd /
% pos&spd / pos&th/ hd&spd / hd&theta / spd&theta / pos / hd / speed/ theta

LLH_increase_mean = mean(LLH_values);
LLH_increase_sem = std(LLH_values)/sqrt(numFolds);

figure(1)
subplot(3,nc,11:15)
errorbar(LLH_increase_mean,LLH_increase_sem,'.k','linewidth',1)
hold on
plot(selected_model,LLH_increase_mean(selected_model),'.r','markersize',15)
plot(0.5:15.5,zeros(16,1),'--b','linewidth',2)
hold off
box off
set(gca,'fontsize',12)
set(gca,'XLim',[0 32]); set(gca,'XTick',1:31)
set(gca,'XTickLabel',{'PHSED', 'PHSE', 'PHSD', 'PHED', 'PSED', 'HSED', ...
    'PHS', 'PHE', 'PHD', 'PSE', 'PSD', 'PED', 'HSE', 'HSD', 'HED', ...
    'SED', 'PH', 'PS', 'PE', 'PD', 'HS', 'HE', 'HD', 'SE', 'SD', ...
    'ED', 'P', 'H', 'S', 'E', 'D'})
set(gca, 'XTickLabelRotation', 45);
legend('Model performance','Selected model','Baseline')
   

