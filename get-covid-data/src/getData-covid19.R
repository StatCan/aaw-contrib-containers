
getData.covid19 <- function(
    retained.jurisdictions = NULL,
    list.covid19.data      = NULL,
    csv.ECDC               = "raw-covid19-ECDC.csv",
    csv.GoCInfobase        = "raw-covid19-GoCInfobase.csv",
    csv.covid19            = "input-covid19.csv"
    ) {

    thisFunctionName <- "getData.covid19";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(lubridate);
    require(readr);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.ECDC <- getData.ECDC(
        list.covid19.data = list.covid19.data,
        csv.ECDC          = csv.ECDC
        );

    is.retained.jurisdictions <- ( DF.ECDC[,"jurisdiction"] %in% retained.jurisdictions);
    DF.ECDC <- DF.ECDC[is.retained.jurisdictions,];

    retained.columns <- setdiff(colnames(DF.ECDC),c("geoId","countryterritoryCode","popData2018","t"));
    DF.ECDC <- DF.ECDC[,retained.columns];

    cat("\nstr(DF.ECDC)\n");
    print( str(DF.ECDC)   );

    cat("\nsummary(DF.ECDC)\n");
    print( summary(DF.ECDC)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.GoCInfobase <- getData.GoCInfobase(
        list.covid19.data = list.covid19.data,
        csv.GoCInfobase   = csv.GoCInfobase
        );

    is.retained.jurisdictions <- ( DF.GoCInfobase[,"jurisdiction"] %in% retained.jurisdictions);
    DF.GoCInfobase <- DF.GoCInfobase[is.retained.jurisdictions,];

    cat("\nstr(DF.GoCInfobase)\n");
    print( str(DF.GoCInfobase)   );

    cat("\nsummary(DF.GoCInfobase)\n");
    print( summary(DF.GoCInfobase)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output <- rbind(DF.ECDC,DF.GoCInfobase);

    write.csv(
        x         = DF.output,
        file      = csv.covid19,
        row.names = FALSE
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( DF.output );

    }

##################################################

