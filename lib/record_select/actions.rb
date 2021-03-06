module RecordSelect
  module Actions
    # :method => :get
    # params => [:page, :search]
    def browse
      conditions = record_select_conditions
      klass = record_select_model.where(conditions).includes(record_select_includes)
      @count = klass.count
      @count = @count.length if @count.is_a? ActiveSupport::OrderedHash
      pager = ::Paginator.new(@count, record_select_config.per_page) do |offset, per_page|
        klass.select(record_select_select).includes(record_select_config.include).order(record_select_config.order_by).limit(per_page).offset(offset).to_a
      end
      @page = pager.page(params[:page] || 1)

      respond_to do |wants|
        wants.html { render_record_select :partial => 'browse'}
        wants.js {
          if params[:update]
            render_record_select :template => 'browse'
          else
            render_record_select :partial => 'browse'
          end
        }
        wants.yaml {}
        wants.xml {}
        wants.json {}
      end
    end

    # :method => :post
    # params => [:id]
    def select
      klass = record_select_model
      record = klass.find(params[:id])
      if record_select_config.notify.is_a? Proc
        record_select_config.notify.call(record)
      elsif record_select_config.notify
        send(record_select_config.notify, record)
      end
      render :nothing => true
    end

    protected

    def record_select_config #:nodoc:
      self.class.record_select_config
    end

    def render_record_select(options = {}) #:nodoc:
      [:template,:partial].each do |template_name|
        if options[template_name] then
          options[template_name] = File.join(record_select_views_path, options[template_name])
        end
      end
      if block_given? then yield options else render options end
    end

    private

    def record_select_views_path
      "record_select"
    end
  end

  def record_select_model
    record_select_config.model
  end
end
