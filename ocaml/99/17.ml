let split l n =
  let rec aux acc n = function
    | [] -> (acc, [])
    | hd :: tl as l ->
      if n = 0
      then (acc, l)
      else aux (hd :: acc) (n - 1) tl
  in
  let (front, back) = aux [] n l in
  (List.rev front, back)
;;

split ["a";"b";"c";"d";"e";"f";"g";"h";"i";"j"] 3;;

split ["a";"b";"c";"d"] 5;;

split ["a";"b";"c";"d"] 0;;
