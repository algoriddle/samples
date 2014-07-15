open Core.Std

print_endline "** seq, strict:";;

Sequence.range 1 1000000
|> Sequence.fold ~init:0 ~f:(fun acc x -> 
    acc + x);;

print_endline "** seq, lazy:";;

let test = Sequence.range 1 100000
|> Sequence.fold ~init:(lazy 0) ~f:(fun acc x -> 
    lazy (Lazy.force acc + x));;

print_endline "** seq, lazy, force eval:";;

test |> Lazy.force;;

print_endline "** tail rec, strict:";;

let rec sum acc x =
  if x = 0 
  then acc
  else sum (acc + x) (x - 1);;

sum 0 999999;;

print_endline "** tail rec, lazy:";;

let rec sum acc x =
  if x = 0 
  then acc
  else sum (lazy (Lazy.force acc + x)) (x - 1);;

let test = sum (lazy 0) 99999;;

print_endline "** tail rec, lazy, force eval:";;

test |> Lazy.force;;

print_endline "** non tail rec, strict:";;

let rec sum x =
  if x = 0
  then 0
  else x + sum (x - 1);;

sum 999999;;

print_endline "** non tail rec, lazy:";;

let rec sum x =
  if x = 0
  then lazy 0
  else lazy (x + Lazy.force (sum (x - 1)));;

let test = sum 999999;;

print_endline "** non tail rec, lazy, force eval:";;

test |> Lazy.force;;
