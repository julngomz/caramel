  $ ls *.ml *.mli
  empty.ml
  functors.ml
  include.ml
  let_open.ml
  nested.ml
  no_exports.ml
  no_exports.mli
  sig.ml
  sig.mli
  sig_dep.ml
  simple_nested.ml
  $ caramelc compile *.ml *.mli
  Compiling simple_nested__a.erl	OK
  Compiling simple_nested__b.erl	OK
  Compiling simple_nested.erl	OK
  Compiling sig.erl	OK
  Compiling nested__a__c.erl	OK
  Compiling nested__a.erl	OK
  Compiling nested__b.erl	OK
  Compiling let_open__a.erl	OK
  Compiling include__a.erl	OK
  Compiling include.erl	OK
  Compiling functors.erl	OK
  $ cat *.erl
  % Source code generated with Caramel.
  -module(functors).
  
  -export([run/0]).
  
  -spec run() :: intadd.t().
  run() ->
    Zero = empty(),
    One = concat(Zero, 1),
    Two = intadd:'<+>'(One, 1),
    Two.
  
  
  % Source code generated with Caramel.
  -module(include).
  
  -export([f/0]).
  -export([run/0]).
  
  -spec run() :: int().
  run() -> f().
  
  
  % Source code generated with Caramel.
  -module(include__a).
  
  -export([f/0]).
  
  -spec f() :: int().
  f() -> 0.
  
  
  % Source code generated with Caramel.
  -module(let_open__a).
  
  -export([f/0]).
  
  -spec f() :: int().
  f() -> 0.
  
  
  % Source code generated with Caramel.
  -module(nested__a).
  
  -export([a/0]).
  
  -spec a() :: bool().
  a() -> true.
  
  
  % Source code generated with Caramel.
  -module(nested__a__c).
  
  -export([c/0]).
  
  -spec c() :: bool().
  c() -> true.
  
  -spec internal_c() :: bool().
  internal_c() -> true.
  
  
  % Source code generated with Caramel.
  -module(nested__b).
  
  -export([b/2]).
  
  -spec b() :: fun(() -> bool()).
  b(X, Y) -> '&&'(X, Y).
  
  
  % Source code generated with Caramel.
  -module(sig).
  
  -export([inc/1]).
  
  -spec inc() :: int().
  inc(X) -> erlang:'+'(X, 1).
  
  -spec hidden() :: ok.
  hidden() -> ok.
  
  -spec secret() :: ok.
  secret() -> ok.
  
  
  % Source code generated with Caramel.
  -module(simple_nested).
  
  -export([run/0]).
  
  -spec run() :: int().
  run() -> erlang:'+'(simple_nested__a:f(), simple_nested__b:f()).
  
  
  % Source code generated with Caramel.
  -module(simple_nested__a).
  
  -export([f/0]).
  
  -spec f() :: int().
  f() -> 0.
  
  
  % Source code generated with Caramel.
  -module(simple_nested__b).
  
  -export([f/0]).
  
  -spec f() :: int().
  f() -> 2.
  
  -spec g() :: ok.
  g() -> ok.
  
  
