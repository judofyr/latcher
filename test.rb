require 'minitest/autorun'

class TestLatcher < MiniTest::Unit::TestCase
  PROG = File.expand_path('../latcher.lua', __FILE__)

  def latch(query, files)
    IO.popen([PROG, query].flatten, 'r+') do |f|
      files.each { |file| f.puts(file) }
      f.close_write
      return f.readlines.map(&:chomp)
    end
  end

  def test_basic
    res = latch('h', ['hello', 'world'])
    assert_equal ['hello'], res
  end

  def test_not_in_middle
    res = latch('h', ['hello', 'blah'])
    assert_equal ['hello'], res
  end

  def test_after_seps
    res = latch('h', ['blah', 'blah/hello'])
    assert_equal ['blah/hello'], res
  end

  def test_avoid_double
    res = latch('h', ['h/h'])
    assert_equal ['h/h'], res
  end

  def test_multiple
    res = latch('core Art', ['vendor/core/Artifact.pm', 'core'])
    assert_equal ['vendor/core/Artifact.pm'], res
  end

  def test_limit
    res = latch(['h', '--limit', '1'], ['hello', 'hope'])
    assert_equal ['hello'], res
  end

  def test_empty
    res = latch('', ['hello', 'world'])
    assert_equal ['hello', 'world'], res
  end

  def test_case
    res = latch('Con', ['MainController'])
    assert_equal ['MainController'], res
  end
end

