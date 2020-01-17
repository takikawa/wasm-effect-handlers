open Types

type module_inst =
{
  types : func_type list;
  funcs : func_inst list;
  tables : table_inst list;
  memories : memory_inst list;
  globals : global_inst list;
  exceptions : exception_inst list;
  exports : export_inst list;
}

and func_inst = module_inst ref Func.t
and table_inst = Table.t
and memory_inst = Memory.t
and global_inst = Global.t
and exception_inst = Exception.t
and export_inst = Ast.name * extern

and extern =
  | ExternFunc of func_inst
  | ExternTable of table_inst
  | ExternMemory of memory_inst
  | ExternGlobal of global_inst
  | ExternException of exception_inst


(* Reference type extensions *)

type Values.ref_ += FuncRef of func_inst
type Values.ref_ += ExnRef of Exception.package

let () =
  let type_of_ref' = !Values.type_of_ref' in
  Values.type_of_ref' := function
    | FuncRef _ -> FuncRefType
    | r -> type_of_ref' r

let () =
  let string_of_ref' = !Values.string_of_ref' in
  Values.string_of_ref' := function
    | FuncRef _ -> "func"
    | r -> string_of_ref' r


(* Auxiliary functions *)

let empty_module_inst =
  { types = []; funcs = []; tables = []; memories = []; globals = [];
    exceptions = []; exports = [] }

let extern_type_of = function
  | ExternFunc func -> ExternFuncType (Func.type_of func)
  | ExternTable tab -> ExternTableType (Table.type_of tab)
  | ExternMemory mem -> ExternMemoryType (Memory.type_of mem)
  | ExternGlobal glob -> ExternGlobalType (Global.type_of glob)
  | ExternException exn -> ExternExceptionType (Exception.type_of exn)

let export inst name =
  try Some (List.assoc name inst.exports) with Not_found -> None
