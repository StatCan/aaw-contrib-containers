
visualize.estimates <- function(
    list.input = NULL
    ) {

    thisFunctionName <- "visualize.estimates";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    visualize.estimates_alpha(
        DF.input = list.input[["alpha"]]
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    temp.variables <- c("prediction","E_deaths","Rt");
    for ( temp.variable in temp.variables ) {
        visualize.estimates_time.series(
            variable   = temp.variable,
            list.input = list.input
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

###################################################
beautify.variable <- function(input.string = NULL) {
    output.string <- input.string;
    output.string <- gsub(x = output.string, pattern = "prediction", replacement = "estimated daily new infection count");
    output.string <- gsub(x = output.string, pattern = "E_deaths",   replacement = "estimated daily death count");
    output.string <- gsub(x = output.string, pattern = "Rt",         replacement = "daily reproduction number");
    return( output.string );
    }

visualize.estimates_time.series <- function(
    variable   = NULL,
    list.input = NULL
    ) {

    require(ggplot2);
    require(dplyr);

    DF.input <- list.input[[variable]];

    temp.jurisdictions <- unique(DF.input[,"jurisdiction"]);
    for ( temp.jurisdiction in temp.jurisdictions ) {

        DF.temp <- DF.input[DF.input[,"jurisdiction"] == temp.jurisdiction,];
        cat("\nDF.temp\n");
        print( DF.temp   );

        DF.plot <- DF.temp %>%
            select( date, posterior.mean ) %>%
            group_by( date ) %>%
            summarise(
                my.median      = median(  posterior.mean),
                my.quantile025 = quantile(posterior.mean,0.025),
                my.quantile250 = quantile(posterior.mean,0.250),
                my.quantile750 = quantile(posterior.mean,0.750),
                my.quantile975 = quantile(posterior.mean,0.975)
                );

        beautified.variable <- beautify.variable(input.string = variable);
        temp.subtitle <- paste0(gsub(x=temp.jurisdiction,pattern="\\.",replacement=" "),", ",beautified.variable);

        my.ggplot <- initializePlot(
            title    = NULL,
            subtitle = temp.subtitle
            );

        my.ggplot <- my.ggplot + xlab("");
        my.ggplot <- my.ggplot + ylab("");

        #my.ggplot <- my.ggplot + scale_x_continuous(limits=20*c(-1,1),breaks=seq(-20,20,5));

        temp.ymax <- 1.1 * max(DF.plot[,"my.quantile975"]);
        my.ggplot <- my.ggplot + scale_y_continuous(limits=c(0,temp.ymax));

        my.ggplot <- my.ggplot + geom_ribbon(
            data    = DF.plot,
            mapping = aes(x = date, ymin = my.quantile025, ymax = my.quantile975),
            alpha   = 0.2
            );

        my.ggplot <- my.ggplot + geom_ribbon(
            data    = DF.plot,
            mapping = aes(x = date, ymin = my.quantile250, ymax = my.quantile750),
            alpha   = 0.3
            );

        my.ggplot <- my.ggplot + geom_line(
            data    = DF.plot,
            mapping = aes(x = date, y = my.median),
            alpha   = 0.80,
            size    = 0.75,
            colour  = "red"
            );

        temp.string <- gsub(x=temp.jurisdiction,pattern="\\.",replacement="-");
        PNG.output  <- paste0("plot-",variable,"-",temp.string,".png");
        ggsave(
            file   = PNG.output,
            plot   = my.ggplot,
            dpi    = 300,
            height =   8,
            width  =  10,
            units  = 'in'
            );

        }

    return( NULL );

    }

visualize.estimates_alpha <- function(
    DF.input = NULL
    ) {

    require(ggplot2);

    temp.covariates <- unique(DF.input[,"covariate"]);
    for ( temp.covariate in temp.covariates ) {

        DF.temp <- DF.input[DF.input[,"covariate"] == temp.covariate,];
        cat("\nDF.temp\n");
        print( DF.temp   );

        my.ggplot <- initializePlot(
            title    = NULL,
            subtitle = gsub(x=temp.covariate,pattern="\\.",replacement=" ")
            );

        my.ggplot <- my.ggplot + scale_x_continuous(limits=c(-0.05,1.05),breaks=seq(0,1,0.1));

        my.ggplot <- my.ggplot + geom_histogram(
            data    = DF.temp,
            mapping = aes(x = posterior.mean),
            #size    = 0.2,
            alpha   = 0.5
            );

        temp.string <- gsub(x=temp.covariate,pattern="\\.",replacement="-");
        PNG.output  <- paste0("plot-alpha-",temp.string,".png");
        ggsave(
            file   = PNG.output,
            plot   = my.ggplot,
            dpi    = 300,
            height =   8,
            width  =  10,
            units  = 'in'
            );

        }

    return( NULL );

    }

