# Replication Guide for: "Bridging or Breaking: Impact of Intergroup Interactions on Religious Polarization"  
**Authors:** Rochana Chaturvedi, Sugat Chaturvedi, Elena Zheleva  
**Updated:** February 18, 2024  

This document provides a guide to replicate the results and analyses in Chaturvedi et al. (2024) *"Bridging or Breaking: Impact of Intergroup Interactions on Religious Polarization"*. The files are divided into: code, data, and output folders. Please direct any questions about these files to Rochana Chaturvedi at [rchatu2@uic.edu](mailto:rchatu2@uic.edu).

**Note:** Personally identifiable information (PII) such as individual names and Twitter user identifiers have been removed from these replication files.

### Software Used:  
- Python 3.10.12 with Jupyter notebook on Google Colab  
- Stata/MP 17.0 for Windows (64-bit x86-64; Revision 14 Jun 2021)  

All Jupyter notebooks (containing Python code) are run on Google Colab. `ComputePolarization.ipynb` is run with GPU setting using Tesla T4 GPU with 12.67 GB RAM, CUDA Version: 11.8.0, cuDNN Version: 8.7.0.84, on Ubuntu 22.04.3 LTS system. *(Please note that GPU setting is optional but can help speed up embedding generation with sentence-transformers.)*

The Stata scripts have been run on Intel(R) Core(TM) i7-1065G7 CPU @ 1.30GHz x64-based processor with 16.0 GB RAM, 1 TB SSD running Windows 10 system.

All the package versions for Python are listed in the `requirements.txt` files installed from within the Colab notebooks.  
For Jupyter notebooks in Colab - mount the drive and run the first code block to install the dependencies. Thereafter restart the runtime from the runtime menu and execute the remaining code in order.

**Note:** For the replication code to work, it is important to have the respective data files. We cannot make the Twitter (recently renamed X) data public due to Twitter terms and conditions. We cannot make the `userid-religion` mapping public either due to ethical considerations. The code to generate this mapping is publicly available at [https://doi.org/10.7910/DVN/JOEVPN](https://doi.org/10.7910/DVN/JOEVPN).

The following is the directory tree structure for the replication folder with details:

---

## CODE FILES

---

### PREPARING DATA, TREATMENT EFFECT ESTIMATION, AND ANALYSES:
- **code**  
  - `requirements.txt`  
    - Files containing packages and versions required for the Python code (.ipynb). The notebooks include code and instructions to install the relevant dependencies.
  - `ComputePolarization.ipynb`  
    - Computes GCS, BOWGCS, Interact variable, Topic Modeling, Outcomes (change in GCS, Topics, and Emotions), and aggregates of all pre-treatment covariates.  
    - **Requires the following files from the `data/` folder:**  
      - `tweet_text.csv` with columns: `['id', 'text']`  
      - `tweet_level_data.csv` with columns: `['created_at', 'in_reply_to_user_id', 'user_id', 'id', 'valence_intensity', 'anger_intensity', 'fear_intensity', 'sadness_intensity', 'joy_intensity', 'user_friends_count', 'user_followers_count', 'retweet_count', 'user_created_at', 'muslim_score', 'muslim', 'reply', 'reply_muslim']`  
      - `final_clean_userid.csv` containing remaining user ids after filtering.  
    - **Generates the following important files in the `data/` folder:**  
      - `causal_data_<EVENT>_7_allcovariates_topics-7_merged.csv`  
      - `gcs.csv`  
      - `bow_gcs.csv`  
  - `TreatmentEffect.ipynb`  
    - Normalizes the covariates and runs metalearners using the specified base-learner (lasso/ridge/rf/etc.).  
    - **Requires the following files from the `data/` folder:**  
      - `causal_data_<EVENT>_7_allcovariates_topics-7_merged.csv`  
    - **Generates the following file in the `data/7_<baselearner>_7_merged` folder (first 7 refers to event window size, second refers to number of topics before merging, `<baselearner>` can be lasso etc.):**  
      - `stx_long.csv` (contains scaled covariates, individual treatment effect corresponding to each Event).  
  - `Analysis.ipynb`  
    - Computes Descriptive statistics for Appendix C Table 3, Figure 1, and Events Selection Table in Supplementary Appendix E, Table 4.  
    - **Requires the following files from the `data/` folder:**  
      - `gcs.csv`  
      - `bow_gcs.csv`  
      - `tweet_text.csv`  
      - `tweet_level_data.csv`  
      - `final_clean_userid.csv`  
      - `causal_data_<EVENT>_7_allcovariates_topics-7_merged.csv`  
    - **Generates the following files in the `data/` folder:**  
      - `gcs_avg_tweet_len_user-day.csv`  
      - `daily_polarization.csv`  
      - `descriptive_stats_7topics_merged_7.csv` (descriptive stats with averages)  
      - `descriptive_stats_sd_7topics_merged_7.csv` (standard deviations)  

  - `main.do`  
    - Runs all Stata scripts to generate figures and tables provided in script names below.  
  - `figure_2_5_6_7-16_table_2.do`  
  - `figure_3.do`  
  - `figure_4.do`  
