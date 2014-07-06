(*
let compress = function
  | [] -> []
  | hd :: tl ->
    let rec loop acc = function
      | [] -> acc
      | hd :: tl -> 
      if hd = List.hd acc 
      then loop acc tl
      else loop (hd :: acc) tl
    in
    tl |> loop [hd] |> List.rev
;;
*)

let compress l =
  let rec loop acc = function
    | [] -> acc
    | [x] -> x :: acc
    | x :: (y :: _ as tl) -> 
      if x = y 
      then loop acc tl
      else loop (x :: acc) tl
  in
  l |> loop [] |> List.rev
;;

compress ["a";"a";"a";"a";"b";"c";"c";"a";"a";"d";"e";"e";"e";"e"];;
