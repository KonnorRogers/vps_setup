namespace 'config' do
  task :setup do
    if Dir.home == '/root'
      user = VpsSetup::Setup.add_user

      VpsSetup::Setup.swap_user(user)
      VpsSetup::Setup.ufw_setup
    end
  end
end

