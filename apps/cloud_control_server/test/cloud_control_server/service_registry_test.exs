defmodule CloudControlServer.ServiceRegistryTest do
  use ExUnit.Case

  alias CloudControlServer.ServiceHandler
  alias CloudControlServer.ServiceRegistry

  defp start_registry_with_handlers configs do
    {:ok, registry} = ServiceRegistry.start_link

    handlers = Enum.map configs, fn(config) ->
      {:ok, handler} = ServiceRegistry.start_handler registry, config

      handler
    end

    {registry, handlers}
  end

  test "starts service handlers" do
    {_registry, [handler]} = start_registry_with_handlers [%{ foo: "bar" }]

    assert is_pid(handler)
  end

  test "find the full list of service handlers" do
    configs = [
      %{ foo: "bar" },
      %{ bim: "baz" }
    ]

    {registry, _handlers} = start_registry_with_handlers configs

    {:ok, handlers} = ServiceRegistry.find_all_handlers registry

    Enum.each handlers, fn(h) ->
      config = ServiceHandler.get_config h

      [foo_config, bar_config] = configs

      assert config == foo_config || config == bar_config
    end
  end

  test "find service handlers by service config" do
    foo_config = %{ foo: "bar" }

    configs = [
      foo_config,
      %{ bim: "baz" }
    ]

    {registry, _handlers} = start_registry_with_handlers configs

    {:ok, handlers} = ServiceRegistry.find_handlers_by_config registry, foo_config

    assert length(handlers) == 1

    [ handler ] = handlers

    config = ServiceHandler.get_config handler

    assert config == foo_config
  end
end
