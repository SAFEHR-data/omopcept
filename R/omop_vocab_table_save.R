#' save omop vocabulary parquet file from provided location to local package cache
#'
#' default using UCLH github repo, option to use local files
#'
#' @param tablename which omop table to download, defaults to 'concept'
#' @param from url of file source location, defaults to UCLH filestore
#' @param to path to save file locally, defaults to package cache which is where omopcept functions look
#' @param download_max_secs max download secounds, default 720 = 12 mins
#'
#' @returns nothing
#' @seealso [omop_vocabs_preprocess()]
#'    alternative that reads in csvs downloaded from Athena and saves to parquet also in local package cache
#'
#' @export
omop_vocab_table_save <- function( tablename = "concept",
                           from = NULL,
                           to = tools::R_user_dir("omopcept", which = "cache"),
                           download_max_secs = 720) {

  if (is.null(from))
  {
    message("Warning: downloading a subset of omop vocab files, pre-processed.\n",
            "If you want to make sure you have the vocabs you need, download from Athena, save locally & call `omop_vocabs_preprocess()`\n")
    tag <- "v4"
    from <- paste0("https://github.com/SAFEHR-data/omop-vocabs-processed/raw/refs/tags/",
                   tag,"/data/")
  }

  #increase timeout, allow that user may have set timeout
  #to be higher via environment variable R_DEFAULT_INTERNET_TIMEOUT
  options(timeout = max(download_max_secs, getOption("timeout")))
  #options(timeout = download_max_secs)

  message("downloading ",tablename, " file, may take a few minutes",
          ", this only needs to be repeated if the package is re-installed")

  # processed data saved in recommended location
  # https://r-pkgs.org/data.html#sec-data-persistent
  # Persistent user data
  # Sometimes there is data that your package obtains, on behalf of itself or the user,
  # that should persist even across R sessions.
  # The primary function you should use to derive acceptable locations for user data is tools::R_user_dir()

  #recursive means it creates all nested folders needed
  if (!dir.exists(to)) {dir.create(to, recursive=TRUE )}

  download <- function(f, mode) {

    result <- utils::download.file(paste0(from,f),
                  destfile = file.path(to,f),
                  mode = mode)

    #if download fails try to remove any partial file
    if (result != 0) {
      warning("download of vocabulary table seems to have failed, try repeating")
      file.remove(file.path(to,f))
    }

  }

  download(paste0(tablename,".parquet"), "wb")
}
