type 'a node =
  | One of 'a 
  | Many of 'a node list
;;

(* using a stack, needlessly complicated
let flatten l =
  let rec flatten_acc acc = function
    | [] -> acc
    | hd::tl -> 
      match hd with
      | [] -> flatten_acc acc tl
      | h::t -> 
        match h with
        | One x -> flatten_acc (x::acc) (t::tl)
        | Many l -> flatten_acc acc (l::t::tl)
  in
  flatten_acc [] [l] |> List.rev
;;
*)

let flatten l =
  let rec loop acc = function
    | [] -> acc
    | One x :: tl -> loop (x :: acc) tl
    | Many l :: tl -> loop (loop acc l) tl
  in
  l |> loop [] |> List.rev
;;

flatten [ One "a" ; Many [ One "b" ; Many [ One "c" ; One "d" ] ; One "e" ] ];;
