require 'securerandom'

class TerminalSession
  attr_reader :width, :height

  def initialize(width: 80, height: 24)
    @width = width
    @height = height

    tmux_command("new-session -d -x #{width} -y #{height} 'zsh -f'")
  end

  def run_command(command)
    send_string(command)
    send_keys('enter')
  end

  def send_string(str)
    tmux_command("send-keys -t 0 -l '#{str.gsub("'", "\\'")}'")
  end

  def send_keys(*keys)
    tmux_command("send-keys -t 0 #{keys.join(' ')}")
  end

  def contents
    tmux_command('capture-pane -p -t 0').strip
  end

  def clear
    send_keys('C-l')
  end

  def destroy
    tmux_command('kill-session')
  end

  private

  def socket_name
    @socket_name ||= SecureRandom.hex(6)
  end

  def tmux_command(cmd)
    out = `tmux -u -L #{socket_name} #{cmd}`

    raise('tmux error') unless $?.success?

    out
  end
end
