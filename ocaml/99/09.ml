let rev l =
  let rec loop acc = function
    | [] -> acc
    | hd :: tl -> loop (hd :: acc) tl
  in
  loop [] l
;;

let pack l =
  let rec loop group_acc acc = function
    | [] -> acc
    | [x] -> (x :: group_acc) :: acc
    | x :: (y :: _ as tl) -> 
      if x = y 
      then loop (x :: group_acc) acc tl
      else loop [] ((x :: group_acc) :: acc) tl
  in
  l |> loop [] [] |> rev
;;

pack ["a";"a";"a";"a";"b";"c";"c";"a";"a";"d";"d";"e";"e";"e";"e"];;
