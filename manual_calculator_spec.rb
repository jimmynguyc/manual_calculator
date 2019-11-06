require 'minitest/autorun'
require 'manual_calculator'

class TestManualCalculator < Minitest::Test
  def test_works
    statement = "1 + 2 + 3"
    c = ManualCalculator.new(statement); c.call
    assert_equal c.ast, ["+", "1", ["+", "2", "3"]]
    assert_equal 6, c.result

    statement = "1 * 2 + 3"
    c = ManualCalculator.new(statement); c.call
    assert_equal c.ast, ["+", ["*", "1", "2"], "3"]
    assert_equal 5, c.result

    statement = "1 + 2 * 3"
    c = ManualCalculator.new(statement); c.call
    assert_equal c.ast, ["+", "1", ["*", "2", "3"]]
    assert_equal 7, c.result

    statement = "1 * 2 * 3"
    c = ManualCalculator.new(statement); c.call
    assert_equal c.ast, ["*", "1", ["*", "2", "3"]]
    assert_equal 6, c.result

    statement = "1 * 2 * 3 + 4 * 5 * 6"
    c = ManualCalculator.new(statement); c.call
    assert_equal c.ast, ["+", ["*", "1", ["*", "2", "3"]], ["*", "4", ["*", "5", "6"]]]
    assert_equal 126, c.result

  end
end
