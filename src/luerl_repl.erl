-module(luerl_repl).

-export([start/0]).

start() ->
  State = luerl:init(),
  repl_loop(1, State).

repl_loop(N, State) ->
  case read_input(N, "", "") of
    "quit" -> ok;
    Cmd ->
      io:format("Cmd: ~p~n", [Cmd]),
      {Ret, State1} = run_script(normalize_input(Cmd), State),
      print_result(Ret),
      repl_loop(N + 1, State1)
  end.

run_script(Cmd, State) ->
  try
    {ok, Chunk, State1} = luerl:load(Cmd, State),
    luerl:do(Chunk, State1)
  catch
    C:E:S ->
      io:format("Error: ~p\n~p\n~p\n", [C, E, S]),
      {[], State}
  end.

read_input(_N, "", CmdSoFar) when length(CmdSoFar) > 0 ->
  lists:reverse(lists:flatten(CmdSoFar));
read_input(N, SubPrompt, CmdSoFar) ->
  Cmd = get_line(prompt(N, SubPrompt)),
  case lists:reverse(Cmd) of
    [$\\ | CmdRev] -> read_input(N, ">", [CmdRev | CmdSoFar]);
    CmdRev -> read_input(N, "", [CmdRev | CmdSoFar])
  end.

prompt(N, SubPrompt) ->
  ["lua [", integer_to_list(N), "]>", SubPrompt, " "].

get_line(Prompt) ->
  string:trim(io:get_line(Prompt), trailing, [10, 13]).

normalize_input(Cmd) -> Cmd.
%%normalize_input([$r, $e, $t, $u, $r, $n, $  | _] = Cmd) -> Cmd;
%%normalize_input(Cmd)                                    -> "return " ++ Cmd.

print_result([])    -> ok;
print_result([Ret]) -> io:format("~p~n", [Ret]);
print_result([Ret | Rest]) ->
  io:format("~p\t", [Ret]),
  print_result(Rest).
