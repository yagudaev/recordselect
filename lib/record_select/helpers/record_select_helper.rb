module RecordSelectHelper
  # Adds a link on the page that toggles a RecordSelect widget from the given controller.
  #
  # *Options*
  # +onselect+::  JavaScript code to handle selections client-side. This code has access to two variables: id, label. If the code returns false, the dialog will *not* close automatically.
  # +params+::    Extra URL parameters. If any parameter is a column name, the parameter will be used as a search term to filter the result set.
  def link_to_record_select(name, controller, options = {})
    options[:params] ||= {}
    options[:params].merge!(:controller => controller, :action => :browse)
    options[:onselect] = "function(id, label) {#{options[:onselect]}}" if options[:onselect]
    options[:html] ||= {}
    options[:html][:id] ||= "rs_#{rand(9999)}"

    assert_controller_responds(options[:params][:controller])

    html = link_to_function(name, '', options[:html])
    html << javascript_tag("new RecordSelect.Dialog(#{options[:html][:id].to_json}, #{url_for(options[:params]).to_json}, {onselect: #{options[:onselect] || ''}})")

    return html
  end

  # Adds a RecordSelect-based form field. The field submits the record's id using a hidden input.
  #
  # *Arguments*
  # +name+:: the input name that will be used to submit the selected record's id.
  # +current+:: the currently selected object. provide a new record if there're none currently selected and you have not passed the optional :controller argument.
  #
  # *Options*
  # +controller+::  The controller configured to provide the result set. Optional if you have standard resource controllers (e.g. UsersController for the User model), in which case the controller will be inferred from the class of +current+ (the second argument)
  # +params+::      A hash of extra URL parameters
  # +id+::          The id to use for the input. Defaults based on the input's name.
  # +field_name+::  The name to use for the text input. Defaults to '', so field is not submitted.
  def record_select_field(name, current, options = {})
    options[:controller] ||= current.class.to_s.pluralize.underscore
    options[:params] ||= {}
    options[:id] ||= name.gsub(/[\[\]]/, '_')
    options[:class] ||= ''
    options[:class] << ' recordselect'

    ActiveSupport::Deprecation.warn 'onchange option is deprecated. Bind recordselect:change event instead.' if options[:onchange]

    controller = assert_controller_responds(options.delete(:controller))
    params = options.delete(:params)
    record_select_options = {}
    record_select_options[:field_name] = options.delete(:field_name) if options[:field_name]
    if current and not current.new_record?
      record_select_options[:id] = current.id
      record_select_options[:label] = label_for_field(current, controller)
    end

    html = text_field_tag(name, nil, options.merge(:autocomplete => 'off', :onfocus => "this.focused=true", :onblur => "this.focused=false"))
    url = url_for({:action => :browse, :controller => controller.controller_path}.merge(params))
    html << javascript_tag("new RecordSelect.Single(#{options[:id].to_json}, #{url.to_json}, #{record_select_options.to_json});")

    return html
  end

  # Adds a RecordSelect-based form field. The field is autocompleted.
  #
  # *Arguments*
  # +name+:: the input name that will be used to submit the selected value.
  # +current+:: the current object. provide a new record if there're none currently selected and you have not passed the optional :controller argument.
  #
  # *Options*
  # +controller+::  The controller configured to provide the result set. Optional if you have standard resource controllers (e.g. UsersController for the User model), in which case the controller will be inferred from the class of +current+ (the second argument)
  # +params+::      A hash of extra URL parameters
  # +id+::          The id to use for the input. Defaults based on the input's name.
  def record_select_autocomplete(name, current, options = {})
    options[:controller] ||= current.class.to_s.pluralize.underscore
    options[:params] ||= {}
    options[:id] ||= name.gsub(/[\[\]]/, '_')
    options[:class] ||= ''
    options[:class] << ' recordselect'

    ActiveSupport::Deprecation.warn 'onchange option is deprecated. Bind recordselect:change event instead.' if options[:onchange]

    controller = assert_controller_responds(options.delete(:controller))
    params = options.delete(:params)
    record_select_options = {}
    if current
      record_select_options[:label] = label_for_field(current, controller)
    end

    html = text_field_tag(name, nil, options.merge(:autocomplete => 'off', :onfocus => "this.focused=true", :onblur => "this.focused=false"))
    url = url_for({:action => :browse, :controller => controller.controller_path}.merge(params))
    html << javascript_tag("new RecordSelect.Autocomplete(#{options[:id].to_json}, #{url.to_json}, #{record_select_options.to_json});")

    return html
  end

  # Assists with the creation of an observer for the :onchange option of the record_select_field method.
  # Currently only supports building an Ajax.Request based on the id of the selected record.
  #
  # options[:url] should be a hash with all the necessary options *except* :id. that parameter
  # will be provided based on the selected record.
  #
  # Question: if selecting users, what's more likely?
  #   /users/5/categories
  #   /categories?user_id=5
  def record_select_observer(options = {})
    fn = ""
    fn << "function(id, value) {"
    fn <<   "var url = #{url_for(options[:url].merge(:id => ":id:")).to_json}.replace(/:id:/, id);"
    fn <<   "new Ajax.Request(url);"
    fn << "}"
  end

  # Adds a RecordSelect-based form field for multiple selections. The values submit using a list of hidden inputs.
  #
  # *Arguments*
  # +name+:: the input name that will be used to submit the selected records' ids. empty brackets will be appended to the name.
  # +current+:: pass a collection of existing associated records
  #
  # *Options*
  # +controller+::  The controller configured to provide the result set.
  # +params+::      A hash of extra URL parameters
  # +id+::          The id to use for the input. Defaults based on the input's name.
  def record_multi_select_field(name, current, options = {})
    options[:controller] ||= current.first.class.to_s.pluralize.underscore
    options[:params] ||= {}
    options[:id] ||= name.gsub(/[\[\]]/, '_')
    options[:class] ||= ''
    options[:class] << ' recordselect'
    options.delete(:name)

    controller = assert_controller_responds(options.delete(:controller))
    params = options.delete(:params)
    record_select_options = {}
    record_select_options[:current] = current.inject([]) { |memo, record| memo.push({:id => record.id, :label => label_for_field(record, controller)}) }

    html = text_field_tag("#{name}[]", nil, options.merge(:autocomplete => 'off', :onfocus => "this.focused=true", :onblur => "this.focused=false"))
    html << hidden_field_tag("#{name}[]", '', :id => nil)
    html << content_tag('ul', '', :class => 'record-select-list');

    # js identifier so we can talk to it.
    widget = "rs_%s" % name.gsub(/[\[\]]/, '_').chomp('_')
    url = url_for({:action => :browse, :controller => controller.controller_path}.merge(params))
    html << javascript_tag("#{widget} = new RecordSelect.Multiple(#{options[:id].to_json}, #{url.to_json}, #{record_select_options.to_json});")

    return html
  end

  # A helper to render RecordSelect partials
  def render_record_select(options = {}) #:nodoc:
    controller.send(:render_record_select, options) do |options|
      render options
    end
  end

  # Provides view access to the RecordSelect configuration
  def record_select_config #:nodoc:
    controller.send :record_select_config
  end

  # The id of the RecordSelect widget for the given controller.
  def record_select_id(controller = nil) #:nodoc:
    controller ||= params[:controller]
    "record-select-#{controller.gsub('/', '_')}"
  end

  def record_select_search_id(controller = nil) #:nodoc:
    "#{record_select_id(controller)}-search"
  end

  private

  # uses renderer (defaults to record_select_config.label) to determine how the given record renders.
  def render_record_from_config(record, renderer = record_select_config.label)
    case renderer
    when Symbol, String
      # return full-html from the named partial
      render :partial => renderer.to_s, :locals => {:record => record}

    when Proc
      # return an html-cleaned descriptive string
      renderer.call(record)
    end
  end

  # uses the result of render_record_from_config to snag an appropriate record label
  # to display in a field.
  #
  # if given a controller, searches for a partial in its views path
  def label_for_field(record, controller = self.controller)
    renderer = controller.record_select_config.label
    case renderer
    when Symbol, String
      # find the <label> element and grab its innerHTML
      description = render_record_from_config(record, File.join(controller.controller_path, renderer.to_s))
      description.match(/<label[^>]*>(.*)<\/label>/)[1]

    when Proc
      # just return the string
      render_record_from_config(record, renderer)
    end
  end

  def assert_controller_responds(controller_name)
    controller_name = "#{controller_name.camelize}Controller"
    controller = controller_name.constantize
    unless controller.uses_record_select?
      raise "#{controller_name} has not been configured to use RecordSelect."
    end
    controller
  end
end
