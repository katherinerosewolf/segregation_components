[![Build Status](https://travis-ci.com/katherinerosewolf/mesc_thesis.svg?token=DTxgzr9n8yRcxMBznjnq&branch=master)](https://travis-ci.com/katherinerosewolf/mesc_thesis)

## TITLE

Racial Residential Segregation and Airborne Fine Particulate Matter Components in the United States

## AUTHOR

Katherine Wolf, @katherinerosewolf

## DESCRIPTION

## FILE LOCATIONS

### Common files

- `README.md` this file, a general overview of the repository in markdown format.  
- `.gitignore` Optional file, ignore common file types we don't want to accidentally commit to GitHub. Most projects should use this. 
- `<REPO-NAME>.Rproj` R-Project file created by RStudio for its own configuration.
- `.gitattributes` I honestly don't know what this does.

### Infrastructure for testing

- `.travis.yml`: A configuration file for automatically running [continuous integration](https://travis-ci.com) checks to verify reproducibility of all `.Rmd` notebooks in the repo.  If all `.Rmd` notebooks can render successfully, the "Build Status" badge above will be green (`build success`), otherwise it will be red (`build failure`).  
- `DESCRIPTION` a metadata file for the repository, based on the R package standard. It's main purpose here is as a place to list any additional R packages/libraries needed for any of the `.Rmd` files to run.
- `tests/render_rmds.R` an R script that is run to execute the above described tests, rendering all `.Rmd` notebooks. 
- `.Rbuildignore` I honestly don't know what this does either.