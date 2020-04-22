
getData.serial.interval <- function(
    csv.serial.interval = NULL,
    csv.output          = "input-serial-interval.csv"
    ) {

    thisFunctionName <- "getData.serial.interval";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(lubridate);
    require(readr);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( file.exists(csv.output) ) {

        cat(paste0("\n# The data file ",csv.output," already exists; loading this file ...\n"));
        DF.output <- read.csv(file = csv.output, stringsAsFactors = FALSE, na.strings = c("NA","N/A"));
        cat(paste0("\n# Loading complete: ",csv.output,"\n"));

    } else {

        DF.output <- read.csv( file = csv.serial.interval, stringsAsFactors = FALSE );
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

