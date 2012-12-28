from fabric.api import *
from os.path import basename
import pystache

env.roledefs = {
    'app': ['10.33.33.34'],
    'db': ['10.33.33.33']
}

APP_SETTINGS = {
    'user' : 'vagrant',
    'group' : 'admin',
    'aws_key' : '',
    'aws_secret' : '',
    'db_host' : '10.33.33.33'
}

def put_parsed_file(template_path, destination, data):
    with open(template_path, 'r') as template:
        result = pystache.render(template.read(), data)
    temp_file = "/tmp/" + basename(template_path)
    with open(temp_file, 'w') as script:
        script.write(result)
    put(temp_file, destination, mode=0755)
    

@roles("db")
def deploy_db():
    put_parsed_file("vms/install_db.sh.template", "/tmp/install_db.sh", {'hosts': env.roledefs['db']})
    sudo("/tmp/install_db.sh")
    
@roles("app")
def init_db():
    run("cd ~/class2go/main && python manage.py syncdb --noinput")
    run("cd ~/class2go/main && python manage.py syncdb --database=celery")
    migrate_db()

@roles("app")
def migrate_db():
    run("cd ~/class2go/main && python manage.py migrate")
    run("cd ~/class2go/main && python manage.py migrate --database=celery")
    
@roles("app")
def create_super_user():
    run("cd ~/class2go/main && python manage.py createsuperuser")

def install_chef():
    put("vms/install_chef.sh", "/tmp/install_chef.sh", mode=0755)
    sudo("/tmp/install_chef.sh")

def prepare_chef_solo():
    local("tar czf /tmp/c2g-chef.tgz chef")
    put("/tmp/c2g-chef.tgz", "/tmp/c2g-chef.tgz")
    sudo("rm -rf /tmp/c2g-chef /tmp/chef solo.rb chef.json")
    run("tar xzf /tmp/c2g-chef.tgz -C /tmp")
    put("vms/solo.rb", "/tmp/solo.rb")
    put_parsed_file("vms/chef.json.template", "/tmp/chef.json", APP_SETTINGS)

@roles("app")
def deploy_app():
    install_chef()
    prepare_chef_solo()
    sudo("chef-solo -c /tmp/solo.rb -j /tmp/chef.json")
