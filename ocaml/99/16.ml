let drop l c =
  let rec drop acc i = function
    | [] -> acc
    | hd :: tl ->
      if i = 1
      then drop acc c tl
      else drop (hd :: acc) (i - 1) tl
  in
  drop [] c l |> List.rev;;

drop ["a";"b";"c";"d";"e";"f";"g";"h";"i";"j"] 3;;
