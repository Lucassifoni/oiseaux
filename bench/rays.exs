for n <- [1001, 10001, 100001] do
  Benchee.run(
    %{
      "Elixir, #{n} rays" => fn -> Optics.Parabola.non_parallel_rayfan_coords(400.0, 57.0, 10000.0, n) end,
      "Rust  , #{n} rays" => fn -> Optics.Parabola.non_parallel_rayfan_coords_rs(400.0, 57.0, 10000.0, n) end
    })
end
