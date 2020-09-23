(**************************************************************************)
(*                                                                        *)
(*                                 OCaml                                  *)
(*                                                                        *)
(*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           *)
(*                                                                        *)
(*   Copyright 1996 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(* An alias for the type of lists. *)
type 'a t = 'a list = [] | ( :: ) of 'a * 'a list

(* List operations *)

let rec length_aux len = function [] -> len | _ :: l -> length_aux (len + 1) l

let length l = length_aux 0 l

let cons a l = a :: l

let hd = function [] -> failwith "hd" | a :: _ -> a

let tl = function [] -> failwith "tl" | _ :: l -> l

let nth l n =
  if n < 0 then invalid_arg "List.nth"
  else
    let rec nth_aux l n =
      match l with
      | [] -> failwith "nth"
      | a :: l -> if n = 0 then a else nth_aux l (n - 1)
    in
    nth_aux l n

let nth_opt l n =
  if n < 0 then invalid_arg "List.nth"
  else
    let rec nth_aux l n =
      match l with
      | [] -> None
      | a :: l -> if n = 0 then Some a else nth_aux l (n - 1)
    in
    nth_aux l n

let append = ( @ )

let rec rev_append l1 l2 =
  match l1 with [] -> l2 | a :: l -> rev_append l (a :: l2)

let rev l = rev_append l []

let rec init_tailrec_aux acc i n f =
  if i >= n then acc else init_tailrec_aux (f i :: acc) (i + 1) n f

let rec init_aux i n f =
  if i >= n then []
  else
    let r = f i in
    r :: init_aux (i + 1) n f

let rev_init_threshold () =
  match Sys.backend_type () with
  | Sys.Native | Sys.Bytecode -> 10_000
  (* We don't know the size of the stack, better be safe and assume it's
     small. *)
  | Sys.Other _ -> 50

let init len f =
  if len < 0 then invalid_arg "List.init"
  else if len > rev_init_threshold () then rev (init_tailrec_aux [] 0 len f)
  else init_aux 0 len f

let rec flatten = function [] -> [] | l :: r -> l @ flatten r

let concat = flatten

let rec map f = function
  | [] -> []
  | a :: l ->
      let r = f a in
      r :: map f l

let rec mapi i f = function
  | [] -> []
  | a :: l ->
      let r = f i a in
      r :: mapi (i + 1) f l

let mapi f l = mapi 0 f l

let rev_map f l =
  let rec rmap_f accu = function
    | [] -> accu
    | a :: l -> rmap_f (f a :: accu) l
  in
  rmap_f [] l

let rec iter f = function
  | [] -> ()
  | a :: l ->
      f a;
      iter f l

let rec iteri i f = function
  | [] -> ()
  | a :: l ->
      f i a;
      iteri (i + 1) f l

let iteri f l = iteri 0 f l

let rec fold_left f accu l =
  match l with [] -> accu | a :: l -> fold_left f (f accu a) l

let rec fold_right f l accu =
  match l with [] -> accu | a :: l -> f a (fold_right f l accu)

let rec map2 f l1 l2 =
  match (l1, l2) with
  | [], [] -> []
  | a1 :: l1, a2 :: l2 ->
      let r = f a1 a2 in
      r :: map2 f l1 l2
  | _, _ -> invalid_arg "List.map2"

let rev_map2 f l1 l2 =
  let rec rmap2_f accu l1 l2 =
    match (l1, l2) with
    | [], [] -> accu
    | a1 :: l1, a2 :: l2 -> rmap2_f (f a1 a2 :: accu) l1 l2
    | _, _ -> invalid_arg "List.rev_map2"
  in
  rmap2_f [] l1 l2

let rec iter2 f l1 l2 =
  match (l1, l2) with
  | [], [] -> ()
  | a1 :: l1, a2 :: l2 ->
      f a1 a2;
      iter2 f l1 l2
  | _, _ -> invalid_arg "List.iter2"

let rec fold_left2 f accu l1 l2 =
  match (l1, l2) with
  | [], [] -> accu
  | a1 :: l1, a2 :: l2 -> fold_left2 f (f accu a1 a2) l1 l2
  | _, _ -> invalid_arg "List.fold_left2"

let rec fold_right2 f l1 l2 accu =
  match (l1, l2) with
  | [], [] -> accu
  | a1 :: l1, a2 :: l2 -> f a1 a2 (fold_right2 f l1 l2 accu)
  | _, _ -> invalid_arg "List.fold_right2"

let rec for_all p = function [] -> true | a :: l -> p a && for_all p l

let rec exists p = function [] -> false | a :: l -> p a || exists p l

let rec for_all2 p l1 l2 =
  match (l1, l2) with
  | [], [] -> true
  | a1 :: l1, a2 :: l2 -> p a1 a2 && for_all2 p l1 l2
  | _, _ -> invalid_arg "List.for_all2"

let rec exists2 p l1 l2 =
  match (l1, l2) with
  | [], [] -> false
  | a1 :: l1, a2 :: l2 -> p a1 a2 || exists2 p l1 l2
  | _, _ -> invalid_arg "List.exists2"

let rec mem x = function [] -> false | a :: l -> compare a x = 0 || mem x l

let rec memq x = function [] -> false | a :: l -> a == x || memq x l

let rec assoc x = function
  | [] -> raise Not_found
  | (a, b) :: l -> if compare a x = 0 then b else assoc x l

let rec assoc_opt x = function
  | [] -> None
  | (a, b) :: l -> if compare a x = 0 then Some b else assoc_opt x l

let rec assq x = function
  | [] -> raise Not_found
  | (a, b) :: l -> if a == x then b else assq x l

let rec assq_opt x = function
  | [] -> None
  | (a, b) :: l -> if a == x then Some b else assq_opt x l

let rec mem_assoc x = function
  | [] -> false
  | (a, _) :: l -> compare a x = 0 || mem_assoc x l

let rec mem_assq x = function
  | [] -> false
  | (a, _) :: l -> a == x || mem_assq x l

let rec remove_assoc x = function
  | [] -> []
  | ((a, _) as pair) :: l ->
      if compare a x = 0 then l else pair :: remove_assoc x l

let rec remove_assq x = function
  | [] -> []
  | ((a, _) as pair) :: l -> if a == x then l else pair :: remove_assq x l

let rec find p = function
  | [] -> raise Not_found
  | x :: l -> if p x then x else find p l

let rec find_opt p = function
  | [] -> None
  | x :: l -> if p x then Some x else find_opt p l

let rec find_map f = function
  | [] -> None
  | x :: l -> (
      match f x with Some _ as result -> result | None -> find_map f l )

let find_all p =
  let rec find accu = function
    | [] -> rev accu
    | x :: l -> if p x then find (x :: accu) l else find accu l
  in
  find []

let filter = find_all

let filteri p l =
  let rec aux i acc = function
    | [] -> rev acc
    | x :: l -> aux (i + 1) (if p i x then x :: acc else acc) l
  in
  aux 0 [] l

let filter_map f =
  let rec aux accu = function
    | [] -> rev accu
    | x :: l -> (
        match f x with None -> aux accu l | Some v -> aux (v :: accu) l )
  in
  aux []

let concat_map f l =
  let rec aux f acc = function
    | [] -> rev acc
    | x :: l ->
        let xs = f x in
        aux f (rev_append xs acc) l
  in
  aux f [] l

let fold_left_map f accu l =
  let rec aux accu l_accu = function
    | [] -> (accu, rev l_accu)
    | x :: l ->
        let accu, x = f accu x in
        aux accu (x :: l_accu) l
  in
  aux accu [] l

let partition p l =
  let rec part yes no = function
    | [] -> (rev yes, rev no)
    | x :: l -> if p x then part (x :: yes) no l else part yes (x :: no) l
  in
  part [] [] l

let rec split = function
  | [] -> ([], [])
  | (x, y) :: l ->
      let rx, ry = split l in
      (x :: rx, y :: ry)

let rec combine l1 l2 =
  match (l1, l2) with
  | [], [] -> []
  | a1 :: l1, a2 :: l2 -> (a1, a2) :: combine l1 l2
  | _, _ -> invalid_arg "List.combine"

(** sorting *)

let rec merge cmp l1 l2 =
  match (l1, l2) with
  | [], l2 -> l2
  | l1, [] -> l1
  | h1 :: t1, h2 :: t2 ->
      if cmp h1 h2 <= 0 then h1 :: merge cmp t1 l2 else h2 :: merge cmp l1 t2

(* Note: on a list of length between about 100000 (depending on the minor
   heap size and the type of the list) and Sys.max_array_size, it is
   actually faster to use the following, but it might also use more memory
   because the argument list cannot be deallocated incrementally.

   Also, there seems to be a bug in this code or in the
   implementation of obj_truncate.

external obj_truncate : 'a array -> int -> unit = "caml_obj_truncate"

let array_to_list_in_place a =
  let l = Array.length a in
  let rec loop accu n p =
    if p <= 0 then accu else begin
      if p = n then begin
        obj_truncate a p;
        loop (a.(p-1) :: accu) (n-1000) (p-1)
      end else begin
        loop (a.(p-1) :: accu) n (p-1)
      end
    end
  in
  loop [] (l-1000) l


let stable_sort cmp l =
  let a = Array.of_list l in
  Array.stable_sort cmp a;
  array_to_list_in_place a

*)

(** sorting + removing duplicates *)

let rec compare_lengths l1 l2 =
  match (l1, l2) with
  | [], [] -> 0
  | [], _ -> -1
  | _, [] -> 1
  | _ :: l1, _ :: l2 -> compare_lengths l1 l2

let rec compare_length_with l n =
  match l with
  | [] -> if n = 0 then 0 else if n > 0 then -1 else 1
  | _ :: l -> if n <= 0 then 1 else compare_length_with l (n - 1)

(** {1 Iterators} *)

let to_seq l =
  let rec aux l () =
    match l with [] -> Seq.Nil | x :: tail -> Seq.Cons (x, aux tail)
  in
  aux l

let of_seq seq =
  let rec direct depth seq : _ list =
    if depth = 0 then Seq.fold_left (fun acc x -> x :: acc) [] seq |> rev
      (* tailrec *)
    else
      match seq () with
      | Seq.Nil -> []
      | Seq.Cons (x, next) -> x :: direct (depth - 1) next
  in
  direct 500 seq