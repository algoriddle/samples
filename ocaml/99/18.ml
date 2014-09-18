let rec fold acc f = function
  | [] -> acc
  | hd :: tl -> fold (f acc hd) f tl
;;

let rec fold_until n acc f = function
  | [] -> (acc, [])
  | hd :: tl as l -> if n = 0 then (acc, l)
    else fold_until (n - 1) (f acc hd) f tl
;;

let take n list = fold_until n

let slice list start stop = 
  let rec skip n = function
    | [] -> []
    | (_ :: tl) as l ->
      if n > 1 then skip (n - 1) tl
      else take (stop - start + 1) l
  and take n = function
    | [] -> []
    | hd :: tl ->
      if n > 0 then hd :: take (n - 1) tl
      else []
    in
    skip start list;;

slice ["a";"b";"c";"d";"e";"f";"g";"h";"i";"j"] 2 6;;
