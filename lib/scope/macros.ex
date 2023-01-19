defmodule Scope.IoMacro do
  defmacro __using__(_) do
    selected_io = Application.fetch_env!(:scope, :selected_io)
    selected_reactive_device = Application.fetch_env!(:scope, :selected_device)

    if __CALLER__.module != selected_io do
      quote do
        defp input(term), do: {:error, "IO Device not available"}
        defp input(term, payload), do: {:error, "IO Device not available"}
        def handle_notify(term), do: {:error, "IO Device not available"}
        def handle_notify(term, payload), do: {:error, "IO Device not available"}
      end
    else
      quote do
        defp input(term), do: apply(unquote(selected_reactive_device), :handle_input, [term])

        defp input(term, payload),
          do: apply(unquote(selected_reactive_device), :handle_input, [term, payload])
      end
    end
  end
end

defmodule Scope.DeviceMacro do
  defmacro __using__(_) do
    selected_io = Application.fetch_env!(:scope, :selected_io)
    selected_reactive_device = Application.fetch_env!(:scope, :selected_device)

    if __CALLER__.module != selected_reactive_device do
      quote do
        defp notify(term), do: {:error, "Reactive device not available"}
        defp notify(term, payload), do: {:error, "Reactive device not available"}
        def handle_input(term), do: {:error, "Reactive device not available"}
        def handle_input(term, payload), do: {:error, "Reactive device not available"}
      end
    else
      quote do
        defp notify(term), do: apply(unquote(selected_io), :handle_notify, [term])

        defp notify(term, payload),
          do: apply(unquote(selected_io), :handle_notify, [term, payload])
      end
    end
  end
end
