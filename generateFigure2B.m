clear; close all; clc;
warning('off', 'all');
addpath('/d/DATD/hyper/software/fieldtrip-20220104/');

t_stamp                                     = [0.5 2 3 4.5];
f_stamp                                     = [7 20];
conds                                       = ["NT", "T"];
t_types                                     = ["pin", "pout"];
t_types_in                                  = ["pin"];
locs                                        = ["ipsi", "contra"];

fName.mTFR                                  = '/d/DATD/datd/MD_TMS_EEG/OSF_data/eegData/masterTFR_allsubs.mat';

disp('Loading existing master TFR file')
load(fName.mTFR)
tidx_before                     = find((mTFR.NT.pin.ipsi.time > t_stamp(1)) ...
    & (mTFR.NT.pin.ipsi.time < t_stamp(2)));
tidx_after                      = find((mTFR.NT.pin.ipsi.time > t_stamp(3)) ...
    & (mTFR.NT.pin.ipsi.time < t_stamp(4)));
tidx                            = [tidx_before tidx_after];
fidx                            = find((mTFR.NT.pin.ipsi.freq > f_stamp(1)) ...
    & (mTFR.NT.pin.ipsi.freq < f_stamp(2)));


%% If running for all subjects regardless
% Average all mTFRs for plotting
for tt = t_types_in
    mTFR.NT.(tt).ipsi.powspctrm         = mean(mTFR.NT.(tt).ipsi.powspctrm, 1, 'omitnan');
    mTFR.NT.(tt).contra.powspctrm       = mean(mTFR.NT.(tt).contra.powspctrm, 1, 'omitnan');
    mTFR.NT.(tt).all.powspctrm          = mean(mTFR.NT.(tt).all.powspctrm, 4, 'omitnan');
end
mTFR.NT.pout.all.powspctrm              = mean(mTFR.NT.pout.all.powspctrm, 4, 'omitnan');
for tt = t_types
    mTFR.T.(tt).ipsi.powspctrm          = mean(mTFR.T.(tt).ipsi.powspctrm, 1, 'omitnan');
    mTFR.T.(tt).contra.powspctrm        = mean(mTFR.T.(tt).contra.powspctrm, 1, 'omitnan');
    mTFR.T.(tt).all.powspctrm           = mean(mTFR.T.(tt).all.powspctrm, 4, 'omitnan');
end
    
create_topo(mTFR, tidx, fidx, 'alpha')
    