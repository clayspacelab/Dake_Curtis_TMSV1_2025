# Import modules
import os, socket
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import nibabel as nib
from nilearn.image import resample_to_img

############################ HELPER FUNCS ##################################
def load_nii_file(fpath, T1):
    """
    Load nifty file and resample to 320x320x320 if not already

    Parameters
    ----------
    fpath : str
        Path to nifty file
    T1 : str
        Path to T1 file

    Returns
    ------- 
    data : np.array
        Nifty data
    
    """
    nii_img = nib.load(fpath)
    if nii_img.shape[0] != 320:
        nii_img = resample_to_img(fpath, T1, interpolation='nearest')
    data = nii_img.get_fdata()
    return data

def calculate_Efield_from_mask(whole_brain, mask):
    masked_data = whole_brain[mask > 0]
    efield_value = masked_data.max() 
    return efield_value
#############################################################################

# Set up paths
rootDir = '/d/DATD/datd/MD_TMS_EEG/OSF_data/simnibsData'
df_efield_fname = f'{rootDir}/EfieldV1.csv'


if not os.path.exists(df_efield_fname):
    # The 15 subjects included in final analysis
    subs = [1, 3, 5, 6, 7, 10, 12, 14, 15, 17, 22, 23, 25, 26, 27]

    hemisphere_stimulated = ['Left', 'Right', 'Left', 'Right', 'Left',
                             'Right', 'Left', 'Right', 'Right', 'Left',
                             'Right', 'Right', 'Right', 'Left', 'Left']

    EfieldEstimArray = {f'lhV1': [], f'rhV1': []}

    for idx, sub in enumerate(subs):
        sub_id = f"sub{sub:02d}"
        print(f"Computing mean E-field estimates for {sub_id}")
        metric = "magnE"
        this_hemi = hemisphere_stimulated[idx]

        subfoldpath = f"{rootDir}/{sub_id}"
        m2mfoldpath = f"{subfoldpath}/m2m_{sub_id}"
        simfoldpath = f"{subfoldpath}/simstandard/subject_volumes/Targets-0001_MagVenture_Cool-B70_scalar_"
        metricfile = f"{simfoldpath}{metric}.nii.gz"
        
        if this_hemi ==  'Left':
            file_paths = {
                'T1': f"{subfoldpath}/T1.nii",
                'lhV1': f"{subfoldpath}/lh.V1.nii.gz",
                'rhV1': f"{subfoldpath}/rh.V1.nii.gz",
            }
        else:
            file_paths = {
                'T1': f"{subfoldpath}/T1.nii",
                'lhV1': f"{subfoldpath}/rh.V1.nii.gz",
                'rhV1': f"{subfoldpath}/lh.V1.nii.gz",
            }
        # Extracting the metric data for the subject
        metric_data = load_nii_file(metricfile, file_paths['T1'])

        # Loading polar angle estimates from pRF analysis for each voxel
        if sub == 12 or sub == 26:
            funcFitpath = f"{subfoldpath}/RF_ss5_25mm-fFit.nii.gz"
        else:
            funcFitpath = f"{subfoldpath}/RF_ss5-fFit.nii.gz"
        funcFitdata = load_nii_file(funcFitpath, file_paths['T1'])

        # Removing voxels with low variance explained
        ve_thresh = 0.1
        bad_voxels = np.where(funcFitdata[:, :, :, 1] < ve_thresh)
        polmap_data = funcFitdata[:, :, :, 0]
        polmap_data[bad_voxels] = np.nan
        polmap_data = np.rad2deg(polmap_data)

        # Change the polar angle coordinate space to match the coordinate space used in behavior
        polmap_data[(polmap_data>=0) & (polmap_data<=180)] = -polmap_data[(polmap_data>=0) & (polmap_data<=180)]
        polmap_data[(polmap_data>180) & (polmap_data<360)] = 360-polmap_data[(polmap_data>180) & (polmap_data<360)]
        polmap_data_flat = polmap_data.flatten()
        
        # Extracting voxels from V1 for desired polarangles targetting only the bottom hemifield and estimating E-field
        # for ROI for each subject
        for roi_name, path in file_paths.items():
            if roi_name != 'T1':
                roi_data = load_nii_file(path, f"{subfoldpath}/T1.nii")
                old_sum = np.sum(roi_data)
                mask = np.ones_like(polmap_data, dtype=bool)
                if this_hemi ==  'Left':
                    if roi_name == 'lhV1':
                        mask &= (polmap_data <= 0) & (polmap_data >= -90)
                    else:
                        mask &= (polmap_data >= -180) & (polmap_data <= -90)
                else:
                    if roi_name == 'rhV1':
                        mask &= (polmap_data <= 0) & (polmap_data >= -90)
                    else:
                        mask &= (polmap_data >= -180) & (polmap_data <= -90)
                
                roi_data[~mask] = 0
                new_sum = np.sum(roi_data)
                if new_sum != old_sum:
                    print(f"    Sum of ROI {roi_name} changed from {old_sum} to {new_sum} for subject {sub_id}")
                efield_estim = calculate_Efield_from_mask(metric_data, roi_data)
                EfieldEstimArray[roi_name].append(efield_estim)

    means = {roi: np.mean(values) for roi, values in EfieldEstimArray.items()}
    std_errors = {roi: np.std(values) / np.sqrt(len(values)) for roi, values in EfieldEstimArray.items()}

    # Convert to pandas dataframe
    df_efieldestim = pd.DataFrame(EfieldEstimArray)
    df_efieldestim.to_csv(df_efield_fname, index=False)
else:
    df_efieldestim = pd.read_csv(df_efield_fname)
    EfieldEstimArray = df_efieldestim.to_dict(orient='list')
    means = {roi: np.mean(values) for roi, values in EfieldEstimArray.items()}
    std_errors = {roi: np.std(values) / np.sqrt(len(values)) for roi, values in EfieldEstimArray.items()}


################################### PLOTTING ###################################
plt.figure(figsize=(3, 6))
bar_width = 0.35
opacity = 0.8
lh_mean = EfieldEstimArray[f'lhV1']
rh_mean = EfieldEstimArray[f'rhV1']
lh_x = - bar_width/2
rh_x = lh_x + bar_width
plt.plot([lh_x + bar_width/2, rh_x + bar_width/2], [lh_mean, rh_mean], 'grey', linestyle='--', marker='o')

left_bars = plt.bar(0, means['lhV1'],
                   bar_width, alpha=opacity, color='b',
                   yerr=std_errors[f'lhV1'],
                   label='ipsi-TMS', error_kw={'elinewidth':2, 'capsize':5})

right_bars = plt.bar(bar_width, means['rhV1'],
                    bar_width, alpha=opacity, color='r',
                    yerr=std_errors['rhV1'],
                    label='contra-TMS', error_kw={'elinewidth':2, 'capsize':5})
plt.xlabel('ROI')
plt.ylabel('E (V/m)')
plt.title('Induced E-field by ROI')
plt.xticks([bar_width / 2], ['V1'])
plt.legend()
plt.ylim([0, max(means.values()) + max(std_errors.values()) * 3]) 
plt.tight_layout()
plt.ylim([0, 2.5])
plt.show()