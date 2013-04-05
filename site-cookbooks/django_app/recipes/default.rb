#
# Cookbook Name:: django_app
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

python_virtualenv "/.venv/pari" do
  owner "root"
  group "root"
  action :create
  notifies :run, "bash[install_app]"
end

bash "install_app" do
  cwd "/pari"
  code <<-EOH 
    source /.venv/pari/bin/activate
    export DJANGO_SETTINGS_MODULE=pari.settings.dev
    pip install -r requirements/dev.txt
    python manage.py syncdb
    python manage.py migrate 
    python manage.py collectstatic --noinput
    EOH
  action :run
end

npm_package "less"

gunicorn_config "/etc/gunicorn/pari.py" do
  action :create
  pid "gunicorn.pid"
end

%w{postgresql-devel}.each do |pkg|
  package pkg do
    action :install
  end
end

supervisor_service "gunicorn_pari" do
  action [:enable, :start]
  autostart true
  autorestart true
  redirect_stderr true
  environment :DJANGO_SETTINGS_MODULE => "pari.settings.dev", :PATH => "/.venv/pari/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/vagrant/bin:"
  command "/.venv/pari/bin/gunicorn pari.wsgi:application -c pari.py -p gunicorn.pid"
  directory "/pari"
  user "root"
  process_name "gunicorn_pari"
end

template "/etc/nginx/sites-enabled/pari" do
    source "nginx.django.conf.erb"
    owner "root"
    group "root"
    mode "644"
    notifies :reload, "service[nginx]"
end
