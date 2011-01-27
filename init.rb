RECORD_SELECT_INSTALLED = :plugin

require 'recordselect'

begin
  RecordSelectAssets.copy_to_public
rescue
  raise $! unless Rails.env == 'production'
end