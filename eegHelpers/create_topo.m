function create_topo(TFR, tidx, fidx, freqband)

if nargin < 5
    freqband                                     = 'alpha';
end

in_type                                          = 'pin';
out_type                                         = 'pout';
NTin_tfr                                         = TFR.NT.pin.all;
NTout_tfr                                        = TFR.NT.pout.all;
Tin_tfr                                          = TFR.T.pin.all;
Tout_tfr                                         = TFR.T.pout.all;

cfg                                              = [];
cfg.operation                                    = '(10^(x1/10) - 10^(x2/10)) / (10^(x1/10) + 10^(x2/10))';
cfg.parameter                                    = 'powspctrm';
NTcontrast                                       = ft_math(cfg, NTin_tfr, NTout_tfr);
Tcontrast                                        = ft_math(cfg, Tin_tfr, Tout_tfr);

occ_elecs                                        = {'O1', 'PO3', 'PO7', 'P1', 'P3', 'P5', 'P7', 'O2', ...
                                                    'PO4', 'PO8', 'P2', 'P4', 'P6', 'P8'};
NT_idx                                           = find(ismember(NTcontrast.label,occ_elecs));
T_idx                                            = find(ismember(Tcontrast.label,occ_elecs));

NT_pmax                                          = max(NTcontrast.powspctrm(NT_idx, fidx, tidx), [], 'all', 'omitnan');
NT_pmin                                          = min(NTcontrast.powspctrm(NT_idx, fidx, tidx), [], 'all', 'omitnan');
T_pmax                                           = max(Tcontrast.powspctrm(T_idx, fidx, tidx), [], 'all', 'omitnan');
T_pmin                                           = min(Tcontrast.powspctrm(T_idx, fidx, tidx), [], 'all', 'omitnan');

min_pow                                          = -0.05; %min([NT_pmin, T_pmin]);
max_pow                                          = 0.05;%; max([NT_pmax, T_pmax]);


figure('Renderer', 'painters', 'Position', [0 1000 1600 800])
if strcmp(t_type, 'P')
    sgtitle(['pro blocks, ' freqband ' band']);
elseif strcmp(t_type, 'A')
    sgtitle(['anti blocks, ' freqband ' band']);
end
cfg                                              = []; 
cfg.layout                                       = 'acticap-64_md.mat'; 
cfg.figure                                       = 'gcf';
%cfg.style                                        = 'straight';
if strcmp(freqband, 'alpha')
    cfg.ylim                                     = [8 12]; 
elseif strcmp(freqband, 'beta')
    cfg.ylim                                     = [13 30];
elseif strcmp(freqband, 'gamma')
    cfg.ylim                                     = [30 50];
end
cfg.colorbar                                     = 'yes'; 
cfg.comment                                      = 'no'; 
cfg.colormap                                     = '*RdBu'; 
cfg.marker                                       = 'on';
cfg.zlim                                         = [min_pow max_pow];
cfg.interpolatenan                               = 'no';

subplot(2, 2, 1)
cfg.xlim                                         = [0.5 1.5];
cfg.title                                        = 'Delay 1 NoTMS';
ft_topoplotTFR(cfg, NTcontrast)
subplot(2, 2, 2)
cfg.xlim                                         = [3 4];
cfg.title                                        = 'Delay 2 NoTMS';
ft_topoplotTFR(cfg, NTcontrast)
subplot(2, 2, 3)
cfg.xlim                                         = [0.5 1.5];
cfg.title                                        = 'Delay 1 TMS';
ft_topoplotTFR(cfg, NTcontrast)
subplot(2, 2, 4)
cfg.xlim                                         = [3 4];
cfg.title                                        = 'Delay 2 TMS';
ft_topoplotTFR(cfg, NTcontrast)

end