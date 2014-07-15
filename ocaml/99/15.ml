let replicate l c =
  let rec repeat acc x c =
    if c = 0
    then acc
    else repeat (x :: acc) x (c - 1)
  in
  let rec aux acc = function
    | [] -> acc
    | hd :: tl -> aux (repeat acc hd c) tl
  in
  l |> List.rev |> aux [];;

replicate ["a";"b";"c"] 3;;
