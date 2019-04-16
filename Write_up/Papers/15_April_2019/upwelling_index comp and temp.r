#Script to plot upwelling indices based on Widguru and SAWS wind data
#upwelling index from Fielding and Davis 1989 paper
#Updated: April 2019


#upwelling index data visualisation

setwd("~/Research/Data & Analyses/Upwelling Index")

library(tidyverse)
library(gridExtra)

UI <- read.csv("upwelling.csv")

#upwelling index calculated for data from one time (8am) each day

head(UI) #just added this so that you can see what the data looks like
#Date Day Temp   WG SAWS
#01-Jan   1   12  7.8  6.3
#02-Jan   2   12  5.7  3.2
#03-Jan   3   11 11.4  7.5
#04-Jan   4   10  8.8  5.4
#05-Jan   5   10  9.4  5.7
#06-Jan   6   10 10.0  9.6


#add condition variable

UI <- UI %>% mutate(WG.condition = ifelse(WG > 0, "upwelling", "downwelling")) %>% 
        mutate(SAWS.condition = ifelse(SAWS > 0, "upwelling", "downwelling")) %>% 
        mutate(ui.diff = WG - SAWS)

#==============================================================================================

#Windguru Data

ggplot(UI, aes(x=Day, y=WG)) +
  geom_area(aes(fill=WG.condition)) +
  geom_line() +
  geom_hline(yintercept=0)

interp <- approx(UI$Day, UI$WG, n=100000)
interp2 <- approx(UI$Day, UI$Temp, n=100000)

UIi <- data.frame(Day=interp$x, Index=interp$y, Temp = interp2$y)
UIi$WG_condition[UIi$Index >= 0] <- "upwelling"
UIi$WG_condition[UIi$Index < 0] <- "downwelling"

index_plot_wg <- ggplot(UIi, aes(x=Day, y=Index)) +
                  theme_bw() +
                  geom_area(aes(fill=WG_condition), alpha = .4) +
                  geom_line() +
                  geom_hline(yintercept=0) +
                  annotate("text", x = 300, y = -20, label = "WindGuru Data") +
                  #geom_vline(xintercept = c(116, 117, 133, 134, 244, 291), lty = 2, lwd = 1) +
                  scale_fill_manual(values=c("salmon", "steelblue")) +
                  scale_x_continuous(expand=c(0, 0)) +
                  scale_y_reverse() +
                  labs(y= "Upwelling Index") +
                  guides(fill=guide_legend(title="Condition"))

index_plot_wg

#--------------------------------------------------------------------------------

#SAWS data

ggplot(UI, aes(x=Day, y=SAWS)) +
  geom_area(aes(fill=SAWS.condition)) +
  geom_line() +
  geom_hline(yintercept=0)

interp <- approx(UI$Day, UI$SAWS, n=100000)
interp2 <- approx(UI$Day, UI$Temp, n=100000)

UIi <- data.frame(Day=interp$x, Index=interp$y, Temp = interp2$y)
UIi$SAWS_condition[UIi$Index >= 0] <- "upwelling"
UIi$SAWS_condition[UIi$Index < 0] <- "downwelling"

index_plot_saws <- ggplot(UIi, aes(x=Day, y=Index)) +
                      geom_area(aes(fill=SAWS_condition), alpha = .4) +
                      geom_line() +
                      geom_hline(yintercept=0) +
                      theme_bw() +
                      annotate("text", x = 300, y = -20, label = "SAWS Data") +
                      #geom_vline(xintercept = c(116, 117, 133, 134, 244, 291), lty = 2, lwd = 1) +
                      scale_fill_manual(values=c("salmon", "steelblue")) +
                      scale_x_continuous(expand=c(0, 0)) +
                      scale_y_reverse() +
                      labs(y= "Upwelling Index") +
                      guides(fill=guide_legend(title="Condition"))

index_plot_saws

#-----------------------------------------------------------------------------------------

#plotting the difference between WG and SAWS - work in progress

ggplot(UI, aes(x=Day, y=ui.diff)) +
  geom_line() +
  geom_hline(yintercept=0)



#-----------------------------------------------------------------------------------------

#adding in-situ temp data (SACTN)

combined_plot_wg <- index_plot_wg + geom_line(aes(x=Day, y = Temp, colour = "SACTN")) +
  scale_y_continuous(sec.axis = sec_axis(~.*1, name = "Temperature [°C]")) +
  scale_colour_manual(values=c("red")) +
  labs(colour = "Temperature [°C]")

combined_plot_wg

ggsave(filename = "upwelling_index WG.png", combined_plot_wg, device = "png",
       scale = 1, width = 280, height = 200, units = "mm",
       dpi = 300, limitsize = TRUE, bg = "white", pointsize = 10)


combined_plot_saws <- index_plot_saws + geom_line(aes(x=Day, y = Temp, colour = "SACTN")) +
  scale_y_continuous(sec.axis = sec_axis(~.*1, name = "Temperature [°C]")) +
  scale_colour_manual(values=c("red")) +
  labs(colour = "Temperature [°C]")

combined_plot_saws

ggsave(filename = "upwelling_index SAWS.png", combined_plot_saws, device = "png",
       scale = 1, width = 280, height = 200, units = "mm",
       dpi = 300, limitsize = TRUE, bg = "white", pointsize = 10)
#------------------------------------------------------------------------------------------

#plots of the two upwelling indices

upwelling_indices <- grid.arrange(index_plot_wg, index_plot_saws, ncol = 1)

#png

ggsave(filename = "upwelling_indices.png", upwelling_indices, device = "png",
       scale = 1, width = 200, height = 280, units = "mm",
       dpi = 300, limitsize = TRUE, bg = "white", pointsize = 10)

#pdf

ggsave(filename = "upwelling_indices.pdf", upwelling_indices, device = "pdf",
       scale = 1, width = 200, height = 280, units = "mm",
       dpi = 300, limitsize = TRUE, bg = "white", pointsize = 10)

ggsave(filename = "upwelling_indices2.pdf", upwelling_indices, device = "pdf",
       scale = 1, width = 290, height = 210, units = "mm",
       dpi = 300, limitsize = TRUE, bg = "white", pointsize = 10)
