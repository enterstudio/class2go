# ensure that the Django log directory and file have permissions so that 
# the daemon:daemon user can write to it.  This is how Python is run from
# Apache.
#
# Note that specifying modes needs to be done as five digits.  See
# this chef bug: http://tickets.opscode.com/browse/CHEF-174


directory "/var/log/django" do
    owner "www-data"
    group "www-data"
    mode 00777
    action :create
end

node['apps'].keys.each do |app|
    
    file "/var/log/django/#{app}-django.log" do
        owner "www-data"
        group "www-data"
        mode 00777
        action :create
    end

end


