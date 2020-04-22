
wrapper.stan <- function(
    StanModel                   = NULL,
    FILE.stan.model             = NULL,
    DF.covid19                  = NULL,
    DF.weighted.fatality.ratios = NULL,
    DF.serial.interval          = NULL,
    DF.covariates               = NULL,
    forecast.window             = 7,
    RData.output                = paste0('stan-model-',StanModel,'.RData'),
    DEBUG                       = FALSE
    ) {

    thisFunctionName <- "wrapper.stan";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(lubridate);
    require(readr);
    require(rstan);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( file.exists(RData.output) ) {

        cat(paste0("\n# ",RData.output," already exists; loading this file ...\n"));
        list.output <- readRDS(file = RData.output);
        cat(paste0("\n# Loading complete: ",RData.output,"\n"));

    } else {

        list.output <- wrapper.stan_inner(
            StanModel                   = StanModel,
            FILE.stan.model             = FILE.stan.model,
            DF.covid19                  = DF.covid19,
            DF.weighted.fatality.ratios = DF.weighted.fatality.ratios,
            DF.serial.interval          = DF.serial.interval,
            DF.covariates               = DF.covariates,
            RData.output                = RData.output,
            DEBUG                       = DEBUG
            );

        if (!is.null(RData.output)) {
            saveRDS(object = list.output, file = RData.output);
            }

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    wrapper.stan_visualize.results(
        list.input = list.output
        );

    plot.3.panel(
        list.input = list.output
        );

    plot.forecast(
        list.input      = list.output,
        forecast.window = forecast.window
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    # return( DF.output );
    return( list.output );

    }

##################################################
wrapper.stan_visualize.results <- function(
    list.input = NULL
    ) {
    
    require(bayesplot);

    # to visualize results

    StanModel     <- list.input[["StanModel"]];
    jurisdictions <- list.input[["jurisdictions"]];

    plot_labels <- c(
        "School Closure",
        "Self Isolation",
        "Public Events",
        "First Intervention",
        "Lockdown",
        'Social distancing'
        );

    alpha <- as.matrix(list.input[["out"]][["alpha"]]);

    colnames(alpha) <- plot_labels;

    g <- bayesplot::mcmc_intervals(alpha, prob = .9);
    ggsave(
        filename = paste0("output-",StanModel,"-covars-alpha-log.png"),
        plot     = g,
        device   = "png",
        width    = 4,
        height   = 6
        );

    g <- bayesplot::mcmc_intervals(alpha, prob = .9,transformations = function(x) exp(-x));
    ggsave(
        filename = paste0("output-",StanModel,"-covars-alpha.png"),
        plot     = g,
        width    = 4,
        height   = 6
        );

    mu <- as.matrix(list.input[["out"]][["mu"]]);
    colnames(mu) = jurisdictions;

    g <- bayesplot::mcmc_intervals(mu,prob = .9);
    ggsave(
        filename = paste0("output-",StanModel,"-covars-mu.png"),
        plot     = g,
        width    = 4,
        height   = 6
        );

    dimensions   <- dim(list.input[["out"]][["Rt"]]);
    Rt           <- as.matrix(list.input[["out"]][["Rt"]][,dimensions[2],]);
    colnames(Rt) <- jurisdictions;

    g <- bayesplot::mcmc_intervals(Rt,prob = .9);
    ggsave(
        filename = paste0("output-",StanModel,"-covars-final-rt.png"),
        plot     = g,
        width    = 4,
        height   = 6
        );

    return( NULL );

    }

wrapper.stan_inner <- function(
    StanModel                   = NULL,
    FILE.stan.model             = NULL,
    DF.covid19                  = NULL,
    DF.weighted.fatality.ratios = NULL,
    DF.serial.interval          = NULL,
    DF.covariates               = NULL,
    RData.output                = NULL,
    DEBUG                       = FALSE
    ) {

    n.covariates  <- ncol(DF.covariates) - 1;
    jurisdictions <- unique(DF.covid19[,'jurisdiction']);
    forecast      <- 0;

    if( DEBUG == FALSE ) {
        N2 = 200 # Increase this for a further forecast
    }  else  {
        ### For faster runs:
        # jurisdictions <- c("Austria","Belgium") #,Spain")
        N2 = 200
        }

    dates          <- list();
    reported_cases <- list();

    stan_data <- list(
        M             = length(jurisdictions),
        N             = NULL,
        p             = n.covariates,
        x1            = poly(1:N2,2)[,1],
        x2            = poly(1:N2,2)[,2],
        y             = NULL,
        covariate1    = NULL,
        covariate2    = NULL,
        covariate3    = NULL,
        covariate4    = NULL,
        covariate5    = NULL,
        covariate6    = NULL,
        covariate7    = NULL,
        deaths        = NULL,
        f             = NULL,
        N0            = 6, # N0 = 6 to make it consistent with Rayleigh
        cases         = NULL,
        LENGTHSCALE   = 7,
        SI            = DF.serial.interval[,"fit"][1:N2],
        EpidemicStart = NULL
        );

    deaths_by_jurisdiction = list();

    for( jurisdiction in jurisdictions ) {

        CFR <- DF.weighted.fatality.ratios$weighted_fatality[DF.weighted.fatality.ratios$jurisdiction == jurisdiction];

        date.colnames <- setdiff(colnames(DF.covariates),"jurisdiction");
        covariates1   <- DF.covariates[DF.covariates$jurisdiction == jurisdiction,date.colnames];

        d1      <- DF.covid19[DF.covid19$jurisdiction == jurisdiction,];
        #d1$date <- d1$DateRep;
        d1$t    <- decimal_date(d1$date);
        d1      <- d1[order(d1$t),];

        index  <- which(d1$cases>0)[1];
        index1 <- which(cumsum(d1$deaths)>=10)[1]; # also 5
        index2 <- index1 - 30;

        print(sprintf("First non-zero cases is on day %d, and 30 days before 5 days is day %d",index,index2));
        d1 <- d1[index2:nrow(d1),];
        stan_data$EpidemicStart <- c(stan_data$EpidemicStart,index1+1-index2);

        for ( ii in 1:ncol(covariates1) ) {
            covariate <- names(covariates1)[ii];
            # should this be > or >=?
            #d1[covariate] <- (as.Date(d1$DateRep,format='%d/%m/%Y') >= as.Date(covariates1[1,covariate])) * 1
            #d1[covariate] <- (d1$DateRep >= as.Date(covariates1[1,covariate])) * 1
            d1[covariate] <- (d1$date >= as.Date(covariates1[1,covariate])) * 1
            }

        dates[[jurisdiction]] = d1$date;
        # hazard estimation
        N <- length(d1$cases);
        print(sprintf("%s has %d days of data",jurisdiction,N));
        forecast <- N2 - N;
        if( forecast < 0 ) {
            print(sprintf("%s: %d", jurisdiction, N))
            print("ERROR!!!! increasing N2")
            N2 <- N;
            forecast <- N2 - N;
            }

        h <- rep(0,forecast+N) # discrete hazard rate from time t = 1, ..., 100
        if( DEBUG ) { # OLD -- but faster for testing this part of the code

            mean <- 18.8;
            cv   <- 0.45;

            for( i in 1:length(h) ) {
                h[i] <- (
                    CFR * pgammaAlt(i,  mean = mean,cv=cv)
                    -
                    CFR * pgammaAlt(i-1,mean = mean,cv=cv)
                    ) / (
                    1 - CFR * pgammaAlt(i-1,mean = mean,cv=cv)
                    );
                }

        } else { # NEW

            mean1 <-  5.1; cv1 <- 0.86; # infection to onset
            mean2 <- 18.8; cv2 <- 0.45; # onset to death

            ## assume that CFR is probability of dying given infection
            x1 <- rgammaAlt(5e6,mean1,cv1) # infection-to-onset ----> do all people who are infected get to onset?
            x2 <- rgammaAlt(5e6,mean2,cv2) # onset-to-death
            f  <- ecdf(x1+x2);
            convolution <- function(u) { CFR * f(u) }

            h[1] = (convolution(1.5) - convolution(0));
            for( i in 2:length(h) ) {
                h[i] = (convolution(i+.5) - convolution(i-.5)) / (1-convolution(i-.5));
                }

            }

        s    <- rep(0,N2);
        s[1] <- 1;
        for( i in 2:N2 ) {
            s[i] <- s[i-1]*(1-h[i-1]);
            }
        f <- s * h;

        y <- c(as.vector(as.numeric(d1$cases)),rep(-1,forecast));
        reported_cases[[jurisdiction]] <- as.vector(as.numeric(d1$cases));
        deaths <- c(as.vector(as.numeric(d1$deaths)),rep(-1,forecast));
        cases  <- c(as.vector(as.numeric(d1$cases)),rep(-1,forecast));
        deaths_by_jurisdiction[[jurisdiction]] <- as.vector(as.numeric(d1$deaths))
        covariates2 <- as.data.frame(d1[, colnames(covariates1)]);

        # x=1:(N+forecast)
        covariates2[N:(N+forecast),] <- covariates2[N,];

        # append data
        stan_data$N <- c(stan_data$N,N   );
        stan_data$y <- c(stan_data$y,y[1]); # just the index case!
        # stan_data$x = cbind(stan_data$x,x)
        stan_data$covariate1 <- cbind(stan_data$covariate1,covariates2[,1]);
        stan_data$covariate2 <- cbind(stan_data$covariate2,covariates2[,2]);
        stan_data$covariate3 <- cbind(stan_data$covariate3,covariates2[,3]);
        stan_data$covariate4 <- cbind(stan_data$covariate4,covariates2[,4]);
        stan_data$covariate5 <- cbind(stan_data$covariate5,covariates2[,5]);
        stan_data$covariate6 <- cbind(stan_data$covariate6,covariates2[,6]);
        stan_data$covariate7 <- cbind(stan_data$covariate7,covariates2[,7]);
        stan_data$f          <- cbind(stan_data$f,f);
        stan_data$deaths     <- cbind(stan_data$deaths,deaths);
        stan_data$cases      <- cbind(stan_data$cases,cases);

        stan_data$N2 <- N2;
        stan_data$x  <- 1:N2;
        if( length(stan_data$N) == 1 ) {
            stan_data$N <- as.array(stan_data$N);
            }

        } # for( jurisdiction in jurisdictions )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    stan_data$covariate2 <- 0 * stan_data$covariate2 # remove travel bans
    stan_data$covariate4 <- 0 * stan_data$covariate5 # remove sport

    #stan_data$covariate1 <- stan_data$covariate1 # school closure
    stan_data$covariate2  <- stan_data$covariate7 # self-isolating if ill
    #stan_data$covariate3 <- stan_data$covariate3 # public events

    # create the `any intervention` covariate
    stan_data$covariate4 <- 1 * as.data.frame((
        stan_data$covariate1 + stan_data$covariate3 + stan_data$covariate5 +
        stan_data$covariate6 + stan_data$covariate7
        ) >= 1);

    stan_data$covariate5 <- stan_data$covariate5 # lockdown
    stan_data$covariate6 <- stan_data$covariate6 # social distancing encouraged
    stan_data$covariate7 <- 0 # models should only take 6 covariates

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if( DEBUG ) {
        for(i in 1:length(jurisdictions)) {
            write.csv(
                file = sprintf("check-dates-%s.csv",jurisdictions[i]),
                x    = data.frame(
                    date                               = dates[[i]],
                    `school closure`                   = stan_data$covariate1[1:stan_data$N[i],i],
                    `self isolating if ill`            = stan_data$covariate2[1:stan_data$N[i],i],
                    `public events`                    = stan_data$covariate3[1:stan_data$N[i],i],
                    `government makes any intervention`= stan_data$covariate4[1:stan_data$N[i],i],
                    `lockdown`                         = stan_data$covariate5[1:stan_data$N[i],i],
                    `social distancing encouraged`     = stan_data$covariate6[1:stan_data$N[i],i]
                    ),
                row.names = FALSE
                );
            }
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    stan_data$y <- t(stan_data$y);
    options(mc.cores = parallel::detectCores())
    rstan_options(auto_write = TRUE)
    m <- rstan::stan_model(FILE.stan.model);

    if(DEBUG) {
        fit <- rstan::sampling(object = m, data = stan_data, iter = 40, warmup = 20, chains = 2);
    } else {

        # fit = rstan::sampling(
        #     object  = m,
        #     data    = stan_data,
        #     iter    = 4000,
        #     warmup  = 2000,
        #     chains  = 8,
        #     thin    = 4,
        #     control = list(adapt_delta = 0.90, max_treedepth = 10)
        #     );

        #fit <- rstan::sampling(
        #    object  = m,
        #    data    = stan_data,
        #    iter    = 200,
        #    warmup  = 100,
        #    chains  = 4,
        #    thin    = 4,
        #    control = list(adapt_delta = 0.90, max_treedepth = 10)
        #    );

        fit = rstan::sampling(
            object  = m,
            data    = stan_data,
            iter    = 1000,
            warmup  =  500,
            chains  = 4,
            thin    = 4,
            control = list(adapt_delta = 0.90, max_treedepth = 10)
            );

        }

    out                 <- rstan::extract(fit);
    prediction          <- out$prediction;
    estimated.deaths    <- out$E_deaths;
    estimated.deaths.cf <- out$E_deaths0;

    list.output <- list(
        StanModel              = StanModel,
        fit                    = fit,
        prediction             = prediction,
        dates                  = dates,
        reported_cases         = reported_cases,
        deaths_by_jurisdiction = deaths_by_jurisdiction,
        jurisdictions          = jurisdictions,
        estimated_deaths       = estimated.deaths,
        estimated_deaths_cf    = estimated.deaths.cf,
        out                    = out,
        covariates             = DF.covariates
        );

    return( list.output );

    }

##################################################

