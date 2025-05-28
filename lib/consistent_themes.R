# Consistent themes and 
theme_bw_me <- theme(panel.background = element_rect(fill = "white",colour = NA), panel.grid = element_blank(), 
                     strip.background = element_rect(fill = "white",colour = "black"),
                     panel.grid.major = element_blank(),
                     panel.grid.minor = element_blank(),
                     axis.line = element_line(colour = "black"),legend.position = "bottom") 
# Figure 2
prolonged_colonization_scale <- scale_fill_manual(breaks = c(1,0),values = c("#00274C","#FFCB05"),labels = c("Yes","No"),name="Prolonged Colonization") 

figure_2_format <- theme(legend.position = "bottom",
                           axis.text =   element_text(size=18, color="black"),
                           axis.title = element_text(size = 22, color="black"),
                           legend.text =   element_text(size=20, color="black"),
                           legend.title = element_text(size = 22, color="black"),
                           plot.title = element_text(size = 24, color="black"),
                           axis.text.x = element_text(angle=90)
)

# Figure 3
figure_3_format <- theme(axis.text =   element_text(size=10, color="black"),
                         axis.title = element_text(size = 12, color="black"),
                         axis.text.x = element_text(angle=90)
)


# Supplemental Figure 1
pairtype_fill <- scale_fill_manual(breaks=c(T,F),values = c('#FFCB05','#00274C'),labels = c("Intra-patient",'Inter-patient'), name="Type", guide = guide_legend(nrow=1, title.position = "top", label.position = "right"))

s_figure_1_format <- theme(legend.position = "bottom",
                axis.text =   element_text(size=12, color="black"),
                axis.title = element_text(size = 14, color="black"),
                legend.text =   element_text(size=12, color="black"),
                legend.title = element_text(size = 14, color="black"),
                plot.title = element_text(size = 24, color="black")
)
s_figure_1_inset_format <- theme(legend.position = "none",
                           axis.text =   element_text(size=12, color="black"),
                           axis.title = element_text(size = 14, color="black"),
                           legend.text =   element_text(size=20, color="black"),
                           legend.title = element_text(size = 22, color="black"))

# Favorite kable
favorite_kable <- function (x) {
  x %>% kable(., format = "html", table.attr = "style='width:100%;'", 
              row.names = F) %>% kable_styling(bootstrap_options = c("striped", 
                                                                     "hover", "condensed", "responsive"))
}