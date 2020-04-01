TmuxFixer = Object.new
class << TmuxFixer
  def repoint_last_symlink_to_last_good
    FileUtils.rm(last_symlink)
    FileUtils.symlink(last_good, last_symlink)
  end

  def last_good
    the_zero = Resurrects.newest_first.index(Resurrects.the_zero)
    Resurrects.newest_first[the_zero - 1]
  end

  def last_symlink
    Dir.pwd + '/last'
  end

  # is this tested?  how will it be used?
  def last_resurrect
    File.readlink(last_symlink)
  end
end

Resurrects = Object.new
class << Resurrects
  def newest_first
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
