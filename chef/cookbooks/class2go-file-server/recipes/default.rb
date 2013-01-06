package "apache2-threaded-dev" do
  action :install
end

bash "install mod_h264_streaming" do
  user "root"
  cwd "/tmp"
  code <<-EOH
wget http://h264.code-shop.com/download/apache_mod_h264_streaming-2.2.7.tar.gz
tar -zxvf apache_mod_h264_streaming-2.2.7.tar.gz
cd mod_h264_streaming-2.2.7
./configure --with-apxs=`which apxs2`
make
make install
    EOH
  action :run
end

template "/etc/apache2/sites-available/class2go-file-server" do
  source "class2go-file-server.erb"
  owner "root"
  group "root"
  variables({
      :files_root_dir => node["files"]["root_dir"]
    })
  mode 00644
end

execute "a2ensite class2go-file-server" do
  user "root"
  action :run
end
