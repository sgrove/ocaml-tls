

(*
 * MORNING PRAYER:
 *
 * I will allocate data, more and more data and all new data, since i'm not
 * writing C like a peasant.
 *
 * This kinda travesty will go away. After we reach correctness. Not before.
 *)

module Cs = struct

  let appends = function
    | []   -> Cstruct.create 0
    | [cs] -> cs
    | csn  ->
        let cs = Cstruct.(create @@ lenv csn) in
        let _ =
          List.fold_left
            (fun off e ->
              let len = Cstruct.len e in
              ( Cstruct.blit e 0 cs off len ; off + len ))
            0 csn in
        cs

  let append cs1 cs2 = appends [ cs1; cs2 ]

  let (<>) = append

  (* let canonicalize cs =
    if cs.Cstruct.off = 0 then cs else
      Cstruct.(of_bigarray @@
                  Bigarray.Array1.sub cs.buffer cs.off cs.len) *)

  (* let equal cs1 cs2 = canonicalize cs1 = canonicalize cs2 *)

  let equal cs1 cs2 =
    let (len1, len2) = Cstruct.(len cs1, len cs2) in
    let rec cmp = function
      | -1 -> true
      |  i -> Cstruct.(get_uint8 cs1 i = get_uint8 cs2 i) && cmp (pred i)
    in
    (len1 = len2) && cmp (pred len1)

  let begins_with cs target =
    let open Cstruct in
    let l1 = len cs and l2 = len target in
    l1 >= l2 && equal (sub cs 0 l2) target

  let ends_with cs target =
    let open Cstruct in
    let l1 = len cs and l2 = len target in
    l1 >= l2 && equal (sub cs (l1 - l2) l2) target

  let empty = Cstruct.create 0
end

let rec filter_map ~f = function
  | []    -> []
  | x::xs ->
      match f x with
      | None    ->       filter_map ~f xs
      | Some x' -> x' :: filter_map ~f xs

let rec map_find ~f = function
  | []    -> None
  | x::xs ->
      match f x with
      | None         -> map_find ~f xs
      | Some _ as x' -> x'

let option none some = function
  | None   -> none
  | Some x -> some x

let rec last = function
  | []    -> invalid_arg "empty list"
  | [x]   -> x
  | _::xs -> last xs

let const a _ = a

let id a = a

let o f g x = f (g x)

let hexdump_to_str cs =
  let b = Buffer.create 16 in
  Cstruct.hexdump_to_buffer b cs ;
  Buffer.contents b

