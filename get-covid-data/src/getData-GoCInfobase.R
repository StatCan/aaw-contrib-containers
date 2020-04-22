
getData.GoCInfobase <- function(
    list.covid19.data = NULL,
    csv.GoCInfobase   = "raw-covid19-GoCInfobase.csv"
    ) {

    thisFunctionName <- "getData.GoCInfobase";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(dplyr);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.GoCInfobase <- list.covid19.data[["GoCInfobase"]];

    DF.GoCInfobase.cases <- getData.GoCInfobase_widen(
        DF.input      = DF.GoCInfobase,
        colname.value = "numconf"
        );

    DF.GoCInfobase.deaths <- getData.GoCInfobase_widen(
        DF.input      = DF.GoCInfobase,
        colname.value = "numdeaths"
        );

    write.csv(
        x         = DF.GoCInfobase.cases,
        file      = "diagnostics-GoCInfobase-cases-wide.csv",
        row.names = FALSE
        );

    write.csv(
        x         = DF.GoCInfobase.deaths,
        file      = "diagnostics-GoCInfobase-deaths-wide.csv",
        row.names = FALSE
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.GoCInfobase.cases <- getData.GoCInfobase_undo.cumulative.sum(
        DF.input = DF.GoCInfobase.cases
        );

    DF.GoCInfobase.deaths <- getData.GoCInfobase_undo.cumulative.sum(
        DF.input = DF.GoCInfobase.deaths
        );

    write.csv(
        x         = DF.GoCInfobase.cases,
        file      = "diagnostics-GoCInfobase-cases-wide-1.csv",
        row.names = FALSE
        );

    write.csv(
        x         = DF.GoCInfobase.deaths,
        file      = "diagnostics-GoCInfobase-deaths-wide-1.csv",
        row.names = FALSE
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.GoCInfobase.cases <- getData.GoCInfobase_elongate(
        DF.input      = DF.GoCInfobase.cases,
        colname.value = "cases"
        );

    DF.GoCInfobase.deaths <- getData.GoCInfobase_elongate(
        DF.input      = DF.GoCInfobase.deaths,
        colname.value = "deaths"
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output <- dplyr::full_join(
        x  = DF.GoCInfobase.cases,
        y  = DF.GoCInfobase.deaths,
        by = c("jurisdiction","date")
        );

    DF.output <- as.data.frame(DF.output);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output <- getData.GoCInfobase_standardize.output(
        DF.input = DF.output
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    write.csv(
        x         = DF.output,
        file      = csv.GoCInfobase,
        row.names = FALSE
        );
    
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( DF.output );

    }

##################################################
getData.GoCInfobase_elongate <- function(
    DF.input      = NULL,
    colname.value = NULL
    ) {
    require(tidyr);
    DF.output <- DF.input;
    DF.output <- DF.output %>% tidyr::gather(
        key   = "date",
        value = "colname_temp",
        -jurisdiction
        );
    colnames(DF.output) <- gsub(
        x           = colnames(DF.output),
        pattern     = "colname_temp",
        replacement = colname.value
        );
    return( DF.output );
    }

getData.GoCInfobase_widen <- function(
    DF.input      = NULL,
    colname.value = NULL
    ) {

    require(tidyr);

    retained.colnames <- c("prname","date",colname.value);
    DF.output <- DF.input[,retained.colnames];

    colnames(DF.output) <- gsub(
        x           = colnames(DF.output),
        pattern     = "prname",
        replacement = "jurisdiction"
        );

    colnames(DF.output) <- gsub(
        x           = colnames(DF.output),
        pattern     = colname.value,
        replacement = "colname.temp"
        );

    DF.output[,"date"] <- as.character(as.Date(
        x          = DF.output[,"date"],
        tryFormats = c("%d-%m-%Y")
        ));

    DF.output <- DF.output %>% tidyr::spread(
        key   = "date",
        value = "colname.temp"
        );

    DF.output <- as.data.frame(DF.output);

    colnames(DF.output) <- gsub(
        x           = colnames(DF.output),
        pattern     = "colname.temp",
        replacement = colname.value
        );

    return( DF.output );

    }

getData.GoCInfobase_undo.cumulative.sum <- function(
    DF.input = NULL
    ) {

    DF.output <- DF.input;

    colnames.non.count <- c("jurisdiction");
    colnames.count     <- setdiff(colnames(DF.output),colnames.non.count);

    DF.count <- DF.output[,colnames.count];
    colnames.DF.count <- colnames(DF.count);

    for ( i in 1:nrow(DF.count) ) {
        temp.vector <- DF.count[i,];
        temp.vector[is.na(temp.vector)] <- 0;
        DF.count[i,] <- temp.vector;
        }

    rightward.shift.1 <- cbind(
        rep(0,nrow(DF.count)),
        DF.count[,1:(ncol(DF.count)-1)]
        );

    DF.count <- as.matrix(DF.count) - as.matrix(rightward.shift.1);
    DF.count <- as.data.frame(DF.count);
    colnames(DF.count) <- colnames.DF.count;

    DF.output <- cbind(
        jurisdiction = as.character(DF.output[,colnames.non.count]),
        DF.count
        );

    DF.output[,"jurisdiction"] <- as.character(DF.output[,"jurisdiction"]);

    return( DF.output );

    }

getData.GoCInfobase_standardize.output <- function(
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
        pattern     = "-[0-9]{1,2}-[0-9]{1,2}$",
        replacement = ""
        );
    DF.output[,"year"] <- as.integer(DF.output[,"year"]);

    DF.output[,"month"] <- gsub(
        x           = DF.output[,"month"],
        pattern     = "^[0-9]{1,4}-",
        replacement = ""
        );
    DF.output[,"month"] <- gsub(
        x           = DF.output[,"month"],
        pattern     = "-[0-9]{1,2}$",
        replacement = ""
        );
    DF.output[,"month"] <- as.integer(DF.output[,"month"]);

    DF.output[,"day"] <- gsub(
        x           = DF.output[,"day"],
        pattern     = "^[0-9]{1,4}-[0-9]{1,2}-",
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

getData.GoCInfobase_download <- function(
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
                stop(sprintf("Error downloading file '%s': %s", target.url, e$message));
                }
            );
        DF.output <- read.csv(output.file, stringsAsFactors = FALSE);
        } 
    return( DF.output );
    }

