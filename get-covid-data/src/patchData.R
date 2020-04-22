
patchData <- function(
    list.covid19.data = NULL,
    min.Date          = as.Date("2019-12-31")
    ) {

    thisFunctionName <- "patchData";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(lubridate);
    require(readr);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    list.output <- list.covid19.data;

    list.output[["GoCInfobase"]] <- patchData_GoCInfobase(
        DF.input = list.output[["GoCInfobase"]],
        min.Date = min.Date
        );

    write.csv(
        x         = list.output[["GoCInfobase"]],
        file      = 'raw-covid19-GoCInfobase-patched.csv',
        row.names = FALSE
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( list.output );

    }

###################################################
patchData_GoCInfobase <- function(
    DF.input               = NULL,
    min.Date               = NULL,
    dateFormat.GoCInfobase = "%d-%m-%Y"
    ) {

    require(dplyr);
    require(tidyr);
    require(lubridate);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    colnames.input   <- colnames(DF.input);
    colnames.numeric <- c("numconf","numprob","numdeaths","numtotal","numtested","numrecover");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    unique.pruids <- unique(DF.input[,"pruid"]);
    unique.dates  <- as.Date(x = unique(DF.input[,"date"]), tryFormats = dateFormat.GoCInfobase);
    unique.dates  <- seq(min(min.Date,min(unique.dates)),max(unique.dates),by=1);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.dictionary.pruid <- unique(DF.input[,c("pruid","prname","prnameFR")]);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    retained.colnames <- c("pruid","date",colnames.numeric);
    DF.counts <- DF.input[,retained.colnames];
    DF.counts[,"Date.Obj"] <- as.Date(x = DF.counts[,"date"], tryFormats = c("%d-%m-%Y"));
    DF.counts <- DF.counts[,setdiff(colnames(DF.counts),"date")];

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.grid <- expand.grid(pruid = unique.pruids, Date.Obj = unique.dates);
    attr(DF.grid,"out.attrs") <- NULL;

    DF.grid[,"date"] <- format(x = DF.grid[,"Date.Obj"], dateFormat.GoCInfobase);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output <- dplyr::full_join(
        x  = DF.grid,
        y  = DF.dictionary.pruid,
        by = c("pruid")
        );

    DF.output <- dplyr::full_join(
        x  = DF.output,
        y  = DF.counts,
        by = c("pruid","Date.Obj")
        );

    DF.output <- as.data.frame(DF.output %>% dplyr::arrange(pruid,Date.Obj));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    leading.colnames <- c("pruid","prname","prnameFR","Date.Obj");
    ordered.colnames <- c(
        leading.colnames,
        setdiff(colnames(DF.output),leading.colnames)
        );
    DF.output <- DF.output[,ordered.colnames];

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    for ( temp.colname in colnames.numeric ) {
        temp.vector <- DF.output[,temp.colname];
        temp.vector[is.na(temp.vector)] <- 0;
        DF.output[,temp.colname] <- temp.vector;
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    for ( temp.pruid in unique(DF.output[,"pruid"]) ) {
        DF.temp <- DF.output[DF.output[,"pruid"] == temp.pruid,];
        for ( temp.index in 2:nrow(DF.temp) ) {
            temp.vector.zero   <- DF.temp[temp.index,  colnames.numeric];
            temp.vector.minus1 <- DF.temp[temp.index-1,colnames.numeric];
            is.a.drop <- (temp.vector.zero < temp.vector.minus1);
            temp.vector.two            <- temp.vector.zero;
            temp.vector.two[is.a.drop] <- temp.vector.minus1[is.a.drop];
            DF.temp[temp.index,colnames.numeric] <- temp.vector.two;
            }
        DF.output[DF.output[,"pruid"] == temp.pruid,] <- DF.temp;
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output <- DF.output[,setdiff(colnames(DF.output),"Date.Obj")];

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    return( DF.output );

    }

