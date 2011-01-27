class RecordSelectAssets

  def self.copy_to_public(options = {})
    if defined? ActiveScaffold
      RecordSelect::Config.js_framework = ActiveScaffold.js_framework
    else
      RecordSelect::Config.js_framework = :jquery
    end
    unless defined?(RECORD_SELECT_INSTALL_ASSETS) && RECORD_SELECT_INSTALL_ASSETS == false
      ['stylesheets', 'images', 'javascripts'].each do |asset_type|
        if asset_type == 'javascripts'
          local_dir = File.join(File.dirname(__FILE__), '..', 'assets', asset_type, RecordSelect::Config.js_framework.to_s)
        else
          local_dir = File.join(File.dirname(__FILE__), '..', 'assets', asset_type)
        end
        public_dir = File.join(Rails.root, 'public', asset_type, 'record_select')
        FileUtils.mkdir public_dir unless File.exists? public_dir
        Dir.entries(local_dir).each do |file|
          next if file =~ /^\./
          FileUtils.cp File.join(local_dir, file), public_dir
        end
      end
    end
  end

protected

end