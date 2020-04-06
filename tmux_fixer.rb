require 'fileutils'

TmuxFixer = Object.new
class << TmuxFixer
  def repoint_the_symlink_to_last_good_resurrect
    FileUtils.rm(the_symlink)
    FileUtils.symlink(last_good_resurrect, the_symlink)
  end

  def last_good_resurrect
    the_zero = Resurrects.newest.index(Resurrects.the_zero)
    Resurrects.newest[the_zero - 1]
  end

  def the_symlink
    Dir.pwd + '/last'
  end

  # is this tested?  how will it be used?
  def last_resurrect
    File.readlink(the_symlink)
  end
end

Resurrects = Object.new
class << Resurrects
  def newest
    today.sort_by { |r| File.mtime(r) }.reverse
  end

  def today
    all.select { |f| File.mtime(f) > (Time.now - 60*60*24) }
  end

  def all
    Dir.children(Dir.pwd).select do |name|
      name[/tmux_resurrect/]
    end
  end

  def the_zero
    zeroes.first
  end

  def just_one_zero?
    zeroes.one?
  end

  def zeroes
    today.select { |r| File.size(r).zero? }
  end
end

if __FILE__ == $0
  FileUtils.chdir("#{ENV['HOME']}/.tmux/resurrect")
  TmuxFixer.repoint_the_symlink_to_last_good_resurrect
end
