let split l n =
  let rec aux acc n = function
    | [] -> (List.rev acc, [])
    | hd :: tl as l ->
      if n = 0
      then (List.rev acc, l)
      else aux (hd :: acc) (n - 1) tl
  in
  aux [] n l
;;

split ["a";"b";"c";"d";"e";"f";"g";"h";"i";"j"] 3;;

split ["a";"b";"c";"d"] 5;;

split ["a";"b";"c";"d"] 0;;
