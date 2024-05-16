FROM rocker/r-ver:4.2.3

# Maintainer information
MAINTAINER Bastien Grasset "bastien.grasset@ird.fr"

# Install system libraries of general use
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libudunits2-dev \
    libproj-dev \
    libgeos-dev \
    libgdal-dev \
    libv8-dev \
    libsodium-dev \
    libsecret-1-dev \
    git \
    libnetcdf-dev
    
# Update and upgrade the system
RUN apt-get update && apt-get upgrade -y

# Install cmake
RUN apt-get update && apt-get -y install cmake

# Install R core package dependencies
RUN install2.r --error --skipinstalled --ncpus -1 httpuv
RUN R -e "install.packages(c('remotes', 'jsonlite', 'yaml'), repos='https://cran.r-project.org/')"

# Install renv package
RUN R -e "install.packages('renv', repos='https://cran.r-project.org/')"

ARG RENV_PATHS_ROOT=/root/minorshinyapp/renv/.cache
# Set environment variables based on build arguments
ENV RENV_PATHS_ROOT=${RENV_PATHS_ROOT}
RUN mkdir -p RENV_PATHS_ROOT

# Set the working directory
WORKDIR /root/minorshinyapp

RUN mkdir -p renv
COPY renv.lock renv.lock
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json

# Restore renv packages
RUN R -e "renv::restore()"

# Copy the rest of the application code
COPY . /root/minorshinyapp

# Define the entry point to run the Shiny app
CMD ["R", "-e", "shiny::runApp('/root/minorshinyapp', port=3838, host='0.0.0.0')"]
