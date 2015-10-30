class NotificationsMailer < ActionMailer::Base
  def notify(notification)
    @notification = notification
    old_locale = I18n.locale
    I18n.locale = @notification.user.locale if I18n.locale.to_s != @notification.user.locale.to_s # we need this if to avoid stack overflow in controller
    if old_locale == :pt || @notification.user.locale == :pt || I18n.locale == :pt
      Airbrake.notify({
          :error_class      => "Custom EC error - Language in Portuguese",
          :error_message    => "An email was sent out that had a locale of Portuguese. Verify against logs at #{Time.now}",
          :parameters       => {
            :notification => @notification.inspect,
            :user => @notification.user.inspect,
            :locale => I18n.locale,
            :user_locale => @notification.user.locale
          }
        })
    end

    from_email = (@notification.mail_params && @notification.mail_params.has_key?(:from)) ? @notification.mail_params[:from] : ::Configuration['email_contact']
    address = Mail::Address.new from_email
    address.display_name = (@notification.mail_params && @notification.mail_params.has_key?(:display_name)) ? @notification.mail_params[:display_name] : ::Configuration[:company_name]
    subject = I18n.t("notifications.#{@notification.notification_type.name}.subject", @notification.mail_params)
    @header = I18n.t("notifications.#{@notification.notification_type.name}.header", @notification.mail_params, default: subject)
    m = mail({
      from: address.format,
      to: @notification.user.email,
      subject: subject
    }) do |format|
      format.html { render @notification.notification_type.name, layout: @notification.notification_type.layout }
    end
    I18n.locale = old_locale if I18n.locale.to_s != @notification.user.locale.to_s
    m
  end
end
