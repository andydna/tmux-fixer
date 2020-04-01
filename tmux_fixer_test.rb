require 'minitest/autorun'
require './tmux_fixer.rb'
require 'pry'

$HERE = Dir.pwd

class TmuxFixerTest < Minitest::Test
  def setup
    FileUtils.chdir("#{ENV['HOME']}/.tmux/resurrect")
  end

  def test_nothing
    assert true
  end

  def test_tmux_fixer_finds_the_symlink
    the_symlink = TmuxFixer.the_symlink

    assert File.symlink? the_symlink 
    assert_match /tmux_resurrect/, File.readlink(the_symlink)
  end

  def test_last_resurrect
    assert_match /tmux_resurrect/, TmuxFixer.last_resurrect
  end

  def test_find_last_good_resurrect
    last_good_resurrect = TmuxFixer.last_good_resurrect

    refute File.size(last_good_resurrect).zero?
  end

  def test_repoint_the_symlink
    FileUtils.chdir($HERE)
    `rm sandbox/*`

    test_bad = 'sandbox/test_bad'
    test_good = 'sandbox/test_good'
    test_link = 'sandbox/test_link'

    # setup
    FileUtils.touch(test_bad)
    FileUtils.touch(test_good)
    FileUtils.symlink(test_bad, test_link)

    TmuxFixer.stub(:last_good_resurrect, test_good) do
      TmuxFixer.stub(:the_symlink, test_link) do
        TmuxFixer.repoint_the_symlink_to_last_good_resurrect
      end
    end

    assert_equal test_good, File.readlink(test_link)

    `rm sandbox/*`
  end

  def test_delete_the_bad_resurrects
    skip "not yet implemented"
  end

  def test_delete_the_old_resurrects
    skip "not yet implemented"
  end
end

class ResurrectsTest < Minitest::Test
  def setup
    FileUtils.chdir("#{ENV['HOME']}/.tmux/resurrect")
  end

  def test_all_resurrects
    Resurrects.all.each do |r|
      assert_match /tmux_resurrect/, r
    end
  end

  def test_resurrects_today
    Resurrects.today.each do |r|
      assert_match /tmux_resurrect/, r
    end
  end

  def test_zeroes
    assert_kind_of Array, Resurrects.zeroes
  end

  def test_just_one_zero?
    refute_nil assert Resurrects.just_one_zero?
  end

  def test_the_zero
    assert_match /tmux_resurrect/, Resurrects.the_zero
  end

  def test_newest
    newest = Resurrects.newest

    assert File.mtime(newest.first) > File.mtime(newest.last)
  end
end
