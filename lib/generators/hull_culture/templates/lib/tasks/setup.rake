# frozen_string_literal: true

namespace :hull_culture do
  desc 'hull_culture Scripts'

  desc 'Create test_users'
  task test_users: :environment do
    {
      'repositories@ulcc.ac.uk' => 'ulcc_admin',
      'hull_culture_admin@example.com' => 'hull_culture_admin',
      'hull_culture_user@example.com' => 'hull_culture_user'
    }.each do |key, value|
      u = User.new
      u.email = key
      u.password = value
      u.save
      next unless value.include? 'admin'
      admin = Role.find_by_name('admin')
      admin = Role.create(name: 'admin') if admin.nil?
      admin.users << u
      admin.save
    end
  end
  
  desc 'Add appearance'
  task colors: :environment do
    # Colours from HHC web site, there is also #65c8c6
    colors = { header_background_color: '#000000',
               header_text_color: '#b2e4e3',
               link_color: '#00788a',
               footer_link_color: '#b2e4e3',
               primary_button_background_color: '#00788a' }
    appearance = Hyrax::Forms::Admin::Appearance.new(colors)
    appearance.update!
  end
  
  desc 'Set announcement text'
  task announcement: :environment do
    announcement_value = "<p>Admins can change this announcement text in the dashboard.</p>"
    block = ContentBlock.find_by(name: 'announcement_text')
    block = ContentBlock.new(name: ContentBlock::NAME_REGISTRY[:announcement], value: announcement_value) if block.nil?
    block.value = announcement_value if block.value.nil?
    block.save
  end

  desc 'Set features'
  # task features: :environment do
  #   Flipflop::FeatureSet.current.switch!(
  #     :proxy_deposit,
  #     Flipflop::FeatureSet.current.strategies.find { |strat| strat.name == 'active_record' }.key,
  #     false
  #   )
  # end

end
