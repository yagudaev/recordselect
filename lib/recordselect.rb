require 'record_select_assets'
require 'record_select'
require File.dirname(__FILE__) + '/localization'
require File.dirname(__FILE__) + '/extensions/active_record'
require File.dirname(__FILE__) + '/extensions/routing_mapper'
require File.dirname(__FILE__) + '/record_select/actions'
require File.dirname(__FILE__) + '/record_select/conditions'
require File.dirname(__FILE__) + '/record_select/config'
require File.dirname(__FILE__) + '/record_select/form_builder'

# if ActiveScaffold is installed use same js_framework
if defined? ActiveScaffold
  RecordSelect::Config.js_framework = ActiveScaffold.js_framework
else
  #RecordSelect::Config.js_framework = :jquery
end

ActionController::Base.send(:include, RecordSelect)
ActionView::Base.send(:include, RecordSelectHelper)
ActionView::Helpers::FormBuilder.send(:include, RecordSelect::FormBuilder)

Rails::Application.initializer("recordselect.install_assets") do
  begin
    RecordSelectAssets.copy_to_public
  rescue
    raise $! unless Rails.env == 'production'
  end
end unless defined?(RECORD_SELECT_INSTALLED) && RECORD_SELECT_INSTALLED == :plugin