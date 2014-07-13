open Core.Std

type 'a tree = Empty | Node of 'a * 'a tree * 'a tree

(* generate random tree of given depth *)
let rec generate = function
  | 0 -> Empty
  | d -> Node (Random.int 5 - 2, (generate (d - 1)), (generate (d - 1)));;

Random.init 12345;;

let test = generate 5;;

(* add to 'lists' those sublists of 'list'
   that begin with head and sum to 'sum' *)
let sublists list sum lists =
  let (res, _, _) = List.fold list ~init:(lists, [], 0) ~f:(fun (ls, l, s) x ->
      let ns = s + x in
      let nl = x :: l in
      if ns = sum
      then (nl :: ls, nl, ns)
      else (ls, nl, ns)) in
  res;;

sublists [2; 2; -2; 2; 0; 1] 4 [];;

(* find paths in the 'tree' that sum to 'sum' *)
let paths tree sum =
  let rec aux tree path paths =
    match tree with
    | Empty -> paths
    | Node (x, left, right) ->
      let new_path = x :: path in
      paths
      |> sublists new_path sum
      |> aux left new_path
      |> aux right new_path
  in
  aux tree [] []
;;

paths test 0;;
