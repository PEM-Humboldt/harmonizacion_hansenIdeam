#' Split a list into sublists
#'
#' @param input_list The input list to be split
#' @param n The number of sublists
#' @return A list of sublists
#' @export
split_list <- function(input_list, n) {
  # Calculate the number of elements in each sublist
  split_size <- ceiling(length(input_list) / n)
  # Split the list into sublists
  split(input_list, rep(1:n, each = split_size, length.out = length(input_list)))
}
