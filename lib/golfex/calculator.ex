defmodule Golfex.Calculator do
  @moduledoc """
  The handicap change calculator.
  """
  alias Decimal, as: D

  @doc """
  Configure the change values and maximum handicap value.

  This has only been memoized as this is likely the only
  values to require changing in future - and will reduce
  the likelihood of me making mistakes!!
  """
  @inc "0.3"
  @dec1 "-0.5"
  @dec2 "-1.0"
  @dec3 "-2.0"
  @max "45.0"
  @min "10.0"

  def max, do: D.new(@max)
  def min, do: D.new(@min)

  def calculate_change(score, type, current_handicap) do
    score
    |> use_ruleset(type)
    |> valid_change(current_handicap)
  end

  defp use_ruleset(score, "Stableford"), do: stableford(score)
  defp use_ruleset(score, "Stroke"), do: stroke(score)
  defp use_ruleset(_score, _type), do: D.new("0.0")

  defp stableford(score) do
    cond do
      score <= 36 -> D.new(@inc)
      score >= 37 and score <= 38 -> D.new(@dec1)
      score >= 39 and score <= 40 -> D.new(@dec2)
      score >= 41 -> D.new(@dec3)
    end
  end

  defp stroke(score) do
    cond do
      score <= 69 -> D.new(@dec3)
      score >= 70 and score <= 71 -> D.new(@dec2)
      score >= 72 and score <= 73 -> D.new(@dec1)
      score >= 74 -> D.new(@inc)
    end
  end

  def valid_change(change, current) do
    new_handicap = D.add(change, current)

    cond do
      D.cmp(new_handicap, @max) == :gt ->
        D.sub(@max, current)

      D.cmp(new_handicap, @min) == :lt ->
        D.sub(@min, current)

      true ->
        change
    end
  end
end
