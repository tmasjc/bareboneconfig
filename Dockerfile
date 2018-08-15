FROM rocker/r-base
MAINTAINER Thomas Jc <thomas.jcng@gmail.com>

RUN apt-get update -qq && apt-get install -y \
    git-core \
    libssl-dev \
    libcurl4-gnutls-dev \
    ccrypt

RUN R -e 'install.packages(c("magrittr", "plumber", "yaml", "argparser"), \
    repos = "http://mirrors.tuna.tsinghua.edu.cn/CRAN/")'

COPY . /bareboneconfigs

WORKDIR /bareboneconfigs

RUN ["./deploy.R", "1234"]

CMD ["Rscript", "plumber.R", "&"]
