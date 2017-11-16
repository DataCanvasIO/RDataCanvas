#' \code{DCRuntime} will parse and extract Input/Output/Paramter, and return
#' in S3 object.
#' 
#' This function will create a runtime object(in S3) for module.
#' In order to create a DCRuntime object, we should provide the following items:
#' \describe{
#'   \item{\emph{spec.json}}{which defines the inputs/outputs/parameters of the module.}
#'   \item{\emph{zetrt.json}}{the parameters at runtime.}
#'   \item{\emph{arguments}}{the arguments from command line. In the format, like "A=1".}
#' }
#'
#' @param spec_json The path for "spec.json".
#' @param zetrt_json The path for "zetrt.json". The default is NULL, which
#'   means we can get it from system environment variable "ZETRT".
#' @param args The arguments for Input/Output with format like "A=1". The default is
#'   NULL, which means we can get it from command line arguments with "commandArgs".
#' @return A S3 object.
#' @export
#' @seealso See \href{http://screwjack.readthedocs.org/en/latest/}{Screwjack} about
#'   howto create a module.
#' @examples
#'
#' \dontrun{example to use DCRuntime
#'   rt <- DCRuntime(spec_json = "/your_path/spec.json",
#'                       zetrt_json = "/some_path/zetrt.json")
#'   # Use "rt" like this:
#'   rt$Output$o1$Val
#'   rt$Input$i1$Val
#'   rt$Param$P1$Val
#' }

authentication <- function(){
    kbConfig = jsonlite::fromJSON(Sys.getenv("kerberosConfig"))
    kdcLocation = kbConfig["kdcLocation"]
    kServer = kbConfig["kServer"]
    userName = kbConfig["kUserName"]
    keyTabRestServer = kbConfig["keyTabServer"]
    keyTabRestPort = kbConfig["keyTabPort"]

    # 1.  下载keyTab文件到~/.kb dir
    destFile <- "/tmp/tmp.keyTab"
    header1 <- " -H 'content-type:application/json'"
    header2 <- " -H 'cache-control:no-cache'"
    header3 <- paste0(" -H '_username:", userName, "'")
    posturl <- paste0(" http://", keyTabRestServer, ":", keyTabRestPort, "/v1/keytab/retrieve")
    curlCommand = paste0("curl ", header1, header2, header3, posturl, " -o ", destFile)

    print(curlCommand)
    system(curlCommand, intern = TRUE)

    # 2. 整理keyTab文件
    echoCommand <- paste0("echo '[realms]\nTEST.COM = {\nkdc = ", kdcLocation, ":88\nadmin_server = ", kServer, ":749\n}' >> /etc/krb5.conf")
    print(echoCommand)
    system(echoCommand, intern = TRUE)

    # 2. 执行shell
    kinitCommand = paste0("kinit -kt ", destFile, " ", userName)
    print(kinitCommand)
    kinitResult <- system(kinitCommand)
    print(kinitResult)
    if (kinitResult != 0) {
        print("authentication fail")
        return(FALSE)
    }else {
        print("authentication success, module is running")
        return(TRUE)
    }
}


DCRuntime <- function (spec_json = "spec.json", zetrt_json = NULL, args = NULL) {

    flag <- FALSE
    if (Sys.getenv("isValidate") == "true") {
        flag <- authentication()
    }

    if (flag|Sys.getenv("isValidate") != "true") {
        if (is.null(zetrt_json))
            zetrt_json <- Sys.getenv("ZETRT")
        if (is.null(args))
            args <- commandArgs(trailingOnly = TRUE)

        zetrt_json <- jsonlite::fromJSON(txt = zetrt_json)
        obj <- jsonlite::fromJSON(txt = spec_json)

        # Params
        param_names <- names(obj$Param)
        obj$Param <- lapply(seq_along(obj$Param), function(i) {
            o <- obj$Param[[i]]
            oname <- param_names[[i]]
            if ("Val" %in% names(zetrt_json$PARAM[[oname]])) {
                o$Val <- zetrt_json$PARAM[[oname]]$Val
            }
            else {
                o$Val <- o$Default
            }
            o
        })
        names(obj$Param) <- param_names

        # Arguments for Input/Output
        args <- commandArgs(trailingOnly = TRUE)
        args_reg_results <- regmatches(args, regexec("([^=]*)=(.*)", args))
        args_names = sapply(args_reg_results, `[[`, 2)
        args_vals = sapply(args_reg_results, `[[`, 3)
        args_kv <- mapply(function (arg_k, arg_v) { arg_v}, args_names, args_vals, SIMPLIFY = FALSE, USE.NAMES = TRUE)

        # Check all args
        input_names <- names(obj$Input)
        output_names <- names(obj$Output)
        all_io_names <- c(input_names, output_names)
        if (! setequal(intersect(args_names, all_io_names), all_io_names)) {
            print("WARNING: not all Input/Output have values")
        }

        # Building every Input
        obj$Input <- lapply(seq_along(obj$Input), function(i) {
            o <- list()
            o$Type <- obj$Input[[i]]
            iname <- input_names[[i]]
            o$Val <- args_kv[[ iname ]]
            o
        })
        names(obj$Input) <- input_names

        # Building every Output
        obj$Output <- lapply(seq_along(obj$Output), function(i) {
            o <- list()
            o$Type <- obj$Output[[i]]
            oname <- output_names[[i]]
            o$Val <- args_kv[[ oname ]]
            o
        })
        names(obj$Output) <- output_names

        # GlobalParams
        obj$GlobalParam <- zetrt_json$GLOBAL_PARAM

        class(obj) <- "zetrt"
        obj
    }
}



if (Sys.getenv("isValidate") == "") {
    # authentication()
    rt <- DCRuntime()
    print(rt)
    # krbServer <- "124.42.117.60"
    # echoCommand <- paste0("echo '[realms]\nTEST.COM = {\nkdc = ",krbServer,":88\nadmin_server = ",krbServer,":749\n}' >> /etc/krb5.conf")
    # print(echoCommand)
    # system(echoCommand,intern = TRUE)
}