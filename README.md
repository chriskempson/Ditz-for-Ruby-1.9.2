# Ditz 0.5 for Ruby 1.9.2
Ditz stopped working when I upgraded to Ruby 1.9.2 so I'm currently working on bringing it up to scratch for 1.9.2.

## Installation
Make sure you have the `yaml_waml` gem installed. Clone the git repo.
    
    gem install yaml_waml
    git clone git://github.com/ChrisKempson/Ditz-for-Ruby-1.9.2.git
    cd Ditz-for-Ruby-1.9.2
    ruby setup.rb
    ditz --version

## Issues
Ditz is currently falling over if there isn't a release set. This can be fixed by adding a release
    
    ditz add-release