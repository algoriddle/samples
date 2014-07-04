open Core.Std

module Dict : sig

  type ('a, 'b) t

  val create : unit -> ('a, 'b) t
  val length : ('a, 'b) t -> int
  val add : ('a, 'b) t -> key:'a -> value:'b -> unit
  val find : ('a, 'b) t -> key:'a -> 'b option
  val iter : ('a, 'b) t -> f:(key:'a -> value:'b -> unit) -> unit
(*
  val remove
*)
end = struct

  type ('a, 'b) t = {
    length: int ref;
    buckets: ('a * 'b) list array
  }

  let bucket_count = 17

  let hash_bucket k = Hashtbl.hash k mod bucket_count

  let create () = {
    length = ref 0;
    buckets = Array.create ~len:bucket_count []
  }

  let length { length } = !length

  let add { length; buckets } ~key ~value =
    let i = hash_bucket key in
    let old_bucket = buckets.(i) in
    let replace = List.exists buckets.(i) ~f:(fun (key', _) -> key' = key) in
    let filtered_bucket = 
      if replace then
        List.filter old_bucket ~f:(fun (key', _) -> key' <> key)
      else
        old_bucket
    in
    buckets.(i) <- (key, value) :: filtered_bucket;
    if not replace then length := !length + 1

  let find { buckets } ~key =
    List.find_map buckets.(hash_bucket key) 
      ~f:(fun (key', value) -> 
          if key' = key then Some value else None)

  let iter { buckets } ~f =
    Array.iter buckets 
      ~f:(fun l -> List.iter l
             ~f:(fun (key, value) -> f ~key ~value))

end
