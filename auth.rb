# Depends on base.rb
load_template "http://cloud.github.com/downloads/robertwalker/rails-app-templates/base.rb"

# Install restful_authentication plugin
plugin 'restful_authentication', 
       :git => 'git://github.com/robertwalker/restful-authentication.git', 
       :submodule => true

# Run the generator
options = []
options << ask("What do you want to call the user model?")
options << ask("What do you want to call the sessions controller?")
options << "--include-activation" if yes?("Include activation?")
if yes?("Use AASM?")
  options << "--aasm"
  gem "rubyist-aasm", :lib => "aasm", :version => ">=2.0.5"
end
options << "--rspec"
generate(:authenticated, *options)

# Run rake db:migrate
rake "db:migrate"

# Setup routing
route "map.signup  '/signup', :controller => 'users',   :action => 'new'"
route "map.login  '/login',  :controller => 'sessions', :action => 'new'"
route "map.logout '/logout', :controller => 'sessions', :action => 'destroy'"
if (options.include?("--include-activation"))
  route "map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil"
end

# Setup observer if using aasm
if options.include?("--aasm")
  #
  # Add AASM observer line to environment.rb
  #
  tmp_file = "config/environment.rb.tmp"
  real_file = "config/environment.rb"
  
  File.open(tmp_file, "w") do |out|
    IO.foreach(real_file) do |line|
      out.puts line
      if (line =~ /^  # config.active_record.observers.+/)
        out.puts "  config.active_record.observers = :user_observer"
      end
    end
  end
  File.delete(real_file)
  File.rename(tmp_file, real_file)

  #
  # Modify users resource route in routes.rb
  #
  tmp_file = "config/routes.rb.tmp"
  real_file = "config/routes.rb"
  modified_route = <<-END
  map.resources :users, :member => { :suspend   => :put,
                                     :unsuspend => :put,
                                     :purge     => :delete } 
END

  File.open(tmp_file, "w") do |out|
    IO.foreach(real_file) do |line|
      if (line == "  map.resources :users\n")
        out.puts modified_route
      else
        out.puts line
      end
    end
  end
  File.delete(real_file)
  File.rename(tmp_file, real_file)
end

# Commit the changes
git :add => "--all"
git :commit => "-m 'Installed restful_authentication'"
