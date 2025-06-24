# library(testthat)
# library(interfacer)
# 
# # Tests ----
# test_that(".should_run_checks() behaves correctly", {
#   
#   # Case 1: In global environment → should run
#   expect_true({
#     caller_env <- globalenv()
#     x = function() {
#       return(.should_run_checks())
#     }
#     environment(x) <- caller_env
#     x()
#   })
#   
#   # Case 2: In dev-loaded package (has 'path' attribute) → should run
#   expect_true({
#     ns <- new.env()
#     attr(ns, "package") <- "mypkg"
#     attr(ns, "path") <- "/some/path"
#     x = function() {
#       return(.should_run_checks())
#     }
#     environment(x) <- ns
#     x()
#   })
#   
#   # # Case 3: Installed package (no 'path') → should NOT run
#   # expect_false({
#   #   withr::with_envvar(list("TESTTHAT" = "false"), {
#   #     ns <- new.env()
#   #     attr(ns, "package") <- "mypkg"
#   #     x = function() {
#   #       return(.should_run_checks())
#   #     }
#   #     environment(x) <- ns
#   #     x()
#   #   })
#   # })
#   
#   # Case 4: Inside testthat → should run
#   expect_true({
#     ns <- new.env()
#     attr(ns, "package") <- "mypkg"
#     withr::with_envvar(list("TESTTHAT" = "true"), {
#       x = function() {
#         return(.should_run_checks())
#       }
#       environment(x) <- ns
#       x()
#     })
#   })
#   
#   # Case 5: Inside R CMD check (NOT_CRAN) → should run
#   expect_true({
#     ns <- new.env()
#     attr(ns, "package") <- "mypkg"
#     withr::with_envvar(list("NOT_CRAN" = "true"),{
#       x = function() {
#         return(.should_run_checks())
#       }
#       environment(x) <- ns
#       x()
#     })
#   })
#   
#   # Case 6: Option override → should run
#   expect_true({
#     ns <- new.env()
#     attr(ns, "package") <- "mypkg"
#     withr::with_options(
#       list(interfacer.always_check_outputs = TRUE),{
#         x = function() {
#           return(.should_run_checks())
#         }
#         environment(x) <- ns
#         x()
#       })
#   })
# })