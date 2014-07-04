open Core.Std

module Dict : sig

  type ('a, 'b) t

  val create : unit -> ('a, 'b) t
  val length : ('a, 'b) t -> int
  val add : ('a, 'b) t -> key:'a -> value:'b -> unit
  val find : ('a, 'b) t -> key:'a -> 'b option
  val iter : ('a, 'b) t -> f:(key:'a -> value:'b -> unit) -> unit
  val remove : ('a, 'b) t -> key:'a -> unit

end = struct

  type ('a, 'b) t = {
    mutable length: int;
    buckets: ('a * 'b) list array
  }

  let bucket_count = 17

  let hash_bucket k = Hashtbl.hash k mod bucket_count

  let create () = {
    length = 0;
    buckets = Array.create ~len:bucket_count []
  }

  let length t = t.length

  let add t ~key ~value =
    let i = hash_bucket key in
    let (new_bucket, replace) = List.fold t.buckets.(i) ~init:([], false)
        ~f:(fun (l, found) ((key', _) as kv) ->
            if key = key' then
              ((key, value)::l, true)
            else
              (kv::l, found))
    in
    if replace then
      t.buckets.(i) <- new_bucket
    else begin
      t.buckets.(i) <- (key, value)::new_bucket;
      t.length <- t.length + 1
    end

  let find t ~key =
    List.find_map t.buckets.(hash_bucket key)
      ~f:(fun (key', value) ->
          if key' = key then Some value else None)

  let iter t ~f =
    Array.iter t.buckets
      ~f:(fun l -> List.iter l
             ~f:(fun (key, value) -> f ~key ~value))

  let remove t ~key =
    let i = hash_bucket key in
    let (new_bucket, removed) = List.fold t.buckets.(i) ~init:([], false)
        ~f:(fun (l, found) ((key', _) as kv) ->
            if key = key' then
              (l, true)
            else
              (kv::l, found))
    in
    t.buckets.(i) <- new_bucket;
    if removed then
      t.length <- t.length - 1

end

let test = Dict.create () in

let add key value = Dict.add test ~key ~value in

let remove key = 
  Dict.remove test ~key in

let print () = 
  printf "%d\n" (Dict.length test); 
  Dict.iter test ~f:(fun ~key ~value -> printf "%s - %d\n" key value) in

add "alma" 5;
print ();
add "korte" 10;
print ();
add "alma" 15;
print ();

remove "korte";
print ();
