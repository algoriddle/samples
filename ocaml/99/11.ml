type 'a rle =
  | One of 'a
  | Many of int * 'a;;

let encode l =
  let acc_item count item acc =
    if count = 0
    then One item :: acc
    else Many (count + 1, item) :: acc
  in
  let rec loop count acc = function
    | [] -> []
    | [x] -> acc_item count x acc
    | x :: (y :: _ as tl) ->
      if x = y
      then loop (count + 1) acc tl
      else loop 0 (acc_item count x acc) tl
  in
  l |> loop 0 [] |> List.rev
;;

open Core.Std

let decode l =
  let rec repeat x acc = function
    | 0 -> acc
    | k -> repeat x (x :: acc) (k - 1)
  in    
  let decode_block acc = function
    | One x -> x :: acc
    | Many (count, x) -> repeat x acc count
  in
  List.fold l ~init:[] ~f:decode_block 
  |> List.rev
;;    

let test = ["a";"a";"a";"a";"b";"c";"c";"a";"a";"d";"e";"e";"e";"e"];;

test |> encode |> decode = test;;
