(*
let rec duplicate = function
  | [] -> []
  | hd :: tl -> hd :: hd :: duplicate tl;;
*)

let duplicate l =
  let rec aux acc = function
    | [] -> acc
    | hd :: tl -> aux (hd :: hd :: acc) tl
  in
  aux [] l |> List.rev;;

duplicate ["a";"b";"c";"c";"d"];;
