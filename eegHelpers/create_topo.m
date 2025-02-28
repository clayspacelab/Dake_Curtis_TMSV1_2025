function create_topo(TFR, tidx, fidx, freqband)

if nargin < 4
    freqband                                     = 'alpha';
end

NTin_tfr                                         = TFR.NT.pin.all;
NTout_tfr                                        = TFR.NT.pout.all;
Tin_tfr                                          = TFR.T.pin.all;
Tout_tfr                                         = TFR.T.pout.all;

cfg                                              = [];
cfg.operation                                    = '(10^(x2/10) - 10^(x1/10)) / (10^(x1/10) + 10^(x2/10))';
cfg.parameter                                    = 'powspctrm';
NTcontrast                                       = ft_math(cfg, NTin_tfr, NTout_tfr);
Tcontrast                                        = ft_math(cfg, Tin_tfr, Tout_tfr);

min_pow                                          = -0.05; 
max_pow                                          = 0.05;

figure('Renderer', 'painters', 'Position', [0 1000 1600 800])
sgtitle([freqband ' band activity'])

cfg                                              = []; 
cfg.layout                                       = 'acticap-64_md.mat'; 
cfg.figure                                       = 'gcf';
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
ft_topoplotTFR(cfg, Tcontrast)
subplot(2, 2, 4)
cfg.xlim                                         = [3 4];
cfg.title                                        = 'Delay 2 TMS';
ft_topoplotTFR(cfg, Tcontrast)

end