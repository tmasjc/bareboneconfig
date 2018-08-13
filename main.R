library(yaml)
library(plumber)
library(purrr)
library(magrittr)

# Main Function Goes Here -------------------------------------------------

# default path to file
DEFAULT_PATH = "~/rconfig.yaml"

# decrypt, read, encrypt
get_config <- function(secret, which, path = DEFAULT_PATH) {
    
    system(sprintf("ccrypt -d %s -K %s", paste0(path, ".cpt"), secret))
    
    configs <- read_yaml(path)
    
    # get key
    kv <- configs[[which]]
    
    system(sprintf("ccrypt %s -K %s", path, secret))
    
    # return
    kv
    
}

# decrypt, read, update, encrypt
mod_config <- function(secret, which, key, value, path = DEFAULT_PATH) {
    
    system(sprintf("ccrypt -d %s -K %s", paste0(path, ".cpt"), secret))
    
    configs <- read_yaml(path)
    
    configs[[which]][key] <- value
    
    # update file
    write(as.yaml(configs), file = DEFAULT_PATH)
    
    system(sprintf("ccrypt %s -K %s", path, secret))
    
    "Success"
    
}

# decrypt, read, delete, encrypt
rm_key <- function(secret, which, key, path = DEFAULT_PATH) {
    
    system(sprintf("ccrypt -d %s -K %s", paste0(path, ".cpt"), secret))
    
    configs <- read_yaml(path)
    
    configs[[which]][key] <- NULL
    
    # update file
    write(as.yaml(configs), file = DEFAULT_PATH)
    
    system(sprintf("ccrypt %s -K %s", path, secret))
    
    "Success"
    
}

# decrypt, read, insert, encrypt
insert_config <- function(secret, which, kvlist, path = DEFAULT_PATH) {
    
    system(sprintf("ccrypt -d %s -K %s", paste0(path, ".cpt"), secret))
    
    configs <- read_yaml(path)
    
    # insert new config
    configs[[which]] <- kvlist
    
    # update file
    write(as.yaml(configs), file = DEFAULT_PATH)
    
    system(sprintf("ccrypt %s -K %s", path, secret))
    
    "Success"
    
}

#* @get /config
function(token, id) {
    get_config(token, id)
}

#* @post /update
function(token, id, key, value) {
    mod_config(token, id, key, value)
}

#* @get /delete
function(token, id, key) {
    rm_key(token, id, key)
}

#* @post /insert
function(req, token, id) {
    
    # parse request body
    zz <- strsplit(req$postBody, split = "&") %>% 
        flatten() %>% 
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







