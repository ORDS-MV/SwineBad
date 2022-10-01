FROM rocker/geospatial:4.2.1

RUN R -e 'install.packages("renv");'

RUN apt update \
    && apt install -y cmake

USER rstudio
COPY --chown=rstudio:rstudio renv/activate.R /home/rstudio/SwineBad/renv/
COPY --chown=rstudio:rstudio renv.lock /home/rstudio/SwineBad/
COPY --chown=rstudio:rstudio .Rprofile /home/rstudio/SwineBad/

# define work folder
WORKDIR /home/rstudio/SwineBad

RUN R -e 'renv::restore()'

USER root
