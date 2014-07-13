type 'a tree = Empty | Node of 'a * 'a tree * 'a tree

let test =
  Node (2,
        Node (-1,
              Node (2,
                    Node (-1,
                          Node (1, Empty, Empty),
                          Node (2, Empty, Empty)),
                    Node (2,
                          Node (-2, Empty, Empty),
                          Node (2, Empty, Empty))),
              Node (1,
                    Node (1,
                          Node (1, Empty, Empty),
                          Node (2, Empty, Empty)),
                    Node (0,
                          Node (0, Empty, Empty),
                          Node (2, Empty, Empty)))),
        Node (1,
              Node (1,
                    Node (0,
                          Node (1, Empty, Empty),
                          Node (2, Empty, Empty)),
                    Node (0,
                          Node (2, Empty, Empty),
                          Node (-2, Empty, Empty))),
              Node (0,
                    Node (-1,
                          Node (1, Empty, Empty),
                          Node (2, Empty, Empty)),
                    Node (-2,
                          Node (-1, Empty, Empty),
                          Node (2, Empty, Empty)))));;

(* add to 'lists' those sublists of 'list'
   that begin with head and sum to 'sum' *)
let sublists list sum lists =
  let (res, _, _) = List.fold (fun (ls, l, s) x ->
      let ns = s + x in
      let nl = x :: l in
      if ns = sum
      then (nl :: ls, nl, ns)
      else (ls, nl, ns)) (lists, [], 0) list in
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
