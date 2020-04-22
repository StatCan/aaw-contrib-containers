
cross.check.JHU.ECDC <- function(
    retained.jurisdictions = NULL,
    list.covid19.data      = NULL,
    csv.output             = "diagnostics-compare-JHU-ECDC.csv"
    ) {

    thisFunctionName <- "cross.check.JHU.ECDC";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(lubridate);
    require(readr);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.JHU.cases  <- list.covid19.data[["JHU.cases" ]];
    DF.JHU.deaths <- list.covid19.data[["JHU.deaths"]];
    DF.ECDC       <- list.covid19.data[["ECDC"      ]];

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.JHU.cases  <- DF.JHU.cases[ DF.JHU.cases[, "Country.Region"] == "Canada",];
    DF.JHU.deaths <- DF.JHU.deaths[DF.JHU.deaths[,"Country.Region"] == "Canada",];
    DF.ECDC       <- DF.ECDC[ DF.ECDC[,"countriesAndTerritories"] == "Canada",];

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.JHU.cases <- cross.check_reformat.JHU(
        DF.input      = DF.JHU.cases,
        colname.value = "cases.JHU"
        );

    DF.JHU.deaths <- cross.check_reformat.JHU(
        DF.input      = DF.JHU.deaths,
        colname.value = "deaths.JHU"
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.ECDC <- cross.check_reformat.ECDC(
        DF.input = DF.ECDC
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.JHU <- dplyr::full_join(
        x  = DF.JHU.cases,
        y  = DF.JHU.deaths,
        by = c("jurisdiction","date")
        );
    DF.JHU <- as.data.frame(DF.JHU);

    excluded.jurisdictions <- c("Diamond Princess","Grand Princess","Recovered");
    is.retained.rows <- !(DF.JHU[,"jurisdiction"] %in% excluded.jurisdictions);
    DF.JHU <- DF.JHU[is.retained.rows,];

    DF.JHU <- DF.JHU %>%
        dplyr::arrange(jurisdiction,date) %>%
        dplyr::group_by( date ) %>%
        dplyr::summarize( cases.JHU = sum(cases.JHU), deaths.JHU = sum(deaths.JHU) );
    DF.JHU <- as.data.frame(DF.JHU);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.cross.check <- dplyr::full_join(
        x  = DF.JHU,
        y  = DF.ECDC,
        by = c("date")
        );

    DF.cross.check <- DF.cross.check %>% dplyr::arrange(date);
    DF.cross.check <- as.data.frame(DF.cross.check);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    colnames.integer <- setdiff(colnames(DF.cross.check),c("date")); 
    for ( temp.colname in colnames.integer) {
        temp.vector <- DF.cross.check[,temp.colname];
        temp.vector[is.na(temp.vector)] <- 0;
        DF.cross.check[,temp.colname] <- temp.vector;
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    write.csv(
        x         = DF.cross.check,
        file      = csv.output,
        row.names = FALSE
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( DF.cross.check );

    }

##################################################
cross.check.JHU.GoCInfobase <- function(
    retained.jurisdictions = NULL,
    list.covid19.data      = NULL,
    csv.output             = "diagnostics-compare-JHU-GoCInfobase.csv"
    ) {

    thisFunctionName <- "cross.check.JHU.GoCInfobase";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(lubridate);
    require(readr);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.JHU.cases   <- list.covid19.data[["JHU.cases"  ]];
    DF.JHU.deaths  <- list.covid19.data[["JHU.deaths" ]];
    DF.GoCInfobase <- list.covid19.data[["GoCInfobase"]];

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.JHU.cases  <- DF.JHU.cases[ DF.JHU.cases[, "Country.Region"] == "Canada",];
    DF.JHU.deaths <- DF.JHU.deaths[DF.JHU.deaths[,"Country.Region"] == "Canada",];

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.JHU.cases <- cross.check_reformat.JHU(
        DF.input      = DF.JHU.cases,
        colname.value = "cases.JHU"
        );

    DF.JHU.deaths <- cross.check_reformat.JHU(
        DF.input      = DF.JHU.deaths,
        colname.value = "deaths.JHU"
        );

    DF.GoCInfobase <- cross.check_reformat.GoCInfobase(
        DF.input = DF.GoCInfobase
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.JHU <- dplyr::full_join(
        x  = DF.JHU.cases,
        y  = DF.JHU.deaths,
        by = c("jurisdiction","date")
        );

    DF.JHU <- DF.JHU %>% dplyr::arrange(jurisdiction,date);
    DF.JHU <- as.data.frame(DF.JHU);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.cross.check <- dplyr::full_join(
        x  = DF.JHU,
        y  = DF.GoCInfobase,
        by = c("jurisdiction","date")
        );

    DF.cross.check <- DF.cross.check %>% dplyr::arrange(jurisdiction,date);
    DF.cross.check <- as.data.frame(DF.cross.check);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    colnames.integer <- setdiff(colnames(DF.cross.check),c("jurisdiction","date")); 
    for ( temp.colname in colnames.integer) {
        temp.vector <- DF.cross.check[,temp.colname];
        temp.vector[is.na(temp.vector)] <- 0;
        DF.cross.check[,temp.colname] <- temp.vector;
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    write.csv(
        x         = DF.cross.check,
        file      = csv.output,
        row.names = FALSE
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( DF.cross.check );

    }

##################################################
cross.check_reformat.ECDC <- function(
    DF.input = NULL
    ) {
    require(dplyr);
    require(tidyr);
    retained.columns <- c("dateRep","cases","deaths");
    DF.output <- DF.input[,retained.columns];
    colnames(DF.output) <- gsub(
        x           = colnames(DF.output),
        pattern     = "dateRep",
        replacement = "date"
        );
    DF.output[,"date"] <- as.Date(
        x          = DF.output[,"date"],
        tryFormats = c("%d/%m/%Y")
        );
    colnames(DF.output) <- gsub(
        x           = colnames(DF.output),
        pattern     = "cases",
        replacement = "cases.ECDC"
        );
    colnames(DF.output) <- gsub(
        x           = colnames(DF.output),
        pattern     = "deaths",
        replacement = "deaths.ECDC"
        );
    DF.output <- DF.output %>% dplyr::arrange(date);
    DF.output <- as.data.frame(DF.output);
    return( DF.output );
    }

cross.check_reformat.GoCInfobase <- function(
    DF.input = NULL
    ) {
    require(dplyr);
    require(tidyr);
    retained.columns <- c("prname","date","numconf","numprob","numdeaths","numtotal");
    DF.output <- DF.input[,retained.columns];
    colnames(DF.output) <- gsub(
        x           = colnames(DF.output),
        pattern     = "prname",
        replacement = "jurisdiction"
        );
    DF.output[,"date"] <- as.Date(
        x          = DF.output[,"date"],
        tryFormats = c("%d-%m-%Y")
        );
    DF.output <- DF.output %>% dplyr::arrange(jurisdiction,date);
    DF.output <- as.data.frame(DF.output);
    return( DF.output );
    }

cross.check_reformat.JHU <- function(
    DF.input      = NULL,
    colname.value = NULL
    ) {

    require(dplyr);
    require(tidyr);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output <- DF.input;
    colnames(DF.output) <- gsub(
        x           = colnames(DF.output),
        pattern     = "^X",
        replacement = ""
        );

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

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
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

    DF.output <- DF.output[,c("jurisdiction","date",colname.value)];
    DF.output <- DF.output %>% dplyr::arrange(jurisdiction,date);
    DF.output <- as.data.frame(DF.output);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    return( DF.output );

    }

