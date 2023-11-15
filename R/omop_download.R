#' download omop vocabulary file from provided location to local package cache
#'
#' default using UCLH temporary private filestore, option use local files
#'
#' TODO do I want to rename this function ? omop_vocab_table_download() or ..._save()
#'
#' @param tablename which omop table to download, defaults to 'concept'
#' @param from url of file source location, defaults to UCLH filestore
#' @param to path to save file locally, defaults to package cache which is where omop_concept() looks for it
#' @param download_max_secs max download secounds, default 720 = 12 mins
#'
#' @export
omop_download <- function( tablename = "concept",
                           from = "https://omopes.blob.core.windows.net/newcontainer/",
                           to = tools::R_user_dir("omopcept", which = "cache"),
                           download_max_secs = 720) {

  #increase timeout, allow that user may have set timeout
  #to be higher via environment variable R_DEFAULT_INTERNET_TIMEOUT
  options(timeout = max(download_max_secs, getOption("timeout")))
  #options(timeout = download_max_secs)

  message("downloading ",tablename, " file, may take a few minutes",
          ", this only needs to be repeated if the package is re-installed")

  #concept_ancestor took just over a minute on local PC
  #concept_relationship took ~5 minutes on local PC

  #concept_relationship
  #Error ... In utils::download.file ... Timeout of 360 seconds was reached

  #where to save concept file ? to allow user to update.
  # https://r-pkgs.org/data.html#sec-data-persistent
  # Persistent user data
  # Sometimes there is data that your package obtains, on behalf of itself or the user,
  # that should persist even across R sessions.
  # The primary function you should use to derive acceptable locations for user data is tools::R_user_dir()

  dest_path <- to

  #[1] "C:\\Users\\andy.south\\AppData\\Local/R/cache/R/omopcept"

  #FAILED before on DataScienceDesktop
  #In dir.create(dest_path) :
  #  cannot create dir 'F:\UserProfiles\andsouth\AppData\Local\R\cache\R\omopcept', reason 'No such file or directory'
  #have to go up quite a few levels to find one that does work
  #dir.exists("F:\\UserProfiles\\andsouth\\AppData\\Local/") [1] TRUE

  #recursive means it creates all nested folders needed
  if (!dir.exists(dest_path)) {dir.create(dest_path, recursive=TRUE )}

  download <- function(f, mode) {
    utils::download.file(paste0(from,f),
                  destfile = file.path(dest_path,f),
                  mode = mode)
  }

  download(paste0(tablename,".parquet"), "wb")
  # download("concept_relationship.parquet", "wb")
  # download("concept_ancestor.parquet", "wb")
  # download("drug_strength.parquet", "wb")
  # download("metadata_version.txt", "w")
}
