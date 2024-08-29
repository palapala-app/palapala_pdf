require "open3"
require "pathname"

module Palapala
  # Manage the Chrome child process
  module ChromeProcess
    # Check if the port is in use
    def self.port_in_use?(port = 9222, host = "127.0.0.1")
      server = TCPServer.new(host, port)
      server.close
      false
    rescue Errno::EADDRINUSE
      true
    end

    # Check if the Chrome process is healthy
    def self.chrome_process_healthy?
      return false if @chrome_process_id.nil?

      begin
        Process.kill(0, @chrome_process_id) # Check if the process is alive
        true
      rescue Errno::ESRCH, Errno::EPERM
        false
      end
    end

    # Check if a Chrome is running locally
    def self.chrome_running?
      port_in_use? || # Check if the port is in use
      chrome_process_healthy? # Check if the process is still alive
    end

    # Kill the Chrome child process
    def self.kill_chrome
      return if @chrome_process_id.nil?

      Process.kill("KILL", @chrome_process_id) # Kill the process
      Process.wait(@chrome_process_id) # Wait for the process to finish
    end

    # Get the path to the Chrome executable, if it's not set, then guess based on the OS
    def self.chrome_path
      return Palapala.headless_chrome_path if Palapala.headless_chrome_path

      case RbConfig::CONFIG["host_os"]
      when /darwin/
        "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
      when /linux/
        "/usr/bin/google-chrome" # or "/usr/bin/chromium-browser"
      when /win|mingw|cygwin/
        "#{ENV.fetch("ProgramFiles(x86)", nil)}\\Google\\Chrome\\Application\\chrome.exe"
      else
        raise "Unsupported OS"
      end
    end

    def self.npx_installed?
      system("which npx > /dev/null 2>&1")
    end

    def self.spawn_chrome_headless_server_with_npx
      # Run the command and capture the output
      puts "Installing/launching chrome-headless-shell@#{Palapala.chrome_headless_shell_version}"
      output, status = Open3.capture2("npx --yes @puppeteer/browsers install chrome-headless-shell@#{Palapala.chrome_headless_shell_version}")

      if status.success?
        # Extract the path from the output
        result = output.lines.find { |line| line.include?("chrome-headless-shell@") }
        if result.nil?
          raise "Failed to install chrome-headless-shell"
        end
        _, chrome_path = result.split(" ", 2).map(&:strip)

        # Directory you want the relative path from (current working directory)
        base_dir = Dir.pwd

        # Convert absolute path to relative path
        relative_path = Pathname.new(chrome_path).relative_path_from(Pathname.new(base_dir)).to_s

        puts "Launching chrome-headless-shell at #{relative_path}" if Palapala.debug
        # Display the version
        system("#{chrome_path} --version") if Palapala.debug
        # Launch chrome-headless-shell with the --remote-debugging-port parameter
        params = [ "--disable-gpu", "--remote-debugging-port=9222" ]
        params.merge!(Palapala.chrome_params) if Palapala.chrome_params
        pid = if Palapala.debug
          spawn(chrome_path, *params)
        else
          spawn(chrome_path, *params, out: "/dev/null", err: "/dev/null")
        end
        Palapala.headless_chrome_url = "http://localhost:9222"
        pid
      else
        raise "Failed to install chrome-headless-shell"
      end
    end

    def self.spawn_chrome_from_path
      params = [ "--headless", "--disable-gpu", "--remote-debugging-port=9222" ]
      params.merge!(Palapala.chrome_params) if Palapala.chrome_params
      # Spawn an existing chrome with the path and parameters
      Process.spawn(chrome_path, *params)
    end

    # Spawn a Chrome child process
    def self.spawn_chrome
      return if chrome_running?

      @chrome_process_id =
        if Palapala.headless_chrome_path.nil? && self.npx_installed?
          spawn_chrome_headless_server_with_npx
        else
          spawn_chrome_from_path
        end

      # Wait until the port is in use
      sleep 0.1 until port_in_use?
      # Detach the process so it runs in the background
      Process.detach(@chrome_process_id)

      at_exit do
        if @chrome_process_id
          begin
            Process.kill("TERM", @chrome_process_id)
            Process.wait(@chrome_process_id)
            puts "Child process #{@chrome_process_id} terminated."
          rescue Errno::ESRCH
            puts "Child process #{@chrome_process_id} is already terminated."
          rescue Errno::ECHILD
            puts "No child process #{@chrome_process_id} found."
          end
        end
      end

      # Handle when the process is killed
      trap("SIGCHLD") do
        while (@chrome_process_id = Process.wait(-1, Process::WNOHANG))
          break if @chrome_process_id.nil?

          puts "Process #{@chrome_process_id} was killed."
          # Handle the error or restart the process if necessary
          @chrome_process_id = nil
        end
      rescue Errno::ECHILD
        @chrome_process_id = nil
      end
    end
  end
end
