ActiveSupport.on_load(:active_record) do
  self.logger = Logger.new(STDOUT)
end if Rails.env.development?
