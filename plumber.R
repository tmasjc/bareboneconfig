library(plumber)

# check trailing '/'
path <- gsub(readLines("init"), pattern = "/$", replacement = "")

# full path to vault.yaml
path <- sprintf("%s/vault.yaml.cpt", path)

if(!file.exists(path)) {
    stop("Vault not found. Have you run `./deploy.R`?")
}

r <- plumb("main.R")
r$run(host = "0.0.0.0", port = 7788)

