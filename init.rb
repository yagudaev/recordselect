require File.dirname(__FILE__) + '/lib/localization'
require File.dirname(__FILE__) + '/lib/extensions/active_record'

ActionController::Base.send(:include, RecordSelect)
ActionView::Base.send(:include, RecordSelectHelper)
ActionView::Helpers::FormBuilder.send(:include, RecordSelect::FormBuilder)

# if ActiveScaffold is installed use same js_framework
if defined? ActiveScaffold
  RecordSelect::Config.js_framework = ActiveScaffold.js_framework
else
  #RecordSelect::Config.js_framework = :jquery
end


['stylesheets', 'images', 'javascripts'].each do |asset_type|
  public_dir = File.join(Rails.root, 'public', asset_type, 'record_select')
  if asset_type == 'javascripts'
    local_dir = File.join(File.dirname(__FILE__), 'assets', asset_type, RecordSelect::Config.js_framework.to_s)
  else
    local_dir = File.join(File.dirname(__FILE__), 'assets', asset_type)
  end
  
  FileUtils.mkdir public_dir unless File.exists? public_dir
  Dir.entries(local_dir).each do |file|
    next if file =~ /^\./
    FileUtils.cp File.join(local_dir, file), public_dir
  end
end
