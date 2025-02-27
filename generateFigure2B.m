clear; close all; clc;
warning('off', 'all');

t_stamp                                     = [0.5 2 3 4.5];
f_stamp                                     = [7 20];
conds                                       = ["NT", "T"];
t_types                                     = ["pin", "pout"];
t_types_in                                  = ["pin"];
locs                                        = ["ipsi", "contra"];

fName.mTFR                                  = '/d/DATD/datd/MD_TMS_EEG/OSF_data/eegData/masterTFR_allsubs.mat';
% save(fName.mTFR, 'mTFR', '-v7.3')


disp('Loading existing master TFR file')
load(fName.mTFR)
tidx_before                     = find((mTFR.NT.pin.ipsi.time > t_stamp(1)) ...
    & (mTFR.NT.pin.ipsi.time < t_stamp(2)));
tidx_after                      = find((mTFR.NT.pin.ipsi.time > t_stamp(3)) ...
    & (mTFR.NT.pin.ipsi.time < t_stamp(4)));
tidx                            = [tidx_before tidx_after];
fidx                            = find((mTFR.NT.pin.ipsi.freq > f_stamp(1)) ...
    & (mTFR.NT.pin.ipsi.freq < f_stamp(2)));
% p.figure                                = fig_path;


%% If running for all subjects regardless
% Average all mTFRs for plotting
for tt = t_types_in
    mTFR.NT.(tt).ipsi.powspctrm         = mean(mTFR.NT.(tt).ipsi.powspctrm, 1, 'omitnan');
    mTFR.NT.(tt).contra.powspctrm       = mean(mTFR.NT.(tt).contra.powspctrm, 1, 'omitnan');
    mTFR.NT.(tt).all.powspctrm          = mean(mTFR.NT.(tt).all.powspctrm, 4, 'omitnan');
end
mTFR.NT.pout.all.powspctrm              = mean(mTFR.NT.pout.all.powspctrm, 4, 'omitnan');
mTFR.NT.aout.all.powspctrm              = mean(mTFR.NT.aout.all.powspctrm, 4, 'omitnan');
for tt = t_types
    mTFR.T.(tt).ipsi.powspctrm          = mean(mTFR.T.(tt).ipsi.powspctrm, 1, 'omitnan');
    mTFR.T.(tt).contra.powspctrm        = mean(mTFR.T.(tt).contra.powspctrm, 1, 'omitnan');
    mTFR.T.(tt).all.powspctrm           = mean(mTFR.T.(tt).all.powspctrm, 4, 'omitnan');
end
    

% Figure names for master plots
% figname.masterTFR_pro                       = [p.figure '/tfrplots/' tfr_type '/allsubs_TFRpro.png'];
% figname.masterTFR_anti                      = [p.figure '/tfrplots/' tfr_type '/allsubs_TFRanti.png'];
% figname.masterTOPO_pro                      = [p.figure '/topoplots/' tfr_type '/allsubs_TOPOpro.png'];
% figname.masterTOPO_anti                     = [p.figure '/topoplots/' tfr_type '/allsubs_TOPOanti.png'];

% Master figure plots for TFR and TOPO
% if ~exist(figname.masterTFR_pro, 'file')
    compare_conds(mTFR, tidx, fidx, 'p')
    % saveas(gcf, figname.masterTFR_pro, 'png')
    % compare_conds(mTFR, tidx, fidx, 'a')
    % saveas(gcf, figname.masterTFR_anti, 'png')
% end
% if ~exist(figname.masterTOPO_pro, 'file')
    create_topo(mTFR, tidx, fidx, 'p', 'alpha')
    % saveas(gcf, figname.masterTOPO_pro, 'png')
    % create_topo(mTFR, tidx, fidx, 'a', 'alpha')
    % saveas(gcf, figname.masterTOPO_anti, 'png')
% end

%% Temporarily made for plotting for the paper
figname.masterTFR_pro                       = [p.figure '/tfrplots/' tfr_type '/allsubs_TFRpro.png'];
figname.masterTFR_anti                      = [p.figure '/tfrplots/' tfr_type '/allsubs_TFRanti.png'];
figname.masterTOPO_pro                      = [p.figure '/topoplots/' tfr_type '/allsubs_TOPOpro.png'];
figname.masterTOPO_anti                     = [p.figure '/topoplots/' tfr_type '/allsubs_TOPOanti.png'];

% Master figure plots for TFR and TOPO
if ~exist(figname.masterTFR_pro, 'file')
    compareconds_SfN(mTFR, tidx, fidx, 'p')
    saveas(gcf, figname.masterTFR_pro, 'png')
    compare_conds(mTFR, tidx, fidx, 'a')
    saveas(gcf, figname.masterTFR_anti, 'png')
end
if ~exist(figname.masterTOPO_pro, 'file')
    createtopo_SfN(mTFR, tidx, fidx, 'p', 'alpha')
    createtopo_SfN(mTFR, tidx, fidx, 'p', 'beta')
    createtopo_SfN(mTFR, tidx, fidx, 'p', 'gamma')
end
%% If running for all subjects regardless (temporarily made for SfN (maybe?)
% for ss = 1:length(subs)
%     NTin_tfr                                         = mTFR.NT.pin.all;
%     NTout_tfr                                        = mTFR.NT.pout.all;
%     Tin_tfr                                          = mTFR.T.pin.all;
%     Tout_tfr                                         = mTFR.T.pout.all;
%     NTin_tfr.powspctrm                               = squeeze(NTin_tfr.powspctrm(:,:,:,ss));
%     NTout_tfr.powspctrm                              = squeeze(NTout_tfr.powspctrm(:,:,:,ss));
%     Tin_tfr.powspctrm                                = squeeze(Tin_tfr.powspctrm(:,:,:,ss));
%     Tout_tfr.powspctrm                               = squeeze(Tout_tfr.powspctrm(:,:,:,ss));
%     
%     cfg                                              = [];
%     cfg.operation                                    = '(10^(x1/10) - 10^(x2/10)) / (10^(x1/10) + 10^(x2/10))';
%     cfg.parameter                                    = 'powspctrm';
%     NTcontrast                                       = ft_math(cfg, NTin_tfr, NTout_tfr);
%     Tcontrast                                        = ft_math(cfg, Tin_tfr, Tout_tfr);
%     cfg                                              = [];
%     cfg.operation                                    = 'x1-x2';
%     cfg.parameter                                    = 'powspctrm';
%     diffcontrast                                     = ft_math(cfg, NTcontrast, Tcontrast);
%     % Fing electrodes that are statistically different from 0
%     tlateidx                                         = find(diffcontrast.time > 2.8 & diffcontrast.time < 3.2);
%     diff_powmat                                      = squeeze(mean(diffcontrast.powspctrm(:, fidx, tlateidx), [2, 3], 'omitnan'));
%     if ~exist('diffmaster', 'var')
%         diffmaster = diff_powmat;
%     else
%         diffmaster = cat(3, diffmaster, diff_powmat);
%     end
%     %diffmaster = [diffmaster; diff_powmat];
%     clearvars NTin_tfr NTout_tfr Tin_tfr Tout_tfr NTcontrast Tcontrast diffcontrast diff_powmat;
% end
% 
% 
% for ii = 1:length(mTFR.NT.Pin.all.label)
%     [h, p, ci, stats]                                = ttest(diffmaster(ii, 1, :), 0, 'alpha', 0.05);
%     if h == 1
%         disp([mTFR.NT.Pin.all.label{ii} ': ' num2str(p, '%.03f')])
%         %disp([mTFR.NT.Pin.all.label{ii} ': ' num2str(h)])
%         %disp(p, stats)
%     end
% end
% 
% %Average all mTFRs for plotting
% for tt = t_types_in
%     mTFR.NT.(tt).ipsi.powspctrm         = mean(mTFR.NT.(tt).ipsi.powspctrm, 1, 'omitnan');
%     mTFR.NT.(tt).contra.powspctrm       = mean(mTFR.NT.(tt).contra.powspctrm, 1, 'omitnan');
%     mTFR.NT.(tt).all.powspctrm          = mean(mTFR.NT.(tt).all.powspctrm, 4, 'omitnan');
% end
% mTFR.NT.Pout.all.powspctrm              = mean(mTFR.NT.Pout.all.powspctrm, 4, 'omitnan');
% mTFR.NT.Aout.all.powspctrm              = mean(mTFR.NT.Aout.all.powspctrm, 4, 'omitnan');
% for tt = t_types
%     mTFR.T.(tt).ipsi.powspctrm          = mean(mTFR.T.(tt).ipsi.powspctrm, 1, 'omitnan');
%     mTFR.T.(tt).contra.powspctrm        = mean(mTFR.T.(tt).contra.powspctrm, 1, 'omitnan');
%     mTFR.T.(tt).all.powspctrm           = mean(mTFR.T.(tt).all.powspctrm, 4, 'omitnan');
% end
%     
% 
% % Figure names for master plots
% figname.masterTFR_pro                       = [p.figure '/tfrplots/' tfr_type 'allsubs_TFRpro.png'];
% figname.masterTFR_anti                      = [p.figure '/tfrplots/' tfr_type 'allsubs_TFRanti.png'];
% figname.masterTOPO_pro                      = [p.figure '/topoplots/' tfr_type 'allsubs_TOPOpro.png'];
% figname.masterTOPO_anti                     = [p.figure '/topoplots/' tfr_type 'allsubs_TOPOanti.png'];
% 
% % Master figure plots for TFR and TOPO
% if ~exist(figname.masterTFR_pro, 'file')
%     compare_conds(mTFR, tidx, fidx, 'P')
%     saveas(gcf, figname.masterTFR_pro, 'png')
%     compare_conds(mTFR, tidx, fidx, 'A')
%     saveas(gcf, figname.masterTFR_anti, 'png')
% end
% %if ~exist(figname.masterTOPO_pro, 'file')
%     createtopo_SfN(mTFR, tidx, fidx, 'P', 'alpha')
%     saveas(gcf, figname.masterTOPO_pro, 'png')
%     createtopo_SfN(mTFR, tidx, fidx, 'A', 'alpha')
%     saveas(gcf, figname.masterTOPO_anti, 'png')
% %end
end