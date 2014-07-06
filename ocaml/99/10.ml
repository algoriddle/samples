let head = function
  | [] -> failwith "empty list"
  | hd :: _ -> hd
;;

let rev l =
  let rec loop acc = function
    | [] -> acc
    | hd :: tl -> loop (hd :: acc) tl
  in
  loop [] l
;;

let length l =
  let rec loop acc = function
    | [] -> acc
    | _ :: tl -> loop (acc + 1) tl
  in
  loop 0 l
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

let map f l =
  let rec loop acc = function
  | [] -> acc
  | hd :: tl -> loop (f hd :: acc) tl
  in
  l |> loop [] |> rev
;;

let encode l =
  l 
  |> pack
  |> map (fun l -> (length l, head l))
;;

encode ["a";"a";"a";"a";"b";"c";"c";"a";"a";"d";"e";"e";"e";"e"];;
