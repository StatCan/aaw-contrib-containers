
plot.3.panel <- function(
    list.input = NULL
    ) {
  
    require(ggplot2);
    require(tidyr)
    require(dplyr)
    require(rstan)
    require(data.table)
    require(lubridate)
    require(gdata)
    require(EnvStats)
    require(matrixStats)
    require(scales)
    require(gridExtra)
    require(ggpubr)
    require(bayesplot)
    require(cowplot)
 
    StanModel              <- list.input[["StanModel"        ]];
    dates                  <- list.input[["dates"            ]];
    jurisdictions          <- list.input[["jurisdictions"    ]];
    prediction             <- list.input[["prediction"       ]];
    estimated.deaths       <- list.input[["estimated_deaths" ]];
    out                    <- list.input[["out"              ]];
    covariates             <- list.input[["covariates"       ]];
    reported_cases         <- list.input[["reported_cases"   ]];
    deaths_by_jurisdiction <- list.input[["deaths_by_jurisdiction"]];

    for( i in 1:length(jurisdictions) ){

        print(i)

        N            <- length(dates[[i]]);
        jurisdiction <- jurisdictions[[i]];

        predicted_cases     <- colMeans(    prediction[,1:N,i]);
        predicted_cases_li  <- colQuantiles(prediction[,1:N,i], probs=.025);
        predicted_cases_ui  <- colQuantiles(prediction[,1:N,i], probs=.975);
        predicted_cases_li2 <- colQuantiles(prediction[,1:N,i], probs=.25 );
        predicted_cases_ui2 <- colQuantiles(prediction[,1:N,i], probs=.75 );

        estimated_deaths     <- colMeans(    estimated.deaths[,1:N,i]);
        estimated_deaths_li  <- colQuantiles(estimated.deaths[,1:N,i], probs=.025);
        estimated_deaths_ui  <- colQuantiles(estimated.deaths[,1:N,i], probs=.975);
        estimated_deaths_li2 <- colQuantiles(estimated.deaths[,1:N,i], probs=.25 );
        estimated_deaths_ui2 <- colQuantiles(estimated.deaths[,1:N,i], probs=.75 );

        rt     <- colMeans(    out$Rt[,1:N,i]);
        rt_li  <- colQuantiles(out$Rt[,1:N,i],probs=.025);
        rt_ui  <- colQuantiles(out$Rt[,1:N,i],probs=.975);
        rt_li2 <- colQuantiles(out$Rt[,1:N,i],probs=.25 );
        rt_ui2 <- colQuantiles(out$Rt[,1:N,i],probs=.75 );

        # delete these 2 lines
        covariates_jurisdiction <- covariates[which(covariates$jurisdiction == jurisdiction), 2:8]   

        # Remove sport
        covariates_jurisdiction$sport = NULL 
        covariates_jurisdiction$travel_restrictions = NULL 
        covariates_jurisdiction_long <- gather(covariates_jurisdiction[], key = "key", 
                                      value = "value")
        covariates_jurisdiction_long$x <- rep(NULL, length(covariates_jurisdiction_long$key))
        un_dates <- unique(covariates_jurisdiction_long$value);

        for ( k in 1:length(un_dates) ) {
            idxs <- which(covariates_jurisdiction_long$value == un_dates[k])
            max_val <- round(max(rt_ui)) + 0.3
            for (j in idxs){
                covariates_jurisdiction_long$x[j] <- max_val
                max_val <- max_val - 0.3
                }
            }

        covariates_jurisdiction_long$value        <- as_date(covariates_jurisdiction_long$value) 
        covariates_jurisdiction_long$jurisdiction <- rep(jurisdiction, length(covariates_jurisdiction_long$value))
    
        data_jurisdiction <- data.frame(
            "time"               = as_date(as.character(dates[[i]])),
            "jurisdiction"       = rep(jurisdiction, length(dates[[i]])),
            "reported_cases"     = reported_cases[[i]], 
            "reported_cases_c"   = cumsum(reported_cases[[i]]), 
            "predicted_cases_c"  = cumsum(predicted_cases),
            "predicted_min_c"    = cumsum(predicted_cases_li),
            "predicted_max_c"    = cumsum(predicted_cases_ui),
            "predicted_cases"    = predicted_cases,
            "predicted_min"      = predicted_cases_li,
            "predicted_max"      = predicted_cases_ui,
            "predicted_min2"     = predicted_cases_li2,
            "predicted_max2"     = predicted_cases_ui2,
            "deaths"             = deaths_by_jurisdiction[[i]],
            "deaths_c"           = cumsum(deaths_by_jurisdiction[[i]]),
            "estimated_deaths_c" = cumsum(estimated_deaths),
            "death_min_c"        = cumsum(estimated_deaths_li),
            "death_max_c"        = cumsum(estimated_deaths_ui),
            "estimated_deaths"   = estimated_deaths,
            "death_min"          = estimated_deaths_li,
            "death_max"          = estimated_deaths_ui,
            "death_min2"         = estimated_deaths_li2,
            "death_max2"         = estimated_deaths_ui2,
            "rt"                 = rt,
            "rt_min"             = rt_li,
            "rt_max"             = rt_ui,
            "rt_min2"            = rt_li2,
            "rt_max2"            = rt_ui2
            );
    
        plot.three.panel_make.plots(
            data_jurisdiction            = data_jurisdiction, 
            covariates_jurisdiction_long = covariates_jurisdiction_long,
            StanModel                    = StanModel,
            jurisdiction                 = jurisdiction
            );
    
        }

    return( NULL );

    }

########################################
plot.three.panel_make.plots <- function(
    data_jurisdiction            = NULL,
    covariates_jurisdiction_long = NULL, 
    StanModel                    = NULL,
    jurisdiction                 = NULL
    ) {
  
  data_cases_95 <- data.frame(data_jurisdiction$time, data_jurisdiction$predicted_min, 
                              data_jurisdiction$predicted_max)
  names(data_cases_95) <- c("time", "cases_min", "cases_max")
  data_cases_95$key <- rep("nintyfive", length(data_cases_95$time))
  data_cases_50 <- data.frame(data_jurisdiction$time, data_jurisdiction$predicted_min2, 
                              data_jurisdiction$predicted_max2)
  names(data_cases_50) <- c("time", "cases_min", "cases_max")
  data_cases_50$key <- rep("fifty", length(data_cases_50$time))
  data_cases <- rbind(data_cases_95, data_cases_50)
  levels(data_cases$key) <- c("ninetyfive", "fifty")
  
  p1 <- ggplot(data_jurisdiction) +
    geom_bar(data = data_jurisdiction, aes(x = time, y = reported_cases), 
             fill = "coral4", stat='identity', alpha=0.5) + 
    geom_ribbon(data = data_cases, 
                aes(x = time, ymin = cases_min, ymax = cases_max, fill = key)) +
    xlab("") +
    ylab("Daily number of infections") +
    scale_x_date(date_breaks = "weeks", labels = date_format("%e %b")) + 
    scale_fill_manual(name = "", labels = c("50%", "95%"),
                      values = c(alpha("deepskyblue4", 0.55), 
                                 alpha("deepskyblue4", 0.45))) + 
    theme_pubr() + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1), 
          legend.position = "None") + 
    guides(fill=guide_legend(ncol=1))
  
  data_deaths_95 <- data.frame(data_jurisdiction$time, data_jurisdiction$death_min, 
                               data_jurisdiction$death_max)
  names(data_deaths_95) <- c("time", "death_min", "death_max")
  data_deaths_95$key <- rep("nintyfive", length(data_deaths_95$time))
  data_deaths_50 <- data.frame(data_jurisdiction$time, data_jurisdiction$death_min2, 
                               data_jurisdiction$death_max2)
  names(data_deaths_50) <- c("time", "death_min", "death_max")
  data_deaths_50$key <- rep("fifty", length(data_deaths_50$time))
  data_deaths <- rbind(data_deaths_95, data_deaths_50)
  levels(data_deaths$key) <- c("ninetyfive", "fifty")
  
  
  p2 <-   ggplot(data_jurisdiction, aes(x = time)) +
    geom_bar(data = data_jurisdiction, aes(y = deaths, fill = "reported"),
             fill = "coral4", stat='identity', alpha=0.5) +
    geom_ribbon(
      data = data_deaths,
      aes(ymin = death_min, ymax = death_max, fill = key)) +
    scale_x_date(date_breaks = "weeks", labels = date_format("%e %b")) +
    scale_fill_manual(name = "", labels = c("50%", "95%"),
                      values = c(alpha("deepskyblue4", 0.55), 
                                 alpha("deepskyblue4", 0.45))) + 
    theme_pubr() + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1), 
          legend.position = "None") + 
    guides(fill=guide_legend(ncol=1))
  
  
  plot_labels <- c("Complete lockdown", 
                   "Public events banned",
                   "School closure",
                   "Self isolation",
                   "Social distancing")
  
  # Plotting interventions
  data_rt_95 <- data.frame(data_jurisdiction$time, 
                           data_jurisdiction$rt_min, data_jurisdiction$rt_max)
  names(data_rt_95) <- c("time", "rt_min", "rt_max")
  data_rt_95$key <- rep("nintyfive", length(data_rt_95$time))
  data_rt_50 <- data.frame(data_jurisdiction$time, data_jurisdiction$rt_min2, 
                           data_jurisdiction$rt_max2)
  names(data_rt_50) <- c("time", "rt_min", "rt_max")
  data_rt_50$key <- rep("fifty", length(data_rt_50$time))
  data_rt <- rbind(data_rt_95, data_rt_50)
  levels(data_rt$key) <- c("ninetyfive", "fifth")
  
  p3 <- ggplot(data_jurisdiction) +
    geom_stepribbon(data = data_rt, aes(x = time, ymin = rt_min, ymax = rt_max, 
                                        group = key,
                                        fill = key)) +
    geom_hline(yintercept = 1, color = 'black', size = 0.1) + 
    geom_segment(data = covariates_jurisdiction_long,
                 aes(x = value, y = 0, xend = value, yend = max(x)), 
                 linetype = "dashed", colour = "grey", alpha = 0.75) +
    geom_point(data = covariates_jurisdiction_long, aes(x = value, 
                                                   y = x, 
                                                   group = key, 
                                                   shape = key, 
                                                   col = key), size = 2) +
    xlab("") +
    ylab(expression(R[t])) +
    scale_fill_manual(name = "", labels = c("50%", "95%"),
                      values = c(alpha("seagreen", 0.75), alpha("seagreen", 0.5))) + 
    scale_shape_manual(name = "Interventions", labels = plot_labels,
                       values = c(21, 22, 23, 24, 25, 12)) + 
    scale_colour_discrete(name = "Interventions", labels = plot_labels) + 
    scale_x_date(date_breaks = "weeks", labels = date_format("%e %b"), 
                 limits = c(data_jurisdiction$time[1], 
                            data_jurisdiction$time[length(data_jurisdiction$time)])) + 
    theme_pubr() + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    theme(legend.position="right")
  
  p <- plot_grid(p1, p2, p3, ncol = 3, rel_widths = c(1, 1, 2))
  save_plot(
      filename = paste0("output-",StanModel,"-3-panel-",jurisdiction,".png"),
      p,
      base_width = 14
      )
}

