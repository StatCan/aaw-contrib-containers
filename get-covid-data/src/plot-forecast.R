
plot.forecast <- function(
    list.input      = NULL,
    forecast.window = 7
    ){
  
    require(ggplot2)
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

    max.N2 <- dim(estimated.deaths)[2];

    for( i in 1:length(jurisdictions) ) {

        N            <- length(dates[[i]])
        N2           <- min(N + forecast.window,max.N2)
        jurisdiction <- jurisdictions[[i]]
    
        predicted_cases    <- colMeans(    prediction[,1:N,i])
        predicted_cases_li <- colQuantiles(prediction[,1:N,i], probs=.025)
        predicted_cases_ui <- colQuantiles(prediction[,1:N,i], probs=.975)
    
        estimated_deaths    <- colMeans(    estimated.deaths[,1:N,i])
        estimated_deaths_li <- colQuantiles(estimated.deaths[,1:N,i], probs=.025)
        estimated_deaths_ui <- colQuantiles(estimated.deaths[,1:N,i], probs=.975)
    
        estimated_deaths_forecast    <- colMeans(    estimated.deaths[,1:N2,i])[N:N2]
        estimated_deaths_li_forecast <- colQuantiles(estimated.deaths[,1:N2,i], probs=.025)[N:N2]
        estimated_deaths_ui_forecast <- colQuantiles(estimated.deaths[,1:N2,i], probs=.975)[N:N2]
    
        rt    <- colMeans(    out$Rt[,1:N,i])
        rt_li <- colQuantiles(out$Rt[,1:N,i],probs=.025)
        rt_ui <- colQuantiles(out$Rt[,1:N,i],probs=.975)
    
        data_jurisdiction <- data.frame(
            "time"                    = as_date(as.character(dates[[i]])),
            "jurisdiction"            = rep(jurisdiction, length(dates[[i]])),
#           "jurisdiction_population" = rep(jurisdiction_population, length(dates[[i]])),
            "reported_cases"          = reported_cases[[i]], 
            "reported_cases_c"        = cumsum(reported_cases[[i]]), 
            "predicted_cases_c"       = cumsum(predicted_cases),
            "predicted_min_c"         = cumsum(predicted_cases_li),
            "predicted_max_c"         = cumsum(predicted_cases_ui),
            "predicted_cases"         = predicted_cases,
            "predicted_min"           = predicted_cases_li,
            "predicted_max"           = predicted_cases_ui,
            "deaths"                  = deaths_by_jurisdiction[[i]],
            "deaths_c"                = cumsum(deaths_by_jurisdiction[[i]]),
            "estimated_deaths_c"      = cumsum(estimated_deaths),
            "death_min_c"             = cumsum(estimated_deaths_li),
            "death_max_c"             = cumsum(estimated_deaths_ui),
            "estimated_deaths"        = estimated_deaths,
            "death_min"               = estimated_deaths_li,
            "death_max"               = estimated_deaths_ui,
            "rt"                      = rt,
            "rt_min"                  = rt_li,
            "rt_max"                  = rt_ui
            );

        times <- as_date(as.character(dates[[i]]))
        times_forecast <- times[length(times)] + 0:(N2 - N)
        data_jurisdiction_forecast <- data.frame(
            "time"                      = times_forecast,
            "jurisdiction"              = rep(jurisdiction,length(estimated_deaths_forecast)),
            "estimated_deaths_forecast" = estimated_deaths_forecast,
            "death_min_forecast"        = estimated_deaths_li_forecast,
            "death_max_forecast"        = estimated_deaths_ui_forecast
            );
    
        plot.forecast_single.plot(
            data_jurisdiction          = data_jurisdiction, 
            data_jurisdiction_forecast = data_jurisdiction_forecast,
            StanModel                  = StanModel,
            jurisdiction               = jurisdiction
            );
    
        }

    return( NULL );

    }

##################################################
plot.forecast_single.plot <- function(
    data_jurisdiction,
    data_jurisdiction_forecast,
    StanModel,
    jurisdiction
    ) {
  
  data_deaths <- data_jurisdiction %>%
    select(time, deaths, estimated_deaths) %>%
    gather("key" = key, "value" = value, -time)
  
  data_deaths_forecast <- data_jurisdiction_forecast %>%
    select(time, estimated_deaths_forecast) %>%
    gather("key" = key, "value" = value, -time)
  
  # Force less than 1 case to zero
  data_deaths$value[data_deaths$value < 1] <- NA
  data_deaths_forecast$value[data_deaths_forecast$value < 1] <- NA
  data_deaths_all <- rbind(data_deaths, data_deaths_forecast)
  
  p <- ggplot(data_jurisdiction) +
    geom_bar(data = data_jurisdiction, aes(x = time, y = deaths), 
             fill = "coral4", stat='identity', alpha=0.5) + 
    geom_line(data = data_jurisdiction, aes(x = time, y = estimated_deaths), 
              col = "deepskyblue4") + 
    geom_line(data = data_jurisdiction_forecast, 
              aes(x = time, y = estimated_deaths_forecast), 
              col = "black", alpha = 0.5) + 
    geom_ribbon(data = data_jurisdiction, aes(x = time, 
                                         ymin = death_min, 
                                         ymax = death_max),
                fill="deepskyblue4", alpha=0.3) +
    geom_ribbon(data = data_jurisdiction_forecast, 
                aes(x = time, 
                    ymin = death_min_forecast, 
                    ymax = death_max_forecast),
                fill = "black", alpha=0.35) +
    geom_vline(xintercept = data_deaths$time[length(data_deaths$time)], 
               col = "black", linetype = "dashed", alpha = 0.5) + 
    #scale_fill_manual(name = "", 
    #                 labels = c("Confirmed deaths", "Predicted deaths"),
    #                 values = c("coral4", "deepskyblue4")) + 
    xlab("Date") +
    ylab("Daily number of deaths\n") + 
    scale_x_date(date_breaks = "weeks", labels = date_format("%e %b")) + 
    scale_y_continuous(trans='log10', labels=comma) + 
    coord_cartesian(ylim = c(1, 100000), expand = FALSE) + 
    theme_pubr() + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
    guides(fill=guide_legend(ncol=1, reverse = TRUE)) + 
    annotate(geom="text", x=data_jurisdiction$time[length(data_jurisdiction$time)]+8, 
             y=10000, label="Forecast",
             color="black")
  print(p)
  
  ggsave(
      file = paste0("output-",StanModel,"-forecast-",jurisdiction,".png"), 
      p,
      width = 10
      );

}
#-----------------------------------------------------------------------------------------------
# make_forecast_plot()

