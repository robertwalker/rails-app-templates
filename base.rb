# Suppress the default index.html page
run "mv public/index.html public/_index.html"

# Configure to use RSpec, Cucumber and Webrat
gem "webrat", :lib => false, :version => ">=0.7.1", :env => "cucumber"
gem "cucumber-rails", :lib => false, :version => ">=0.3.1", :env => "cucumber"
gem "cucumber", :lib => false, :version => ">=0.7.2", :env => "cucumber"
gem "rspec-rails", :lib => false, :version => ">=1.3.2", :evn => "test"
gem "rspec", :lib => false, :version => ">=1.3.0", :evn => "test"

# Run the RSpec generator
generate(:rspec)
generate(:cucumber, "--rspec", "--webrat")

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
git :commit => "-m 'Initial commit.'"

# Create the basic .gitignore file for rails projects
file ".gitignore", <<-EOF
.DS_Store
log/*.log
tmp/*
db/*.sqlite3
db/*.sqlite3-journal
config/database.yml
EOF

# Commit the ignore file
git :add => ".gitignore"
git :commit => "-m 'Created basic git ignore list.'"

# Copy config/example_database.yml to config/database.yml
run "cp config/example_database.yml config/database.yml"
