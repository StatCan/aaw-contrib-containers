
getData.raw <- function(
    csv.ECDC        = 'raw-covid19-ECDC.csv', 
    csv.JHU.cases   = 'raw-covid19-JHU-cases.csv', 
    csv.JHU.deaths  = 'raw-covid19-JHU-deaths.csv', 
    csv.GoCInfobase = 'raw-covid19-GoCInfobase.csv', 
    url.ECDC        = "https://opendata.ecdc.europa.eu/covid19/casedistribution/csv",
    url.JHU.cases   = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv",
    url.JHU.deaths  = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv",
    url.GoCInfobase = "https://health-infobase.canada.ca/src/data/covidLive/covid19.csv"
    ) {

    thisFunctionName <- "getData.raw";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(lubridate);
    require(readr);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.ECDC <- getData.raw_load.or.download(
        target.url = url.ECDC,
        csv.file   = csv.ECDC
        );

    DF.JHU.cases <- getData.raw_load.or.download(
        target.url = url.JHU.cases,
        csv.file   = csv.JHU.cases
        );

    DF.JHU.deaths <- getData.raw_load.or.download(
        target.url = url.JHU.deaths,
        csv.file   = csv.JHU.deaths
        );

    DF.GoCInfobase <- getData.raw_load.or.download(
        target.url = url.GoCInfobase,
        csv.file   = csv.GoCInfobase
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    list.output <- list(
        ECDC        = DF.ECDC,
        JHU.cases   = DF.JHU.cases,
        JHU.deaths  = DF.JHU.deaths,
        GoCInfobase = DF.GoCInfobase
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( list.output );

    }

##################################################
getData.raw_load.or.download <- function(
    target.url = NULL,
    csv.file   = NULL
    ) {

    if ( file.exists(csv.file) ) {

        cat(paste0("\n# Data file ",csv.file," already exists; loading this file ...\n"));
        DF.output <- read.csv(file = csv.file, stringsAsFactors = FALSE, na.strings = c("NA","N/A"));
        cat(paste0("\n# Loading complete: ",csv.file,".\n"));
    
    } else {

        cat(paste0("\n# Data file ",csv.file," does NOT yet exists; downloading it from: ",target.url,"\n"));
        tryCatch(
            expr = {
                code <- download.file(url = target.url, destfile = csv.file);
                if (code != 0) { stop("Error downloading file") }
                },
            error = function(e) {
                stop(sprintf("Error downloading file '%s': %s", target.url, e$message));
                }
            );
        cat(paste0("\n# Download complete: ",target.url,".\n"));
        DF.output <- read.csv(file = csv.file, stringsAsFactors = FALSE);

        }

    return( DF.output );

    }

