namespace 'config' do
  task :setup do
    if Dir.home == '/root'
      VpsSetup::Setup.add_dejavu_sans_mono_font
      VpsSetup::Setup.ufw_setup
    end
  end
end

