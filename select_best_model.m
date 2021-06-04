
%% Description
% This code will implement forward feature selection in order to determine
% the simplest model that best describes neural spiking. First, the
% highest-performing single-variable model is identified. Then, the
% highest-perfmoring double-variable model that includes the
% single-variable model is identified. This continues until the full model
% is identified. Next, statistical tests are applied to see if including
% extra variables significantly improves model performance. The first time
% that including variable does NOT signficantly improve performance, the
% procedure is stopped and the model at that point is recorded as the
% selected model.

% the model indexing scheme:
% phst, phs, pht, pst, hst, ph, ps, pt, hs, ht, st, p,  h,  s,  t
% 1      2    3    4    5    6  7   8   9   10  11  12  13  14  15



testFit_mat = cell2mat(testFit);
LLH_values = reshape(testFit_mat(:,3),numFolds,numModels);

% find the best single model
singleModels = 27:31;
[~,top1] = max(nanmean(LLH_values(:,singleModels))); top1 = top1 + singleModels(1)-1;

% find the best double model that includes the single model
if top1 == 27 % P -> PH, PS, PE, PD
    vec = [17 18 19 20];
    [~,top2] = max(nanmean(LLH_values(:,vec)));
    top2 = vec(top2);
elseif top1 == 28 % H -> PH, HS, HE, HD
    vec = [17 21 22 23];
    [~,top2] = max(nanmean(LLH_values(:,vec)));
    top2 = vec(top2);
elseif top1 == 29 % S -> PS, HS, SE, SD
    vec = [18 21 24 25]; 
    [~,top2] = max(nanmean(LLH_values(:,vec)));
    top2 = vec(top2);
elseif top1 == 30 % E -> PE, HE, SE, ED
    vec = [19 22 24 26];
    [~,top2] = max(nanmean(LLH_values(:,vec)));
    top2 = vec(top2);
elseif top1 == 31 % D -> PD, HD, SD, ED
    vec = [20 23 25 26];
    [~,top2] = max(nanmean(LLH_values(:,vec)));
    top2 = vec(top2);
end

% find the best triple model that includes the double model
if top2 == 17 % PH-> PHS, PHE, PHD
    vec = [7 8 9];
    [~,top3] = max(nanmean(LLH_values(:,vec)));
    top3 = vec(top3);
elseif top2 == 18 % PS -> PHS, PSE, PSD
    vec = [7 10 11];
    [~,top3] = max(nanmean(LLH_values(:,vec)));
    top3 = vec(top3);
elseif top2 == 19 % PE -> PHE, PSE, PED
    vec = [8 10 12];
    [~,top3] = max(nanmean(LLH_values(:,vec)));
    top3 = vec(top3);
elseif top2 == 20 % PD -> PHD, PSD, PED
    vec = [9 11 12];
    [~,top3] = max(nanmean(LLH_values(:,vec)));
    top3 = vec(top3);
elseif top2 == 21 % HS -> PHS, HSE, HSD
    vec = [7 13 14];
    [~,top3] = max(nanmean(LLH_values(:,vec)));
    top3 = vec(top3);
elseif top2 == 22 % HE -> PHE, HSE, HED
    vec = [8 13 15];
    [~,top3] = max(nanmean(LLH_values(:,vec)));
    top3 = vec(top3);
elseif top2 == 23 % HD -> PHD, HSD, HED
    vec = [9, 14, 15];
    [~,top3] = max(nanmean(LLH_values(:,vec)));
    top3 = vec(top3);
elseif top2 == 24 % SE -> PSE, HSE, SED
    vec = [10 13 16];
    [~,top3] = max(nanmean(LLH_values(:,vec)));
    top3 = vec(top3);
elseif top2 == 25 % SD -> PSD, HSD, SED
    vec = [11 14 16];
    [~,top3] = max(nanmean(LLH_values(:,vec)));
    top3 = vec(top3);
elseif top2 == 26 % ED -> PED, HED, SED
    vec = [14 15 16];
    [~,top3] = max(nanmean(LLH_values(:,vec)));
    top3 = vec(top3);
end

% find the best quadruple model that includes the triple model
if top3 == 7 % PHS -> PHSE, PHSD
    vec = [2 3];
    [~,top4] = max(nanmean(LLH_values(:,vec)));
    top4 = vec(top4);
elseif top3 == 8 % PHE -> PHSE, PHED
    vec = [2 4];
    [~,top4] = max(nanmean(LLH_values(:,vec)));
    top4 = vec(top4);
elseif top3 == 9 % PHD -> PHSD, PHED
    vec = [3 4];
    [~,top4] = max(nanmean(LLH_values(:,vec)));
    top4 = vec(top4);
elseif top3 == 10 % PSE -> PHSE, PSED
    vec = [2 5];
    [~,top4] = max(nanmean(LLH_values(:,vec)));
    top4 = vec(top4);
elseif top3 == 11 % PSD -> PHSD, PSED
    vec = [3 5];
    [~,top4] = max(nanmean(LLH_values(:,vec)));
    top4 = vec(top4);
elseif top3 == 12 % PED -> PHED, PSED
    vec = [4 5];
    [~,top4] = max(nanmean(LLH_values(:,vec)));
    top4 = vec(top4);
elseif top3 == 13 % HSE -> PHSE, HSED
    vec = [2 6];
    [~,top4] = max(nanmean(LLH_values(:,vec)));
    top4 = vec(top4);
elseif top3 == 14 % HSD -> PHSD, HSED
    vec = [3 6];
    [~,top4] = max(nanmean(LLH_values(:,vec)));
    top4 = vec(top4);
elseif top3 == 15 % HED -> PHED, HSED
    vec = [4 6];
    [~,top4] = max(nanmean(LLH_values(:,vec)));
    top4 = vec(top4);
elseif top3 == 16 % SED -> PSED, HSED
    vec = [5 6];
    [~,top4] = max(nanmean(LLH_values(:,vec)));
    top4 = vec(top4);
end

top5 = 1;
LLH1 = LLH_values(:,top1); LLH2 = LLH_values(:,top2);
LLH3 = LLH_values(:,top3); LLH4 = LLH_values(:,top4);
LLH5 = LLH_values(:,top5);

[p_llh_12,~] = signrank(LLH2,LLH1,'tail','right');
[p_llh_23,~] = signrank(LLH3,LLH2,'tail','right');
[p_llh_34,~] = signrank(LLH4,LLH3,'tail','right');
[p_llh_45,~] = signrank(LLH5,LLH4,'tail','right');


if p_llh_12 < 0.05 % double model is sig. better
    if p_llh_23 < 0.05  % triple model is sig. better
        if p_llh_34 < 0.05 % quad model is sig. better
            if p_llh_45 < 0.05 % full model is sig. better
                selected_model = 1; % full model
            else
                selected_model = top4; %quad model
            end
        else
            selected_model = top3; %triple model
        end
    else
        selected_model = top2; %double model
    end
else 
    selected_model = top2; %single model
end

% % re-set if selected model is not above baseline
% pval_baseline = signrank(LLH_values(:,selected_model),[],'tail','right');
% 
% if pval_baseline > 0.05
%     selected_model = NaN;
% end
