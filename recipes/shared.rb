git "/usr/src/oh-my-zsh" do
  repository "https://github.com/robbyrussell/oh-my-zsh.git"
  reference "master"
  action :sync
end

if Chef::Config[:solo]
    # support fnichol/chef-user method
    users = []
    # loop the users set for the node
    node["users"].each do |u|
        # get that users data bag
        user = data_bag_item('users', u)
        # finds users with the zsh env
        if !user["shell"].nil and user["shell"].match("zsh")
            # add the user to the list to be configured
            users.push(user["id"])
        end
    end
else
    # support opscode-cookbooks/users method
    # search users with the zsh shell
    users = search( :users, "shell:*zsh" )
end

users.each do |u|
  user_id = u["id"]

  theme = data_bag_item( "users", user_id )["oh-my-zsh-theme"]

  link "/home/#{user_id}/.oh-my-zsh" do
    to "/usr/src/oh-my-zsh"
    not_if "test -d /home/#{user_id}/.oh-my-zsh"
  end

  template "/home/#{user_id}/.zshrc" do
    source "zshrc.erb"
    owner user_id
    group user_id
    variables( :theme => ( theme || node[:ohmyzsh][:theme] ))
    action :create_if_missing
  end
end
