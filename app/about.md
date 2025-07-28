The aim of this dashboard is to explore the metadata of FunBioDiv datasets. You can select the dataset based on **diversification measures**, measured **response variables** (either pest or natural enemies - NE), or other covariates.

#### Diversification measures

Diversification measures used for the experimental design in primary studies, i.e. used as a structuring variable for the experimental design.


| Name               | Description                                            |
| -------------------| ------------------------------------------------------ |
| `service_plant`    | Service plant                                          |
| `cultivar_mixture` | Cultivar mixture                                       |
| `intercropping`    | Intercropping                                          |
| `cover_crop`       | Cover crop                                             |
| `agroforestry`     | Agroforestry                                           |
| `crop_rotation`    | Crop rotation at the field scale                       |
| `natural_habitats` | Amount of semi-natural habitats at the landscape scale |
| `crop_diversity`   | Crop diversity at the landscape scale                  |



#### Response variables

You can select datasets that measured the presence of Pest (`Resp_pest`) and/or of Natural Enemies (`Resp_NE`).



#### Other covariates

You can select other covariates from the study design characteristics.

| Name             | Description                                            |
| ---------------- | ------------------------------------------------------ |
| `Crop.type`      | Crop type, either `annual`, `perennial`, or `both`     |
| `Organic`        | Organic farming as structuring or measured variable.   |
| `Tillage`        | Tillage as as structuring or measured variable         |
| `N_qty`          | Nitrogen applied as structuring or measured variable   |
| `TFI`            | Treatment frequency index as structuring or measured variable    |
| `Yield`          | Yield as structuring or measured variable                        |




## About Funbiodiv


The [**FunBioDiv** project](https://www.fondationbiodiversite.fr/en/the-frb-in-action/programs-and-projects/le-cesab/funbiodiv/) assesses the impact of combining plant diversification strategies at different spatial and temporal scales on biodiversity and the control of crop pests.  

The research project **FunBioDiv** was selected from the [2023 FRB-MTE-OFB "Antropogenic pressures and impacts on terrestrial biodiversity](https://www.fondationbiodiversite.fr/en/calls/appel-a-projets-frb-mte-ofb-2023-pressions-anthropiques-et-impacts-sur-la-biodiversite-terrestre/).  


This is a beta version with non tested functionality and incomplete metadata. Source code is available on [Github](https://github.com/FRBCesab/shinyFunBioDiv)

<!-- badges: start -->
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![Lifecycle Experimental](https://img.shields.io/badge/Lifecycle-Experimental-339999)
<!-- badges: end -->
