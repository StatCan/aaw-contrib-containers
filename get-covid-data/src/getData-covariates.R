
getData.covariates <- function(
    csv.covariates.europe  = NULL,
    csv.covariates.canada  = NULL,
    csv.output             = "input-covariates.csv",
    retained.jurisdictions = NULL,
    retained.columns       = c(
        "jurisdiction",
        "schools_universities",
        "travel_restrictions",
        "public_events",
        "sport",
        "lockdown",
        "social_distancing_encouraged",
        "self_isolating_if_ill"
        )
    ) {

    thisFunctionName <- "getData.covariates";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(lubridate);
    require(readr);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( file.exists(csv.output) ) {

        cat(paste0("\n# ",csv.output," already exists; loading this file ...\n"));
        DF.output <- read.csv(file = csv.output, stringsAsFactors = FALSE);
        cat(paste0("\n# Loading complete: ",csv.output,"\n"));

    } else {

        DF.covariates.europe <- getData.covariates_load(
            csv.covariates   = csv.covariates.europe,
            retained.columns = retained.columns
            );

        DF.covariates.canada <- getData.covariates_load(
            csv.covariates   = csv.covariates.canada,
            retained.columns = retained.columns
            );

        # DF.output <- DF.covariates.europe;
        DF.output <- rbind(
            DF.covariates.europe,
            DF.covariates.canada
            );

        write.csv(
            x         = DF.output,
            file      = csv.output,
            row.names = FALSE
            );

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( DF.output );

    }

##################################################
getData.covariates_load <- function(
    csv.covariates   = NULL,
    retained.columns = NULL
    ) {

    DF.covariates <- read.csv(
        file  = csv.covariates,
        stringsAsFactors = FALSE
        );

    DF.covariates <- DF.covariates[,retained.columns];

    date.colnames <- setdiff(colnames(DF.covariates),"jurisdiction");
    for ( temp.colname in date.colnames ) {
        DF.covariates[,temp.colname] <- as.Date(
            x      = DF.covariates[,temp.colname],
            format = "%Y-%m-%d"
            );
        }

    # making all covariates that happen after lockdown to have same date as lockdown
    date.colnames <- setdiff(colnames(DF.covariates),c("jurisdiction","lockdown"));
    for ( temp.colname in date.colnames ) {
        is.after.lockdown <- (DF.covariates[,temp.colname] > DF.covariates[,"lockdown"]);
        DF.covariates[is.after.lockdown,temp.colname] <- DF.covariates[is.after.lockdown,"lockdown"];
        }

    return( DF.covariates );

    }

