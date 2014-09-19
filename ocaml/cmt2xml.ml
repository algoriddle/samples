open Cmt_format
open Printf
(* open Types *)
open Typedtree

let xml = true

let printx s f = printf "<%s>" s; f (); printf "</%s>" s
let printxo s = if xml then printf "<%s>" s else ()
let printxc s = if xml then printf "</%s>" s else ()
let printxsc s = if xml then printf "<%s />" s else ()

(* let xref : out_channel ref = ref stdout *)

let base_path = ref []

let base_path_string = function
  | [] -> ""
  | bp -> (String.concat "." (List.rev bp)) ^ "."

type crossref = Def | Sig | Ref

let process_location loc =
  let tag = "location" in
  let (f, bl, bc) = Location.get_pos_info loc.Location.loc_start in
  let (_, el, ec) = Location.get_pos_info loc.Location.loc_end in
  printxo tag;
  printf "%s[%d,%d]..[%d,%d]" f bl bc el ec;
  if loc.Location.loc_ghost then printf " ghost" else ();
  printxc tag

let process_ident id =
  let tag = "ident" in
  printxo tag;
  printf "%s/%d" id.Ident.name id.Ident.stamp;
  printxc tag

let normalize_ident id =
  sprintf "%s/%d" id.Ident.name id.Ident.stamp

let rec normalize_path = function
    Path.Pident id -> 
    normalize_ident id
  | Path.Pdot (p, s, _) ->
    (normalize_path p) ^ "." ^ s
  | Path.Papply (p1, p2) ->
    failwith "Path.Papply"

let rec process_path p =
  printx "ident" (fun () ->
  printf "%s" (normalize_path p))

(* = function
    Path.Pident id -> 
    process_ident id
  | Path.Pdot (p, s, i) ->
    let tag = "dot" in
    printxo tag;
    printf "%s/%d" s i;
    process_path p;
    printxc tag;
  | Path.Papply (p1, p2) ->
    let tag = "apply" in
    printxo tag;
    process_path p1;
    process_path p2;
    printxc tag
*)

(*
let ident_use t i l =
  let ts = match t with
      Def -> "def"
    | Ref -> "ref" 
    | Sig -> "sig"
  in
  let (f, bl, bc) = Location.get_pos_info l.Location.loc_start in
  let (_, el, ec) = Location.get_pos_info l.Location.loc_end in
  let bid = if t <> Ref then (base_path_string !base_path) ^ i else i in
  fprintf !xref "%s %s %s %d %d %d %d\n" ts bid f bl bc el ec

let xref_path_use t p l =
  ident_use t (normalize_path p) l

let xref_ident_use t i l =
  ident_use t (normalize_ident i) l
*)

let rec process_longident li =
    let tag = "longident" in 
    printxo tag;
    (match li with
      Longident.Lident s ->
      printf "%s" s;
    | Longident.Ldot (li, s) -> 
      printf "%s" s;
      process_longident li
    | Longident.Lapply (li1, li2) ->
      process_longident li1;
      process_longident li2);
    printxc tag

(*
let rec process_type_expr te =
  match te.Types.desc with
    Tvar _ -> printxsc "Tvar"
  | Tarrow (_ (*label*), te1, te2, _ (*commutable*)) ->
    let tag = "Tarrow" in
    printxo tag;
    process_type_expr te1;
    process_type_expr te2;
    printxc tag
  | Ttuple _ -> printxsc "Ttuple"
  | Tconstr (p, _, _) -> 
    (*let tag = "Tconstr" in
    printxo tag; *)
    process_path p (*;
    printxc tag *)
  | Tobject (_, _) -> printxsc "Tobject"
  | Tfield (_, _, _, _) -> printxsc "Tfield"
  | Tnil -> printxsc "Tnil"
  | Tlink te -> (*printxsc "Tlink";*) process_type_expr te
  | Tsubst _ -> printxsc "Tsubst"
  | Tvariant _ -> printxsc "Tvariant"
  | Tunivar _ -> printxsc "Tunivar"
  | Tpoly (_, _) -> printxsc "Tpoly"
  | Tpackage (_, _, _) -> printxsc "Tpackage"
*)

let rec process_env env =
  printx "env" (fun () ->
  process_env_summary (Env.summary env))

and process_env_summary = 
  let open Env in function
  | Env_empty -> ()
  | Env_value (s, id, vd) ->
    printx "Env_value" (fun () ->
        process_ident id;
        ());
    process_env_summary s
  | Env_type (s, id, td) ->
    printx "Env_type" (fun () ->
        process_ident id;
        ());
    process_env_summary s
  | Env_extension (s, id, ec) -> 
    printx "Env_extension" (fun () ->
        process_ident id;
        ());
    process_env_summary s
  | Env_module (s, id, md) ->
    printx "Env_module" (fun () ->
        process_ident id;
        ());
    process_env_summary s
  | Env_modtype (s, id, mtd) ->
    printx "Env_modtype" (fun () ->
        process_ident id;
        ());
    process_env_summary s
  | Env_class (s, id, cd) ->
    printx "Env_class" (fun () ->
        process_ident id;
        ());
    process_env_summary s
  | Env_cltype (s, id, ctd) ->
    printx "Env_cltype" (fun () ->
        process_ident id;
        ());
    process_env_summary s
  | Env_open (s, p) ->
    printx "Env_open" (fun () ->
        process_path p);
    process_env_summary s
  | Env_functor_arg (s, id) ->
    printx "Env_functor_arg" (fun () ->
        process_ident id);
    process_env_summary s

and process_value_description
    { val_id (* Ident.t *);
      val_name (* string loc *);
      val_desc (* core_type *);
      val_val (* Types.value_description *);
      val_prim (* string list *);
      val_loc (* Location.t *);
      val_attributes (* attribute list *)
    } =
  printx "value_description" (fun () -> 
      process_ident val_id
    );
  (*  xref_ident_use Sig val_id val_loc *)
  
and process_signature_item_desc = function
    Tsig_value vd ->
    printx "Tsig_value" (fun () -> process_value_description vd)
  | _ -> printxsc "Tsig_"
(*  | Tsig_type of (Ident.t * string loc * type_declaration) list
  | Tsig_exception of Ident.t * string loc * exception_declaration
  | Tsig_module of Ident.t * string loc * module_type
  | Tsig_recmodule of (Ident.t * string loc * module_type) list
  | Tsig_modtype of Ident.t * string loc * modtype_declaration
  | Tsig_open of override_flag * Path.t * Longident.t loc
  | Tsig_include of module_type * Types.signature
  | Tsig_class of class_description list
  | Tsig_class_type of class_type_declaration list *)

(*sig_desc: signature_item_desc;
  sig_env : Env.t; (* BINANNOT ADDED *)
  sig_loc: Location.t*)
and process_signature_item si = 
  printx "signature_item" (fun () ->
      process_signature_item_desc si.sig_desc;
      process_location si.sig_loc)

(* sig_items : signature_item list;
  sig_type : Types.signature;
  sig_final_env : Env.t*)
and process_signature s =
  printx "signature" (fun () ->
    List.iter process_signature_item s.sig_items) 

(*  Tmty_ident of Path.t * Longident.t loc
  | Tmty_signature of signature
  | Tmty_functor of Ident.t * string loc * module_type * module_type
  | Tmty_with of module_type * (Path.t * Longident.t loc * with_constraint) list
  | Tmty_typeof of module_expr*)
and process_module_type_desc = function
    Tmty_ident (p, lid_loc) -> 
    printx "Tmty_ident" (fun () ->
        process_path p;
        process_location lid_loc.Location.loc)
  | Tmty_signature s -> 
    printx "Tmty_signature" (fun () ->
        process_signature s)
  | Tmty_functor (_, _, _, _) -> printxsc "Tmty_functor"
  | Tmty_with (_, _) -> printxsc "Tmty_with"
  | Tmty_typeof _ -> printxsc "Tmty_typeof"

and process_core_type_desc = function
    Ttyp_any -> printxsc "Ttyp_any"
  | Ttyp_var _ -> printxsc "Ttyp_var"
  | Ttyp_arrow (_, _, _) -> printxsc "Ttyp_arrow"
  | Ttyp_tuple _ -> printxsc "Ttyp_tuple"
  | Ttyp_constr (p, li_loc, _) -> 
    let tag = "Ttyp_constr" in
    printxo tag;
    process_path p;
    process_location li_loc.Location.loc;
    printxc tag;
    (* xref_path_use Ref p li_loc.Location.loc *)
  | Ttyp_object _ -> printxsc "Ttyp_object"
  | Ttyp_class (_, _, _) -> printxsc "Ttyp_class"
  | Ttyp_alias (_, _) -> printxsc "Ttyp_alias"
  | Ttyp_variant (_, _, _) -> printxsc "Ttyp_variant"
  | Ttyp_poly (_, _) -> printxsc "Ttyp_poly"
  | Ttyp_package _ -> printxsc "Ttyp_package"

(*  Tpat_any
  | Tpat_var of Ident.t * string loc
  | Tpat_alias of pattern * Ident.t * string loc
  | Tpat_constant of constant
  | Tpat_tuple of pattern list
  | Tpat_construct of
      Longident.t loc * constructor_description * pattern list * bool
  | Tpat_variant of label * pattern option * row_desc ref
  | Tpat_record of
      (Longident.t loc * label_description * pattern) list *
        closed_flag
  | Tpat_array of pattern list
  | Tpat_or of pattern * pattern * row_desc option
  | Tpat_lazy of pattern *)
and process_pattern_desc = function
    Tpat_any -> printxsc "Tpat_any"
  | Tpat_var (id, sl) ->
    let tag = "Tpat_var" in
    printxo tag;
    process_ident id;
    process_location sl.Location.loc;
    printxc tag;
    (* xref_ident_use Def id sl.Location.loc *)
  | Tpat_alias (_, _, _) -> printxsc "Tpat_alias"
  | Tpat_constant _ -> printxsc "Tpat_constant"
  | Tpat_tuple _ -> printxsc "Tpat_tuple"
  | Tpat_construct (_, _, args) -> 
    printx "Tpat_construct" (fun () ->
        List.iter process_pattern args)
  | Tpat_variant (_, _, _) -> printxsc "Tpat_variant"
  | Tpat_record (_, _) -> printxsc "Tpat_record"
  | Tpat_array _ -> printxsc "Tpat_array"
  | Tpat_or (_, _, _) -> printxsc "Tpat_or"
  | Tpat_lazy _ -> printxsc "Tpat_lazy"

(*pat_desc: pattern_desc;
  pat_loc: Location.t;
  pat_extra: (pat_extra * Location.t) list;
  pat_type: type_expr;
  mutable pat_env: Env.t*)
and process_pattern p = 
  let tag = "pattern" in
  printxo tag;  
  process_pattern_desc p.pat_desc;
  process_location p.pat_loc;
(*process_type_expr p.pat_type*)
  printxc tag

and process_case
    {
      c_lhs (* pattern *);
      c_guard (* expression option *);
      c_rhs (* expression *)
    } =
  printx "case" (fun () ->
      process_pattern c_lhs;
      process_expression c_rhs
    )

and process_cases list =
  printx "cases" (fun () ->
      List.iter process_case list)

and process_value_binding  
    {
      vb_pat (* pattern *);
      vb_expr (* expression *);
      vb_attributes (* attributes *);
      vb_loc (* Location.t *)
    } =
  printx "binding" (fun () ->
      process_pattern vb_pat;
      process_expression vb_expr)

and process_bindings rec_flag list =
  printx "bindings" (fun () ->
      List.iter process_value_binding list)

(*val_type: type_expr;
  val_kind: value_kind;
  val_loc: Location.t*)
and process_types_value_description
    { Types.val_type; Types.val_kind; Types.val_loc } =
  printx "Types.value_description" (fun () ->
      process_location val_loc)

(*  Texp_ident of Path.t * Longident.t loc * Types.value_description
  | Texp_constant of constant
  | Texp_let of rec_flag * (pattern * expression) list * expression
  | Texp_function of label * (pattern * expression) list * partial
  | Texp_apply of expression * (label * expression option * optional) list
  | Texp_match of expression * (pattern * expression) list * partial
  | Texp_try of expression * (pattern * expression) list
  | Texp_tuple of expression list
  | Texp_construct of
      Longident.t loc * constructor_description * expression list *
        bool
  | Texp_variant of label * expression option
  | Texp_record of
      (Longident.t loc * label_description * expression) list *
        expression option
  | Texp_field of expression * Longident.t loc * label_description
  | Texp_setfield of
      expression * Longident.t loc * label_description * expression
  | Texp_array of expression list
  | Texp_ifthenelse of expression * expression * expression option
  | Texp_sequence of expression * expression
  | Texp_while of expression * expression
  | Texp_for of
      Ident.t * string loc * expression * expression * direction_flag *
        expression
  | Texp_when of expression * expression
  | Texp_send of expression * meth * expression option
  | Texp_new of Path.t * Longident.t loc * Types.class_declaration
  | Texp_instvar of Path.t * Path.t * string loc
  | Texp_setinstvar of Path.t * Path.t * string loc * expression
  | Texp_override of Path.t * (Path.t * string loc * expression) list
  | Texp_letmodule of Ident.t * string loc * module_expr * expression
  | Texp_assert of expression
  | Texp_assertfalse
  | Texp_lazy of expression
  | Texp_object of class_structure * string list
  | Texp_pack of module_expr *)
and process_expression_desc = function
  | Texp_ident (p, li, vd) ->
    let tag = "Texp_ident" in
    printxo tag;
    process_path p;
    process_longident li.Location.txt;
    process_location li.Location.loc;
    process_types_value_description vd;
    (*printx "env_lookup" (fun () ->
        try begin
          let (ep, evd) = Env.lookup_type li.Location.txt env in
          process_path ep;
          process_types_value_description evd
        end with _ -> ());*)
    printxc tag;
    (* xref_path_use Ref p li.Location.loc *)
  | Texp_constant _ -> printxsc "Texp_constant"
  | Texp_let (rec_flag, list, exp) ->
    printx "Texp_let" (fun () ->
    process_bindings rec_flag list;
    process_expression exp)
  | Texp_function (_, cases, _) ->
    printx "Texp_function" (fun () ->
        process_cases cases)
  | Texp_apply (exp, list) ->
    printx "Texp_apply" (fun () ->
        process_expression exp;
        List.iter (fun (label, expo, _) ->
            match expo with
              None -> ()
            | Some exp -> process_expression exp
          ) list)
  | Texp_match (_, _, _, _) -> printxsc "Texp_match"
  | Texp_try (_, _) -> printxsc "Texp_try"
  | Texp_tuple _ -> printxsc "Texp_tuple"
  | Texp_construct (_, _, _) -> printxsc "Texp_construct"
  | Texp_variant (_, _) -> printxsc "Texp_variant"
  | Texp_record (_, _) -> printxsc "Texp_record"
  | Texp_field (_, _, _) -> printxsc "Texp_field"
  | Texp_setfield (_, _, _, _) -> printxsc "Texp_setfield"
  | Texp_array _ -> printxsc "Texp_array"
  | Texp_ifthenelse (_, _, _) -> printxsc "Texp_ifthenelse"
  | Texp_sequence (_, _) -> printxsc "Texp_sequence"
  | Texp_while (_, _) -> printxsc "Texp_while"
  | Texp_for (_, _, _, _, _, _) -> printxsc "Texp_for"
  | Texp_send (_, _, _) -> printxsc "Texp_send"
  | Texp_new (_, _, _) -> printxsc "Texp_new"
  | Texp_instvar (_, _, _) -> printxsc "Texp_instvar"
  | Texp_setinstvar (_, _, _, _) -> printxsc "Texp_setinstvar"
  | Texp_override (_, _) -> printxsc "Texp_override"
  | Texp_letmodule (_, _, _, _) -> printxsc "Texp_letmodule"
  | Texp_assert _ -> printxsc "Texp_assert"
  | Texp_lazy _ -> printxsc "Texp_lazy"
  | Texp_object (_, _) -> printxsc "Texp_object"
  | Texp_pack _ -> printxsc "Texp_pack"


(*
    and iter_expression exp =
      Iter.enter_expression exp;
      List.iter (function (cstr, _) ->
        match cstr with
          Texp_constraint (cty1, cty2) ->
            option iter_core_type cty1; option iter_core_type cty2
        | Texp_open (_, path, _, _) -> ()
        | Texp_poly cto -> option iter_core_type cto
        | Texp_newtype s -> ())
        exp.exp_extra;
      begin
        match exp.exp_desc with
        | Texp_match (exp, list, _) ->
            iter_expression exp;
            iter_bindings Nonrecursive list
        | Texp_try (exp, list) ->
            iter_expression exp;
            iter_bindings Nonrecursive list
        | Texp_tuple list ->
            List.iter iter_expression list
        | Texp_construct (_, _, args, _) ->
            List.iter iter_expression args
        | Texp_variant (label, expo) ->
            begin match expo with
                None -> ()
              | Some exp -> iter_expression exp
            end
        | Texp_record (list, expo) ->
            List.iter (fun (_, _, exp) -> iter_expression exp) list;
            begin match expo with
                None -> ()
              | Some exp -> iter_expression exp
            end
        | Texp_field (exp, _, label) ->
            iter_expression exp
        | Texp_setfield (exp1, _, label, exp2) ->
            iter_expression exp1;
            iter_expression exp2
        | Texp_array list ->
            List.iter iter_expression list
        | Texp_ifthenelse (exp1, exp2, expo) ->
            iter_expression exp1;
            iter_expression exp2;
            begin match expo with
                None -> ()
              | Some exp -> iter_expression exp
            end
        | Texp_sequence (exp1, exp2) ->
            iter_expression exp1;
            iter_expression exp2
        | Texp_while (exp1, exp2) ->
            iter_expression exp1;
            iter_expression exp2
        | Texp_for (id, _, exp1, exp2, dir, exp3) ->
            iter_expression exp1;
            iter_expression exp2;
            iter_expression exp3
        | Texp_when (exp1, exp2) ->
            iter_expression exp1;
            iter_expression exp2
        | Texp_send (exp, meth, expo) ->
            iter_expression exp;
          begin
            match expo with
                None -> ()
              | Some exp -> iter_expression exp
          end
        | Texp_new (path, _, _) -> ()
        | Texp_instvar (_, path, _) -> ()
        | Texp_setinstvar (_, _, _, exp) ->
            iter_expression exp
        | Texp_override (_, list) ->
            List.iter (fun (path, _, exp) ->
                iter_expression exp
            ) list
        | Texp_letmodule (id, _, mexpr, exp) ->
            iter_module_expr mexpr;
            iter_expression exp
        | Texp_assert exp -> iter_expression exp
        | Texp_assertfalse -> ()
        | Texp_lazy exp -> iter_expression exp
        | Texp_object (cl, _) ->
            iter_class_structure cl
        | Texp_pack (mexpr) ->
            iter_module_expr mexpr
      end;
      Iter.leave_expression exp;

*)

(*exp_desc: expression_desc;
  exp_loc: Location.t;
  exp_extra : (exp_extra * Location.t) list;
  exp_type: type_expr;
  exp_env: Env.t*)
and process_expression e =
  let tag = "expression" in  
  printxo tag;
  process_expression_desc e.exp_desc;
  process_location e.exp_loc;
  (*process_env e.exp_env;*)
  (*process_type_expr e.exp_type;*) 
  printxc tag

and process_module_binding
    {
      mb_id (* Ident.t *);
      mb_name (* string loc *);
      mb_expr (* module_expr *);
      mb_attributes (* attributes *);
      mb_loc (* Location.t *)
    } =
  printx "module_binding" (fun () ->
        process_ident mb_id;
        process_location mb_loc;
        (* xref_ident_use Def mb_id mb_loc; *)
        let temp = !base_path in
        base_path := 
          (sprintf "%s/%d" mb_id.Ident.name mb_id.Ident.stamp) :: !base_path;
        process_module_expr mb_expr;
        base_path := temp)

and process_module_type_declaration {
    mtd_id;
    mtd_name;
    mtd_type;
    mtd_attributes;
    mtd_loc
  } =
  printx "module_type_declaration" (fun () ->
      process_ident mtd_id;
      process_location mtd_loc;
      begin match mtd_type with
        | Some mt -> process_module_type mt
        | None -> ()
      end)

(*mty_desc: module_type_desc;
  mty_type : Types.module_type;
  mty_env : Env.t;
  mty_loc: Location.t*)
and process_module_type m =
  printx "module_type" (fun () ->
  process_module_type_desc m.mty_desc;
  process_location m.mty_loc)

(*        match mexpr.mod_desc with
        | Tmod_functor (id, _, mtype, mexpr) ->
            iter_module_type mtype;
            iter_module_expr mexpr
        | Tmod_apply (mexp1, mexp2, _) ->
            iter_module_expr mexp1;
            iter_module_expr mexp2
        | Tmod_constraint (mexpr, _, Tmodtype_implicit, _ ) ->
            iter_module_expr mexpr
        | Tmod_constraint (mexpr, _, Tmodtype_explicit mtype, _) ->
            iter_module_expr mexpr;
            iter_module_type mtype
        | Tmod_unpack (exp, mty) ->
            iter_expression exp
(*          iter_module_type mty *)
*)
(*  Tmod_ident of Path.t * Longident.t loc
  | Tmod_structure of structure
  | Tmod_functor of Ident.t * string loc * module_type * module_expr
  | Tmod_apply of module_expr * module_expr * module_coercion
  | Tmod_constraint of
      module_expr * Types.module_type * module_type_constraint * module_coercion
  | Tmod_unpack of expression * Types.module_type *)
and process_module_expr_desc = function
    Tmod_ident (p, li_loc) -> 
    printx "Tmod_ident" (fun () ->
        process_path p;
        process_location li_loc.Location.loc)
        (* xref_path_use Ref p li_loc.Location.loc) *)
  | Tmod_structure s -> 
    printx "Tmod_structure" (fun () ->
        process_structure s)
  | Tmod_functor (id, txt, mto, me) -> 
    printx "Tmod_functor" (fun () -> 
        process_ident id;
        process_location txt.Location.loc;
        begin match mto with
          | Some mt -> process_module_type mt
          | None -> ()
        end;
        process_module_expr me)
  | Tmod_apply (me1, me2, mc) -> 
    printx "Tmod_apply" (fun () ->
        process_module_expr me1;
        process_module_expr me2)
  | Tmod_constraint (m, _, tmt, _) -> 
    printx "Tmod_constraint" (fun () ->
        printx "implicit" (fun () -> process_module_expr m);
        match tmt with
          Tmodtype_implicit -> ()
        | Tmodtype_explicit emt -> printx "explicit" (fun () ->
            process_module_type emt)
      )
  | Tmod_unpack (_, _) -> printxsc "Tmod_unpack"

(*mod_desc: module_expr_desc;
  mod_loc: Location.t;
  mod_type: Types.module_type;
  mod_env: Env.t*)
and process_module_expr me =
    printx "module_expr" (fun () ->
      process_module_expr_desc me.mod_desc;
      process_location me.mod_loc)

and process_open_description 
    { open_path; open_txt; open_override; open_loc; open_attributes } =
    printx "open_description" (fun () ->
      process_path open_path;
      process_longident open_txt.Location.txt;
      process_location open_loc)
      (* xref_path_use Ref open_path open_loc *)

and process_type_declaration
    {
      typ_id; 
      typ_name;
      typ_params;
      typ_type;
      typ_cstrs;
      typ_kind;
      typ_private;
      typ_manifest;
      typ_loc;
      typ_attributes
    } =
  process_ident typ_id;
  process_location typ_loc
(* xref_ident_use Def typ_id typ_loc *)

and process_structure_item_desc = function
  | Tstr_eval (exp, _) -> 
    let tag = "Tstr_eval" in
    printxo tag; 
    process_expression exp;
    printxc tag
  | Tstr_value (rec_flag, list) ->
    let tag = "Tstr_value" in
    printxo tag;
    process_bindings rec_flag list;
    printxc tag
  | Tstr_primitive _ -> printxsc "Tstr_primitive"
  | Tstr_type tl -> 
    printx "Tstr_type" (fun () ->
        List.iter process_type_declaration tl
    )
  | Tstr_exception _ -> printxsc "Tstr_exception"
  | Tstr_module mb -> 
    printx "Tstr_module" (fun () ->
        process_module_binding mb)
  | Tstr_recmodule _ -> printxsc "Tstr_recmodule"
  | Tstr_modtype mtd ->
    printx "Tstr_modtype" (fun () ->
        process_module_type_declaration mtd)
  | Tstr_open od -> 
    printx "Tstr_open" (fun () ->
        process_open_description od)
  | Tstr_class _ -> printxsc "Tstr_class"
  | Tstr_class_type _ -> printxsc "Tstr_class_type"
  | Tstr_include _ -> printxsc "Tstr_include"

(*str_desc : structure_item_desc;
  str_loc : Location.t;
  str_env : Env.t *)
and process_structure_item si =
  let tag = "structure_item" in
  printxo tag;
  process_structure_item_desc si.str_desc;
  process_location si.str_loc;
  printxc tag

(*str_items : structure_item list;
  str_type : Types.signature;
  str_final_env : Env.t; *)
and process_structure s =
  let tag = "structure" in
  printxo tag;
  List.iter process_structure_item s.str_items;
  printxc tag

(*  Packed of Types.signature * string list
  | Implementation of structure
  | Interface of signature
  | Partial_implementation of binary_part array
  | Partial_interface of binary_part array *)
let process_binary_annots = function
  | Implementation impl -> process_structure impl
  | _ -> ()

(*cmt_modname : string;
  cmt_annots : binary_annots;
  cmt_comments : (string * Location.t) list;
  cmt_args : string array;
  cmt_sourcefile : string option;
  cmt_builddir : string;
  cmt_loadpath : string list;
  cmt_source_digest : string option;
  cmt_initial_env : Env.t;
  cmt_imports : (string * Digest.t) list;
  cmt_interface_digest : Digest.t option;
  cmt_use_summaries : bool*)
let process_cmt_infos ci =
  process_binary_annots ci.cmt_annots

(*
module IteratorArg : IteratorArgument = struct
  let enter_structure _ = printxo "structure"
  let enter_value_description v = 
  (*val_desc : core_type;
    val_val : Types.value_description;
    val_prim : string list;
    val_loc : Location.t;*)
    printxo "value_description";
    process_location v.val_loc
  let enter_type_declaration t = 
  (*typ_params: string loc option list;
    typ_type : Types.type_declaration;
    typ_cstrs: (core_type * core_type * Location.t) list;
    typ_kind: type_kind;
    typ_private: private_flag;
    typ_manifest: core_type option;
    typ_variance: (bool * bool) list;
    typ_loc: Location.t*)
    printxo "type_declaration";
    process_location t.typ_loc
  let enter_modtype_declaration _ = printxo "modtype_declaration"
  let enter_module_expr m =
  let enter_with_constraint _ = printxo "with_constraint"
  let enter_class_expr _ = printxo "class_expr"
  let enter_class_signature _ = printxo "class_signature"
  let enter_class_declaration _ = printxo "class_declaration"
  let enter_class_description _ = printxo "class_description"
  let enter_class_type_declaration _ = printxo "class_type_declaration"
  let enter_class_type _ = printxo "class_type"
  let enter_class_type_field _ = printxo "class_type_field"
  let enter_core_type ct = 
  (*mutable ctyp_desc : core_type_desc;
    mutable ctyp_type : type_expr;
    ctyp_env : Env.t; (* BINANNOT ADDED *)
    ctyp_loc : Location.t*)
    printxo "core_type";
    process_core_type_desc ct.ctyp_desc;
    (*process_type_expr ct.ctyp_type;*)
    process_location ct.ctyp_loc
end

module Iterator = MakeIterator(IteratorArg)
*)

let () =
(*  xref := open_out ""; *)
  printxo "tt";
  let (_, cmt) = read Sys.argv.(1) in
  (match cmt with
     Some m -> process_cmt_infos m
   | None -> ());
  printxc "tt";
(*  close_out !xref *)
