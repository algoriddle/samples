open Core.Std

type 'a tree = Empty | Node of 'a * 'a tree * 'a tree

(* generate random tree of given depth *)
let rec generate = function
  | 0 -> Empty
  | d -> Node (Random.int 5 - 2, (generate (d - 1)), (generate (d - 1)));;

Random.init 12345;;

let test = generate 5;;

(* add to 'acc' those sublists of 'list' that begin with head and sum to 'sum' *)
let sublists acc list sum =
  let (res, _, _) = List.fold list ~init:(acc, [], 0) ~f:(fun (ls, l, s) x ->
      let ns = s + x in
      let nl = x :: l in
      if ns = sum
      then (nl :: ls, nl, ns)
      else (ls, nl, ns)) in
  res;;

sublists [] [2; 2; -2; 2; 0; 1] 4;;

(* find paths in the 'tree' that sum to 'sum' *)
let paths tree sum =
  let rec aux paths path = function
    | Empty -> paths
    | Node (x, left, right) ->
      let new_path = x :: path in
      let new_paths = sublists paths new_path sum in
      let left_paths = aux new_paths new_path left in
      aux left_paths new_path right
  in
  aux [] [] tree
;;

paths test 0;;
