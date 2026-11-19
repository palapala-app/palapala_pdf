# frozen_string_literal: true

require "open3"
require_relative "test_helper"

class TestChromeProcess < Minitest::Test
  def test_starting_chrome_preserves_the_apps_child_process_handler
    skip "SIGCHLD is unavailable" unless Signal.list.key?("CHLD")

    # Keep changes to signal handling in a separate Ruby process.
    lib = File.expand_path("../lib", __dir__)
    _, stderr, status = Open3.capture3(RbConfig.ruby, "-I", lib, "-e", <<~'RUBY')
      require "palapala/chrome_process"

      def Palapala.headless_chrome_path = RbConfig.ruby

      chrome = Palapala::ChromeProcess
      def chrome.chrome_running? = false
      def chrome.port_in_use? = true

      def chrome.spawn_chrome_from_path
        Process.spawn(RbConfig.ruby, "-e", "sleep 10", out: File::NULL, err: File::NULL)
      end

      handler = proc {}
      Signal.trap("CHLD", handler)
      chrome.spawn_chrome
      abort "Starting Chrome replaced the application's SIGCHLD handler" unless Signal.trap("CHLD", handler).equal?(handler)

      helper_pid = Process.spawn(RbConfig.ruby, "-e", "exit 42")
      _, helper_status = Process.wait2(helper_pid)
      abort "Could not collect the other child's exit status" unless helper_status.exitstatus == 42

      abort "Chrome was expected to be running" unless chrome.chrome_process_healthy?
      chrome.kill_chrome
      abort "Chrome was expected to have stopped" if chrome.chrome_process_healthy?
    RUBY
    assert_predicate status, :success?, stderr
  end
end
