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
    %__MODULE__{name: "none"}
  end

  @doc """
  Get variables required to calculate a formulae
  """

  def get_variables_required_for_formula(%CalculateMetric{} = metric) do
    formula = metric.formula
    # pass through regular expressions to remove signs [+, (,), / * %]
    signs_to_watch_out = ["=", "(", "+", ")", "-", "*", "/", "%"]

    my_list = String.split(formula, signs_to_watch_out)

    updated_list = for item <- my_list, item != "", do: String.trim(item)

    updated_list

    # Enum.reject(updated_list, fn el -> Enum.member?(signs_to_watch_out, el) end)
  end

  def get_values_of_formula() do
  end

  @doc """
  Generates the result of a formula

  Get list of variables_names in formula
  replace variable names with variable values in formula
  evaluate expression

  """

  def equation_calc(%CalculateMetric{} = metric) do
    substitution = %{"days" => "10", "weeks" => "10", "months" => "40"}

    # days + week
    formula = metric.formula

    #  ["[id: 4]", "[id: 3]"]
    list_of_variables_names = get_variables_required_for_formula(metric)

    result =
      String.replace(formula, list_of_variables_names, fn
        key ->
          to_string(get_variable_value(key))
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
end
