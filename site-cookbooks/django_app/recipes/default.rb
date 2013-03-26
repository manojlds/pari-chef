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
end

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
  environment :DJANGO_SETTINGS_MODULE => "pari.settings.dev"
  command "gunicorn pari.wsgi:application -c pari.py -p gunicorn.pid"
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
