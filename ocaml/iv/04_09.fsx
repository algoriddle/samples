type 'a tree = Empty | Node of 'a * 'a tree * 'a tree

let test = Node (2,
                 Node (-1,
                       Node (2, Node (-1, Node (1, Empty, Empty), Node (2, Empty, Empty)),
                             Node (2, Node (-2, Empty, Empty), Node (2, Empty, Empty))),
                       Node (1, Node (1, Node (1, Empty, Empty), Node (2, Empty, Empty)),
                             Node (0, Node (0, Empty, Empty), Node (2, Empty, Empty)))),
                 Node (1,
                       Node (1, Node (0, Node (1, Empty, Empty), Node (2, Empty, Empty)),
                             Node (0, Node (2, Empty, Empty), Node (-2, Empty, Empty))),
                       Node (0, Node (-1, Node (1, Empty, Empty), Node (2, Empty, Empty)),
                             Node (-2, Node (-1, Empty, Empty), Node (2, Empty, Empty)))));;

let accSublistsThatSumTo acc list sum =
  let (res, _, _) =
    List.fold (fun (ls, l, s) x ->
               let ns = s + x
               let nl = x :: l
               if ns = sum
               then (nl :: ls, nl, ns)
               else (ls, nl, ns)) (acc, [], 0) list
  res;;

accSublistsThatSumTo [] [2; 2; -2; 2; 0; 1] 4;;

let findPathsThatSumTo tree sum =
  let rec aux paths current_path = function
    | Empty -> paths
    | Node (x, left, right) -> 
      let new_path = x :: current_path in
      let new_paths = accSublistsThatSumTo paths new_path sum in
      let new_left_paths = aux new_paths new_path left in
      aux new_left_paths new_path right
  in
  aux [] [] tree
;;

findPathsThatSumTo test 0;;
