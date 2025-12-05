# Consistent themes and 
theme_bw_me <- theme(panel.background = element_rect(fill = "white",colour = NA), panel.grid = element_blank(), 
                     strip.background = element_rect(fill = "white",colour = "black"),
                     panel.grid.major = element_blank(),
                     panel.grid.minor = element_blank(),
                     axis.line = element_line(colour = "black"),
                     legend.position = "bottom") 
# Figure 1
prolonged_colonization_scale <- scale_fill_manual(breaks = c(1,0),values = c("#00274C","#FFCB05"),labels = c("Yes","No"),name="Prolonged Colonization") 

figure_1_format <- theme(legend.position = "bottom",
                           axis.text =   element_text(size=18, color="black"),
                           axis.title = element_text(size = 22, color="black"),
                           legend.text =   element_text(size=20, color="black"),
                           legend.title = element_text(size = 22, color="black"),
                           plot.title = element_text(size = 24, color="black"),
                           axis.text.x = element_text(size=15, angle=45,hjust=1),
                           legend.margin=margin(c(-20,0,0,0))
                         )


# Supplemental Figure 1
pairtype_fill <- scale_fill_manual(breaks=c(T,F),values = c('#00274C','#FFCB05'),labels = c("Intra-subject",'Inter-subject'), name="Type", guide = guide_legend(nrow=1, title.position = "top", label.position = "right"))

s_figure_1_format <- theme(legend.position = "bottom",
                axis.text =   element_text(size=12, color="black",hjust=0.5,vjust=0.5),
                axis.title = element_text(size = 14, color="black"),
                legend.text =   element_text(size=12, color="black"),
                legend.title = element_text(size = 14, color="black"),
                plot.title = element_text(size = 24, color="black")
                )

s_figure_1_inset_format <- theme(legend.position = "none",
                           axis.text =   element_text(size=12, color="black",hjust=0.5,vjust=0.5),
                           axis.title = element_text(size = 14, color="black"),
                           legend.text =   element_text(size=20, color="black"),
                           legend.title = element_text(size = 22, color="black")
                           )

# Supplemental Figure 2
s_figure_2_format <- theme(axis.text =   element_text(size=10, color="black"),
                           axis.title = element_text(size = 12, color="black"),
                           axis.title.x = element_blank(),
                           axis.text.x = element_text(angle=90,hjust=1,vjust=0.5)
)
# Favorite kable
favorite_kable <- function (x) {
  x %>% kable(., format = "html", table.attr = "style='width:100%;'", 
              row.names = F) %>% kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive"))
}