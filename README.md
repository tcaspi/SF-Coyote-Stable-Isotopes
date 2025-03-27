# SF-Coyote-Stable-Isotopes

This repository contains all raw data, plots and scripts for the data analysis implemented in Caspi et al. (2025) (In Preparation) titled: *Urbanization facilitates intrapopulation niche diversity in a generalist carnivore* and published in XXXXX.

Please find below a description of all raw and clean data sets and the scripts used to clean the raw data, run the models, and create the figures presented in the manuscript.

## Data files

In the `Data` folder, you will find a number of files:

> `20240102_data.csv`; `20240910_data.csv`; and `pilot_and_20231003.csv`: csv files containing the raw isotopic data.

| Column     | Description                                                |
|------------|------------------------------------------------------------|
| SampleID   | Label for whisker segment                                  |
| C_raw      | Raw d13C value                                             |
| N_raw      | Raw d15N values                                            |
| C_total    | Total C                                                    |
| N_total    | Total N                                                    |
| individual | Identifier for individual coyote                           |
| whisker    | Identifier for whisker                                     |
| tray       | Tray number sample was processed on                        |
| duplicate  | Indicates whether or not the whisker is a duplicate sample |

> `prey_data_si.csv`: csv file containing the raw isotopic data for dietary sources.

| Column   | Description                         |
|----------|-------------------------------------|
| SampleID | Label for sample                    |
| d13C     | Raw d13C value                      |
| TotalC   | Total C                             |
| d15N     | Raw d15N value                      |
| TotalN   | Total N                             |
| tray     | Tray number sample was processed on |
| well     | Well sample was processed in        |
| material | Tissue type (hair, feather, etc.)   |
| species  | Species sample came from            |

> `fastfood_si.csv`: csv file containing raw data for chicken and beef samples from San Francisco taken from A.H. Jahren & R.A. Kraft, Carbon and nitrogen stable isotopes in fast food: Signatures of corn and confinement, Proc. Natl. Acad. Sci. U.S.A. 105 (46) 17855-17860, <https://doi.org/10.1073/pnas.0809870105> (2008).

| Column   | Description                |
|----------|----------------------------|
| SampleID | Label for sample           |
| species  | Food type: chicken or beef |
| d13C     | Raw d13C value             |
| d15N     | Raw d15N value             |

> `whisker_metadata.csv`: csv file containing metadata for whisker samples.

| Column         | Description                                                                                                                                                                                                                                                                                                            |
|----------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| whisker        | Label for sample                                                                                                                                                                                                                                                                                                       |
| date_clean     | Date sample was rinsed                                                                                                                                                                                                                                                                                                 |
| date_chopped   | Date sample was chopped                                                                                                                                                                                                                                                                                                |
| initials       | Initials of person preparing sample                                                                                                                                                                                                                                                                                    |
| tray           | Tray number sample was processed on                                                                                                                                                                                                                                                                                    |
| storage        | Storage form for whisker                                                                                                                                                                                                                                                                                               |
| urban          | Region (San Francisco = urban; Marin County = nonurban)                                                                                                                                                                                                                                                                |
| FieldID        | Label of sample as identified in the field                                                                                                                                                                                                                                                                             |
| site           | Location sample was collected                                                                                                                                                                                                                                                                                          |
| lat            | Latitude of sample location                                                                                                                                                                                                                                                                                            |
| long           | Longitude of sample location                                                                                                                                                                                                                                                                                           |
| year           | Year sample was collected                                                                                                                                                                                                                                                                                              |
| date.collected | Day sample was collected                                                                                                                                                                                                                                                                                               |
| age            | Estimated age of coyote during sample collection                                                                                                                                                                                                                                                                       |
| sex            | Sex of coyote                                                                                                                                                                                                                                                                                                          |
| dead           | Sample collection type: roadkill = coyote killed by vehicle strike; sick.euth = coyote euthanized for medical reasons; live cap = live capture; euthanized = coyote lethally removed by wildlife officials for aggression; sick.release = sick coyote treated and released; unknown = no information on cause of death |

> `individual_ids.csv`

| Column     | Description                                                               |
|------------|---------------------------------------------------------------------------|
| individual | Individual coyote labels that match up with whisker data                  |
| sfcoy      | Unique name for each individual identified by genotyping in San Francisco |
| sex        | Sex as identified by genotyping                                           |
| group      | Family group assignment                                                   |

> `territory_covs.csv`

| Column           | Description                                                 |
|------------------|-------------------------------------------------------------|
| group            | Coyote family group/territory                               |
| lat              | Location of territory center point - latitude               |
| long             | Location of territory center point - longitude              |
| ISA              | Percent of territory classified as impervious surface cover |
| Urban            | Percent of territory classified as urban land cover         |
| Food.Services    | Number of food services in territory                        |
| Pop.Den.2020     | Mean human population density in territory                  |
| Housing.Den.2020 | Mean housing density in territory                           |

## Scripts

The scripts for the full workflow are available as R and Rmd files in the `Code` folder. All files are R scripts that were run in R version 4.2.1. The output of the models are not stored on github due to the large file sizes, but can be generated on your own device, or are available on Dryad Digital Repository (doi: XXXX).

-   `Sample_Collection_Map.R`: this script generates a study site map indicating where samples were collected.

-   `Clean_Data.Rmd`: this script takes the raw isotope data and creates cleaned data frames that can be used in data visualization and analysis. The script also calculates some basic summary statistics presented in the manuscript.

-   `Isotope_Biplots.Rmd`: this script generates the isotope biplots presented in the manuscript.

-   `SIBER.Rmd`: this script uses the *SIBER* package to calculate Bayesian-based standard ellipse areas.

-   `RInSp.Rmd`: this script uses the *RInSp* package to calculate niche components and the WIC/TNW index of individual dietary specialization.

-   `DHGLMs.Rmd`: this script uses the *brms* package to construct double-hierarchical generalized linear models that assess the effect of sex and region on among-individual differences in isotopic means and variances.

-   `GLMMs.Rmd`: this script uses the *brms* package to construct generalized linear mixed-effect models that assess effect of impervious surface cover on d13C and d15N values.

-   `Mixing_Models.Rmd`: this script uses the *MixSIAR* package to construct Bayesian-based stable isotope mixing models to estimate mean proportions of different dietary sources. These models are computationally intensive and take a long time to run. Thus, it is recommended to run them on an HPC cluster rather than on a personal laptop.

## Clean data

In the `Cleaned_Data` folder, you will find a number of cleaned up files that are generated within the R scripts described above.

Cleaned raw data:

> -   `cleaned_whiskerdata.csv`: output of `Clean_Data.Rmd` script
>
> -   `averaged_whiskerdata.csv`: output of `Clean_Data.Rmd` script

For MixSIAR models:

> -   `coyote_consumer_avgs.csv`: generated as an intermediate file in the `Mixing_Models.Rmd` script for the six-source mixing model.
>
> -   `coyote_source.csv`: generated as an intermediate file in the `Mixing_Models.Rmd` script for the six-source mixing model.
>
> -   `coyote_discrimination.csv`: generated as an intermediate file in the `Mixing_Models.Rmd` script for the six-source mixing model.

> -   `coyote_consumer_isa.csv`: generated as an intermediate file in the `Mixing_Models.Rmd` script for the three-source mixing model.
>
> -   `coyote_source_three.csv`: generated as an intermediate file in the `Mixing_Models.Rmd` script for the three-source mixing model.
>
> -   `coyote_discrimination_three.csv`: generated as an intermediate file in the `Mixing_Models.Rmd` script for the three-source mixing model.

## Model output

The output of the models are not stored on GitHub in the `Model_Output` folder due to the large file sizes, but can be generated on your own device, or are available on Dryad Digital Repository (doi: XXXX). The `.rds` that can be downloaded from Dryad are described below.

-   <div>

    Stable isotope mixing models:

    > `jags.full.rds`: model output for the six-source, categorical effect Bayesian-based stable isotope mixing model. This file is generated in the `Mixing_Models.Rmd` script.
    >
    > `jags.ISA.rds`: model output for the three-source, continuous effect Bayesian-based stable isotope mixing model. This file is generated in the `Mixing_Models.Rmd` script.

    </div>

-   <div>

    Generalized linear mixed-effect models:

    > `glmm_C_skew.rds`: model output for the effect of impervious surface cover on d13C. This file is generated in the `GLMMs.Rmd` script.
    >
    > `glmm_N_skew.rds`: model output for the effect of impervious surface cover on d15CN This file is generated in the `GLMMs.Rmd` script.

    </div>

-   <div>

    Double-hierarchical generalized linear models:

    > `dhglm_C_skew.rds`: model output for the d13C DHGLM. This file is generated in the `DHGLMs.Rmd` script.
    >
    > `dhglm_N_skew.rds`: model output for the d13C DHGLM. This file is generated in the `DHGLMs.Rmd` script.

    </div>

## Figures

In the folder `Figures` you will find `.png` files for figures in the manuscript, which are generated by the scripts above.
