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

    # Check if a Chrome is running
    def self.chrome_running?
      port_in_use? || # Check if the port is in use and Chrome is running externally
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

    # Spawn a Chrome child process
    def self.spawn_chrome
      return if chrome_running?

      # Define the path and parameters separately
      # chrome_path = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
      params = ["--headless", "--disable-gpu", "--remote-debugging-port=9222"]
      params.merge!(Palapala.chrome_params) if Palapala.chrome_params

      # Spawn the process with the path and parameters
      @chrome_process_id = Process.spawn(chrome_path, *params)

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
