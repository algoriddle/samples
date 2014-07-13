open Core.Std

type 'a tree = Empty | Node of 'a * 'a tree * 'a tree

let rec generate = function
  | 0 -> Empty
  | d -> Node (Random.int 5 - 2, (generate (d - 1)), (generate (d - 1)));;

Random.init 12345;;

let test = generate 5;;

let acc_sublists_that_sum_to acc list sum =
  let (res, _, _) = List.fold list ~init:(acc, [], 0) ~f:(fun (ls, l, s) x ->
      let ns = s + x in
      let nl = x :: l in
      if ns = sum 
      then (nl :: ls, nl, ns)
      else (ls, nl, ns)) in
  res;;

acc_sublists_that_sum_to [] [2; 2; -2; 2; 0; 1] 4;;

let find_paths_that_sum_to tree sum =
  let rec aux paths current_path = function
    | Empty -> paths
    | Node (x, left, right) -> 
      let new_path = x :: current_path in
      let new_paths = acc_sublists_that_sum_to paths new_path sum in
      let new_left_paths = aux new_paths new_path left in
      aux new_left_paths new_path right
  in
  aux [] [] tree
;;

find_paths_that_sum_to test 0;;
