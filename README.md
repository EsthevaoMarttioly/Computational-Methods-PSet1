# Mega-Sena Expected Return Analysis

This project was developed for Computational Methods in Economics — Problem Set 1.
The objective is to compute the expected return of buying a Mega-Sena lottery ticket conditional on the announced prize.

The analysis uses historical data on all Mega-Sena draws published by [Caixa Econômica Federal](https://loterias.caixa.gov.br/Paginas/Mega-Sena.aspx).
To download, click on "Download de resultados" and then "Resultados da Mega-Sena por ordem crescente." Place the file in the project root folder.

The project is written in R, structured to ensure reproducibility, and outputs figures used in the final report.

## Project Structure

EsthevaoMarttioly_PSet1/

output/

renv/

.RData

.Rhistory

.Rprofile

EsthevaoMarttioly_PSet1.R

EsthevaoMarttioly_PSet1.Rproj

Mega-Sena.xlsx

EsthevaoMarttioly_PSet1.pdf

README.md

## Reproducibility

Certificate yourself that you open directly the .Rproj file.

To reproduce the environment:
renv::restore()

If needed, you can install packages using:

install.packages(c(
"renv","readxl","tidyverse","ggplot2",
"gridExtra","stargazer","lubridate","latex2exp"
))

## Ticket Price Data

The Mega-Sena dataset does not include the price of a ticket.

Ticket prices were obtained from the following data visualization project:

[(https://graficos.poder360.com.br/PEXGE/1/)](https://graficos.poder360.com.br/PEXGE/1/)

This source compiles historical changes in the price of a Mega-Sena ticket.

Using this information, a ticket price variable is constructed in the script based on the draw date.

## Running the project

To reproduce the analysis:

Download the dataset and place it in the project folder as Mega-Sena.xlsx

* Open the file: EsthevaoMarttioly_PSet1.Rproj
* Restore package versions: renv::restore()
* Run the script: EsthevaoMarttioly_PSet1.R
* Output: The script generates the following figures in the output/ folder:
  * revenue_prize.pdf
  * expected_return_bins.pdf
  * expected_return_parametric.pdf




