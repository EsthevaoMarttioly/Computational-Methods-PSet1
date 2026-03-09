########## Computational Methods - Problem Set 1 - Esthevao Marttioly ##########
#### Important: open the Rproject, instead of the script itself
rm(list = ls())       ## Be careful with this! It clears the environment

# renv::init()        ## Freeze the package version == just in the first time
# renv::snapshot()    ## Look the package version   == just in the first time
# renv::restore()     ## Restoring my versions      == run in the first time of a computer


# Set a seed for future replications
set.seed(20260307)


# Import Packages
# install.packages(c("readxl","tidyverse","ggplot2","gridExtra","stargazer","lubridate","latex2exp"))

library(readxl)
library(tidyverse)
library(ggplot2)
library(gridExtra)
library(stargazer)
library(lubridate)
library(latex2exp)


# Import data set
data_raw = read_excel("Mega-Sena.xlsx")


###### Save a theme for the graphs ######
mytheme = theme(legend.position = "bottom",
                plot.title = element_text(size = 12, face = "bold"),
                plot.subtitle = element_text(size = 10),
                panel.background = element_rect(fill = "transparent", colour = "black",
                                                linewidth = 0.5, linetype = "solid"),
                panel.grid.major.y = element_line(colour = "grey", linewidth = 0.5),
                panel.grid.minor.y = element_line(colour = "grey", linewidth = 0.5),
                panel.grid = element_line(colour = "grey98"),
                panel.grid.major.x = element_line(colour = "transparent"),
                panel.grid.minor.x = element_line(colour = "transparent"),
                axis.text = element_text(colour = "black", size = 9),
                strip.background = element_rect(fill = "grey95", colour = "black"),
                strip.text = element_text(colour = "black", size = 9))


####### Data set Cleaning #########

# Create a temporary data set
## Editing column names

data_temp = 
  data_raw[,c("Data do Sorteio",
              paste0(rep("Bola", 6), 1:6),
              "Arrecadação Total", "Estimativa prêmio",
              paste("Ganhadores", 6:4, "acertos"),
              paste("Rateio", 6:4, "acertos"))] %>%
  `colnames<-`(c("Date",
                 paste0(rep("Ball", 6), 1:6),
                 "Revenue", "Prize",
                 paste0("G", 6:4),
                 paste0("Y", 6:4)))


## Formatting date as date

data_temp$Date = as.Date(data_temp$Date,      # Formatting Date
                         format = "%d/%m/%Y")
data_temp$Prize = lag(data_temp$Prize)        # Prize Announced = Estimated Prize(-1)

data_temp = data_temp %>%                     # Filtering Date > Jun-2009
  filter(Date >= "2009-06-01", Revenue > 0)   # Filtering Revenue > 0


## Clean monetary values

clean_money <- function(x) {
  x = gsub("R\\$\\s*", "", x)  # remove R$
  x = gsub("\\.", "", x)       # remove thousand separators
  x = gsub(",", ".", x)        # convert decimal comma
  as.numeric(x)
} 

data_temp = data_temp %>%
  mutate(across(c(Revenue, Prize, Y6, Y5, Y4),
                clean_money))


## Ticket's Price

data_temp = data_temp %>%
  mutate(ticket_price =
           case_when(Date < ymd("2014-05-10") ~ 1.0,
                     Date < ymd("2015-05-24") ~ 2.5,
                     Date < ymd("2019-11-10") ~ 3.5,
                     Date < ymd("2023-05-03") ~ 4.5,
                     Date < ymd("2025-07-09") ~ 5.0, TRUE ~ 6.0))

data = data_temp


####### (a) Relationship between Prize and Revenue #########

reg1 = lm(log(Revenue) ~ log(Prize), data)   ## Log-regression to see the relationship

summary(reg1)   # Summary the regression
stargazer(reg1, font.size = "footnotesize")  ## Latex-pattern
reg1$coef[2]    # Elasticity = 0.40


# Graphics

data %>%
  ggplot(aes(x = log(Prize), y = log(Revenue))) + mytheme +
  geom_point(size = 1, colour = "#85C0F9") +
  geom_smooth(method = "lm", se = FALSE, colour = "#0F2080") +  # lm(y ~ x)
  geom_smooth(method = "lm", se = FALSE, colour = "#A95AA1",    # lm(y ~ x + x^2)
              formula = y ~ x + I(x^2)) +
  labs(title = "Revenue Collected v.s. Annouunced Prize")


ggsave("output/revenue_prize.pdf", width = 5, height = 4)   ## Save the graph into pdf
ggsave("output/revenue_prize.png", width = 5, height = 4)   ## Save the graph into png


####### (b) Number of individuals participating #########

data = data %>%
  mutate(N = round(Revenue / ticket_price))


####### (c) Expected prize #########

data = data %>%
  mutate(Expected_Prize = (G6*Y6 + G5*Y5 + G4*Y4) / N)


####### (d) Return of buying the ticket #########

data = data %>%
  mutate(Return = Expected_Prize / ticket_price)


####### (e) Average Return #########

# Cutting the Prize bins for each 50 units

bin_return = data %>%
  mutate(prize_bin = cut(Prize, 50)) %>%
  group_by(prize_bin) %>%
  summarise(avg_return = mean(Return, na.rm = T), 
            avg_prize = mean(Prize, na.rm = T),
            n = n())


bin_return %>%
  ggplot(aes(x = avg_prize / 10e6, y = avg_return)) +
  geom_point(color = "#0F2080", size = 2) + mytheme +
  geom_line(color = "#0F2080", linewidth = 0.8) +
  labs(x = "Announced Prize (in millions)",
       y = TeX("Average Return $E[Y_j / p_j | P_j]$"),
       title = "Expected Return vs Announced Prize")

ggsave("output/expected_return_bins.pdf", width = 5, height = 4)   ## Save the graph into pdf
ggsave("output/expected_return_bins.png", width = 5, height = 4)   ## Save the graph into png


# Parametric Model

reg2 = lm(Return ~ Prize + I(Prize^2), data)
summary(reg2)


data %>%
  ggplot(aes(x = Prize / 10e6, y = Return)) +
  geom_point(alpha = 0.2) + mytheme +
  geom_smooth(method = "lm", color = "#A95AA1",
              formula = y ~ x + I(x^2)) +
  labs(x = "Announced Prize (in millions)",
       y = TeX("Average Return $E[Y_j / p_j | P_j]$"),
       title = "Estimated Return as Function of Prize")

ggsave("output/expected_return_parametric.pdf", width = 5, height = 4)   ## Save the graph into pdf
ggsave("output/expected_return_parametric.png", width = 5, height = 4)   ## Save the graph into png




