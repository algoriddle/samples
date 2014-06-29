type 'a tree = Empty | Node of 'a * 'a tree * 'a tree

let test = Node (10, 
                 Node (30, Empty, Empty), 
                 Node (20, Empty, 
                       Node (40, Empty, Empty)))

let rec height = function
  | Empty -> 0
  | Node (_, l, r) -> 1 + max (height l) (height r)

let height_tr tree = 
  let rec aux depth = function
    | [] -> depth
    | (d, Empty)::t -> aux (max d depth) t
    | (d, Node (_, l, r))::t -> aux depth ((d + 1, l)::(d + 1, r)::t)
  in
  aux 0 [(0, tree)]
