type 'a expr =
  | Base of 'a
  | Const of bool
  | And of 'a expr list
  | Or of 'a expr list
  | Not of 'a expr

type mail_field = To | From | CC
type mail_predicate = 
  { 
    field: mail_field;
    contains: string
  }

let test field contains = Base { field; contains }

let and_or l b t =
  if List.mem l (Const (not b)) then Const (not b)
  else
    match List.filter l ~f:((<>) (Const b)) with
    | [] -> Const b
    | [x] -> x
    | l -> t l

let not_ = function
  | Const b -> Const (not b)
  | Not e -> e
  | Base _ | And _ | Or _ as e -> Not e

let rec simplify = function
  | Base _ | Const _ as x -> x
  | And l -> and_or (List.map ~f:simplify l) true (fun x -> And x)
  | Or l -> and_or (List.map ~f:simplify l) false (fun x -> Or x)
  | Not e -> not_ (simplify e)

let x = And [ Or [ test To "Joe"; test CC "Joe" ]; test From "Jane" ]

let y = Not (And [ Or [ Const true; Base "The sky is red." ]; Not (Base "The sky is blue.") ])

let z = simplify y
