
initializePlot <- function(
    textsize.title = 25,
    textsize.axis  = 20,
    title          = 'my-title',
    subtitle       = 'my-subtitle',
    # my.palette   = c("#66C2A5","#FC8D62","#8DA0CB","blue","black","#FFD92F")
    # my.palette   = RColorBrewer::brewer.pal(n = 6, name = "Set2")
    # my.palette   = c("#000000","#E69F00","#56B4E9","#009E73","#F0E442","#0072B2","#D55E00","#CC79A7")
    # my.palette   = c("#000000","#E69F00","#CC79A7","#009E73","#F0E442","#0072B2","#D55E00","#56B4E9")
    my.palette     = c("#000000","#E69F00","#56B4E9","#009E73","#F0E442","red",    "#D55E00","#CC79A7")
    ) {

    require(ggplot2);

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
    my.ggplot <- ggplot(data = NULL) + theme_bw();
    my.ggplot <- my.ggplot + theme(
        title            = element_text(size = textsize.title, face = "bold"),
        axis.title.x     = element_text(size = textsize.axis,  face = "bold"),
        axis.title.y     = element_text(size = textsize.axis,  face = "bold"),
        axis.text.x      = element_text(size = textsize.axis, face = "bold"),
        axis.text.y      = element_text(size = textsize.axis, face = "bold"),
	strip.text.y     = element_text(size = textsize.axis, face = "bold"),
        legend.text      = element_text(size = textsize.axis),
        panel.grid.major = element_line(colour="gray", linetype=2, size=0.25),
        panel.grid.minor = element_line(colour="gray", linetype=2, size=0.25)
        );

    my.ggplot <- my.ggplot + labs(
        title    = title,
        subtitle = subtitle
        );

    my.ggplot <- my.ggplot + scale_colour_manual(
        values = my.palette
        );

    my.ggplot <- my.ggplot + scale_fill_manual(
        values = my.palette
        );

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
    return( my.ggplot );

    }

