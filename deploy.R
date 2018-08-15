#!/usr/bin/env Rscript --vanilla

library(argparser, quietly = TRUE)
library(yaml)

p <- arg_parser(description = "A bare bone configuration management for quick and dirty development purposes.")

# positional argument
p <- add_argument(p, "secret", "Secret to lock / unlock vault. Do not forget this.")

# optinal argument
p <- add_argument(p, "--file", "An initial config file (*.yaml)")
p <- add_argument(p, "--force", "Force override existing config file", flag = TRUE)
p <- add_argument(p, "--path", "Path to initializing vault. Default '~/.bbcfg/'")
argvs <- parse_args(p)


# set up a new environment
v <- new.env()

# which path to vault
if(is.na(argvs$path)) {
    v$path <- "~/.bbcfg"
} else {
    v$path <- gsub(argvs$path, pattern = "/$", replacement = "")
}

# create vault
if(!dir.exists(v$path)) {
    dir.create(v$path)
}

# path to vault yaml
v$vault <- sprintf("%s/vault.yaml", v$path)

# either make one or read one from user
if(is.na(argvs$file)) {
    # a dummy config to kickstart
    v$config <- list(
            Dummy.One = list(
                user = "admin",
                password = "HelloWorld2018",
                host = "somewhere",
                port = "someport")
        )
} else {
    # read from specify config file
    v$config <- read_yaml(argvs$file)
}

# helper function
write_into_vault <- function(config, vault, secret) {
    
    # write into vault
    tryCatch(write(as.yaml(config), file = vault),
             error = function(e) e,
             finally = message("Vault initiated."))
    
    # encrypt
    system(sprintf("ccrypt %s -K %s --force", vault, secret))
    
    return(1)
}

# vault exists?
if(!file.exists(paste0(v$vault, ".cpt"))) {
    
    tryCatch(file.create(v$vault), finally = message("Initiate new vault."))
    status <- write_into_vault(v$config, v$vault, argvs$secret)
    msg <- ifelse(status == 1, "Success!", "Failed: Action cannot be completed.")
    
} else {

    # check if overriden is permitted
    if(argvs$force) {
        
        # remove existing vault
        tryCatch(file.remove(paste0(v$vault, ".cpt")), finally = message("Remove existing vault."))
        tryCatch(file.create(v$vault), finally = message("Initiate new vault."))
        status <- write_into_vault(v$config, v$vault, argvs$secret)
        msg <- ifelse(status == 1, "Success!", "Failed: Action cannot be completed.")
        
    } else {
        
        # overriden is not permitted
        msg <- sprintf("Vault has been initiated at %s.\nUse --force to start anew.", v$path)
    }
}

# ends here
message(msg)

