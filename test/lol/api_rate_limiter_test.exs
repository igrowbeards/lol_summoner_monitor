defmodule Lol.Api.RateLimiterTest do
  use ExUnit.Case

  alias Lol.Api.RateLimiter

  @default_args [
    long_period: 10_000,
    long_limit: 10_000,
    short_period: 10_000,
    short_limit: 10_000
  ]

  describe "lol_api_rate_limiter" do
    test "it limits against the short limit" do
      args = Keyword.put(@default_args, :short_limit, 1)

      spec = test_limiter_spec(args)
      {:ok, pid} = start_supervised(spec)

      # first request goes through
      assert GenServer.call(pid, :under_limits?)

      # second request is limited
      refute GenServer.call(pid, :under_limits?)

      # manually clear the short count
      Process.send(pid, :clear_short, [])

      # the next request goes through again
      assert GenServer.call(pid, :under_limits?)
    end

    test "it limits against the long limit" do
      args = Keyword.put(@default_args, :long_limit, 1)

      spec = test_limiter_spec(args)
      {:ok, pid} = start_supervised(spec)

      # first request goes through
      assert GenServer.call(pid, :under_limits?)

      # second request is limited
      refute GenServer.call(pid, :under_limits?)

      # manually clear the long count
      Process.send(pid, :clear_long, [])

      # the next request goes through again
      assert GenServer.call(pid, :under_limits?)
    end

    test "if the process is not enabled it always returns true for `under_limts?`" do
      args = [
        long_period: 10_000,
        long_limit: 0,
        short_period: 10_000,
        short_limit: 0,
        enabled: false
      ]

      spec = test_limiter_spec(args)
      {:ok, pid} = start_supervised(spec)

      for _ <- 1..10 do
        assert GenServer.call(pid, :under_limits?)
      end
    end
  end

  defp test_limiter_spec(args) do
    %{id: TestLimiter, start: {GenServer, :start_link, [RateLimiter, args, [name: TestLimiter]]}}
  end
end
