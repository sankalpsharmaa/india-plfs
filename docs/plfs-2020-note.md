## Notes from processing PLFS 2020 Microdata

1. New variables on migration and duration spells of unemployment added - need to add corresponding labels to processing script.

2. The individual recode contains 413405 observations. This will not correspond to official [counts]([url](https://pib.gov.in/PressReleaseIframePage.aspx?PRID=1833855)) because this includes 2587 temporary visitors. 

To check the total count for temporary visitors in Stata, run `count if per_sn >= 81`.These observations need to be omitted to replicate official statistics from the microdata. 

## Validation

I check some basic figures to ensure that the processing was correct [TODO: automate quality checks]

### Labour force participation rates

#### Estimated
![image](https://user-images.githubusercontent.com/41304604/177514596-7614d8d4-078e-4b02-9cda-8ffff228761b.png)

![image](https://user-images.githubusercontent.com/41304604/177515278-eee76a91-d63c-4717-95eb-8a12002dfa51.png)

#### Official
![image](https://user-images.githubusercontent.com/41304604/177515954-382fcf90-7d79-4ad5-98da-c06114492ca9.png)

### Migration Rates

#### Estimated
![image](https://user-images.githubusercontent.com/41304604/177515613-14b0441a-fb35-4b1d-91b8-1d868089425f.png)

![image](https://user-images.githubusercontent.com/41304604/177515896-7c6b8f42-c4f3-4fe7-a1ea-9b6a755858b1.png)

#### Official
![image](https://user-images.githubusercontent.com/41304604/177515700-333524e8-f09f-4ae6-ab93-9e1b4ce036ec.png)


### Employment Rates

![image](https://user-images.githubusercontent.com/41304604/177515131-79415b37-b3a3-4a23-8445-7bffbb68932c.png)
