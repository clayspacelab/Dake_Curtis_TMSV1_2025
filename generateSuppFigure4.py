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
df = pd.read_csv('controlResults.csv')
nsubs = df['subjID'].nunique()

controlErrFile = 'controlErr.csv'

if not os.path.exists(controlErrFile):

    ## Creating behavioral figure 
    errHolder = np.empty((nsubs, 2)) # 0 = distractorOut, 1 = distractorIn
    for i, sub in enumerate(df['subjID'].unique()):
        sub_data = df[df['subjID'] == sub]
        nodistractorData = sub_data[((sub_data['distractorHemi'] == 0) & (sub_data['instimVF'] == 0) | 
                                    (sub_data['distractorHemi'] == 1) & (sub_data['instimVF'] == 1))]
        distractorData = sub_data[((sub_data['distractorHemi'] == 0) & (sub_data['instimVF'] == 1) | 
                                (sub_data['distractorHemi'] == 1) & (sub_data['instimVF'] == 0))]
        errHolder[i, 0] = distractorData['ierr'].mean()
        errHolder[i, 1] = nodistractorData['ierr'].mean()

    df_errHolder = pd.DataFrame(errHolder, columns=['distractorContra', 'distractorIpsi'])
    df_errHolder.to_csv(controlErrFile, index=False)
else:
    df_errHolder = pd.read_csv(controlErrFile)
    errHolder = df_errHolder.to_numpy()

plt.figure(figsize=(3, 6))
sns.barplot(data=errHolder, palette='viridis')
sns.stripplot(data=errHolder, color="blue", alpha = 1, jitter=False, size=6)
plt.ylabel('Mean Error (deg)')
plt.xticks([0, 1], ['Contra', 'Ipsi'])
plt.show()