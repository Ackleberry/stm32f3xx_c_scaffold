
namespace :stlink do
  namespace :flash do
    desc "Flashes the debug HEX file onto the target"
    task debug: 'debug:hex' do
      sh "st-flash --reset --format ihex write build/debug/#{TARGET[:name]}.hex"
    end

    desc "Flashes the release HEX file onto the target"
    task release: 'release:hex' do
      sh "st-flash --reset --format ihex write build/release/#{TARGET[:name]}.hex"
    end
  end

  desc "Erases the targets flash"
  task :erase do
    sh "st-flash erase"
  end
end
