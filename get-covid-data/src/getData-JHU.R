
getData.JHU <- function(
    JHU.file.cases  = NULL, 
    JHU.file.deaths = NULL, 
    JHU.url.cases   = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv",
    JHU.url.deaths  = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv",
    JHU.RData       = "raw-covid19-JHU.RData"
    ) {

    thisFunctionName <- "getData.JHU";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(dplyr);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( file.exists(JHU.RData) ) {

        cat(paste0("\n# ",JHU.RData," already exists; loading this file ...\n"));
        DF.output <- readRDS(file = JHU.RData);
        cat(paste0("\n# Loading complete: ",JHU.RData,"\n"));

    } else {

        DF.JHU.cases <- getData.JHU_download(
            input.file  = JHU.file.cases,
            target.url  = JHU.url.cases,
            output.file = "raw-covid19-JHU-cases.csv"
            )

        DF.JHU.deaths <- getData.JHU_download(
            input.file  = JHU.file.deaths,
            target.url  = JHU.url.deaths,
            output.file = "raw-covid19-JHU-deaths.csv"
            )

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.JHU.cases <- getData.JHU_undo.cumulative.sum(
        DF.input      = DF.JHU.cases,
        colname.value = "Cases"
        );

    DF.JHU.deaths <- getData.JHU_undo.cumulative.sum(
        DF.input      = DF.JHU.deaths,
        colname.value = "Deaths"
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.JHU.cases <- getData.JHU_reformat(
        DF.input      = DF.JHU.cases,
        colname.value = "cases"
        );

    DF.JHU.deaths <- getData.JHU_reformat(
        DF.input      = DF.JHU.deaths,
        colname.value = "deaths"
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output <- dplyr::full_join(
        x  = DF.JHU.cases,
        y  = DF.JHU.deaths,
        by = c("jurisdiction","date")
        );

    DF.output <- as.data.frame(DF.output);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output <- getData.JHU_standardize.output(
        DF.input = DF.output
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if (!is.null(JHU.RData)) {
        saveRDS(object = DF.output, file = JHU.RData);
        write.csv(
            x         = DF.output,
            file      = gsub(x = JHU.RData, pattern = "\\.RData", replacement = ".csv"),
            row.names = FALSE
            );
        }
    
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( DF.output );

    }

##################################################
getData.JHU_undo.cumulative.sum <- function(
    DF.input      = NULL,
    colname.value = NULL
    ) {

    DF.output <- DF.input;

    colnames.count <- grep(
        x       = colnames(DF.output),
        pattern = "^X",
        value   = TRUE
        );

    colnames.non.count <- setdiff(colnames(DF.output),colnames.count);

    DF.count <- DF.output[,colnames.count];
    colnames.DF.count <- colnames(DF.count);

    rightward.shift.1 <- cbind(
        rep(0,nrow(DF.count)),
        DF.count[,1:(ncol(DF.count)-1)]
        );

    DF.count <- as.matrix(DF.count) - as.matrix(rightward.shift.1);
    DF.count <- as.data.frame(DF.count);
    colnames(DF.count) <- colnames.DF.count;

    DF.output <- cbind(
        DF.output[,colnames.non.count],
        DF.count
        );

    return( DF.output );

    }

getData.JHU_standardize.output <- function(
    DF.input = NULL
    ) {

    DF.output <- DF.input;

    DF.output[,"date"] <- gsub(
        x           = DF.output[,"date"],
        pattern     = "\\.",
        replacement = "-"
        );

    DF.output[,"day"  ] <- DF.output[,"date"];
    DF.output[,"month"] <- DF.output[,"date"];
    DF.output[,"year" ] <- DF.output[,"date"];

    DF.output[,"year"] <- gsub(
        x           = DF.output[,"year"],
        pattern     = "^[0-9]{1,2}-[0-9]{1,2}-",
        replacement = ""
        );
    DF.output[,"year"] <- paste0("20",DF.output[,"year"]);
    DF.output[,"year"] <- as.integer(DF.output[,"year"]);

    DF.output[,"month"] <- gsub(
        x           = DF.output[,"month"],
        pattern     = "-[0-9]{1,2}-[0-9]{1,2}$",
        replacement = ""
        );
    DF.output[,"month"] <- as.integer(DF.output[,"month"]);

    DF.output[,"day"] <- gsub(
        x           = DF.output[,"day"],
        pattern     = "^[0-9]{1,2}-",
        replacement = ""
        );
    DF.output[,"day"] <- gsub(
        x           = DF.output[,"day"],
        pattern     = "-[0-9]{1,2}$",
        replacement = ""
        );
    DF.output[,"day"] <- as.integer(DF.output[,"day"]);

    DF.output[,"date"] <- as.Date(paste(
        DF.output[,"year"],
        DF.output[,"month"],
        DF.output[,"day"],
        sep="-"
        ));

    DF.output <- DF.output[,c("jurisdiction","date","year","month","day","cases","deaths")];
    DF.output <- DF.output %>% dplyr::arrange(jurisdiction,date);
    DF.output <- as.data.frame(DF.output);

    DF.dictionary <- data.frame(
        province.short = c('BC','AB','SK','MB','ON','QC','NB','NL','NS','PE','YK','NT'),
        province.long  = c(
            "British Columbia",
            "Alberta",
            "Saskatchewan",
            "Manitoba",
            "Ontario",
            "Quebec",
            "New Brunswick",
            "Newfoundland and Labrador",
            "Nova Scotia",
            "Prince Edward Island",
            "Yukon",
            "Northwest Territories"    
            )
        );

    DF.output <- DF.output[DF.output[,"jurisdiction"] %in% DF.dictionary[,"province.long"],  ];

    for ( i in 1:nrow(DF.dictionary)) {
        DF.output[,"jurisdiction"] <- gsub(
            x           = DF.output[,"jurisdiction"],
            pattern     = DF.dictionary[i,"province.long"],
            replacement = DF.dictionary[i,"province.short"]
            );
        }

    return( DF.output );

    }

getData.JHU_download <- function(
    input.file  = NULL,
    target.url  = NULL,
    output.file = NULL
    ) {
    if ( !is.null(input.file) ) {
        DF.output <- read.csv(input.file, stringsAsFactors = FALSE);
    } else {
        tryCatch(
            expr = {
                code <- download.file(url = target.url, destfile = output.file);
                if (code != 0) { stop("Error downloading file") }
                },
            error = function(e) {
                stop(sprintf("Error downloading file '%s': %s, please check %s", url, e$message, url_page));
                }
            );
        DF.output <- read.csv(output.file, stringsAsFactors = FALSE);
        } 
    return( DF.output );
    }

getData.JHU_reformat <- function(
    DF.input      = NULL,
    colname.value = NULL
    ) {

    require(tidyr);

    DF.output <- DF.input;
    colnames(DF.output) <- gsub(
        x           = colnames(DF.output),
        pattern     = "^X",
        replacement = ""
        );

    DF.output <- DF.output[DF.output[,"Country.Region"] == "Canada",];

    retained.columns <- setdiff( colnames(DF.output) , c("Lat","Long","Country.Region") );
    DF.output <- DF.output[,retained.columns];

    colnames(DF.output) <- gsub(
        x           = colnames(DF.output),
        pattern     = "Province\\.State",
        replacement = "jurisdiction"
        );

    DF.output <- DF.output %>% tidyr::gather(
        key   = "date",
        value = "colname_temp",
        -jurisdiction
        );

    DF.output <- as.data.frame(DF.output);

    colnames(DF.output) <- gsub(
        x           = colnames(DF.output),
        pattern     = "colname_temp",
        replacement = colname.value
        );

    return( DF.output );

    }

