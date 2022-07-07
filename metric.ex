defmodule CalculateMetric do
  @moduledoc """
  Calculate the result of a formula stored in a struct in another module
  Note: days and week could be ids from different tables
  """

  @id1 10
  @id2 7
  defstruct [:name, formula: "[id: 4] + [id: 3] / [id: 4] - [id: 3]", result: 0]

  @database_values [%{id: 4, value: 10}, %{id: 3, value: 7}]

  @formula1 "week + days"

  def new() do
    %__MODULE__{name: "new metric"}
  end

  def new_metric(%{"name" => name, "formula" => formula, "result" => result} = _new_metric) do
  end

  @doc """
  Get variables required to calculate a formulae
  """

  def get_variables_required_for_formula(%CalculateMetric{formula: formula} = _metric) do
    # pass through regular expressions to remove signs [+, (,), / * %]
    signs_to_watch_out = ["=", "(", "+", ")", "-", "*", "/", "%"]

    my_list =
      for item <- String.split(formula, signs_to_watch_out), item != "", do: String.trim(item)

    my_list
  end

  def get_values_of_formula() do
  end

  @doc """
  Generates the result of a formula

  Get list of variables_names in formula
  replace variable names with variable values in formula
  evaluate expression

  """

  def equation_calc(%CalculateMetric{formula: formula} = metric) do
    #  ["[id: 4]", "[id: 3]"]
    list_of_variables_names = get_variables_required_for_formula(metric)

    result =
      String.replace(formula, list_of_variables_names, fn
        key ->
          get_variable_value(key)
          |> to_string()
      end)

    Code.eval_string(result)
  end

  def get_variable_value(string_with_formula) do
    updated_list =
      for item <- String.split(string_with_formula, ["[", ":", "id", "]"]),
          item != "",
          do: String.to_integer(String.trim(item))

    Enum.find(@database_values, fn map -> map.id == List.first(updated_list) end).value
  end

  def valid_formula(formula) do
    # Todo
    # validate there's no number/string lying radomly

    # validate what is in [] has id:  followed by character that can be number
    # get all items within brackets

    valid_ids? =
      ~r/\[(.*?)\]/
      |> Regex.scan(formula)
      |> Enum.map(fn x ->
        last_item = List.last(x)

        if String.starts_with?(last_item, "id:") do
          contains_id? =
            String.split(last_item, ":")
            |> List.last()
            |> String.trim()
            |> Integer.parse()

          contains_id? != :error
        else
          false
        end
      end)
      |> Enum.member?(false) == false

    # validate math operations * / % + - are always followed by space
    spaced_operations? = Regex.match?(~r/(?<!\S)[-, +, *, %, \/](?!\S)/, formula)

    valid_ids? and spaced_operations?
    # validate [] are not immediately followed by
    # get all values wrapped in []
  end
end
