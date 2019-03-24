defmodule Golfex.CalculatorTest do
  use Golfex.DataCase

  alias Golfex.Calculator, as: C
  alias Decimal, as: D

  test "stableford game does not increase handicap above maximum" do
    assert C.calculate_change(6, "Stableford", D.new("44.8")) == D.new("0.2")
    assert C.calculate_change(36, "Stableford", D.new("44.9")) == D.new("0.1")
    assert C.calculate_change(1, "Stableford", D.new("45.0")) == D.new("0.0")
  end

  test "stableford game does not decrease handicap below minimum" do
    assert C.calculate_change(46, "Stableford", D.new("11.9")) == D.new("-1.9")
    assert C.calculate_change(46, "Stableford", D.new("11.0")) == D.new("-1.0")
    assert C.calculate_change(41, "Stableford", D.new("10.5")) == D.new("-0.5")
    assert C.calculate_change(41, "Stableford", D.new("10.1")) == D.new("-0.1")
  end

  test "stroke game does not increase handicap above maximum" do
    assert C.calculate_change(79, "Stroke", D.new("44.8")) == D.new("0.2")
    assert C.calculate_change(78, "Stroke", D.new("44.9")) == D.new("0.1")
    assert C.calculate_change(77, "Stroke", D.new("45.0")) == D.new("0.0")
  end

  test "stroke game does not decrease handicap below minimum" do
    assert C.calculate_change(66, "Stroke", D.new("11.9")) == D.new("-1.9")
    assert C.calculate_change(69, "Stroke", D.new("11.0")) == D.new("-1.0")
    assert C.calculate_change(65, "Stroke", D.new("10.5")) == D.new("-0.5")
    assert C.calculate_change(65, "Stroke", D.new("10.1")) == D.new("-0.1")
  end

  test "fun match returns a change value of 0" do
    assert C.calculate_change(1, "Fun match", D.new("11.0")) == D.new("0.0")
    assert C.calculate_change(1, "Ye", D.new("44.0")) == D.new("0.0")
  end
end
