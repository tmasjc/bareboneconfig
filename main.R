library(yaml)
library(plumber)
library(magrittr)

# default path to file
get_default_path <- function() {
    
    ## Not tested on Windows
    
    # check trailing '/'
    path <- gsub(readLines("init"), pattern = "/$", replacement = "")
    
    # full path to vault.yaml
    sprintf("%s/vault.yaml", path)
}


# Vault Operation --------------------------------------------------------------


open_vault <- function(secret, path = NULL) {
    
    #browser()
    
    # assign default path
    if(is.null(path)) {
        path <- get_default_path()
    }
    
    # return 0 for success, 8 for failure
    status <- tryCatch(
        system(sprintf("ccrypt -d %s -K %s", paste0(path, ".cpt"), secret)),
        error = function(e) e
    )
    
    if(status != 0) {
        stop("Vault cannot be opened.")
    }
    
    read_yaml(path)
    
}

close_vault <- function(secret, configs = NULL, path = NULL) {
    
    #browser()
    
    # assign default path
    if(is.null(path)) {
        path <- get_default_path()
    }
    
    if(!is.null(configs)) {
        # update file
        write(as.yaml(configs), file = path)
    }
    
    # return 0 for success, 8 for failure
    status <- tryCatch(
        system(sprintf("ccrypt %s -K %s", path, secret)),
        error = function(e) e
    )
    
    if(status != 0) {
        stop("Vault cannot be closed.")
    }
    
}
 

# Get  --------------------------------------------------

# decrypt, read, encrypt
get_config <- function(secret, which) {
    
    configs <- open_vault(secret)
    
    # get key
    kv <- configs[[which]]
    
    close_vault(secret)
    
    # return
    kv
    
}


# Update ------------------------------------------------------------------


# decrypt, read, update, encrypt
mod_config <- function(secret, which, key, value) {
    
    configs <- open_vault(secret)
    
    # update key
    configs[[which]][key] <- value
    
    close_vault(secret, configs)
    
    "Success"
    
}


# Delete ------------------------------------------------------------------


# decrypt, read, delete, encrypt
drop_key <- function(secret, which, key) {
    
    configs <- open_vault(secret)
    
    # drop key
    configs[[which]][key] <- NULL
    
    close_vault(secret, configs)
    
    "Success"
    
}


# Insert ------------------------------------------------------------------


# decrypt, read, insert, encrypt
insert_config <- function(secret, which, kvlist) {
    
    configs <- open_vault(secret)
    
    # insert new config
    configs[[which]] <- kvlist
    
    close_vault(secret, configs)
    
    "Success"
    
}


# Plumber -----------------------------------------------------------------

#' @serializer unboxedJSON
#* @get /config
function(token, id) {
    message(sprintf("Retrieve key from %s", id))
    get_config(token, id)
}

#* @post /update
function(token, id, key, value) {
    message(sprintf("Update %s from %s", key, id))
    mod_config(token, id, key, value)
}

#* @get /delete
function(token, id, key) {
    message(sprintf("Drop %s from %s", key, id))
    drop_key(token, id, key)
}

#* @post /insert
function(req, token, id) {
    
    #browser()
    message(sprintf("Add new id", id))
    
    # parse request body
    zz <- strsplit(req$postBody, split = "&") %>% 
        unlist() %>% 
        lapply(FUN = strsplit, split = "=") %>% 
        lapply(unlist)
    
    # assign names
    names(zz) <- lapply(zz, extract, 1) %>% unlist()
    
    # extract components
    comps <- lapply(zz, extract, 2)
    
    # token and id not needed
    comps$token <- NULL
    comps$id <- NULL
    
    # insert to config file
    insert_config(token, zz$id[2], comps)
    
}







