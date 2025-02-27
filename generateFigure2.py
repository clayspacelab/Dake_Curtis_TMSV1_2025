import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

def calculate_mean_and_se_abs(group, error_metric):
    group[error_metric] = np.abs(group[error_metric])
    mean = group[error_metric].mean()
    se = group[error_metric].std()
    return pd.Series({'mean': mean, 'se': se})

# Load the data
rootDir = '/d/DATD/datd/MD_TMS_EEG/OSF_data/behavioralData'
df = pd.read_csv(f"{rootDir}/behavioralData_allsubs.csv")
nsubs = df['subjID'].nunique()

## Creating behavioral figure 
metric = 'isacc_peakvel'
metric_df = f"{rootDir}/{metric}.csv"

if not os.path.exists(metric_df):
    # Days 1,2,3 refer to experiment 1 and days 4,5 refer to experiment 2
    conds_all5 = {
        'No TMS': df[(df['TMS_condition'] == 'No TMS')  & (df['day'].isin([1, 2, 3]))],
        'mid inPF': df[(df['TMS_condition'] == 'TMS intoVF') & (df['day'].isin([1, 2, 3]))],
        'mid outPF': df[(df['TMS_condition'] == 'TMS outVF') & (df['day'].isin([1, 2, 3]))],
        'early inPF': df[(df['TMS_condition'] == 'TMS intoVF') & (df['day'] == 4)],
        'early outPF': df[(df['TMS_condition'] == 'TMS outVF') & (df['day'] == 4)],
        'midrep inPF': df[(df['TMS_condition'] == 'TMS intoVF') & (df['day'] == 5)],
        'midrep outPF': df[(df['TMS_condition'] == 'TMS outVF') & (df['day'] == 5)],
    }

    if metric == 'ierr':
        y_range = [0, 3]
    elif metric == 'isacc_rt':
        y_range = [0, 0.6]
    elif metric == 'isacc_peakvel':
        y_range = [0, 600]

    results_all5 = {cond: data.groupby('subjID').apply(calculate_mean_and_se_abs, error_metric=metric) for cond, data in conds_all5.items()}
    combined_all5 = pd.concat(results_all5, names=['Condition']).reset_index()
    # if condition = 'no tms' or 'mid inPF' or 'mid outPF' then exp = 1
    # if condition = 'early inPF' or 'early outPF' or 'midrep inPF' or 'midrep outPF' then exp = 2
    combined_all5['exp'] = combined_all5['Condition'].apply(lambda x: 1 if x in ['No TMS', 'mid inPF', 'mid outPF'] else 2)
    combined_all5.to_csv(metric_df, index=False)
else:
    combined_all5 = pd.read_csv(metric_df)

# Plotting
f, axs = plt.subplots(1, 2, figsize=(10, 5))
sns.barplot(data=combined_all5[combined_all5['exp']==1], x='Condition', y='mean', errorbar='se', color='grey', capsize=.2, ax=axs[0])
sns.stripplot(data=combined_all5[combined_all5['exp']==1], x='Condition', y='mean', color="blue", alpha = 1, jitter=False, size=6, ax=axs[0])
axs[0].set_title('Experiment 1')
axs[0].set_ylabel(f'Mean {metric}')
axs[0].set_xlabel('Condition')
axs[0].set_xticks([0, 1, 2])
axs[0].set_xticklabels(['No TMS', 'Middle inPF', 'Middle outPF'], rotation=45)

sns.barplot(data=combined_all5[combined_all5['exp']==2], x='Condition', y='mean', errorbar='se', color='grey', capsize=.2, ax=axs[1])
sns.stripplot(data=combined_all5[combined_all5['exp']==2], x='Condition', y='mean', color="blue", alpha = 1, jitter=False, size=6, ax=axs[1])
axs[1].set_title('Experiment 2')
axs[1].set_ylabel(f'Mean {metric}')
axs[1].set_xlabel('Condition')
axs[1].set_xticks([0, 1, 2, 3])
axs[1].set_xticklabels(['Early inPF', 'Early outPF', 'Middle inPF', 'Middle outPF'], rotation=45)
plt.tight_layout()
plt.show()
