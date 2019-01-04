namespace 'config' do
  task :setup do
    if VpsSetup::Setup.root?
      
    end

    if VpsSetup::Setup.privileged_user?
      VpsSetup::Setup.add_snippets
      VpsSetup::Setup.add_dejavu_sans_mono_font
      VpsSetup::Setup.ufw_setup
    end
  end
end

