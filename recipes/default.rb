#
# Cookbook Name:: check_linux
# Recipe:: default
#
#
#
# creating Check_LinuxNode.sh

cookbook_file '/home/ec2-user/Check_LinuxNode.sh' do
  owner 'ec2-user'
  group 'ec2-user'
  mode '0755'
  source 'Check_LinuxNode.sh'
  action :create
end


cron 'Check_LinuxNode'do
  minute '0'
  hour '*/4'
  command "/home/ec2-user/Check_LinuxNode.sh >> /home/ec2-user/Check_LinuxNode_Log.log 2>&1"
  only_if do File.exist?('/home/ec2-user/Check_LinuxNode.sh') end
end