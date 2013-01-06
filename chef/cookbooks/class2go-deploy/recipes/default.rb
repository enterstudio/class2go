#
# Cookbook Name:: class2go-deploy
# Recipe:: default
#
#
node['apps'].keys.each do |app|

    directory "/opt/#{app}" do
        owner node['system']['admin_user']
        group node['system']['admin_group']
        mode 00777
        action :create
    end

    directory "/opt/#{app}/static" do
        owner node['system']['admin_user']
        group node['system']['admin_group']
        mode 00777
        action :create
    end

    directory "#{node['files']['root_dir']}" do
        owner "www-data"
        group "www-data"
        mode 00755
        action :create
    end

    # For initial machine bring up, check out the first time.  Doing as a
    # shell script so we can test first.
    bash "git clone" do
        user node['system']['admin_user']
        cwd node['system']['admin_home']
        code <<-EOH
        if [[ ! -d #{app} ]]; then
            git clone https://github.com/exceedhl/class2go.git #{app}
        fi
        EOH
    end

    execute "git remote update" do
        command "git remote update"
        cwd node['system']['admin_home'] + "/#{app}"
        user node['system']['admin_user']
        group node['system']['admin_group']
        action :run
    end

    # Be really super sure that we get the revision we want
    execute "git checkout" do
        command "git checkout -f " + node['apps'][app]['git_branch']
        cwd node['system']['admin_home'] + "/#{app}"
        user node['system']['admin_user']
        group node['system']['admin_group']
        action :run
    end

    # ... and then do a reset hard <branch>.  Unclear if this is even 
    # necessary, just being double-safe
    execute "git reset" do
        command "git reset --hard " + node['apps'][app]['git_branch']
        cwd node['system']['admin_home'] + "/#{app}"
        user node['system']['admin_user']
        group node['system']['admin_group']
        action :run
    end

    # Clear out *.pyc in this tree. Makes sure that file deletions aren't
    # hidden by vestigial compilation products.
    execute "remove all *.pyc" do
        command "find . -name \\*.pyc -exec rm {} \\; -print"
        cwd node['system']['admin_home'] + "/#{app}"
        user node['system']['admin_user']
        group node['system']['admin_group']
        action :run
    end

end

