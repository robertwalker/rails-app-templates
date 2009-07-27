# Configure to use rSpec, Cucumber and Webrat
gem "webrat", :lib => false, :version => ">=0.4.4"
gem "cucumber", :lib => false, :version => ">=0.3.91"
gem "rspec-rails", :lib => false, :version => ">=1.2.7.1"
gem "rspec", :lib => false, :version => ">=1.2.8"

# Run the rSpec generator
generate(:rspec)

# Setup an empty README.textile
run "rm README; echo 'TODO: Create the application README' > README.textile"

# Prepare for Git
run "mv config/database.yml config/example_database.yml"
run "rm log/*.log"
run "rm -rf tmp/*"
run "find . -type d -empty -exec touch {}/.gitignore \\;"

# Initialize git repository, add all created files and perform initial commit
git :init
git :add => "."
git :commit => "-a -m 'Initial commit.'"

# Create the basic .gitignore file for rails projects
file ".gitignore", <<-EOF
.DS_Store
log/*.log
tmp/*
db/*.sqlite3
config/database.yml
EOF

# Commit the ignore file
git :add => ".gitignore"
git :commit => "-m 'Created basic git ignore list.'"

# Copy config/example_database.yml to config/database.yml
run "cp config/example_database.yml config/database.yml"
