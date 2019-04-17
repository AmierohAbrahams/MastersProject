library(ggplot2)
# library(extrafont)
# loadfonts(device = "pdf", quiet = FALSE)

# make a custom theme
theme_set(theme_bw())
bw_update <- theme_bw() +
  theme(panel.border = element_rect(size = 1.0),
        # panel.grid.major = element_line(colour = "black", size = 0.2, linetype = 2),
        panel.grid.major = element_line(colour = NA),
        panel.grid.minor = element_line(colour = NA),
        axis.title = element_text(size = 12, face = "bold"),
        axis.text = element_text(size = 12, colour = "black"),
        plot.title = element_text(size = 12, hjust = 0),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 10),
        legend.key = element_rect(size = 0.8, colour = NA),
        strip.background = element_rect(colour = NA, fill = NA),
        strip.text = element_text(size = 10))
# theme_set(bw_update) # Set theme

theme_set(theme_bw())
bw_update2 <- theme_bw() +
  theme(panel.border = element_rect(size = 1.0),
        panel.grid.major = element_line(colour = "black", size = 0.2, linetype = 2),
        panel.grid.minor = element_line(colour = NA),
        axis.title = element_text(size = 12, face = "bold"),
        axis.text = element_text(size = 12, colour = "black"),
        plot.title = element_text(size = 12, hjust = 0),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 10),
        legend.key = element_rect(size = 0.8, colour = NA),
        legend.background = element_blank(),
        strip.background = element_rect(colour = NA, fill = NA),
        strip.text = element_text(size = 10))
theme_set(bw_update2) # Set theme

theme_set(theme_grey())
grey_update <- theme_grey() +
  theme(#panel.border = element_rect(colour = "black", fill = NA, size = 1.0),
        panel.grid.major = element_line(size = 0.2, linetype = 2),
        panel.grid.minor = element_line(colour = NA),
        axis.title = element_text(size = 12, face = "bold"),
        axis.text = element_text(size = 12, colour = "black"),
        plot.title = element_text(size = 12, hjust = 0),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 10),
        legend.key = element_rect(size = 0.8, colour = NA),
        legend.background = element_blank())
# theme_set(grey_update) # Set theme

theme_set(theme_grey())
grey_update2 <- theme_grey() +
  theme(#panel.border = element_rect(colour = "black", fill = NA, size = 1.0),
    panel.grid.major = element_line(size = 0.2, linetype = 2),
    panel.grid.minor = element_line(colour = NA))
# theme_set(grey_update2) # Set theme
